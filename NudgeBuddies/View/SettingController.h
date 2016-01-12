//
//  SettingController.h
//  NudgeBuddies
//
//  Created by Xian Lee on 5/12/2015.
//  Copyright © 2015 Blue Silver. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SettingControllerDelegate <NSObject>

@optional

- (void)onSettingDone:(int)status;
- (void)onSettingUpdate;
- (void)onSettingCountHide:(BOOL)hide;
- (void)onSettingADPurchased;
- (void)onSettingSoundPurchased;

@end

@interface SettingController : UIViewController

@property(weak) id <SettingControllerDelegate> delegate;

- (void) initView:(BOOL) night;

@end
