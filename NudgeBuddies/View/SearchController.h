//
//  SearchController.h
//  NudgeBuddies
//
//  Created by Xian Lee on 6/12/2015.
//  Copyright © 2015 Blue Silver. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SearchControllerDelegate <NSObject>

@optional

- (void)onSearchDone;

@end

@interface SearchController : UITableViewController

@property(weak) id <SearchControllerDelegate> delegate;

- (int)searchResult:(NSMutableArray *)searchArr;
- (void)emptyTable;

@end
