//
//  StreamController.m
//  NudgeBuddies
//
//  Created by Blue Silver on 12/31/15.
//  Copyright © 2015 Blue Silver. All rights reserved.
//

#import "StreamController.h"

@interface StreamController ()
{
    Nudger *nudger;
    NSArray *streamArr;
}
@end

@implementation StreamController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView setFrame:CGRectMake(0, 0, 262, 143)];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)streamResult:(Nudger *)selectedNudger {
    [SVProgressHUD show];
    
    nudger = selectedNudger;
    [QBRequest countOfMessagesForDialogID:nudger.dialogID extendedRequest:nil
                             successBlock:^(QBResponse *response, NSUInteger count) {
                                 QBResponsePage *resPage = [QBResponsePage responsePageWithLimit:5 skip:0];
                                 [QBRequest messagesWithDialogID:nudger.dialogID extendedRequest:nil forPage:resPage successBlock:^(QBResponse *response, NSArray *messages, QBResponsePage *responcePage) {
                                     streamArr = messages;
                                     [SVProgressHUD dismiss];
                                     [self.tableView reloadData];
//                                     [self.tableView setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
                                 } errorBlock:^(QBResponse *response) {
                                     [SVProgressHUD showErrorWithStatus:@"Failed to retrieve nudge stream. Please try later."];
                                 }];
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
    timeLab.text = [formatter stringFromDate:msg.dateSent];
    for (Nudger *contact in g_center.contactsArray) {
        if (contact.user.ID == msg.senderID) {
            [profileImg setImage:[UIImage imageWithData:[g_var loadFile:contact.user.blobID]]];
            nameLab.text = contact.user.fullName;
            return cell;
        }
    }
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
            [profileImg setImage:[UIImage imageNamed:@"empty"]];
        }
    } errorBlock:^(QBResponse *response) {
    }];
    return cell;
}

@end
