//
//  AppCenter.m
//  NudgeBuddies
//
//  Created by Blue Silver on 12/21/15.
//  Copyright © 2015 Blue Silver. All rights reserved.
//

#import "AppCenter.h"
#import "AlertCtrl.h"

@implementation AppCenter {
    NSUInteger loadCount;
    NSUInteger fixLoadCount;
    BOOL contactLoaded;
    BOOL pendingLoaded;
    QBContactList *delegateContactList;
}

@synthesize pendingArray, contactsArray, notificationArray, favArray, currentUser, currentNudger, isNight, isCount, groupArray, fbFriendsArr;

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
    currentNudger.alertSound = [g_var loadLocalVal:USER_ALERT];
    
    isNight = [g_var loadLocalBool:USER_NIGHT];
    isCount = [g_var loadLocalBool:USER_COUNT];

    [SVProgressHUD showWithStatus:@"Connecting..."];
    
    [[QBChat instance] addDelegate:self];
    [[QBChat instance] connectWithUser:user  completion:^(NSError *error) {
        if (error) {
            [self.delegate onceErr];
            //[self initCenter:user];
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
//            [contactsArray addObject:newUser];
            [self addContact:newUser];
            [self add:newUser];
        }
        
        [self loadGroups];
    } errorBlock:^(QBResponse *response) {
        [self.delegate onceErr];
    }];
}

- (void)loadGroups {
    
//    NSMutableDictionary *extendedRequest = @{@"type" : @(QBChatDialogTypeGroup)}.mutableCopy;
    
    QBResponsePage *allPage = [QBResponsePage responsePageWithLimit:100 skip:0];
    
    [QBRequest dialogsForPage:allPage extendedRequest:nil successBlock:^(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, QBResponsePage *page) {
        for (QBChatDialog *dialog in dialogObjects) {
            if (dialog.type == QBChatDialogTypePrivate) {
                NSArray *idNums = dialog.occupantIDs;
                NSInteger userID = [idNums[0] integerValue];
                if (userID == currentUser.ID) {
                    userID = [idNums[1] integerValue];
                }
                for (Nudger *contactUser in contactsArray) {
                    if (contactUser.user.ID == userID) {
                        contactUser.dialogID = dialog.ID;
                        contactUser.unreadMsg = dialog.unreadMessagesCount;
                        if (contactUser.unreadMsg > 0) {
                            contactUser.isNew = YES;
                            contactUser.shouldAnimate = NO;
                        }
                        break;
                    }
                }
            } else {
                Group *group = [Group new];
                group.gName = dialog.name;
                group.gBlobID = [dialog.photo integerValue];
                group.gUsers = (NSMutableArray *)dialog.occupantIDs;
                group.gID = dialog.ID;
                
                for (Nudger *conNudger in contactsArray) {
                    if (conNudger.user.ID == dialog.userID) {
                        group.gInviter = conNudger.user.fullName;
                        break;
                    }
                }
                
                Nudger *gNudger = [[Nudger alloc] initWithGroup:group];
                gNudger.dialogID = dialog.ID;
                gNudger.unreadMsg = dialog.unreadMessagesCount;
                if (gNudger.unreadMsg > 0) {
                    gNudger.isNew = YES;
                    gNudger.shouldAnimate = NO;
                }
                [groupArray addObject:gNudger];
                [notificationArray addObject:gNudger];
            }
        }
        [self loadMetaTable];

    } errorBlock:^(QBResponse *response) {
        [self.delegate onceErr];
    }];
}

- (void)loadMetaTable {
    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
    [getRequest setObject:[NSString stringWithFormat:@"%lu",currentUser.ID] forKey:@"user_id"];
    [QBRequest objectsWithClassName:@"NudgerBuddy" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
        for (QBCOCustomObject *cObject in objects) {
            NSString *desID = cObject.parentID;
            BOOL found = NO;
            for (Nudger *contactUser in contactsArray) {
                if ([desID integerValue] == contactUser.user.ID) {
                    contactUser.isFavorite = [cObject.fields[@"Favorite"] boolValue];
                    contactUser.favCount = [cObject.fields[@"FavCount"] integerValue];
                    contactUser.response = (ResponseType)[cObject.fields[@"NudgerType"] integerValue];
                    contactUser.defaultNudge = cObject.fields[@"NudgeTxt"];
                    contactUser.defaultReply = cObject.fields[@"AcknowledgeTxt"];
                    contactUser.silent = [cObject.fields[@"Silent"] boolValue];
                    contactUser.block = [cObject.fields[@"Block"] boolValue];
                    contactUser.metaID = cObject.ID;
                    contactUser.alertSound = [cObject.fields[@"Alert"] integerValue];
                    found = YES;
                    break;
                }
            }
            if (!found) {
                for (Nudger *contactUser in groupArray) {
                    if ([desID isEqualToString:contactUser.group.gID]) {
                        contactUser.isFavorite = [cObject.fields[@"Favorite"] boolValue];
                        contactUser.favCount = [cObject.fields[@"FavCount"] integerValue];
                        contactUser.response = (ResponseType)[cObject.fields[@"NudgerType"] integerValue];
                        contactUser.defaultNudge = cObject.fields[@"NudgeTxt"];
                        contactUser.defaultReply = cObject.fields[@"AcknowledgeTxt"];
                        contactUser.silent = [cObject.fields[@"Silent"] boolValue];
                        contactUser.block = [cObject.fields[@"Block"] boolValue];
                        contactUser.metaID = cObject.ID;
                        contactUser.accept = [cObject.fields[@"Accept"] boolValue];
                        contactUser.alertSound = [cObject.fields[@"Alert"] integerValue];
                        break;
                    }
                }
            }
        }
//        [self.delegate onceLoadedContactList];
        for (Nudger *groupUser in notificationArray) {
            if (groupUser.type == NTGroup) {
                if (groupUser.metaID == nil) {
                    groupUser.status = NSInvited;
                    groupUser.isNew = YES;
                    groupUser.shouldAnimate = NO;
                } else if (groupUser.metaID !=nil && !groupUser.accept) {
                    groupUser.status = NSReject;
                }
            }
        }
        
        [self getPending];
    } errorBlock:^(QBResponse *response) {
        [self.delegate onceErr];
    }];
}

- (void)getPending {
    
    NSMutableArray *newPendingArr = [NSMutableArray new];
    pendingLoaded = YES;
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
//            [notificationArray addObject:newUser];
            [self add:newUser];
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

- (void)chatDidReceiveContactAddRequestFromUser:(NSUInteger)userID {
    NSLog(@"receive %lu", userID);
    [QBRequest userWithID:userID successBlock:^(QBResponse *response, QBUUser *user) {
        Nudger *newUser = [[Nudger alloc] initWithUser:user];
        newUser.isNew = YES;
        newUser.shouldAnimate = NO;
        if (pendingLoaded) {
            newUser.shouldAnimate = YES;
        }
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
    Group *group = [Group new];
    group.gID = message.customParameters[@"_id"];
    group.gName = message.customParameters[@"name"];
    group.gBlobID = [message.customParameters[@"blob"] integerValue];
    group.gUsers = (NSMutableArray *)[message.customParameters[@"occupants_ids"] componentsSeparatedByString:@","];
    
    for (Nudger *contactGroup in notificationArray) {
        if ([contactGroup.group.gID isEqualToString:group.gID] || message.senderID == currentUser.ID) {
            return;
        }
    }
    for (Nudger *nudger in contactsArray) {
        if (nudger.user.ID == message.senderID) {
            group.gInviter = nudger.user.fullName;
            break;
        }
    }
    
    Nudger *newUser = [[Nudger alloc] initWithGroup:group];
    newUser.isNew = YES;
    newUser.shouldAnimate = YES;
    newUser.status = NSInvited;
    [self add:newUser];
}

- (void)chatDidAccidentallyDisconnect{
    [self.delegate onceDisconnected];
}

- (void)chatDidConnect {
    
    [self.delegate onceConnect];
}

- (void)chatDidReconnect {
    if (!contactLoaded) {
        [self.delegate onceConnect];
    }
}

#pragma mark - Add Contact Module

- (void) addBuddy:(Nudger *)buddy success:(void (^)(BOOL))success {
    [SVProgressHUD showWithStatus:@"Please wait.."];
    [[QBChat instance] confirmAddContactRequest:buddy.user.ID completion:^(NSError * _Nullable error) {
        NSLog(@"confirm Add Request func ###############");
//        [self.contactsArray addObject:buddy];
        [self addContact:buddy];
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
    customParams[@"notification_type"] = @"2";
    
    inviteMessage.customParameters = customParams;
    NSTimeInterval timestamp = (unsigned long)[[NSDate date] timeIntervalSince1970];
    inviteMessage.customParameters[@"date_sent"] = (NSString *)@(timestamp);
    inviteMessage.customParameters[@"sender"] = currentUser.fullName;
    [[QBChat instance] sendSystemMessage:inviteMessage completion:^(NSError * _Nullable error) {
        NSLog(@"*******##############system msg sent");
    }];

}

- (void)add:(Nudger *)user {
    
    BOOL isFound = NO;

    NSLog(@"add func init: %@ ###############", user.user.login);
    for (int i=0; i<self.notificationArray.count; i++) {
        Nudger *nudger = [self.notificationArray objectAtIndex:i];
        if (nudger.user.ID == user.user.ID) {
            nudger.alertSound = user.alertSound;
            nudger.alarmCount = user.alarmCount;
            nudger.block = user.block;
            nudger.silent = user.silent;
            nudger.autoNudge = user.autoNudge;
            isFound = YES;
            break;
        }
    }
    if (!isFound) {
        [self.notificationArray addObject:user];
        NSLog(@"add func:not found %lu ###############", self.notificationArray.count);
    } else {
        NSLog(@"add func:found %lu ###############", self.notificationArray.count);
    }
    
    [self.delegate onceAddedContact:user];
    
}

- (void)addContact:(Nudger *)user {
    
    BOOL isFound = NO;
    
    for (int i=0; i<self.contactsArray.count; i++) {
        Nudger *nudger = [self.contactsArray objectAtIndex:i];
        if (nudger.user.ID == user.user.ID) {
            nudger.alertSound = user.alertSound;
            nudger.alarmCount = user.alarmCount;
            nudger.block = user.block;
            nudger.silent = user.silent;
            nudger.autoNudge = user.autoNudge;
            isFound = YES;
            break;
        }
    }
    if (!isFound) {
        [self.contactsArray addObject:user];
    }
}

#pragma mark - Update Contact Module

- (void)updateContact:(Nudger *)buddy success:(void (^)(BOOL))success {
    if (buddy.metaID) {
        QBCOCustomObject *object = [QBCOCustomObject customObject];
        object.className = @"NudgerBuddy"; // your Class name
        object.ID = buddy.metaID;
        if (buddy.type == NTGroup) {
            [object.fields setObject:buddy.group.gID forKey:@"_parent_id"];
        } else {
            [object.fields setObject:[NSString stringWithFormat:@"%lu", buddy.user.ID] forKey:@"_parent_id"];
        }
        
        [QBRequest updateObject:object successBlock:^(QBResponse *response, QBCOCustomObject *object) {
            buddy.shouldAnimate = NO;
            buddy.isNew = NO;
            buddy.status = NSFriend;
            success(YES);
//            [self add:buddy];
        } errorBlock:^(QBResponse *response) {
            success(NO);
        }];
    } else {
        QBCOCustomObject *object = [QBCOCustomObject customObject];
        object.className = @"NudgerBuddy"; // your Class name
        if (buddy.type == NTGroup) {
            [object.fields setObject:buddy.group.gID forKey:@"_parent_id"];
        } else {
            [object.fields setObject:[NSString stringWithFormat:@"%lu", buddy.user.ID] forKey:@"_parent_id"];
        }
        [QBRequest createObject:object successBlock:^(QBResponse *response, QBCOCustomObject *object) {
            buddy.metaID = object.ID;
            buddy.isNew = NO;
            buddy.shouldAnimate = NO;
            buddy.status = NSFriend;
//            [self add:buddy];
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
                           
                       } errorBlock:^(QBResponse *response) {
                           success(NO);
                       }];
}

- (void)remove:(Nudger *)user {
    for (int i=0; i<self.notificationArray.count; i++) {
        Nudger *nudger = [self.notificationArray objectAtIndex:i];
        if ([nudger isEqual:user]) {
            [self.notificationArray removeObjectAtIndex:i];
            [self.delegate onceRemovedContact:user];
            break;
        }
    }
}

#pragma mark - Message Module

- (void)sendMessage:(Nudger *)nudger txt:(NSString *)text success:(void (^)(QBChatMessage *))success {
//    [SVProgressHUD show];
    if (nudger.type == NTGroup) {
//        QBChatDialog *groupChatDialog = [[QBChatDialog alloc] initWithDialogID:nudger.group.gID type:QBChatDialogTypeGroup];
//
//        
        
        NSMutableDictionary *extendedRequest = @{@"_id" : nudger.group.gID}.mutableCopy;
        
        QBResponsePage *page = [QBResponsePage responsePageWithLimit:1 skip:0];
        
        [QBRequest dialogsForPage:page extendedRequest:extendedRequest successBlock:^(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, QBResponsePage *page) {
            
        } errorBlock:^(QBResponse *response) {
            [SVProgressHUD dismiss];
            success(nil);
        }];
    } else {

            QBChatDialog *chatDialog = [[QBChatDialog alloc] initWithDialogID:nil type:QBChatDialogTypePrivate];
            chatDialog.occupantIDs = @[@(nudger.user.ID)];
            
            [QBRequest createDialog:chatDialog successBlock:^(QBResponse *response, QBChatDialog *createdDialog) {
                
                
            } errorBlock:^(QBResponse *response) {
                success(nil);
            }];
//        }
    }
}

- (void)sendMessage:(Nudger *)nudger txt:(NSString *)text attachment:(NSData *)attach success:(void (^)(QBChatMessage *))success {
    
    if (nudger.type == NTGroup) {
        
        NSMutableDictionary *extendedRequest = @{@"_id" : nudger.group.gID}.mutableCopy;
        
        QBResponsePage *page = [QBResponsePage responsePageWithLimit:1 skip:0];
        
        [QBRequest dialogsForPage:page extendedRequest:extendedRequest successBlock:^(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, QBResponsePage *page) {
        
            
        } errorBlock:^(QBResponse *response) {
            [SVProgressHUD dismiss];
            success(nil);
        }];
    } else {

        QBChatDialog *chatDialog = [[QBChatDialog alloc] initWithDialogID:nil type:QBChatDialogTypePrivate];
        chatDialog.occupantIDs = @[@(nudger.user.ID)];
        
        [QBRequest createDialog:chatDialog successBlock:^(QBResponse *response, QBChatDialog *createdDialog) {
            
            
        } errorBlock:^(QBResponse *response) {
            success(nil);
        }];
    }
}

- (void)chatDidReceiveMessage:(QBChatMessage *)message{
//    NSLog(@":::");
    
}

- (void)chatRoomDidReceiveMessage:(QB_NONNULL QBChatMessage *)message fromDialogID:(QB_NONNULL NSString *)dialogID {

    if (message.senderID == currentUser.ID) {
        return;
    }
     NSMutableDictionary *extendedRequest = @{@"_id" : dialogID}.mutableCopy;
    
    QBResponsePage *page = [QBResponsePage responsePageWithLimit:1 skip:0];
    
    [QBRequest dialogsForPage:page extendedRequest:extendedRequest successBlock:^(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, QBResponsePage *page) {
        
    } errorBlock:^(QBResponse *response) {
        
    }];
}

- (void)getUnreadMessages:(void (^)(NSInteger, NSDictionary *))unreadCount {
    NSMutableArray *mySet = [NSMutableArray new];
    for (Nudger *dNudger in notificationArray) {
        if (dNudger.dialogID) {
            [mySet addObject:dNudger.dialogID];
        }
    }
    NSSet *dialogsIDs = [NSSet setWithArray:(NSArray *)mySet];
    [QBRequest totalUnreadMessageCountForDialogsWithIDs:dialogsIDs successBlock:^(QBResponse *response, NSUInteger count, NSDictionary *dialogs) {
        
    } errorBlock:^(QBResponse *response) {
        
    }];
}

- (void)getUnreadMessage:(NSString *)dialogID success:(void (^)(NSInteger))unreadCount {
    NSMutableArray *mySet = [NSMutableArray new];

    [mySet addObject:dialogID];
    NSSet *dialogsIDs = [NSSet setWithArray:(NSArray *)mySet];
    [QBRequest totalUnreadMessageCountForDialogsWithIDs:dialogsIDs successBlock:^(QBResponse *response, NSUInteger count, NSDictionary *dialogs) {
    
    } errorBlock:^(QBResponse *response) {
        
    }];
}

- (void)connectGroupChat {
    for (Nudger *nudger in notificationArray) {
        if (nudger.type == NTGroup && nudger.group.gID) {
            QBChatDialog *groupChatDialog = [[QBChatDialog alloc] initWithDialogID:nudger.group.gID type:QBChatDialogTypeGroup];
            
            [groupChatDialog joinWithCompletionBlock:^(NSError * _Nullable error) {
                if (error) {
                    NSLog(@"----------failed to %@", nudger.group.gName);
                } else {
                    NSLog(@"----------connected to %@", nudger.group.gName);
                }
            }];
        }
    }
}

- (void)isBlock:(Nudger *)receiver success:(void (^)(BOOL))success {
    
    if (receiver.type == NTGroup) {
        success(NO);
        return;
    }
    
    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
    [getRequest setObject:[NSString stringWithFormat:@"%lu",receiver.user.ID] forKey:@"user_id"];
    [getRequest setObject:[NSString stringWithFormat:@"%lu",currentUser.ID] forKey:@"_parent_id"];
    [QBRequest objectsWithClassName:@"NudgerBuddy" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
        
    } errorBlock:^(QBResponse *response) {
        [self.delegate onceErr];
    }];
}

- (void)isSilent:(Nudger *)receiver success:(void (^)(BOOL))success {
    
}

- (void)logout:(void (^)(BOOL))success {
    [SVProgressHUD show];
    [[QBChat instance] disconnectWithCompletionBlock:^(NSError * _Nullable error) {
    
    }];
}

@end
