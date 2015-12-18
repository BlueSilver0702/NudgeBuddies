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
    Nudger *tUser;
    NSIndexPath *selectedPath;
}
@end

@implementation MenuController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (CGSize)createMenu:(Nudger *)nudger {
    tUser = nudger;
    if (nudger.type == NTGroup) {
        if (nudger.stream.count > 0) {
            menuType = MTGroupStream;
        } else {
            menuType = MTGroup;
        }
    } else {
        if (nudger.status == NSFriend) {
            if (nudger.stream.count > 0) {
                menuType = MTBuddyStream;
            } else {
                menuType = MTBuddy;
            }
        } else {
            menuType = MTAdd;
        }
    }
    [self.tableView setFrame:CGRectMake(0, 0, 212, self.tableView.frame.size.height)];
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
    } else if (menuType == MTBuddy || menuType == MTGroupStream) {
        return 6;
    } else if (menuType == MTBuddyStream) {
        return 7;
    } else if (menuType == MTGroup) {
        return 5;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (menuType == MTAdd) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell-add" forIndexPath:indexPath];
    } else if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell-icon" forIndexPath:indexPath];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell-btn" forIndexPath:indexPath];
    }

    UIButton *itemBtn = (UIButton *)[cell viewWithTag:1];
    UIImageView *itemLab = (UIImageView *)[cell viewWithTag:2];
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:9];
    UIButton *nudgeBtn = (UIButton *)[cell viewWithTag:3];
    UIButton *rumbleBtn = (UIButton *)[cell viewWithTag:4];
    UIButton *silentBtn = (UIButton *)[cell viewWithTag:5];
    UIButton *annoyBtn = (UIButton *)[cell viewWithTag:6];
    UIButton *addBtn = (UIButton *)[cell viewWithTag:7];
    UIButton *rejectBtn = (UIButton *)[cell viewWithTag:8];
    [nudgeBtn addTarget:self action:@selector(onResponseType:) forControlEvents:UIControlEventTouchUpInside];
    [rumbleBtn addTarget:self action:@selector(onResponseType:) forControlEvents:UIControlEventTouchUpInside];
    [silentBtn addTarget:self action:@selector(onResponseType:) forControlEvents:UIControlEventTouchUpInside];
    [annoyBtn addTarget:self action:@selector(onResponseType:) forControlEvents:UIControlEventTouchUpInside];
    [addBtn addTarget:self action:@selector(onResponseType:) forControlEvents:UIControlEventTouchUpInside];
    [rejectBtn addTarget:self action:@selector(onResponseType:) forControlEvents:UIControlEventTouchUpInside];
    if (indexPath.row == 0 && menuType == MTAdd) {
        nameLabel.text = tUser.user.fullName;
    } else if (indexPath.row == 0 && menuType != MTAdd) {
        if (tUser.response == RTNudge) [nudgeBtn setImage:[UIImage imageNamed:@"icon-nudge-active"] forState:UIControlStateNormal];
        if (tUser.response == RTRumble) [rumbleBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble-active"] forState:UIControlStateNormal];
        if (tUser.response == RTSilent) [silentBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble-silent-active"] forState:UIControlStateNormal];
        if (tUser.response == RTAnnoy) [annoyBtn setImage:[UIImage imageNamed:@"icon-nudge-annoy-active"] forState:UIControlStateNormal];
    } else if (indexPath.row == 1 && tUser.stream > 0) {
        [itemLab setHidden:YES];
        [itemBtn setTitle:@"view nudge stream" forState:UIControlStateNormal];
        [itemBtn setImage:[UIImage imageNamed:@"menu-item-stream"] forState:UIControlStateNormal];
    } else if (tUser.type == NTGroup && ((indexPath.row == 2 && tUser.stream > 0) || (indexPath.row == 1 && tUser.stream == 0))) {
        [itemLab setHidden:YES];
        [itemBtn setTitle:@"View Group" forState:UIControlStateNormal];
        [itemBtn setImage:[UIImage imageNamed:@"menu-item-group"] forState:UIControlStateNormal];
    } else if (tUser.type == NTGroup && ((indexPath.row == 3 && tUser.stream > 0) || (indexPath.row == 2 && tUser.stream == 0))) {
        [itemLab setHidden:YES];
        [itemBtn setTitle:@"block group" forState:UIControlStateNormal];
        [itemBtn setImage:[UIImage imageNamed:@"menu-item-bgroup"] forState:UIControlStateNormal];
    } else if ((indexPath.row == 4 && tUser.stream > 0) || (indexPath.row == 3 && tUser.stream == 0)) {
        [itemLab setHidden:YES];
        [itemBtn setTitle:@"silent mode" forState:UIControlStateNormal];
        [itemBtn setImage:[UIImage imageNamed:@"menu-item-silent"] forState:UIControlStateNormal];
    } else if (tUser.type == NTGroup && ((indexPath.row == 5 && tUser.stream > 0) || (indexPath.row == 4 && tUser.stream == 0))) {
        [itemLab setHidden:YES];
        [itemBtn setTitle:@"edit group" forState:UIControlStateNormal];
        [itemBtn setImage:[UIImage imageNamed:@"menu-item-edit"] forState:UIControlStateNormal];
    } else if (tUser.type == NTIndividual && ((indexPath.row == 2 && tUser.stream > 0) || (indexPath.row == 1 && tUser.stream == 0))) {
        [itemLab setHidden:YES];
        [itemBtn setTitle:@"Add to group" forState:UIControlStateNormal];
        [itemBtn setImage:[UIImage imageNamed:@"menu-item-agroup"] forState:UIControlStateNormal];
    } else if (tUser.type == NTIndividual && ((indexPath.row == 3 && tUser.stream > 0) || (indexPath.row == 2 && tUser.stream == 0))) {
        [itemLab setHidden:YES];
        [itemBtn setTitle:@"block" forState:UIControlStateNormal];
        [itemBtn setImage:[UIImage imageNamed:@"menu-item-block"] forState:UIControlStateNormal];
    } else if (tUser.type == NTIndividual && ((indexPath.row == 5 && tUser.stream > 0) || (indexPath.row == 4 && tUser.stream == 0))) {
        [itemLab setHidden:YES];
        [itemBtn setTitle:@"auto nudge" forState:UIControlStateNormal];
        [itemBtn setImage:[UIImage imageNamed:@"menu-item-auto"] forState:UIControlStateNormal];
    } else if (tUser.type == NTIndividual && ((indexPath.row == 6 && tUser.stream > 0) || (indexPath.row == 5 && tUser.stream == 0))) {
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIImageView *checkView = (UIImageView *)[cell viewWithTag:2];

    if (tUser.type == NTIndividual && indexPath.row == 1 && tUser.stream > 0) {
        [self.delegate onMenuClicked:MRStream nudger:tUser];
    } else if (tUser.type == NTGroup && indexPath.row == 1 && tUser.stream > 0) {
        [self.delegate onMenuClicked:MRStreamGroup nudger:tUser];
    } else if (tUser.type == NTGroup && ((indexPath.row == 2 && tUser.stream > 0) || (indexPath.row == 1 && tUser.stream == 0))) {
        [self.delegate onMenuClicked:MRViewGroup nudger:tUser];
    } else if (tUser.type == NTGroup && ((indexPath.row == 3 && tUser.stream > 0) || (indexPath.row == 2 && tUser.stream == 0))) {
        [self.delegate onMenuClicked:MRBlock nudger:tUser];
        if (tUser.block) {
            tUser.block = NO;
            checkView.hidden = YES;
        } else {
            tUser.block = YES;
            checkView.hidden = NO;
        }
    } else if ((indexPath.row == 4 && tUser.stream > 0) || (indexPath.row == 3 && tUser.stream == 0)) {
        [self.delegate onMenuClicked:MRSilent nudger:tUser];
        if (tUser.silent) {
            tUser.silent = NO;
            checkView.hidden = YES;
        } else {
            tUser.silent = YES;
            checkView.hidden = NO;
        }
    } else if (tUser.type == NTGroup && ((indexPath.row == 5 && tUser.stream > 0) || (indexPath.row == 4 && tUser.stream == 0))) {
        [self.delegate onMenuClicked:MREditGroup nudger:tUser];
    } else if (tUser.type == NTIndividual && ((indexPath.row == 2 && tUser.stream > 0) || (indexPath.row == 1 && tUser.stream == 0))) {
        [self.delegate onMenuClicked:MRAddGroup nudger:tUser];
    } else if (tUser.type == NTIndividual && ((indexPath.row == 3 && tUser.stream > 0) || (indexPath.row == 2 && tUser.stream == 0))) {
        [self.delegate onMenuClicked:MRBlock nudger:tUser];
        if (tUser.block) {
            tUser.block = NO;
            checkView.hidden = YES;
        } else {
            tUser.block = YES;
            checkView.hidden = NO;
        }
    } else if (tUser.type == NTIndividual && ((indexPath.row == 5 && tUser.stream > 0) || (indexPath.row == 4 && tUser.stream == 0))) {
        [self.delegate onMenuClicked:MRAuto nudger:tUser];
        if (tUser.autoNudge) {
            tUser.autoNudge = NO;
            checkView.hidden = YES;
        } else {
            tUser.autoNudge = YES;
            checkView.hidden = NO;
        }
    } else if (tUser.type == NTIndividual && ((indexPath.row == 6 && tUser.stream > 0) || (indexPath.row == 5 && tUser.stream == 0))) {
        [self.delegate onMenuClicked:MREdit nudger:tUser];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (menuType == MTAdd) {
        return 110;
    }
    return 36;
}

@end
