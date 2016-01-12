//
//  StreamController.m
//  NudgeBuddies
//
//  Created by Blue Silver on 12/31/15.
//  Copyright © 2015 Blue Silver. All rights reserved.
//

#import "StreamController.h"
#import "SVPullToRefresh.h"

@interface StreamController ()
{
    Nudger *nudger;
    NSMutableArray *streamArr;
    int skip;
}
@end

@implementation StreamController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView setFrame:CGRectMake(0, 0, 262, 162)];

    __weak StreamController *weakSelf = self;
    
    [self.tableView addPullToRefreshWithActionHandler:^{
        [weakSelf insertRowAtTop];
    }];
    
    skip = 0;
}

- (void)insertRowAtTop {
    __weak StreamController *weakSelf = self;
    
    int64_t delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSMutableDictionary *extendedRequest = @{@"sort_desc" : @"date_sent"}.mutableCopy;
        QBResponsePage *resPage = [QBResponsePage responsePageWithLimit:5 skip:skip];
        [QBRequest messagesWithDialogID:nudger.dialogID extendedRequest:extendedRequest forPage:resPage successBlock:^(QBResponse *response, NSArray *messages, QBResponsePage *responcePage) {
            [SVProgressHUD dismiss];
            if (messages.count == 0) [SVProgressHUD showErrorWithStatus:@"There is no more message history!"];
            [weakSelf.tableView beginUpdates];
//            [streamArr insertObjects:messages atIndexes:[[NSIndexSet new] initWithIndexesInRange:NSMakeRange(0, messages.count)]];
            for (NSInteger j = 0; j < messages.count; j++) {
//                [streamArr addObject:[messages objectAtIndex:j]];
                [streamArr insertObject:[messages objectAtIndex:j] atIndex:0];
            }
            NSMutableArray *indexArray = [NSMutableArray new];
            for (int i=0; i<messages.count; i++) {
                [indexArray addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }
            [weakSelf.tableView insertRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationBottom];
            [weakSelf.tableView endUpdates];
            [weakSelf.tableView.pullToRefreshView stopAnimating];
            skip += messages.count;
            
            [g_center getUnreadMessage:nudger.dialogID success:^(NSInteger unreadCount) {
                [self.delegate onUnreadCount:unreadCount];
            }];
            //                                     [self.tableView setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
        } errorBlock:^(QBResponse *response) {
            [SVProgressHUD showErrorWithStatus:@"Failed to retrieve nudge stream. Please try later."];
        }];
    });
}

- (void)streamResult:(Nudger *)selectedNudger {
    [SVProgressHUD show];
    
    nudger = selectedNudger;
    streamArr = [NSMutableArray new];
//    [QBRequest countOfMessagesForDialogID:nudger.dialogID extendedRequest:nil
//                             successBlock:^(QBResponse *response, NSUInteger count) {
//                                 
//                             } errorBlock:^(QBResponse *response) {
//                                 [SVProgressHUD showErrorWithStatus:@"Failed to retrieve nudge stream. Please try later."];
//                             }];
    NSMutableDictionary *extendedRequest = @{@"sort_desc" : @"date_sent"}.mutableCopy;
    QBResponsePage *resPage = [QBResponsePage responsePageWithLimit:5 skip:0];
    [QBRequest messagesWithDialogID:nudger.dialogID extendedRequest:extendedRequest forPage:resPage successBlock:^(QBResponse *response, NSArray *messages, QBResponsePage *responcePage) {
//        streamArr = (NSMutableArray *)messages;
        for (int i=0; i<messages.count; i++) {
            [streamArr insertObject:[messages objectAtIndex:i] atIndex:0];
        }
        [SVProgressHUD dismiss];
        [self.tableView reloadData];
        
        NSIndexPath *ipath = [NSIndexPath indexPathForRow:messages.count-1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:ipath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
        skip += 5;
        
        [g_center getUnreadMessage:nudger.dialogID success:^(NSInteger unreadCount) {
            [self.delegate onUnreadCount:unreadCount];
        }];
        //                                     [self.tableView setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
    } errorBlock:^(QBResponse *response) {
        [SVProgressHUD showErrorWithStatus:@"Failed to retrieve nudge stream. Please try later."];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
    if (streamArr == nil) {
        return 0;
    }
    return streamArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell-stream" forIndexPath:indexPath];
    QBChatMessage *msg = [streamArr objectAtIndex:indexPath.row];
    UIImageView *profileImg = (UIImageView *)[cell viewWithTag:1];
    UILabel *nameLab = (UILabel *)[cell viewWithTag:2];
    UILabel *msgLab = (UILabel *)[cell viewWithTag:3];
    UILabel *timeLab = (UILabel *)[cell viewWithTag:4];
    [profileImg setImage:[UIImage imageNamed:@"empty"]];
    nameLab.text = @"";
    msgLab.text = msg.text;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh.mm a"];
    NSString *related = [self relativeDateStringForDate:msg.dateSent];
    timeLab.text = [NSString stringWithFormat:@"%@ %@",related,[formatter stringFromDate:msg.dateSent]];
    for (Nudger *contact in g_center.contactsArray) {
        if (contact.user.ID == msg.senderID) {
            [profileImg setImage:[UIImage imageWithData:[g_var loadFile:contact.user.blobID]]];
            nameLab.text = contact.user.fullName;
            return cell;
        }
    }
    if (msg.senderID == g_center.currentUser.ID) {
        nameLab.text = g_center.currentUser.fullName;
        NSData *profileData = [g_var loadFile:g_center.currentUser.blobID];
        [profileImg setImage:[UIImage imageWithData:profileData]];
    } else {
        [QBRequest userWithID:msg.senderID successBlock:^(QBResponse *response, QBUUser *user) {
            nameLab.text = user.fullName;
            NSData *profileData = [g_var loadFile:user.blobID];
            if (profileData == nil) {
                [QBRequest downloadFileWithID:nudger.user.blobID successBlock:^(QBResponse *response, NSData *fileData) {
                    [g_var saveFile:fileData uid:nudger.user.blobID];
                    [profileImg setImage:[UIImage imageWithData:fileData]];
                } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
                } errorBlock:^(QBResponse *response) {
                }];
            } else {
                [profileImg setImage:[UIImage imageWithData:profileData]];
            }
        } errorBlock:^(QBResponse *response) {
        }];
    }
    
    return cell;
}

- (NSString *)relativeDateStringForDate:(NSDate *)date
{
    NSCalendarUnit units = NSCalendarUnitDay | NSCalendarUnitWeekOfYear |
    NSCalendarUnitMonth | NSCalendarUnitYear;
    
    // if `date` is before "now" (i.e. in the past) then the components will be positive
    NSDateComponents *components = [[NSCalendar currentCalendar] components:units
                                                                   fromDate:date
                                                                     toDate:[NSDate date]
                                                                    options:0];
    
    if (components.year > 0) {
        return [NSString stringWithFormat:@"%ld years ago", (long)components.year];
    } else if (components.month > 0) {
        return [NSString stringWithFormat:@"%ld months ago", (long)components.month];
    } else if (components.weekOfYear > 0) {
        return [NSString stringWithFormat:@"%ld weeks ago", (long)components.weekOfYear];
    } else if (components.day > 0) {
        if (components.day > 1) {
            return [NSString stringWithFormat:@"%ld days ago", (long)components.day];
        } else {
            return @"Yesterday";
        }
    } else {
        return @"Today";
    }
}

@end
