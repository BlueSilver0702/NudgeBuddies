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
            [self update:nil];
        }
    }];
}

- (void)update:(Nudger *)user {
    if (user == nil) {
        [self.notificationArray addObjectsFromArray:self.contactArray];
        [self.notificationArray addObjectsFromArray:self.pendingArray];
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
    self.pendingArray = [NSMutableArray new];
    self.contactArray = [NSMutableArray new];
    self.notificationArray = [NSMutableArray new];
    self.favArray = [NSMutableArray new];
    
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
            [self.contactArray addObject:newUser];
        } errorBlock:^(QBResponse *response) {
            NSLog(@"Err: loading pending users");
        }];
    }
    [self sort];
    [self update:nil];
}

- (void)sort {
    self.contactArray = (NSMutableArray *)[self.contactArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *user1 = [(QBUUser *)obj1 fullName];
        NSString *user2 = [(QBUUser *)obj2 fullName];
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

@end
