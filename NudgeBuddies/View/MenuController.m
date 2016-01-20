//
//  MenuController.m
//  NudgeBuddies
//
//  Created by Hans Adler on 13/12/15.
//  Copyright © 2015 Blue Silver. All rights reserved.
//

#import "MenuController.h"
#import "UIImagePickerStreamHelper.h"

@interface MenuController ()
{
    MenuType menuType;
    NSIndexPath *selectedPath;
    UIImagePickerStreamHelper *iPHStream;
    BOOL isAttached;
    NSData *attachData;
    NSString *attachString;
}
@end

@implementation MenuController
@synthesize tUser;
- (void)viewDidLoad {
    [super viewDidLoad];
    iPHStream = [[UIImagePickerStreamHelper alloc] init];
}

- (CGSize)createMenu:(Nudger *)nudger {
    tUser = nudger;
    isAttached = NO;
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
    isAttached = NO;
    menuType = MTNudge;
    
    [self.tableView setFrame:CGRectMake(0, 0, 252, self.tableView.frame.size.height)];
    [self.tableView reloadData];
    return self.tableView.contentSize;
}

- (CGSize)createNudgedMenu:(Nudger *)nudger {
    tUser = nudger;
    isAttached = NO;
    menuType = MTNudged;
    
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

- (void)customizeTxt:(UITextField *)textField {
    NSLog(@"all are selected");
//    [textField becomeFirstResponder];
    UITextRange *range = [textField textRangeFromPosition:textField.beginningOfDocument toPosition:textField.endOfDocument];
//    [textField setSelectedTextRange:range];
//
//    [textField selectAll:nil];
    textField.selectedTextRange = range;
    [textField performSelector:@selector(selectAll:) withObject:nil afterDelay:0.0];
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
        [sendNudgeTxt addTarget:self action:@selector(customizeTxt:) forControlEvents:UIControlEventEditingDidBegin];
        UIButton *sendNudgeBtn = (UIButton *)[cell viewWithTag:51];
        UIButton *cancelNudgeBtn = (UIButton *)[cell viewWithTag:52];
        [sendNudgeBtn addTarget:self action:@selector(nudgeEvent:) forControlEvents:UIControlEventTouchUpInside];
        [cancelNudgeBtn addTarget:self action:@selector(nudgeEvent:) forControlEvents:UIControlEventTouchUpInside];
        
        sendNudgeTxt.text = @"";//tUser.defaultNudge;

        [nudgeBtn addTarget:self action:@selector(onResponseType:) forControlEvents:UIControlEventTouchUpInside];
        [rumbleBtn addTarget:self action:@selector(onResponseType:) forControlEvents:UIControlEventTouchUpInside];
        [silentBtn addTarget:self action:@selector(onResponseType:) forControlEvents:UIControlEventTouchUpInside];
        [annoyBtn addTarget:self action:@selector(onResponseType:) forControlEvents:UIControlEventTouchUpInside];

        switch (tUser.response) {
            case RTNudge:
                [nudgeBtn setImage:[UIImage imageNamed:@"icon-nudge-active"] forState:UIControlStateNormal];
                [rumbleBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble"] forState:UIControlStateNormal];
                [silentBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble-silent"] forState:UIControlStateNormal];
                [annoyBtn setImage:[UIImage imageNamed:@"icon-nudge-annoy"] forState:UIControlStateNormal];
                break;
            case RTRumble:
                [nudgeBtn setImage:[UIImage imageNamed:@"icon-nudge"] forState:UIControlStateNormal];
                [rumbleBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble-active"] forState:UIControlStateNormal];
                [silentBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble-silent"] forState:UIControlStateNormal];
                [annoyBtn setImage:[UIImage imageNamed:@"icon-nudge-annoy"] forState:UIControlStateNormal];
                break;
            case RTSilent:
                [nudgeBtn setImage:[UIImage imageNamed:@"icon-nudge"] forState:UIControlStateNormal];
                [rumbleBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble"] forState:UIControlStateNormal];
                [silentBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble-silent-active"] forState:UIControlStateNormal];
                [annoyBtn setImage:[UIImage imageNamed:@"icon-nudge-annoy"] forState:UIControlStateNormal];
                break;
            case RTAnnoy:
                [nudgeBtn setImage:[UIImage imageNamed:@"icon-nudge-active"] forState:UIControlStateNormal];
                [rumbleBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble"] forState:UIControlStateNormal];
                [silentBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble-silent"] forState:UIControlStateNormal];
                [annoyBtn setImage:[UIImage imageNamed:@"icon-nudge-annoy-active"] forState:UIControlStateNormal];
                break;
            case RTAnnoyRumble:
                [nudgeBtn setImage:[UIImage imageNamed:@"icon-nudge"] forState:UIControlStateNormal];
                [rumbleBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble-active"] forState:UIControlStateNormal];
                [silentBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble-silent"] forState:UIControlStateNormal];
                [annoyBtn setImage:[UIImage imageNamed:@"icon-nudge-annoy-active"] forState:UIControlStateNormal];
                break;
            case RTAnnoySilent:
                [nudgeBtn setImage:[UIImage imageNamed:@"icon-nudge"] forState:UIControlStateNormal];
                [rumbleBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble"] forState:UIControlStateNormal];
                [silentBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble-silent-active"] forState:UIControlStateNormal];
                [annoyBtn setImage:[UIImage imageNamed:@"icon-nudge-annoy-active"] forState:UIControlStateNormal];
                break;
            default:
                break;
        }
        
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
    UIButton *picNudgeBtn = (UIButton *)[cell viewWithTag:53];
    
    sendNudgeBtn.layer.borderWidth = 1.0;
    sendNudgeBtn.layer.borderColor = [[UIColor colorWithRed:240/255.0 green:102/255.0 blue:48/255.0 alpha:1.0] CGColor];
    sendNudgeTxt.text = @"";//tUser.defaultNudge;
    [sendNudgeTxt addTarget:self action:@selector(customizeTxt:) forControlEvents:UIControlEventEditingDidBegin];
    [sendNudgeBtn addTarget:self action:@selector(nudgeEvent:) forControlEvents:UIControlEventTouchUpInside];
    [picNudgeBtn addTarget:self action:@selector(picEvent:) forControlEvents:UIControlEventTouchUpInside];
    [nudgeBtn addTarget:self action:@selector(onResponseType:) forControlEvents:UIControlEventTouchUpInside];
    [rumbleBtn addTarget:self action:@selector(onResponseType:) forControlEvents:UIControlEventTouchUpInside];
    [silentBtn addTarget:self action:@selector(onResponseType:) forControlEvents:UIControlEventTouchUpInside];
    [annoyBtn addTarget:self action:@selector(onResponseType:) forControlEvents:UIControlEventTouchUpInside];
    [addBtn addTarget:self action:@selector(onResponseType:) forControlEvents:UIControlEventTouchUpInside];
    [rejectBtn addTarget:self action:@selector(onResponseType:) forControlEvents:UIControlEventTouchUpInside];
    
    if (!isAttached) {
        UIImageView *imageView = (UIImageView *)[cell viewWithTag:54];
        UIView *container2 = [cell viewWithTag:55];
        if (container2 != nil) {
            [imageView setImage:nil];
            [container2 setFrame:CGRectMake(container2.frame.origin.x, container2.frame.origin.y, container2.frame.size.width, 54)];
            [imageView setFrame:CGRectMake(container2.frame.size.width - 172 - 8, imageView.frame.origin.y, 172, 0)];
        }
    }
    
    if (indexPath.row == 0 && menuType == MTAdd) {
        if (tUser.type == NTGroup) {
            nameLabel.text = tUser.group.gInviter;
            groupLabel.text = tUser.group.gName;
        } else {
            nameLabel.text = tUser.user.fullName;
        }
    } else if (indexPath.row == 0 && menuType != MTAdd) {
        switch (tUser.response) {
            case RTNudge:
                [nudgeBtn setImage:[UIImage imageNamed:@"icon-nudge-active"] forState:UIControlStateNormal];
                [rumbleBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble"] forState:UIControlStateNormal];
                [silentBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble-silent"] forState:UIControlStateNormal];
                [annoyBtn setImage:[UIImage imageNamed:@"icon-nudge-annoy"] forState:UIControlStateNormal];
                break;
            case RTRumble:
                [nudgeBtn setImage:[UIImage imageNamed:@"icon-nudge"] forState:UIControlStateNormal];
                [rumbleBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble-active"] forState:UIControlStateNormal];
                [silentBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble-silent"] forState:UIControlStateNormal];
                [annoyBtn setImage:[UIImage imageNamed:@"icon-nudge-annoy"] forState:UIControlStateNormal];
                break;
            case RTSilent:
                [nudgeBtn setImage:[UIImage imageNamed:@"icon-nudge"] forState:UIControlStateNormal];
                [rumbleBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble"] forState:UIControlStateNormal];
                [silentBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble-silent-active"] forState:UIControlStateNormal];
                [annoyBtn setImage:[UIImage imageNamed:@"icon-nudge-annoy"] forState:UIControlStateNormal];
                break;
            case RTAnnoy:
                [nudgeBtn setImage:[UIImage imageNamed:@"icon-nudge-active"] forState:UIControlStateNormal];
                [rumbleBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble"] forState:UIControlStateNormal];
                [silentBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble-silent"] forState:UIControlStateNormal];
                [annoyBtn setImage:[UIImage imageNamed:@"icon-nudge-annoy-active"] forState:UIControlStateNormal];
                break;
            case RTAnnoyRumble:
                [nudgeBtn setImage:[UIImage imageNamed:@"icon-nudge"] forState:UIControlStateNormal];
                [rumbleBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble-active"] forState:UIControlStateNormal];
                [silentBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble-silent"] forState:UIControlStateNormal];
                [annoyBtn setImage:[UIImage imageNamed:@"icon-nudge-annoy-active"] forState:UIControlStateNormal];
                break;
            case RTAnnoySilent:
                [nudgeBtn setImage:[UIImage imageNamed:@"icon-nudge"] forState:UIControlStateNormal];
                [rumbleBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble"] forState:UIControlStateNormal];
                [silentBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble-silent-active"] forState:UIControlStateNormal];
                [annoyBtn setImage:[UIImage imageNamed:@"icon-nudge-annoy-active"] forState:UIControlStateNormal];
                break;
            default:
                break;
        }
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
        if (tUser.response == RTNudge || tUser.response == RTNil) {
            tUser.response = RTAnnoy;
            [nudgeBtn setImage:[UIImage imageNamed:@"icon-nudge-active"] forState:UIControlStateNormal];
            [rumbleBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble"] forState:UIControlStateNormal];
            [silentBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble-silent"] forState:UIControlStateNormal];
            [annoyBtn setImage:[UIImage imageNamed:@"icon-nudge-annoy-active"] forState:UIControlStateNormal];
            [self.delegate onMenuClicked:MRAnnoy nudger:tUser];
        } else if (tUser.response == RTRumble) {
            tUser.response = RTAnnoyRumble;
            [nudgeBtn setImage:[UIImage imageNamed:@"icon-nudge"] forState:UIControlStateNormal];
            [rumbleBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble-active"] forState:UIControlStateNormal];
            [silentBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble-silent"] forState:UIControlStateNormal];
            [annoyBtn setImage:[UIImage imageNamed:@"icon-nudge-annoy-active"] forState:UIControlStateNormal];
            [self.delegate onMenuClicked:MRAnnoyRumble nudger:tUser];
        } else if (tUser.response == RTSilent) {
            tUser.response = RTAnnoySilent;
            [nudgeBtn setImage:[UIImage imageNamed:@"icon-nudge"] forState:UIControlStateNormal];
            [rumbleBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble"] forState:UIControlStateNormal];
            [silentBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble-silent-active"] forState:UIControlStateNormal];
            [annoyBtn setImage:[UIImage imageNamed:@"icon-nudge-annoy-active"] forState:UIControlStateNormal];
            [self.delegate onMenuClicked:MRAnnoySilent nudger:tUser];
        } else {
            if (tUser.response == RTAnnoyRumble) {
                [self.delegate onMenuClicked:MRAnnoyRumble nudger:tUser];
            } else if (tUser.response == RTAnnoySilent) {
                [self.delegate onMenuClicked:MRAnnoySilent nudger:tUser];
            } else {
                [self.delegate onMenuClicked:MRAnnoy nudger:tUser];
            }
        }
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
    } else if (menuType == MTNudged) {
        return 160;
    } else if (indexPath.row == 0) {
        if (isAttached) return 200;
        return 100;
    }
    return 36;
}

- (void)nudgeEvent:(UIButton *)sender {
    if (sender.tag == 51) {
        [SVProgressHUD show];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        UITextField *sendNudgeTxt = (UITextField *)[cell viewWithTag:100];
        [sendNudgeTxt resignFirstResponder];
        if (isAttached) {
            UIImageView *imageView = (UIImageView *)[cell viewWithTag:54];
            NSData *imageData = UIImageJPEGRepresentation(imageView.image, 1.0f);
            
            [g_center sendMessage:tUser txt:sendNudgeTxt.text attachment:imageData success:^(QBChatMessage *success) {
                [SVProgressHUD dismiss];
                [self.delegate onMenuNudged:nil];
            }];
        } else {
            [g_center sendMessage:tUser txt:sendNudgeTxt.text success:^(QBChatMessage *success) {
                [SVProgressHUD dismiss];
                [self.delegate onMenuNudged:nil];
            }];
        }
//        tUser.defaultNudge = sendNudgeTxt.text;
//        [self.delegate onMenuNudged:tUser];
    } else {
        [self.delegate onMenuNudged:nil];
    }
}

- (void)picEvent:(UIButton *)sender {
    [iPHStream imagePickerInView:self WithSuccess:^(UIImage *image) {
        CGFloat imgSize = 130.0;
        isAttached = YES;

        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        UIImageView *imageView = (UIImageView *)[cell viewWithTag:54];
        UITextField *nudgeTxt = (UITextField *)[cell viewWithTag:100];
        NSString *nudgeStr = nudgeTxt.text;
        UIView *container2 = [cell viewWithTag:55];
//        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView reloadData];
        [nudgeTxt setText:nudgeStr];
        float actualHeight = image.size.height;
        float actualWidth = image.size.width;
        float imgRatio = actualWidth/actualHeight;
        
        actualHeight = imgSize;
        actualWidth = imgSize*imgRatio;
        
        if (actualWidth > 165) actualWidth = 165;
        
        CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
        UIGraphicsBeginImageContext(rect.size);
        [image drawInRect:rect];
        UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        
        [imageView setImage:img];
        
        [container2 setFrame:CGRectMake(container2.frame.origin.x, container2.frame.origin.y, container2.frame.size.width, actualHeight + 35)];
        [imageView setFrame:CGRectMake(container2.frame.size.width - actualWidth - 8, imageView.frame.origin.y, actualWidth, imgSize)];
        
//        [self.tableView setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.tableView.contentSize.height)];
//        [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.tableView.contentSize.height)];
        [self.delegate onMenuUpdated:self.tableView.contentSize.height];
        
    } failure:^(NSError *error) {
    }];
}

@end