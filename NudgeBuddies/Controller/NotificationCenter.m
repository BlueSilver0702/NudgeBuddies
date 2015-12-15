//
//  NotificationCenter.m
//  NudgeBuddies
//
//  Created by Hans Adler on 13/12/15.
//  Copyright © 2015 Blue Silver. All rights reserved.
//

#import "NotificationCenter.h"

@implementation NotificationCenter

- (void)initCenter {
    self.pendingArray = [NSMutableArray new];
    self.contactArray = [NSMutableArray new];
    self.notificationArray = [NSMutableArray new];
    self.favArray = [NSMutableArray new];
    [[QBChat instance] connectWithUser:g_var.currentUser  completion:^(NSError *error) {
        if (error) {
            [[[UIAlertView alloc] initWithTitle:@"Couldn't connect to chat" message:[NSString stringWithFormat:@"%@", error.description] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        } else {
            for (QBContactListItem *item in [QBChat instance].contactList.pendingApproval) {
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
                    [self.contactArray addObject:newUser];
                } errorBlock:^(QBResponse *response) {
                    NSLog(@"Err: loading pending users");
                }];
            }
            [self sort];
        }
    }];
}

- (void)update:(NSUInteger)userID {
    BOOL isExist = NO;
    NSMutableArray *newNotificationArray = [NSMutableArray new];
    for (Nudger *nudger in self.notificationArray) {
        if (nudger.user.ID == userID) {
            isExist = YES;
        } else {
            newNotificationArray = nudger;
        }
    }
    [QBRequest userWithID:userID successBlock:^(QBResponse *response, QBUUser *user) {
        
    } errorBlock:^(QBResponse *response) {
        NSLog(@"Err: adding users");
    }];
}

- (void)sort {
    self.contactArray = (NSMutableArray *)[self.contactArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *user1 = [(QBUUser *)obj1 fullName];
        NSString *user2 = [(QBUUser *)obj2 fullName];
        return [user1 compare:user2];
    }];
}

- (Menu *)getMenu:(int)index {
    Menu *menu = [Menu new];
    menu.index = index;
//    for (Menu in <#collection#>) {
//        <#statements#>
//    }
    menu.menuPoint = CGPointMake(0, 0);
    menu.triPoint = CGPointMake(0, 0);
    menu.triDirection = YES;
    return menu;
}

@end
