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

@synthesize pendingArray, contactsArray, notificationArray, favArray, currentUser;

- (void)initCenter:(QBUUser *)user {
    pendingArray = [NSMutableArray new];
    contactsArray = [NSMutableArray new];
    notificationArray = [NSMutableArray new];
    favArray = [NSMutableArray new];
    
    currentUser = user;

    [[QBChat instance] addDelegate:self];
    [[QBChat instance] connectWithUser:user  completion:^(NSError *error) {
        if (error) {
            [[[UIAlertView alloc] initWithTitle:@"Couldn't connect to chat" message:[NSString stringWithFormat:@"%@", error.description] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            [self initCenter:user];
        } else {
            QBContactList *list = [QBChat instance].contactList;
            NSLog(@"%@", list);
            [self.delegate onceConnect];
        }
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

- (void)getContact {
    NSArray *cArr = [QBChat instance].contactList.contacts;
    for (QBContactListItem *item in [QBChat instance].contactList.contacts) {
        [QBRequest userWithID:item.userID successBlock:^(QBResponse *response, QBUUser *user) {
            Nudger *newUser = [[Nudger alloc] initWithUser:user];
            [contactsArray addObject:newUser];
            [notificationArray addObject:newUser];
            loadCount ++;
            if (loadCount == cArr.count) {
                [self.delegate onceLoadedContactList];
//                for (QBContactListItem *item in [QBChat instance].contactList.pendingApproval) {
//                    NSLog(@"%lu", item.subscriptionState);
//                    if (item.subscriptionState == QBPresenseSubscriptionStateFrom) {
//                        [QBRequest userWithID:item.userID successBlock:^(QBResponse *response, QBUUser *user) {
//                            Nudger *newUser = [[Nudger alloc] initWithUser:user];
//                            newUser.status = NSInvited;
//                            [self.pendingArray addObject:newUser];
//                        } errorBlock:^(QBResponse *response) {
//                            NSLog(@"Err: loading pending users");
//                        }];
//                    }
//                }
            }
        } errorBlock:^(QBResponse *response) {
            NSLog(@"Err: loading pending users");
        }];
    }
    //    [self sort];
//    [self add:nil];
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

#pragma mark - Chat Module
///// --------- msg list ----------- /////////////////////////////////////////////////////////////////////////
- (void)chatRoomDidReceiveMessage:(QB_NONNULL QBChatMessage *)message fromDialogID:(QB_NONNULL NSString *)dialogID {
    
}
///// --------- contact list ----------- /////////////////////////////////////////////////////////////////////////
- (void)chatDidReceiveContactAddRequestFromUser:(NSUInteger)userID {
    [QBRequest userWithID:userID successBlock:^(QBResponse *response, QBUUser *user) {
        NSLog(@"--------Got add contact request from   %lu ---------", userID);
        Nudger *newUser = [[Nudger alloc] initWithUser:user];
        newUser.isNew = YES;
        newUser.status = NSInvited;
        [self add:newUser];
        [self.delegate onceAddedContact:newUser];
    } errorBlock:^(QBResponse *response) {
        NSLog(@"Err: loading pending users");
    }];
}

- (void)chatContactListDidChange:(QB_NONNULL QBContactList *)contactList {
    NSLog(@"--------chatContactListDidChange--------- %@", contactList);
    if (self.contactsArray.count == 0) {
        [self getContact];
        [self.delegate startLoadContactList];
    }
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
        NSLog(@"Err: loading pending users");
    }];
}

- (void)chatDidReceiveRejectContactRequestFromUser:(NSUInteger)userID {
    NSLog(@"--------chatDidReceiveRejectContactRequestFromUser--------- %lu", userID);
    [self.delegate onceRejected:userID];
//    [[[UIAlertView alloc] initWithTitle:@"Alert" message:[NSString stringWithFormat:@"Your add contact request (ID:%lu is rejected!", userID] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
}

@end
