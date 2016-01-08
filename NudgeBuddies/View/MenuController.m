//
//  MenuController.m
//  NudgeBuddies
//
//  Created by Hans Adler on 13/12/15.
//  Copyright © 2015 Blue Silver. All rights reserved.
//

#import "MenuController.h"

@interface MenuController ()
{
    MenuType menuType;
    NSIndexPath *selectedPath;
}
@end

@implementation MenuController
@synthesize tUser;
- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (CGSize)createMenu:(Nudger *)nudger {
    tUser = nudger;
    
    if (nudger.status == NSInvited) {
            menuType = MTAdd;
    } else if (nudger.type == NTGroup) {
        if (tUser.unreadMsg > 0) {
            menuType = MTGroupStream;
        } else {
            menuType = MTGroup;
        }
    } else {
        if (nudger.status == NSFriend) {
            if (tUser.unreadMsg > 0) {
                menuType = MTBuddyStream;
            } else {
                menuType = MTBuddy;
            }
        }
    }
    [self.tableView setFrame:CGRectMake(0, 0, 252, self.tableView.frame.size.height)];
    [self.tableView reloadData];
    return self.tableView.contentSize;
}

- (CGSize)createSendMenu:(Nudger *)nudger {
    tUser = nudger;
    
    menuType = MTNudge;
    
    [self.tableView setFrame:CGRectMake(0, 0, 252, self.tableView.frame.size.height)];
    [self.tableView reloadData];
    return self.tableView.contentSize;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (menuType == MTAdd) {
        return 1;
    } else if (menuType == MTGroupStream || menuType == MTBuddyStream) {
        return 6;
//    } else if () {
//        return 7;
    } else if (menuType == MTBuddy || menuType == MTGroup) {
        return 5;
    } else if (menuType == MTNudge) {
        return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    if (menuType == MTNudge) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell-nudge" forIndexPath:indexPath];
        UIButton *nudgeBtn = (UIButton *)[cell viewWithTag:3];
        UIButton *rumbleBtn = (UIButton *)[cell viewWithTag:4];
        UIButton *silentBtn = (UIButton *)[cell viewWithTag:5];
        UIButton *annoyBtn = (UIButton *)[cell viewWithTag:6];
        UITextField *sendNudgeTxt = (UITextField *)[cell viewWithTag:100];
        UIButton *sendNudgeBtn = (UIButton *)[cell viewWithTag:51];
        UIButton *cancelNudgeBtn = (UIButton *)[cell viewWithTag:52];
        [sendNudgeBtn addTarget:self action:@selector(nudgeEvent:) forControlEvents:UIControlEventTouchUpInside];
        [cancelNudgeBtn addTarget:self action:@selector(nudgeEvent:) forControlEvents:UIControlEventTouchUpInside];
        
        sendNudgeTxt.text = tUser.defaultNudge;

        [nudgeBtn addTarget:self action:@selector(onResponseType:) forControlEvents:UIControlEventTouchUpInside];
        [rumbleBtn addTarget:self action:@selector(onResponseType:) forControlEvents:UIControlEventTouchUpInside];
        [silentBtn addTarget:self action:@selector(onResponseType:) forControlEvents:UIControlEventTouchUpInside];
        [annoyBtn addTarget:self action:@selector(onResponseType:) forControlEvents:UIControlEventTouchUpInside];

        if (tUser.response == RTNudge) [nudgeBtn setImage:[UIImage imageNamed:@"icon-nudge-active"] forState:UIControlStateNormal];
        else [nudgeBtn setImage:[UIImage imageNamed:@"icon-nudge"] forState:UIControlStateNormal];
        if (tUser.response == RTRumble) [rumbleBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble-active"] forState:UIControlStateNormal];
        else [rumbleBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble"] forState:UIControlStateNormal];
        if (tUser.response == RTSilent) [silentBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble-silent-active"] forState:UIControlStateNormal];
        else  [silentBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble-silent"] forState:UIControlStateNormal];
        if (tUser.response == RTAnnoy) [annoyBtn setImage:[UIImage imageNamed:@"icon-nudge-annoy-active"] forState:UIControlStateNormal];
        else [annoyBtn setImage:[UIImage imageNamed:@"icon-nudge-annoy"] forState:UIControlStateNormal];
        
        return cell;
    } else if (menuType == MTAdd) {
        if (tUser.type == NTGroup) cell = [tableView dequeueReusableCellWithIdentifier:@"cell-add-group" forIndexPath:indexPath];
        else cell = [tableView dequeueReusableCellWithIdentifier:@"cell-add" forIndexPath:indexPath];
    } else if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell-icon" forIndexPath:indexPath];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell-btn" forIndexPath:indexPath];
    }

    UIButton *itemBtn = (UIButton *)[cell viewWithTag:1];
    UIImageView *itemLab = (UIImageView *)[cell viewWithTag:2];
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:9];
    UILabel *groupLabel = (UILabel *)[cell viewWithTag:10];
    UIButton *nudgeBtn = (UIButton *)[cell viewWithTag:3];
    UIButton *rumbleBtn = (UIButton *)[cell viewWithTag:4];
    UIButton *silentBtn = (UIButton *)[cell viewWithTag:5];
    UIButton *annoyBtn = (UIButton *)[cell viewWithTag:6];
    UIButton *addBtn = (UIButton *)[cell viewWithTag:7];
    UIButton *rejectBtn = (UIButton *)[cell viewWithTag:8];
    UITextField *sendNudgeTxt = (UITextField *)[cell viewWithTag:100];
    UIButton *sendNudgeBtn = (UIButton *)[cell viewWithTag:51];
    sendNudgeBtn.layer.borderWidth = 1.0;
    sendNudgeBtn.layer.borderColor = [[UIColor colorWithRed:240/255.0 green:102/255.0 blue:48/255.0 alpha:1.0] CGColor];
    sendNudgeTxt.text = tUser.defaultNudge;
    [sendNudgeBtn addTarget:self action:@selector(nudgeEvent:) forControlEvents:UIControlEventTouchUpInside];
    [nudgeBtn addTarget:self action:@selector(onResponseType:) forControlEvents:UIControlEventTouchUpInside];
    [rumbleBtn addTarget:self action:@selector(onResponseType:) forControlEvents:UIControlEventTouchUpInside];
    [silentBtn addTarget:self action:@selector(onResponseType:) forControlEvents:UIControlEventTouchUpInside];
    [annoyBtn addTarget:self action:@selector(onResponseType:) forControlEvents:UIControlEventTouchUpInside];
    [addBtn addTarget:self action:@selector(onResponseType:) forControlEvents:UIControlEventTouchUpInside];
    [rejectBtn addTarget:self action:@selector(onResponseType:) forControlEvents:UIControlEventTouchUpInside];
    if (indexPath.row == 0 && menuType == MTAdd) {
        if (tUser.type == NTGroup) {
            nameLabel.text = tUser.group.gInviter;
            groupLabel.text = tUser.group.gName;
        } else {
            nameLabel.text = tUser.user.fullName;
        }
    } else if (indexPath.row == 0 && menuType != MTAdd) {
        if (tUser.response == RTNudge) [nudgeBtn setImage:[UIImage imageNamed:@"icon-nudge-active"] forState:UIControlStateNormal];
        else [nudgeBtn setImage:[UIImage imageNamed:@"icon-nudge"] forState:UIControlStateNormal];
        if (tUser.response == RTRumble) [rumbleBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble-active"] forState:UIControlStateNormal];
        else [rumbleBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble"] forState:UIControlStateNormal];
        if (tUser.response == RTSilent) [silentBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble-silent-active"] forState:UIControlStateNormal];
        else  [silentBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble-silent"] forState:UIControlStateNormal];
        if (tUser.response == RTAnnoy) [annoyBtn setImage:[UIImage imageNamed:@"icon-nudge-annoy-active"] forState:UIControlStateNormal];
        else [annoyBtn setImage:[UIImage imageNamed:@"icon-nudge-annoy"] forState:UIControlStateNormal];
    } else if (indexPath.row == 1 && tUser.unreadMsg > 0) {
        [itemLab setHidden:YES];
        [itemBtn setTitle:@"view nudge stream" forState:UIControlStateNormal];
        [itemBtn setImage:[UIImage imageNamed:@"menu-item-stream"] forState:UIControlStateNormal];
    } else if (tUser.type == NTGroup && ((indexPath.row == 2 && tUser.unreadMsg > 0) || (indexPath.row == 1 && tUser.unreadMsg == 0))) {
        [itemLab setHidden:YES];
        [itemBtn setTitle:@"View Group" forState:UIControlStateNormal];
        [itemBtn setImage:[UIImage imageNamed:@"menu-item-group"] forState:UIControlStateNormal];
    } else if (tUser.type == NTGroup && ((indexPath.row == 3 && tUser.unreadMsg > 0) || (indexPath.row == 2 && tUser.unreadMsg == 0))) {
        if (tUser.block) [itemLab setHidden:NO];
        else [itemLab setHidden:YES];
        [itemBtn setTitle:@"block group" forState:UIControlStateNormal];
        [itemBtn setImage:[UIImage imageNamed:@"menu-item-gblock"] forState:UIControlStateNormal];
    } else if ((indexPath.row == 4 && tUser.unreadMsg > 0) || (indexPath.row == 3 && tUser.unreadMsg == 0)) {
        if (tUser.silent) [itemLab setHidden:NO];
        else [itemLab setHidden:YES];
        [itemBtn setTitle:@"silent mode" forState:UIControlStateNormal];
        [itemBtn setImage:[UIImage imageNamed:@"menu-item-silent"] forState:UIControlStateNormal];
    } else if (tUser.type == NTGroup && ((indexPath.row == 5 && tUser.unreadMsg > 0) || (indexPath.row == 4 && tUser.unreadMsg == 0))) {
        [itemLab setHidden:YES];
        [itemBtn setTitle:@"edit group" forState:UIControlStateNormal];
        [itemBtn setImage:[UIImage imageNamed:@"menu-item-edit"] forState:UIControlStateNormal];
    } else if (tUser.type == NTIndividual && ((indexPath.row == 2 && tUser.unreadMsg > 0) || (indexPath.row == 1 && tUser.unreadMsg == 0))) {
        [itemLab setHidden:YES];
        [itemBtn setTitle:@"Add to group" forState:UIControlStateNormal];
        [itemBtn setImage:[UIImage imageNamed:@"menu-item-agroup"] forState:UIControlStateNormal];
    } else if (tUser.type == NTIndividual && ((indexPath.row == 3 && tUser.unreadMsg > 0) || (indexPath.row == 2 && tUser.unreadMsg == 0))) {
        if (tUser.block) [itemLab setHidden:NO];
        else [itemLab setHidden:YES];
        [itemBtn setTitle:@"block" forState:UIControlStateNormal];
        [itemBtn setImage:[UIImage imageNamed:@"menu-item-block"] forState:UIControlStateNormal];
//    } else if (tUser.type == NTIndividual && ((indexPath.row == 5 && tUser.unreadMsg > 0) || (indexPath.row == 4 && tUser.unreadMsg == 0))) {
//        [itemLab setHidden:YES];
//        [itemBtn setTitle:@"auto nudge" forState:UIControlStateNormal];
//        [itemBtn setImage:[UIImage imageNamed:@"menu-item-auto"] forState:UIControlStateNormal];
    } else if (tUser.type == NTIndividual && ((indexPath.row == 5 && tUser.unreadMsg > 0) || (indexPath.row == 4 && tUser.unreadMsg == 0))) {
        [itemLab setHidden:YES];
        [itemBtn setTitle:@"edit profile" forState:UIControlStateNormal];
        [itemBtn setImage:[UIImage imageNamed:@"menu-item-edit"] forState:UIControlStateNormal];
    }
    return cell;
}

- (void)onResponseType:(id)sender {
    UIButton *senderBtn = (UIButton *)sender;
    if (menuType == MTAdd) {
        if (senderBtn.tag == 7) {
            [self.delegate onMenuClicked:MRAdd nudger:tUser];
        } else {
            [self.delegate onMenuClicked:MRReject nudger:tUser];
        }
        return;
    }
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    UIButton *nudgeBtn = (UIButton *)[cell viewWithTag:3];
    UIButton *rumbleBtn = (UIButton *)[cell viewWithTag:4];
    UIButton *silentBtn = (UIButton *)[cell viewWithTag:5];
    UIButton *annoyBtn = (UIButton *)[cell viewWithTag:6];
    if (senderBtn.tag == 3) {
        tUser.response = RTNudge;
        [nudgeBtn setImage:[UIImage imageNamed:@"icon-nudge-active"] forState:UIControlStateNormal];
        [rumbleBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble"] forState:UIControlStateNormal];
        [silentBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble-silent"] forState:UIControlStateNormal];
        [annoyBtn setImage:[UIImage imageNamed:@"icon-nudge-annoy"] forState:UIControlStateNormal];
        [self.delegate onMenuClicked:MRNudge nudger:tUser];
    } else if (senderBtn.tag == 4) {
        tUser.response = RTRumble;
        [nudgeBtn setImage:[UIImage imageNamed:@"icon-nudge"] forState:UIControlStateNormal];
        [rumbleBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble-active"] forState:UIControlStateNormal];
        [silentBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble-silent"] forState:UIControlStateNormal];
        [annoyBtn setImage:[UIImage imageNamed:@"icon-nudge-annoy"] forState:UIControlStateNormal];
        [self.delegate onMenuClicked:MRRumble nudger:tUser];
    } else if (senderBtn.tag == 5) {
        tUser.response = RTSilent;
        [nudgeBtn setImage:[UIImage imageNamed:@"icon-nudge"] forState:UIControlStateNormal];
        [rumbleBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble"] forState:UIControlStateNormal];
        [silentBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble-silent-active"] forState:UIControlStateNormal];
        [annoyBtn setImage:[UIImage imageNamed:@"icon-nudge-annoy"] forState:UIControlStateNormal];
        [self.delegate onMenuClicked:MRSilent nudger:tUser];
    } else if (senderBtn.tag == 6) {
        tUser.response = RTAnnoy;
        [nudgeBtn setImage:[UIImage imageNamed:@"icon-nudge"] forState:UIControlStateNormal];
        [rumbleBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble"] forState:UIControlStateNormal];
        [silentBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble-silent"] forState:UIControlStateNormal];
        [annoyBtn setImage:[UIImage imageNamed:@"icon-nudge-annoy-active"] forState:UIControlStateNormal];
        [self.delegate onMenuClicked:MRAnnoy nudger:tUser];
    } else {
        [nudgeBtn setImage:[UIImage imageNamed:@"icon-nudge"] forState:UIControlStateNormal];
        [rumbleBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble"] forState:UIControlStateNormal];
        [silentBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble-silent"] forState:UIControlStateNormal];
        [annoyBtn setImage:[UIImage imageNamed:@"icon-nudge-annoy"] forState:UIControlStateNormal];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (menuType == MTNudge) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        return;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIImageView *checkView = (UIImageView *)[cell viewWithTag:2];

    if (tUser.type == NTIndividual && indexPath.row == 1 && tUser.unreadMsg > 0) {
        [self.delegate onMenuClicked:MRStream nudger:tUser];
    } else if (tUser.type == NTGroup && indexPath.row == 1 && tUser.unreadMsg > 0) {
        [self.delegate onMenuClicked:MRStreamGroup nudger:tUser];
    } else if (tUser.type == NTGroup && ((indexPath.row == 2 && tUser.unreadMsg > 0) || (indexPath.row == 1 && tUser.unreadMsg == 0))) {
        [self.delegate onMenuClicked:MRViewGroup nudger:tUser];
    } else if (tUser.type == NTGroup && ((indexPath.row == 3 && tUser.unreadMsg > 0) || (indexPath.row == 2 && tUser.unreadMsg == 0))) {
        if (tUser.block) {
            tUser.block = NO;
            checkView.hidden = YES;
        } else {
            tUser.block = YES;
            checkView.hidden = NO;
        }
        [self.delegate onMenuClicked:MRBlock nudger:tUser];
    } else if ((indexPath.row == 4 && tUser.unreadMsg > 0) || (indexPath.row == 3 && tUser.unreadMsg == 0)) {
        if (tUser.silent) {
            tUser.silent = NO;
            checkView.hidden = YES;
        } else {
            tUser.silent = YES;
            checkView.hidden = NO;
        }
        [self.delegate onMenuClicked:MRSilent nudger:tUser];
    } else if (tUser.type == NTGroup && ((indexPath.row == 5 && tUser.unreadMsg > 0) || (indexPath.row == 4 && tUser.unreadMsg == 0))) {
        [self.delegate onMenuClicked:MREditGroup nudger:tUser];
    } else if (tUser.type == NTIndividual && ((indexPath.row == 2 && tUser.unreadMsg > 0) || (indexPath.row == 1 && tUser.unreadMsg == 0))) {
        [self.delegate onMenuClicked:MRAddGroup nudger:tUser];
    } else if (tUser.type == NTIndividual && ((indexPath.row == 3 && tUser.unreadMsg > 0) || (indexPath.row == 2 && tUser.unreadMsg == 0))) {
        if (tUser.block) {
            tUser.block = NO;
            checkView.hidden = YES;
        } else {
            tUser.block = YES;
            checkView.hidden = NO;
        }
        [self.delegate onMenuClicked:MRBlock nudger:tUser];
//    } else if (tUser.type == NTIndividual && ((indexPath.row == 5 && tUser.unreadMsg > 0) || (indexPath.row == 4 && tUser.unreadMsg == 0))) {
//        if (tUser.autoNudge) {
//            tUser.autoNudge = NO;
//            checkView.hidden = YES;
//        } else {
//            tUser.autoNudge = YES;
//            checkView.hidden = NO;
//        }
//        [self.delegate onMenuClicked:MRAuto nudger:tUser];
    } else if (tUser.type == NTIndividual && ((indexPath.row == 5 && tUser.unreadMsg > 0) || (indexPath.row == 4 && tUser.unreadMsg == 0))) {
        [self.delegate onMenuClicked:MREdit nudger:tUser];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (menuType == MTAdd) {
        return 120;
    } else if (menuType == MTNudge) {
        return 140;
    } else if (indexPath.row == 0) {
        return 72;
    }
    return 36;
}

- (void)nudgeEvent:(UIButton *)sender {
    if (sender.tag == 51) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        UITextField *sendNudgeTxt = (UITextField *)[cell viewWithTag:100];
        [sendNudgeTxt resignFirstResponder];
        tUser.defaultNudge = sendNudgeTxt.text;
        [self.delegate onMenuNudged:tUser];
    } else {
        [self.delegate onMenuNudged:nil];
    }
}

@end
