//
//  SearchController.m
//  NudgeBuddies
//
//  Created by Xian Lee on 6/12/2015.
//  Copyright © 2015 Blue Silver. All rights reserved.
//

#import "SearchController.h"

@interface SearchController ()
{
    NSMutableArray *dataArr;
    NSMutableArray *fbFriendsArr;
    NSMutableArray *localNudgers;
    NSMutableArray *otherNudgers;
    NSMutableArray *potentialNudgers;
    NSMutableArray *searchArr;
    NSIndexPath *selectedPath;
}
@end

@implementation SearchController

- (void) viewDidLoad {
    [super viewDidLoad];
    
//    User *user1 = [User new]; user1.fname = @"Stuart"; user1.lname = @"Jeaves"; user1.type = 0; user1.profile = @"user-1";
//    User *user2 = [User new]; user2.fname = @"Stuart"; user2.lname = @"Michaels"; user2.type = 0; user2.profile = @"user-2";
//    User *user3 = [User new]; user3.fname = @"Stuart"; user3.lname = @"Jimmy"; user3.type = 0; user3.profile = @"user-3";
//    User *user4 = [User new]; user4.fname = @"Stuart001"; user4.lname = @""; user4.type = 1; user4.profile = @"user-4";
//    User *user5 = [User new]; user5.fname = @"Android12"; user5.lname = @""; user5.type = 1; user5.profile = @"user-5";
//    User *user6 = [User new]; user6.fname = @"ABC333"; user6.lname = @""; user6.type = 1; user6.profile = @"user-1";
//    User *user7 = [User new]; user7.fname = @"Stuart"; user7.lname = @"Adler"; user7.type = 2; user7.profile = @"user-2";
//    User *user8 = [User new]; user8.fname = @"Stuart323"; user8.lname = @""; user8.type = 2; user8.profile = @"user-3";
    localNudgers = [NSMutableArray new];
    otherNudgers = [NSMutableArray new];
    potentialNudgers = [NSMutableArray new];
    
    fbFriendsArr = [NSMutableArray new];
    
    if ([FBSDKAccessToken currentAccessToken]) {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me/friends" parameters:@{ @"fields" : @"id"}] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                NSLog(@"%@", result);
                NSDictionary *dictionary = (NSDictionary *)result;
                NSArray* friends = [dictionary objectForKey:@"data"];
                for (NSDictionary* friend in friends) {
                    NSLog(@"I have a friend named %@ with id", [friend objectForKey:@"id"]);
                    [fbFriendsArr addObject:friend];
                }
                
                NSMutableDictionary *filters = [NSMutableDictionary dictionary];
                filters[@"order"] = @"asc string full_name";
                
                [QBRequest usersWithExtendedRequest:filters page:[QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:10] successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
                    dataArr = [NSMutableArray new];
                    for (QBUUser *user in users) {
                        if (![user.login isEqualToString:g_var.currentUser.login]) {
                            [dataArr addObject:user];
                        }
                    }
                    [self searchResult:@""];
                    NSLog(@"completed!");
                } errorBlock:^(QBResponse *response) {
                    // Handle error  
                }];
            }
        }];
    }

//    dataArr = [NSArray arrayWithObjects:user1, user2, user3, user4, user5, user6, user7, user8, nil];

}

- (int)searchResult:(NSString *)searchStr {
    searchArr = [NSMutableArray new];
    localNudgers = [NSMutableArray new];
    otherNudgers = [NSMutableArray new];
    potentialNudgers = [NSMutableArray new];
    for (QBUUser *user in dataArr) {
        NSUInteger searchOptions = NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;
        NSString *string = user.fullName;
        NSRange searchRange = NSMakeRange(0, string.length);
        NSRange foundRange = [string rangeOfString:searchStr options:searchOptions range:searchRange];
        if (foundRange.length > 0 || [searchStr isEqualToString:@""]) {
            [searchArr addObject:user];
        }
    }
    for (QBUUser *user in searchArr) {
        BOOL isAdded = NO;
        for (QBContactListItem *item in [QBChat instance].contactList.contacts) {
            if (user.ID == item.userID) {
                [localNudgers addObject:user];
                isAdded = YES;
                break;
            }
        }
        if (!isAdded) {
            for (QBContactListItem *item in [QBChat instance].contactList.pendingApproval) {
                if (user.ID == item.userID) {
                    [localNudgers addObject:user];
                    isAdded = YES;
                    break;
                }
            }
        }
        if (!isAdded) {
            for (NSDictionary *dict in fbFriendsArr) {
                NSString *dictID = [dict objectForKey:@"id"];
                if ([dictID isEqualToString: user.facebookID]) {
                    [potentialNudgers addObject: user];
                    isAdded = YES;
                    break;
                }
            }
        }
        if (!isAdded) {
            [otherNudgers addObject:user];
        }
    }
    [self.tableView reloadData];
    if (self.tableView.contentSize.height > 320) {
        [self.tableView setFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 320)];
        return 320;
    } else {
        [self.tableView setFrame:CGRectMake(0, 0, self.tableView.frame.size.width, self.tableView.contentSize.height)];
    }
    return self.tableView.contentSize.height;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1) {
        return otherNudgers.count;
    } else if (section == 2) {
        return potentialNudgers.count;
    }
    return localNudgers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"cell-search";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    UIImageView *profileImg = (UIImageView *) [cell viewWithTag:1];
    UIImageView *logoImg = (UIImageView *) [cell viewWithTag:2];
    UIImageView *fbImg = (UIImageView *) [cell viewWithTag:3];
    UILabel *userName = (UILabel *) [cell viewWithTag:4];
    UIImageView *nextBtn = (UIImageView *) [cell viewWithTag:5];
    UIButton *btn1 = (UIButton *) [cell viewWithTag:6];
    UIButton *btn2 = (UIButton *) [cell viewWithTag:7];
    UIButton *btn3 = (UIButton *) [cell viewWithTag:8];
    UIButton *becomeLab = [(UIButton *) cell viewWithTag:9];
    QBUUser *userInfo;
    if (indexPath.section == 0) {
        userInfo = [localNudgers objectAtIndex:indexPath.row];
    } else if (indexPath.section == 1) {
        userInfo = [otherNudgers objectAtIndex:indexPath.row];
    } else {
        userInfo = [potentialNudgers objectAtIndex:indexPath.row];
    }
    [becomeLab setTag:userInfo.ID];
    if (userInfo.blobID > 0) {
        NSData *imgData = [g_var loadFile:userInfo.blobID];
        if (imgData) {
            [profileImg setImage:[UIImage imageWithData:imgData]];
        } else {
            [QBRequest downloadFileWithID:userInfo.blobID successBlock:^(QBResponse *response, NSData *fileData) {
                [profileImg setImage:[UIImage imageWithData:fileData]];
            } statusBlock:nil errorBlock:nil];
        }
    } else {
        [profileImg setImage:[UIImage imageNamed:@"empty"]];
    }
    [userName setText:userInfo.fullName];
    if (indexPath.section == 0) {
        fbImg.hidden = YES;
        logoImg.hidden = NO;
        nextBtn.hidden = YES;
        btn1.hidden = NO;
        btn2.hidden = NO;
        btn3.hidden = NO;
        [btn1 addTarget:self action:@selector(searchDone) forControlEvents:UIControlEventTouchUpInside];
        [btn2 addTarget:self action:@selector(searchDone) forControlEvents:UIControlEventTouchUpInside];
        [btn3 addTarget:self action:@selector(searchDone) forControlEvents:UIControlEventTouchUpInside];
    } else if (indexPath.section == 1) {
        fbImg.hidden = YES;
        logoImg.hidden = NO;
        nextBtn.hidden = NO;
        btn1.hidden = YES;
        btn2.hidden = YES;
        btn3.hidden = YES;
    } else if (indexPath.section == 2) {
        logoImg.hidden = YES;
        fbImg.hidden = NO;
        nextBtn.hidden = NO;
        btn1.hidden = YES;
        btn2.hidden = YES;
        btn3.hidden = YES;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    QBUUser *userInfo;
    if (indexPath.section == 0) {
        userInfo = [localNudgers objectAtIndex:indexPath.row];
    } else if (indexPath.section == 1) {
        userInfo = [otherNudgers objectAtIndex:indexPath.row];
    } else {
        userInfo = [potentialNudgers objectAtIndex:indexPath.row];
    }
    UIButton *becomeLab = [(UIButton *) cell viewWithTag:userInfo.ID];
    [becomeLab addTarget:self action:@selector(becomeNudger:) forControlEvents:UIControlEventTouchUpInside];
    if (indexPath.section > 0) {
        if (selectedPath != indexPath) {
            UITableViewCell *selected = [tableView cellForRowAtIndexPath:selectedPath];
            UIButton *selectedLab = [(UIButton *) selected viewWithTag:9];
            [UIView transitionWithView:selectedLab duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                [selectedLab setFrame:CGRectMake(320, selectedLab.frame.origin.y, selectedLab.frame.size.width, selectedLab.frame.size.height)];
            } completion:nil];
        }
        [UIView transitionWithView:becomeLab duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            if (becomeLab.frame.origin.x == 320) {
                [becomeLab setFrame:CGRectMake(320-becomeLab.frame.size.width, becomeLab.frame.origin.y, becomeLab.frame.size.width, becomeLab.frame.size.height)];
            } else {
                [becomeLab setFrame:CGRectMake(320, becomeLab.frame.origin.y, becomeLab.frame.size.width, becomeLab.frame.size.height)];
            }
        } completion:nil];
        selectedPath = indexPath;
    } else {
        [becomeLab setFrame:CGRectMake(320, becomeLab.frame.origin.y, becomeLab.frame.size.width, becomeLab.frame.size.height)];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 32;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 32)];
    if (section > 0) {
        UIView *dView = [[UIView alloc] initWithFrame:CGRectMake(20, 0, 300, 1)];
        [dView setBackgroundColor:[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.7]];
        [view addSubview:dView];
    }
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 200, 15)];
    [label setFont:[UIFont systemFontOfSize:12]];
    [label setTextColor:[UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1.0]];
    if (section == 0) {
        [label setText:@"local nudgers"];
    } else if (section == 1) {
        [label setText:@"other nudgers"];
    } else {
        [label setText:@"potential nudgers"];
    }
    [view addSubview:label];
    [view setBackgroundColor:[UIColor clearColor]];
    return view;
}

- (void)becomeNudger:(id)sender {
    UIButton *button = (UIButton *)sender;
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:selectedPath];
    QBUUser *userInfo;
    if (selectedPath.section == 0) {
        userInfo = [localNudgers objectAtIndex:selectedPath.row];
    } else if (selectedPath.section == 1) {
        userInfo = [otherNudgers objectAtIndex:selectedPath.row];
    } else {
        userInfo = [potentialNudgers objectAtIndex:selectedPath.row];
    }
    UIButton *becomeLab = [(UIButton *) cell viewWithTag:userInfo.ID];
    [UIView transitionWithView:becomeLab duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [becomeLab setFrame:CGRectMake(320, becomeLab.frame.origin.y, becomeLab.frame.size.width, becomeLab.frame.size.height)];
    } completion:nil];
    [[QBChat instance] addUserToContactListRequest:button.tag completion:^(NSError *error) {
        [self.tableView reloadData];
    }];
}

- (void) searchDone {
    if ([self.delegate respondsToSelector:@selector(onSearchDone)]) {
        [self.delegate onSearchDone];
    }
}

- (void) emptyTable {
    searchArr = nil;
    [self.tableView reloadData];
    [self.tableView setFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 0)];
}

@end
