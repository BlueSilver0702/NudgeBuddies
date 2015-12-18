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

@end

@interface MenuController : UITableViewController

@property(weak) id <MenuControllerDelegate> delegate;

- (CGSize)createMenu:(Nudger *)nudger;

@end
