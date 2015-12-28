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
    NSUInteger fixLoadCount;
    BOOL contactLoaded;
    QBContactList *delegateContactList;
}

@synthesize pendingArray, contactsArray, notificationArray, favArray, currentUser, currentNudger, isNight, groupArray, fbFriendsArr;

#pragma mark - Retrieve Module

- (void)initCenter:(QBUUser *)user {
    
    pendingArray = [NSMutableArray new];
    contactsArray = [NSMutableArray new];
    notificationArray = [NSMutableArray new];
    favArray = [NSMutableArray new];
    groupArray = [NSMutableArray new];
    fbFriendsArr = [NSMutableArray new];
    
    currentUser = user;
    currentNudger = [[Nudger alloc] initWithUser:user];
    currentNudger.response = [g_var loadLocalVal:USER_RESPONSE];
    currentNudger.defaultNudge = [g_var loadLocalStr:USER_NUDGE];
    currentNudger.defaultReply = [g_var loadLocalStr:USER_ACKNOWLEDGE];
    
    isNight = [g_var loadLocalBool:USER_NIGHT];

    [SVProgressHUD showWithStatus:@"Connecting..."];
    
    [[QBChat instance] addDelegate:self];
    [[QBChat instance] connectWithUser:user  completion:^(NSError *error) {

        if (error) {
            [self.delegate onceErr];
//            [self initCenter:user];
        }
    }];
}

- (void)loadContacts:(QBContactList *)contactList {
    NSMutableArray *userIDs = [NSMutableArray new];
    for (QBContactListItem *item in contactList.contacts) {
        [userIDs addObject:[NSNumber numberWithUnsignedInteger:item.userID]];
    }
    [QBRequest usersWithIDs:userIDs page:[QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:100] successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
        for (QBUUser *user in users) {
            Nudger *newUser = [[Nudger alloc] initWithUser:user];
            [contactsArray addObject:newUser];
            [notificationArray addObject:newUser];
        }
        
        [self loadGroups];
    } errorBlock:^(QBResponse *response) {
        [self.delegate onceErr];
    }];
}

- (void)loadGroups {
    
    NSMutableDictionary *extendedRequest = @{@"type" : @(QBChatDialogTypeGroup)}.mutableCopy;
    
    QBResponsePage *allPage = [QBResponsePage responsePageWithLimit:100 skip:0];
    
    [QBRequest dialogsForPage:allPage extendedRequest:extendedRequest successBlock:^(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, QBResponsePage *page) {
        for (QBChatDialog *dialog in dialogObjects) {
            Group *group = [Group new];
            group.gName = dialog.name;
            group.gBlobID = [dialog.photo integerValue];
            group.gUsers = (NSMutableArray *)dialog.occupantIDs;
            group.gID = dialog.ID;

            Nudger *gNudger = [[Nudger alloc] initWithGroup:group];
            [groupArray addObject:gNudger];
            [notificationArray addObject:gNudger];
        }
        [self loadMetaTable];

    } errorBlock:^(QBResponse *response) {
        [self.delegate onceErr];
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
                    if ([desID isEqualToString:contactUser.group.gID] && [cObject.fields[@"Accept"] boolValue]) {
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
//        [self.delegate onceLoadedContactList];
        [self getPending];
    } errorBlock:^(QBResponse *response) {
        [self.delegate onceErr];
    }];
}

- (void)getPending {
    NSMutableArray *newPendingArr = [NSMutableArray new];
    for (QBContactListItem *item in delegateContactList.pendingApproval) {
        if (item.subscriptionState == QBPresenseSubscriptionStateFrom || item.subscriptionState == QBPresenseSubscriptionStateBoth) {
            [newPendingArr addObject:item];
        }
    }
    
    if (newPendingArr.count == 0) {
        [self.delegate onceLoadedContactList];
        return;
    }
    
    NSMutableArray *userIDs = [NSMutableArray new];
    for (QBContactListItem *item in newPendingArr) {
        [userIDs addObject:[NSNumber numberWithUnsignedInteger:item.userID]];
    }
    
    [QBRequest usersWithIDs:userIDs page:[QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:100] successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
        for (QBUUser *user in users) {
            Nudger *newUser = [[Nudger alloc] initWithUser:user];
            newUser.status = NSInvited;
            newUser.isNew = YES;
            newUser.shouldAnimate = NO;
            [notificationArray addObject:newUser];
        }
        [self.delegate onceLoadedContactList];
    } errorBlock:^(QBResponse *response) {
        [self.delegate onceErr];
    }];
}

#pragma mark - QBChat Delegate

- (void)chatContactListDidChange:(QB_NONNULL QBContactList *)contactList {
    
    if (!contactLoaded) {
        
        contactLoaded = YES;
        delegateContactList = contactList;
        
        [SVProgressHUD showWithStatus:@"Loading contacts..."];
        
        if (contactList.contacts.count > 0) {
            [self loadContacts:contactList];
        } else if (contactList.pendingApproval.count > 0) {
            [self getPending];
        } else {
            [self.delegate onceLoadedContactList];
        }
    }
}

- (void)chatRoomDidReceiveMessage:(QB_NONNULL QBChatMessage *)message fromDialogID:(QB_NONNULL NSString *)dialogID {
    NSLog(@"%@", message);
    [self.delegate onceErr];
}

- (void)chatDidReceiveContactAddRequestFromUser:(NSUInteger)userID {
    [QBRequest userWithID:userID successBlock:^(QBResponse *response, QBUUser *user) {
        Nudger *newUser = [[Nudger alloc] initWithUser:user];
        newUser.isNew = YES;
        newUser.shouldAnimate = YES;
        newUser.status = NSInvited;
        [self add:newUser];
        
    } errorBlock:^(QBResponse *response) {
        [self.delegate onceErr];
    }];
}

- (void)chatDidReceiveAcceptContactRequestFromUser:(NSUInteger)userID {
    NSLog(@"--------chatDidReceiveAcceptContactRequestFromUser--------- %lu", userID);

    for (Nudger *contact in contactsArray) {
        if (contact.user.ID == userID) {
            return;
        }
    }
    
    [QBRequest userWithID:userID successBlock:^(QBResponse *response, QBUUser *user) {
        Nudger *newUser = [[Nudger alloc] initWithUser:user];
        newUser.isNew = NO;
        newUser.shouldAnimate = NO;
        newUser.status = NSFriend;
        [self add:newUser];
        [self.delegate onceAddedContact:newUser];
        [self.delegate onceAccepted:newUser.user.fullName];
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
    NSLog(@"%@", message);
    [self.delegate onceErr];
}

- (void)chatDidAccidentallyDisconnect{
    [self.delegate onceDisconnected];
}

- (void)chatDidConnect {
    [self.delegate onceConnect];
}

#pragma mark - Add Contact Module

- (void) addBuddy:(Nudger *)buddy success:(void (^)(BOOL))success {
    [[QBChat instance] confirmAddContactRequest:buddy.user.ID completion:^(NSError * _Nullable error) {
        [self.contactsArray addObject:buddy];
        buddy.status = NSFriend;
        buddy.isNew = NO;
        buddy.shouldAnimate = NO;
        [self add:buddy];
    }];
}

- (void) addGroup:(Nudger *)group updatePic:(BOOL)update success:(void (^)(BOOL))success {
    
    QBChatDialog *chatDialog = [[QBChatDialog alloc] initWithDialogID:nil type:QBChatDialogTypeGroup];
    chatDialog.name = group.group.gName;
    chatDialog.occupantIDs = (NSArray *)group.group.gUsers;
    
    [QBRequest createDialog:chatDialog successBlock:^(QBResponse *response, QBChatDialog *createdDialog) {
        if (group.picData && update) {
            [QBRequest TUploadFile:group.picData fileName:@"group.jpg" contentType:@"image/jpeg" isPublic:NO successBlock:^(QBResponse *response, QBCBlob *uploadedBlob) {
                NSUInteger uploadedFileID = uploadedBlob.ID;
                createdDialog.photo = [NSString stringWithFormat:@"%lu", uploadedFileID];
                group.group.gBlobID = uploadedFileID;
                [QBRequest updateDialog:createdDialog successBlock:^(QBResponse *responce, QBChatDialog *dialog) {
                    success(YES);
                } errorBlock:^(QBResponse *response) {
                    success(NO);
                }];
            } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
                success(NO);
            } errorBlock:^(QBResponse *response) {
                success(NO);
            }];
        } else {
            success(YES);
        }
    } errorBlock:^(QBResponse *response) {
        success(NO);
    }];
}

//- (QBChatMessage *)createChatNotificationForGroupChatCreation:(QBChatDialog *)dialog
//{
//    // create message:
//    QBChatMessage *inviteMessage = [QBChatMessage message];
//    
//    NSMutableDictionary *customParams = [NSMutableDictionary new];
//    customParams[@"name"] = dialog.name;
//    customParams[@"photo"] = dialog.photo;
//    customParams[@"notification_type"] = @"1";
//    
//    inviteMessage.customParameters = customParams;
//    return inviteMessage;
//}

- (void)createChatNotificationForGroupChatCreation:(QBChatDialog *)dialog
{
    // create message:
    QBChatMessage *inviteMessage = [QBChatMessage message];
    inviteMessage.text = @"optional text";
    
    NSMutableDictionary *customParams = [NSMutableDictionary new];
    customParams[@"xmpp_room_jid"] = dialog.roomJID;
    customParams[@"name"] = dialog.name;
    customParams[@"_id"] = dialog.ID;
    customParams[@"type"] = @(dialog.type);
    customParams[@"occupants_ids"] = [dialog.occupantIDs componentsJoinedByString:@","];
    
    // Add notification_type=2 to extra params when you updated a group chat
    //
    customParams[@"notification_type"] = @"1";
    
    inviteMessage.customParameters = customParams;
    NSTimeInterval timestamp = (unsigned long)[[NSDate date] timeIntervalSince1970];
    inviteMessage.customParameters[@"date_sent"] = (NSString *)@(timestamp);
    inviteMessage.customParameters[@"sender"] = currentUser.fullName;
    [[QBChat instance] sendSystemMessage:inviteMessage completion:^(NSError * _Nullable error) {
        NSLog(@"");
    }];

}

- (void)add:(Nudger *)user {
    
    BOOL isFound = NO;

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
    if (buddy.metaID) {
        QBCOCustomObject *object = [QBCOCustomObject customObject];
        object.className = @"NudgerBuddy"; // your Class name
        object.ID = buddy.metaID;
        [object.fields setObject:buddy.group.gID forKey:@"_parent_id"];
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
    } else {
        QBCOCustomObject *object = [QBCOCustomObject customObject];
        object.className = @"NudgerBuddy"; // your Class name
        [object.fields setObject:buddy.group.gID forKey:@"_parent_id"];
        [object.fields setObject:buddy.defaultNudge forKey:@"NudgeTxt"];
        [object.fields setObject:buddy.defaultReply forKey:@"AcknowledgeTxt"];
        [object.fields setObject:[NSNumber numberWithBool:buddy.isFavorite] forKey:@"Favorite"];
        [object.fields setObject:[NSNumber numberWithInteger:buddy.response] forKey:@"NudgerType"];
        [object.fields setObject:[NSNumber numberWithBool:buddy.silent] forKey:@"Silent"];
        [object.fields setObject:[NSNumber numberWithBool:buddy.block] forKey:@"Block"];
        [QBRequest createObject:object successBlock:^(QBResponse *response, QBCOCustomObject *object) {
            buddy.metaID = object.ID;
            success(YES);
        } errorBlock:^(QBResponse *response) {
            success(NO);
        }];
    }
}

- (void)addBuddyToGroup:(Nudger *)buddy group:(Nudger *)group success:(void (^)(BOOL))success {
    QBChatDialog *updateDialog = [[QBChatDialog alloc] initWithDialogID:group.group.gID type:QBChatDialogTypeGroup];
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
    [QBRequest deleteDialogsWithIDs:[NSSet setWithObject:buddy.group.gID] forAllUsers:YES
                       successBlock:^(QBResponse *response, NSArray *deletedObjectsIDs, NSArray *notFoundObjectsIDs, NSArray *wrongPermissionsObjectsIDs) {
                           success(YES);
                       } errorBlock:^(QBResponse *response) {
                           success(NO);
                       }];
}

- (void)removeGroup:(Nudger *)group success:(void (^)(BOOL))success {
    [QBRequest deleteDialogsWithIDs:[NSSet setWithObject:group.group.gID] forAllUsers:NO
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

@end
