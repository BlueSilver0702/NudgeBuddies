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
    
    [self.tableView setFrame:CGRectMake(0, 0, 262, 256)];

    __weak StreamController *weakSelf = self;
    
    [self.tableView addPullToRefreshWithActionHandler:^{
        [weakSelf insertRowAtTop];
    }];
    
//    self.tableView.rowHeight = UITableViewAutomaticDimension;
//    self.tableView.estimatedRowHeight = 54.0;
    
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

- (void)sentNudge:(Nudger *)nudger msg:(QBChatMessage *)msg {
    
    [self.tableView beginUpdates];
    [streamArr addObject:msg];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:streamArr.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
    [self.tableView endUpdates];
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:streamArr.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)streamResult:(Nudger *)selectedNudger {

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
        [self.tableView reloadData];
        
        [self.delegate tableContentHeight:self.tableView.contentSize.height];
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
    UITableViewCell *cell;
    QBChatMessage *msg = [streamArr objectAtIndex:indexPath.row];

    if (msg.senderID == g_center.currentUser.ID) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell-stream1" forIndexPath:indexPath];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell-stream" forIndexPath:indexPath];
    }
    
    UIImageView *profileImg = (UIImageView *)[cell viewWithTag:1];
    UILabel *nameLab = (UILabel *)[cell viewWithTag:2];
    UILabel *msgLab = (UILabel *)[cell viewWithTag:3];
    UILabel *timeLab = (UILabel *)[cell viewWithTag:4];
    UILabel *mmLab = (UILabel *)[cell viewWithTag:5];
    UILabel *dayLab = (UILabel *)[cell viewWithTag:6];
    UIImageView *attachImg = (UIImageView *)[cell viewWithTag:7];
    
    [profileImg setImage:[UIImage imageNamed:@"empty"]];
    nameLab.text = @"";
    msgLab.text = msg.text;
    CGSize size = [msgLab sizeOfMultiLineLabel];
    [msgLab setFrame:CGRectMake(msgLab.frame.origin.x, msgLab.frame.origin.y, 160.0, size.height)];
    
    if (msg.attachments.count > 0) {
        QBChatAttachment *attachment = msg.attachments[0];
        NSData *saveFile = [g_var loadFile:[attachment.ID integerValue]];
        if (saveFile) {
            [attachImg setImage:[UIImage imageWithData:saveFile]];
        } else {
            [QBRequest downloadFileWithID:[attachment.ID integerValue] successBlock:^(QBResponse *response, NSData *fileData) {
                [attachImg setImage:[UIImage imageWithData:fileData]];
                [g_var saveFile:fileData uid:[attachment.ID integerValue]];
            } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
                // handle progress
            } errorBlock:^(QBResponse *response) {
                NSLog(@"error: %@", response.error);
            }];
        }
        [attachImg setFrame:CGRectMake(attachImg.frame.origin.x, msgLab.frame.origin.y+msgLab.frame.size.height+8, attachImg.frame.size.width, 150.0)];
    } else {
        [attachImg setFrame:CGRectMake(attachImg.frame.origin.x, msgLab.frame.origin.y+msgLab.frame.size.height+8, attachImg.frame.size.width, 0.0)];
        [attachImg setImage:nil];
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh.mm"];
    dayLab.text = [self relativeDateStringForDate:msg.dateSent];
    timeLab.text = [formatter stringFromDate:msg.dateSent];
    [formatter setDateFormat:@"a"];
    mmLab.text = [formatter stringFromDate:msg.dateSent];
    
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    UILabel *msgLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 160, 21)];
    QBChatMessage *msg = [streamArr objectAtIndex:indexPath.row];
    msgLab.text = msg.text;
    CGSize size = [msgLab sizeOfMultiLineLabel];
    if (msg.attachments.count > 0) {
        return size.height + 130.0;
    }
    if (size.height < 54-18) {
        return 54.0;
    }
    return size.height + 18.0;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
