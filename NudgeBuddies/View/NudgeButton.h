//
//  NudgeButton.h
//  NudgeBuddies
//
//  Created by Hans Adler on 14/12/15.
//  Copyright © 2015 Blue Silver. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NudgeButtonDelegate <NSObject>

@optional

- (void)onNudgeClicked:(Nudger *)nudger frame:(CGRect)rect;
- (void)onSendNudge:(Nudger *)nudger;

@end

@interface NudgeButton : UIViewController

@property(weak) id <NudgeButtonDelegate> delegate;
@property (nonatomic) int index;
@property (nonatomic, retain) Nudger *userInfo;

- (void)initNudge:(Nudger *)user;
- (void)notify;

@end
