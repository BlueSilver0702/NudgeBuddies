//
//  NotificationCenter.h
//  NudgeBuddies
//
//  Created by Hans Adler on 13/12/15.
//  Copyright © 2015 Blue Silver. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotificationCenter : NSObject

//@property (nonatomic) int notifyCount;
@property (nonatomic, retain) NSMutableArray *contactArray;
@property (nonatomic, retain) NSMutableArray *pendingArray;
@property (nonatomic, retain) NSMutableArray *favArray;
@property (nonatomic, retain) NSMutableArray *notificationArray;

- (void)initCenter;
- (Menu *)getMenu:(CGRect)frame menuSize:(CGSize)size;
- (void)refresh;
- (void)update:(Nudger *)user;
- (void)sort;

@end
