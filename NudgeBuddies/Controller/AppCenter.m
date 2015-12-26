//
//  AppCenter.m
//  NudgeBuddies
//
//  Created by Blue Silver on 12/21/15.
//  Copyright © 2015 Blue Silver. All rights reserved.
//

#import "AppCenter.h"

@implementation AppCenter {
    NSUInteger loadCount;
}

@synthesize pendingArray, contactsArray, notificationArray, favArray, currentUser, currentNudger, isNight, groupArray;

#pragma mark - Retrieve Module

- (void)initCenter:(QBUUser *)user {
    
    pendingArray = [NSMutableArray new];
    contactsArray = [NSMutableArray new];
    notificationArray = [NSMutableArray new];
    favArray = [NSMutableArray new];
    groupArray = [NSMutableArray new];
    
    currentUser = user;
    currentNudger = [[Nudger alloc] initWithUser:user];
    currentNudger.response = [g_var loadLocalVal:USER_RESPONSE];
    currentNudger.defaultNudge = [g_var loadLocalStr:USER_NUDGE];
    currentNudger.defaultReply = [g_var loadLocalStr:USER_ACKNOWLEDGE];
    
    isNight = [g_var loadLocalBool:USER_NIGHT];

    [[QBChat instance] addDelegate:self];
    [[QBChat instance] connectWithUser:user  completion:^(NSError *error) {
        if (error) {
            [self.delegate onceErr];
            [self initCenter:user];
        } else {
            QBResponsePage *allPage = [QBResponsePage responsePageWithLimit:100 skip:0];
            
            [QBRequest dialogsForPage:allPage extendedRequest:nil successBlock:^(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, QBResponsePage *page) {
                
                loadCount = 0;
                for (QBChatDialog *dialog in dialogObjects) {
                    if (dialog.type == QBChatDialogTypePrivate) {
                        [QBRequest userWithID:dialog.occupantIDs[0].integerValue successBlock:^(QBResponse *response, QBUUser *user) {
                            Nudger *newUser = [[Nudger alloc] initWithUser:user];
                            newUser.dialogID = dialog.ID;
                            [contactsArray addObject:newUser];
                            [notificationArray addObject:newUser];
                            loadCount ++;
                            if (loadCount == dialogObjects.count) {
                                [self loadMetaTable];
                            }
                        } errorBlock:^(QBResponse *response) {
                            [self.delegate onceErr];
                        }];
                    } else if (dialog.type == QBChatDialogTypeGroup) {

                        Group *group = [Group new];
                        group.gName = dialog.name;
                        group.gBlobID = [dialog.photo integerValue];
                        group.gUsers = (NSMutableArray *)dialog.occupantIDs;
                        
                        Nudger *gNudger = [[Nudger alloc] initWithGroup:group];
                        gNudger.dialogID = dialog.ID;
                        
                        [groupArray addObject:gNudger];
                        [notificationArray addObject:gNudger];
                        loadCount ++;
                        
                        if (loadCount == dialogObjects.count) {
                            [self loadMetaTable];
                        }
                    }
                }
            } errorBlock:^(QBResponse *response) {
                [self.delegate onceErr];
            }];
        }
    }];
}

- (void)loadMetaTable {
    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
    [getRequest setObject:[NSString stringWithFormat:@"%lu",currentUser.ID] forKey:@"_user_id"];
    [QBRequest objectsWithClassName:@"NudgerBuddy" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
        for (QBCOCustomObject *cObject in objects) {
            NSString *desID = cObject.parentID;
            BOOL found = NO;
            for (Nudger *contactUser in contactsArray) {
                if ([desID integerValue] == contactUser.user.ID) {
                    contactUser.isFavorite = [cObject.fields[@"Favorite"] boolValue];
                    contactUser.response = (ResponseType)[cObject.fields[@"NudgerType"] integerValue];
                    contactUser.defaultNudge = cObject.fields[@"NudgeTxt"];
                    contactUser.defaultReply = cObject.fields[@"AcknowledgeTxt"];
                    contactUser.silent = [cObject.fields[@"Silent"] boolValue];
                    contactUser.block = [cObject.fields[@"Block"] boolValue];
                    contactUser.metaID = cObject.ID;
                    found = YES;
                    break;
                }
            }
            if (found) {
                for (Nudger *contactUser in groupArray) {
                    if ([desID isEqualToString:contactUser.dialogID] && [cObject.fields[@"Accept"] boolValue]) {
                        contactUser.isFavorite = [cObject.fields[@"Favorite"] boolValue];
                        contactUser.response = (ResponseType)[cObject.fields[@"NudgerType"] integerValue];
                        contactUser.defaultNudge = cObject.fields[@"NudgeTxt"];
                        contactUser.defaultReply = cObject.fields[@"AcknowledgeTxt"];
                        contactUser.silent = [cObject.fields[@"Silent"] boolValue];
                        contactUser.block = [cObject.fields[@"Block"] boolValue];
                        contactUser.metaID = cObject.ID;
                        break;
                    }
                }
            }
        }

        [self.delegate onceLoadedContactList];
    } errorBlock:^(QBResponse *response) {
        [self.delegate onceErr];
    }];
}

- (NSMutableArray *)searchBuddy:(NSString *)searchStr {
    
    return nil;
}

- (void)sort {
    contactsArray = (NSMutableArray *)[contactsArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        Nudger *nuObj1 = (Nudger *)obj1;
        Nudger *nuObj2 = (Nudger *)obj2;
        NSString *user1 = nuObj1.type==NTGroup?nuObj1.group.gName:nuObj1.user.fullName;
        NSString *user2 = nuObj2.type==NTGroup?nuObj2.group.gName:nuObj2.user.fullName;
        return [user1 compare:user2];
    }];
}

#pragma mark - Add Contact Module

- (void) addBuddy:(Nudger *)buddy success:(void (^)(BOOL))success {
    [[QBChat instance] confirmAddContactRequest:buddy.user.ID completion:^(NSError * _Nullable error) {
        if (error) {
            success(NO);
        } else {
            QBChatDialog *chatDialog = [[QBChatDialog alloc] initWithDialogID:nil type:QBChatDialogTypePrivate];
            chatDialog.occupantIDs = @[@(buddy.user.ID)];
            
            [QBRequest createDialog:chatDialog successBlock:^(QBResponse *response, QBChatDialog *createdDialog) {
                
                QBCOCustomObject *object = [QBCOCustomObject customObject];
                object.className = @"NudgerBuddy"; // your Class name
                [object.fields setObject:createdDialog.ID forKey:@"_parent_id"];
                [object.fields setObject:buddy.defaultNudge forKey:@"NudgeTxt"];
                [object.fields setObject:buddy.defaultReply forKey:@"AcknowledgeTxt"];
                [object.fields setObject:[NSNumber numberWithBool:buddy.isFavorite] forKey:@"Favorite"];
                [object.fields setObject:[NSNumber numberWithInteger:buddy.response] forKey:@"NudgerType"];
                [object.fields setObject:[NSNumber numberWithBool:buddy.silent] forKey:@"Silent"];
                [object.fields setObject:[NSNumber numberWithBool:buddy.block] forKey:@"Block"];
                [object.fields setObject:[NSNumber numberWithBool:YES] forKey:@"Accept"];
                
                [QBRequest createObject:object successBlock:^(QBResponse *response, QBCOCustomObject *object) {
                    success(YES);
                } errorBlock:^(QBResponse *response) {
                    success(NO);
                }];
            } errorBlock:^(QBResponse *response) {
                success(NO);
            }];
        }
    }];
}

- (void) addGroup:(Nudger *)group updatePic:(BOOL)update success:(void (^)(BOOL))success {
    
    QBChatDialog *chatDialog = [[QBChatDialog alloc] initWithDialogID:nil type:QBChatDialogTypeGroup];
    chatDialog.name = group.group.gName;
    chatDialog.occupantIDs = (NSArray *)group.group.gUsers;
    
    [QBRequest createDialog:chatDialog successBlock:^(QBResponse *response, QBChatDialog *createdDialog) {
        QBCOCustomObject *object = [QBCOCustomObject customObject];
        object.className = @"NudgerBuddy"; // your Class name
        [object.fields setObject:createdDialog.ID forKey:@"_parent_id"];
        [object.fields setObject:group.defaultNudge forKey:@"NudgeTxt"];
        [object.fields setObject:group.defaultReply forKey:@"AcknowledgeTxt"];
        [object.fields setObject:[NSNumber numberWithBool:group.isFavorite] forKey:@"Favorite"];
        [object.fields setObject:[NSNumber numberWithInteger:group.response] forKey:@"NudgerType"];
        [object.fields setObject:[NSNumber numberWithBool:group.silent] forKey:@"Silent"];
        [object.fields setObject:[NSNumber numberWithBool:group.block] forKey:@"Block"];
        [object.fields setObject:[NSNumber numberWithBool:YES] forKey:@"Accept"];

        if (group.picData && update) {
            [QBRequest TUploadFile:group.picData fileName:@"group.jpg" contentType:@"image/jpeg" isPublic:NO successBlock:^(QBResponse *response, QBCBlob *uploadedBlob) {
                NSUInteger uploadedFileID = uploadedBlob.ID;
                createdDialog.photo = [NSString stringWithFormat:@"%lu", uploadedFileID];
                group.group.gBlobID = uploadedFileID;
                [QBRequest updateDialog:createdDialog successBlock:^(QBResponse *responce, QBChatDialog *dialog) {
                    [QBRequest createObject:object successBlock:^(QBResponse *response, QBCOCustomObject *object) {
                        success(YES);
                    } errorBlock:^(QBResponse *response) {
                        success(NO);
                    }];
                } errorBlock:^(QBResponse *response) {
                    success(NO);
                }];
            } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
                success(NO);
            } errorBlock:^(QBResponse *response) {
                success(NO);
            }];
        } else {
            [QBRequest createObject:object successBlock:^(QBResponse *response, QBCOCustomObject *object) {
                success(YES);
            } errorBlock:^(QBResponse *response) {
                success(NO);
            }];
        }
    } errorBlock:^(QBResponse *response) {
        success(NO);
    }];
}

- (QBChatMessage *)createChatNotificationForGroupChatCreation:(QBChatDialog *)dialog
{
    // create message:
    QBChatMessage *inviteMessage = [QBChatMessage message];
    
    NSMutableDictionary *customParams = [NSMutableDictionary new];
    customParams[@"name"] = dialog.name;
    customParams[@"photo"] = dialog.photo;
    customParams[@"notification_type"] = @"1";
    
    inviteMessage.customParameters = customParams;
    
    return inviteMessage;
}

- (void)add:(Nudger *)user {
    BOOL isFound = NO;
    user.isNew = NO;
    user.status = NSFriend;
    for (int i=0; i<self.notificationArray.count; i++) {
        Nudger *nudger = [self.notificationArray objectAtIndex:i];
        if (nudger.user.ID == user.user.ID || [nudger.group.gName isEqualToString:user.group.gName]) {
            [self.notificationArray removeObjectAtIndex:i];
            [self.notificationArray addObject:nudger];
            isFound = YES;
            break;
        }
    }
    if (!isFound) {
        [self.notificationArray addObject:user];
    }
    [self.delegate onceAddedContact:user];
}

#pragma mark - Update Contact Module

- (void)updateContact:(Nudger *)buddy success:(void (^)(BOOL))success {
    QBCOCustomObject *object = [QBCOCustomObject customObject];
    object.className = @"NudgerBuddy"; // your Class name
    object.ID = buddy.metaID;
    [object.fields setObject:buddy.dialogID forKey:@"_parent_id"];
    [object.fields setObject:buddy.defaultNudge forKey:@"NudgeTxt"];
    [object.fields setObject:buddy.defaultReply forKey:@"AcknowledgeTxt"];
    [object.fields setObject:[NSNumber numberWithBool:buddy.isFavorite] forKey:@"Favorite"];
    [object.fields setObject:[NSNumber numberWithInteger:buddy.response] forKey:@"NudgerType"];
    [object.fields setObject:[NSNumber numberWithBool:buddy.silent] forKey:@"Silent"];
    [object.fields setObject:[NSNumber numberWithBool:buddy.block] forKey:@"Block"];
    [QBRequest updateObject:object successBlock:^(QBResponse *response, QBCOCustomObject *object) {
        success(YES);
    } errorBlock:^(QBResponse *response) {
        success(NO);
    }];
}

- (void)addBuddyToGroup:(Nudger *)buddy group:(Nudger *)group success:(void (^)(BOOL))success {
    QBChatDialog *updateDialog = [[QBChatDialog alloc] initWithDialogID:group.dialogID type:QBChatDialogTypeGroup];
    updateDialog.pushOccupantsIDs = @[[NSString stringWithFormat:@"%lu",buddy.user.ID]];
    [QBRequest updateDialog:updateDialog successBlock:^(QBResponse *responce, QBChatDialog *dialog) {
        success(YES);
    } errorBlock:^(QBResponse *response) {
        success(NO);
    }];
}

#pragma mark - Remove Contact Module

- (void)removeBuddy:(Nudger *)buddy success:(void (^)(BOOL))success {
    ////////////////////////////////////////
    ////////////////////////////////////////
    [QBRequest deleteDialogsWithIDs:[NSSet setWithObject:buddy.dialogID] forAllUsers:YES
                       successBlock:^(QBResponse *response, NSArray *deletedObjectsIDs, NSArray *notFoundObjectsIDs, NSArray *wrongPermissionsObjectsIDs) {
                           success(YES);
                       } errorBlock:^(QBResponse *response) {
                           success(NO);
                       }];
}

- (void)removeGroup:(Nudger *)group success:(void (^)(BOOL))success {
    [QBRequest deleteDialogsWithIDs:[NSSet setWithObject:group.dialogID] forAllUsers:NO
                       successBlock:^(QBResponse *response, NSArray *deletedObjectsIDs, NSArray *notFoundObjectsIDs, NSArray *wrongPermissionsObjectsIDs) {
                           success(YES);
                       } errorBlock:^(QBResponse *response) {
                           success(NO);
                       }];
}

- (void)remove:(Nudger *)user {
    for (int i=0; i<self.notificationArray.count; i++) {
        Nudger *nudger = [self.notificationArray objectAtIndex:i];
        if (nudger.user.ID == user.user.ID || [nudger.group.gName isEqualToString:user.group.gName]) {
            [self.notificationArray removeObjectAtIndex:i];
            [self.delegate onceRemovedContact:user];
            break;
        }
    }
}

#pragma mark - Message Module

- (BOOL)sendNudge:(Nudger *)to {
    
    return NO;
}

#pragma mark - QBChat Delegate

- (void)chatRoomDidReceiveMessage:(QB_NONNULL QBChatMessage *)message fromDialogID:(QB_NONNULL NSString *)dialogID {
    
}

- (void)chatDidReceiveContactAddRequestFromUser:(NSUInteger)userID {
    [QBRequest userWithID:userID successBlock:^(QBResponse *response, QBUUser *user) {

        Nudger *newUser = [[Nudger alloc] initWithUser:user];
        newUser.isNew = YES;
        newUser.shouldAnimate = YES;
        newUser.status = NSInvited;
        [self add:newUser];
        
        [self.delegate onceAddedContact:newUser];

    } errorBlock:^(QBResponse *response) {
        NSLog(@"Err: loading pending users");
    }];
}

- (void)chatContactListDidChange:(QB_NONNULL QBContactList *)contactList {

}

- (void)chatDidReceiveContactItemActivity:(NSUInteger)userID isOnline:(BOOL)isOnline status:(QB_NULLABLE NSString *)status {
    NSLog(@"--------chatDidReceiveContactItemActivity--------- %lu", userID);
}

- (void)chatDidReceiveAcceptContactRequestFromUser:(NSUInteger)userID {
    NSLog(@"--------chatDidReceiveAcceptContactRequestFromUser--------- %lu", userID);
    [[[UIAlertView alloc] initWithTitle:@"Alert" message:[NSString stringWithFormat:@"Your add contact request (ID:%lu is accepted!", userID] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    [QBRequest userWithID:userID successBlock:^(QBResponse *response, QBUUser *user) {
        Nudger *newUser = [[Nudger alloc] initWithUser:user];
        newUser.isNew = YES;
        newUser.status = NSFriend;
        [self add:newUser];
        [self.delegate onceAddedContact:newUser];
        [self.delegate onceAccepted:newUser.user.ID];
    } errorBlock:^(QBResponse *response) {
        [self.delegate onceErr];
    }];
}

- (void)chatDidReceiveRejectContactRequestFromUser:(NSUInteger)userID {
    NSLog(@"--------chatDidReceiveRejectContactRequestFromUser--------- %lu", userID);
    [self.delegate onceRejected:userID];
}

- (void)chatDidReceiveSystemMessage:(QBChatMessage *)message
{
    
}

- (void)chatDidAccidentallyDisconnect{
    [self.delegate onceDisconnected];
}

@end
