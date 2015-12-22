//
//  NotificationCenter.m
//  NudgeBuddies
//
//  Created by Hans Adler on 13/12/15.
//  Copyright © 2015 Blue Silver. All rights reserved.
//

#import "NotificationCenter.h"

@implementation NotificationCenter
@synthesize pendingArray, contactsArray, notificationArray, favArray;
- (void)initCenter {
    pendingArray = [NSMutableArray new];
    contactsArray = [NSMutableArray new];
    notificationArray = [NSMutableArray new];
    favArray = [NSMutableArray new];
    if (g_var.currentUser == nil) {
        return;
    }
    [[QBChat instance] connectWithUser:g_var.currentUser  completion:^(NSError *error) {
        if (error) {
            [[[UIAlertView alloc] initWithTitle:@"Couldn't connect to chat" message:[NSString stringWithFormat:@"%@", error.description] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            [self initCenter];
        } else {
//            NSArray *pendingArr = [QBChat instance].contactList;
            for (QBContactListItem *item in [QBChat instance].contactList.pendingApproval) {
                NSLog(@"%lu", item.subscriptionState);
//                if (item.subscriptionState == QBPresenseSubscriptionStateFrom) {
                    [QBRequest userWithID:item.userID successBlock:^(QBResponse *response, QBUUser *user) {
                        Nudger *newUser = [[Nudger alloc] initWithUser:user];
                        newUser.status = NSInvited;
                        [pendingArray addObject:newUser];
                    } errorBlock:^(QBResponse *response) {
                        NSLog(@"Err: loading pending users");
                    }];
//                }
            }
            for (QBContactListItem *item in [QBChat instance].contactList.contacts) {
                [QBRequest userWithID:item.userID successBlock:^(QBResponse *response, QBUUser *user) {
                    Nudger *newUser = [[Nudger alloc] initWithUser:user];
                    [contactsArray addObject:newUser];
                } errorBlock:^(QBResponse *response) {
                    NSLog(@"Err: loading pending users");
                }];
            }
            NSArray *arrr = [QBChat instance].contactList.contacts;
            NSLog(@"%d", arrr.count);
//            [self sort];
            [self update:nil];
        }
    }];
}

- (void)update:(Nudger *)user {
    if (user == nil) {
        [self.notificationArray addObjectsFromArray:contactsArray];
        [self.notificationArray addObjectsFromArray:pendingArray];
    } else {
        for (int i=0; i<self.notificationArray.count; i++) {
            Nudger *nudger = [self.notificationArray objectAtIndex:i];
            if (nudger.user.ID == user.user.ID || [nudger.group.gName isEqualToString:user.group.gName]) {
                [self.notificationArray removeObjectAtIndex:i];
                [self.notificationArray addObject:nudger];
                break;  
            }
        }
    }
}

- (void)refresh {
    pendingArray = [NSMutableArray new];
    contactsArray = [NSMutableArray new];
    notificationArray = [NSMutableArray new];
    favArray = [NSMutableArray new];
    
    for (QBContactListItem *item in [QBChat instance].contactList.pendingApproval) {
        NSLog(@"%lu", item.subscriptionState);
        if (item.subscriptionState == QBPresenseSubscriptionStateFrom) {
            [QBRequest userWithID:item.userID successBlock:^(QBResponse *response, QBUUser *user) {
                Nudger *newUser = [[Nudger alloc] initWithUser:user];
                newUser.status = NSInvited;
                [self.pendingArray addObject:newUser];
            } errorBlock:^(QBResponse *response) {
                NSLog(@"Err: loading pending users");
            }];
        }
    }
    for (QBContactListItem *item in [QBChat instance].contactList.contacts) {
        [QBRequest userWithID:item.userID successBlock:^(QBResponse *response, QBUUser *user) {
            Nudger *newUser = [[Nudger alloc] initWithUser:user];
            [contactsArray addObject:newUser];
        } errorBlock:^(QBResponse *response) {
            NSLog(@"Err: loading pending users");
        }];
    }
//    [self sort];
    [self update:nil];
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

- (Menu *)getMenu:(CGRect)frame menuSize:(CGSize)size{
    Menu *menu = [Menu new];
    if (frame.origin.x > 568/2.0) {
        menu.menuPoint = CGPointMake(frame.origin.x+frame.size.width/2.0-size.width/2.0, frame.origin.y-size.height);
        if (menu.menuPoint.x < 0) {
            menu.menuPoint = CGPointMake(12, menu.menuPoint.y);
        } else if (frame.origin.x + size.width > 320) {
            menu.menuPoint = CGPointMake(320-12-size.width, menu.menuPoint.y);
        }
        menu.triDirection = NO;
        menu.triPoint = CGPointMake(frame.origin.x+frame.size.width/2.0-9 - menu.menuPoint.x, frame.origin.y+frame.size.height);
    } else {
        menu.menuPoint = CGPointMake(frame.origin.x+frame.size.width/2.0-size.width/2.0, frame.origin.y+frame.size.height);
        if (menu.menuPoint.x < 0) {
            menu.menuPoint = CGPointMake(12, menu.menuPoint.y);
        } else if (menu.menuPoint.x + size.width > 320) {
            menu.menuPoint = CGPointMake(320-12-size.width, menu.menuPoint.y);
        }
        menu.triDirection = YES;
        menu.triPoint = CGPointMake(frame.origin.x+frame.size.width/2.0-9 - menu.menuPoint.x, frame.origin.y+frame.size.height);
    }
    return menu;
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
        //        [center.contactArray addObject:newUser];
//        [center.notificationArray addObject:newUser];
//        [center sort];
//        [self refreshUI];
    } errorBlock:^(QBResponse *response) {
        NSLog(@"Err: loading pending users");
    }];
}

- (void)chatContactListDidChange:(QB_NONNULL QBContactList *)contactList {
    NSLog(@"--------chatContactListDidChange--------- %@", contactList);
//    [center refresh];
//    [self refreshUI];
}

- (void)chatDidReceiveContactItemActivity:(NSUInteger)userID isOnline:(BOOL)isOnline status:(QB_NULLABLE NSString *)status {
    NSLog(@"--------chatDidReceiveContactItemActivity--------- %lu", userID);
}

- (void)chatDidReceiveAcceptContactRequestFromUser:(NSUInteger)userID {
    NSLog(@"--------chatDidReceiveAcceptContactRequestFromUser--------- %lu", userID);
    [[[UIAlertView alloc] initWithTitle:@"Alert" message:[NSString stringWithFormat:@"Your add contact request (ID:%lu is accepted!", userID] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
//    [center refresh];
//    [self refreshUI];
}

- (void)chatDidReceiveRejectContactRequestFromUser:(NSUInteger)userID {
    NSLog(@"--------chatDidReceiveRejectContactRequestFromUser--------- %lu", userID);
    [[[UIAlertView alloc] initWithTitle:@"Alert" message:[NSString stringWithFormat:@"Your add contact request (ID:%lu is rejected!", userID] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
}

@end
