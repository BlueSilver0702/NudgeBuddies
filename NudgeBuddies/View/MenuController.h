//
//  MenuController.h
//  NudgeBuddies
//
//  Created by Hans Adler on 13/12/15.
//  Copyright © 2015 Blue Silver. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MenuControllerDelegate <NSObject>

@optional

- (void)onMenuClicked:(MenuReturn)menuReturn nudger:(Nudger *)nudger;
- (void)onMenuNudged:(Nudger *)nudger;

@end

@interface MenuController : UITableViewController

@property(weak) id <MenuControllerDelegate> delegate;
@property(nonatomic, retain) Nudger *tUser;
@property(nonatomic) BOOL isOpen;

- (CGSize)createMenu:(Nudger *)nudger;
- (CGSize)createSendMenu:(Nudger *)nudger;

@end
