//
//  StreamController.h
//  NudgeBuddies
//
//  Created by Blue Silver on 12/31/15.
//  Copyright © 2015 Blue Silver. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol StreamControllerDelegate <NSObject>

@optional

- (void)onUnreadCount:(NSInteger)count;
- (void)tableContentHeight:(CGFloat)contentHeight;

@end

@interface StreamController : UITableViewController

@property(weak) id <StreamControllerDelegate> delegate;

- (void)streamResult:(Nudger *)selectedNudger;
- (void)sentNudge:(Nudger *)nudger msg:(QBChatMessage *)msg;

@end
