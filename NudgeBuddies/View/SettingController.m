//
//  SettingController.m
//  NudgeBuddies
//
//  Created by Xian Lee on 5/12/2015.
//  Copyright © 2015 Blue Silver. All rights reserved.
//

#import "SettingController.h"
#import "UIImagePickerHelper.h"
#import "ViewController.h"
#import "AlertCtrl.h"
#import "DownPicker.h"

@interface SettingController () //<UIDatePickerDelegate>
{
    IBOutlet UIView *integrationView;
    IBOutlet UIView *autoNudgeView;
    IBOutlet UIView *contentView;
    IBOutlet UIView *nudgeView;
    IBOutlet UIView *responseView;
    IBOutlet UIView *nightView;
    IBOutlet UIView *profileView;
    IBOutlet UISwitch *nightSwitch;
    IBOutlet UISwitch *removeCountSwitch;
    IBOutlet UIButton *nudgeBtn1;
    IBOutlet UIButton *nudgeBtn2;
    IBOutlet UIButton *nudgeBtn3;
    IBOutlet UIButton *responseBtn1;
    IBOutlet UIButton *responseBtn2;
    IBOutlet UIButton *responseBtn3;
    IBOutlet UITextField *nudgeTxt;
    IBOutlet UITextField *nudgeDropTxt;
    IBOutlet UITextField *responseTxt;
    IBOutlet UISwitch *facebookSwitch;
    IBOutlet UISwitch *instagramSwitch;
    IBOutlet UISwitch *twitterSwitch;
    IBOutlet UIButton *profileBtn;
    IBOutlet UILabel *profileLab;
    IBOutlet UITextField *profilePwdTxt;
    IBOutlet UITextField *profileEmailTxt;
    
    UIImagePickerHelper *iPH;
    NSData *profileImgData;
    BOOL profilePictureUpdate;
    
    DownPicker *downPicker;
    BOOL isFrom;
    IBOutlet UIButton *nightFromBtn;
    IBOutlet UIButton *nightToBtn;
    IBOutlet UIDatePicker *nightDatePicker;
    
    IBOutlet UILabel *nightFromLab;
    IBOutlet UILabel *nightToLab;
}
@end

@implementation SettingController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    integrationView.hidden = YES;
    autoNudgeView.hidden = YES;
    nudgeView.hidden = YES;
    responseView.hidden = YES;
    profileView.hidden = YES;
    nightView.hidden = YES;
    [contentView setFrame:CGRectMake(0, 0, contentView.frame.size.width, contentView.frame.size.height)];
    
    [nightSwitch addTarget:self action:@selector(nightChanged:) forControlEvents:UIControlEventValueChanged];
    [removeCountSwitch addTarget:self action:@selector(countChanged:) forControlEvents:UIControlEventValueChanged];
    
    if ([g_var loadLocalBool:USER_NIGHT]) {
        [nightSwitch setOn:YES];
    } else {
        [nightSwitch setOn:NO];
    }

    if ([g_var loadLocalBool:USER_COUNT]) {
        [removeCountSwitch setOn:YES];
    } else {
        [removeCountSwitch setOn:NO];
    }
    
    if ([g_var loadLocalDate:USER_NIGHT_FROM] == nil) {
        NSDateComponents *comps = [[NSCalendar currentCalendar] components:(NSCalendarUnitHour|NSCalendarUnitMinute) fromDate:[NSDate new]];
        [comps setHour:22];
        [comps setMinute:0];
        NSDate *fromDate = [[NSCalendar currentCalendar] dateFromComponents:comps];
        [g_var saveLocalDate:fromDate key:USER_NIGHT_FROM];
        [comps setHour:7];
        NSDate *toDate = [[NSCalendar currentCalendar] dateFromComponents:comps];
        [g_var saveLocalDate:toDate key:USER_NIGHT_TO];
    }
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"h:mm a"];
    
    nightFromLab.text = [dateFormatter stringFromDate:[g_var loadLocalDate:USER_NIGHT_FROM]];
    nightToLab.text = [dateFormatter stringFromDate:[g_var loadLocalDate:USER_NIGHT_TO]];
    [nightFromBtn setTitle:nightFromLab.text forState:UIControlStateNormal];
    [nightToBtn setTitle:nightToLab.text forState:UIControlStateNormal];
    [nightDatePicker setDate:[g_var loadLocalDate:USER_NIGHT_FROM]];
    [nightDatePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)nightChanged:(UISwitch *)switchState {
    if ([switchState isOn]) {
        g_center.isNight = YES;
    } else {
        g_center.isNight = NO;
    }
    [g_var saveLocalBool:g_center.isNight key:USER_NIGHT];
    [self.delegate onSettingUpdate];
}

- (void)countChanged:(UISwitch *)switchState {
    if ([switchState isOn]) {
        g_center.isCount = YES;
    } else {
        g_center.isCount = NO;
    }
    [g_var saveLocalBool:g_center.isCount key:USER_COUNT];
//    [self.delegate onSettingCountHide:YES];
    [self.delegate onSettingUpdate];
}

- (IBAction)onDone:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(onSettingDone:)]) {
        [self.delegate onSettingDone:0];
    }
    [contentView setFrame:CGRectMake(0, 0, contentView.frame.size.width, contentView.frame.size.height)];
}

- (IBAction)onIntegration:(id)sender {
    integrationView.hidden = NO;
    autoNudgeView.hidden   = YES;
    nudgeView.hidden = YES;
    responseView.hidden = YES;
    profileView.hidden = YES;
    nightView.hidden = YES;
    [UIView transitionWithView:contentView duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [contentView setFrame:CGRectMake(-320, 0, contentView.frame.size.width, contentView.frame.size.height)];
    } completion:nil];
}

- (IBAction)onAutoNudge:(id)sender {
    integrationView.hidden = YES;
    autoNudgeView.hidden   = NO;
    nudgeView.hidden = YES;
    responseView.hidden = YES;
    profileView.hidden = YES;
    nightView.hidden = YES;
    [UIView transitionWithView:contentView duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [contentView setFrame:CGRectMake(-320, 0, contentView.frame.size.width, contentView.frame.size.height)];
    } completion:nil];
}

- (IBAction)onNudge:(id)sender {
    integrationView.hidden = YES;
    autoNudgeView.hidden   = YES;
    nudgeView.hidden = NO;
    responseView.hidden = YES;
    profileView.hidden = YES;
    nightView.hidden = YES;
    [UIView transitionWithView:contentView duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [contentView setFrame:CGRectMake(-320, 0, contentView.frame.size.width, contentView.frame.size.height)];
    } completion:nil];
    
    [self setAcademies:[AlertCtrl initWithAlerts]];
    [downPicker setValueAtIndex:g_center.currentNudger.alertSound];
    [downPicker addTarget:self
                   action:@selector(dp_Selected:)
         forControlEvents:UIControlEventValueChanged];
}

- (IBAction)onResponse:(id)sender {
    integrationView.hidden = YES;
    autoNudgeView.hidden   = YES;
    nudgeView.hidden = YES;
    responseView.hidden = NO;
    profileView.hidden = YES;
    nightView.hidden = YES;
    [UIView transitionWithView:contentView duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [contentView setFrame:CGRectMake(-320, 0, contentView.frame.size.width, contentView.frame.size.height)];
    } completion:nil];
}

- (IBAction)onNight:(id)sender {
    integrationView.hidden = YES;
    autoNudgeView.hidden   = YES;
    nudgeView.hidden = YES;
    responseView.hidden = YES;
    profileView.hidden = YES;
    nightView.hidden = NO;
    
    isFrom = YES;
    
    [nightFromBtn setBackgroundColor:[UIColor colorWithRed:170/255.0 green:170/255.0 blue:170/255.0 alpha:.62]];
    [nightToBtn setBackgroundColor:[UIColor whiteColor]];

    [UIView transitionWithView:contentView duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [contentView setFrame:CGRectMake(-320, 0, contentView.frame.size.width, contentView.frame.size.height)];
    } completion:nil];
}

- (IBAction)onProfile:(id)sender {
    integrationView.hidden = YES;
    autoNudgeView.hidden   = YES;
    nudgeView.hidden = YES;
    responseView.hidden = YES;
    profileView.hidden = NO;
    nightView.hidden = YES;
    [UIView transitionWithView:contentView duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [contentView setFrame:CGRectMake(-320, 0, contentView.frame.size.width, contentView.frame.size.height)];
    } completion:nil];
    profileLab.text = g_center.currentUser.fullName;
    profileEmailTxt.text = g_center.currentUser.email;
    [profileEmailTxt setEnabled:NO];
    profilePwdTxt.text = g_center.currentUser.password;
    
    NSData *picData = [g_var loadFile:g_center.currentUser.blobID];
    if (picData) {
        [profileBtn setBackgroundImage:[UIImage imageWithData:picData] forState:UIControlStateNormal];
    } else if (g_center.currentUser.blobID) {
        [QBRequest downloadFileWithID:g_center.currentUser.blobID successBlock:^(QBResponse *response, NSData *fileData) {
            [g_var saveFile:fileData uid:g_center.currentUser.blobID];
            UIImage *img = [UIImage imageWithData:fileData];
            [profileBtn setBackgroundImage:img forState:UIControlStateNormal];
            NSLog(@"profile loaded");
        } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
            // handle progress
        } errorBlock:^(QBResponse *response) {
        }];
    }
}

- (IBAction)onProfileSave:(id)sender {
    [SVProgressHUD show];
    if (profilePictureUpdate) {
        [QBRequest TUploadFile:g_var.profileImg fileName:@"profile.jpg" contentType:@"image/jpeg" isPublic:NO successBlock:^(QBResponse *response, QBCBlob *blob) {
            [g_var saveFile:g_var.profileImg uid:blob.ID];
            QBUpdateUserParameters *updateParameters = [QBUpdateUserParameters new];
            updateParameters.blobID = blob.ID;
            updateParameters.oldPassword = g_center.currentUser.password;
            updateParameters.password = profilePwdTxt.text;
            [QBRequest updateCurrentUser:updateParameters successBlock:^(QBResponse *response, QBUUser *user) {
                [SVProgressHUD dismiss];
                [g_var saveLocalStr:updateParameters.password key:@"pwd"];
                g_center.currentUser.blobID = blob.ID;
                g_center.currentUser.password = profilePwdTxt.text;
                [self onDone:nil];
            } errorBlock:^(QBResponse *response) {
                [SVProgressHUD showErrorWithStatus:@"Failed to save your profile info"];
            }];
        } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
            // handle progress
            NSLog(@"profile status err");
        } errorBlock:^(QBResponse *response) {
            [SVProgressHUD showErrorWithStatus:@"Failed to save your profile info"];
        }];
    } else {
        QBUpdateUserParameters *updateParameters = [QBUpdateUserParameters new];
        updateParameters.oldPassword = g_center.currentUser.password;
        updateParameters.password = profilePwdTxt.text;
        [QBRequest updateCurrentUser:updateParameters successBlock:^(QBResponse *response, QBUUser *user) {
            // User updated successfully
            NSLog(@"%@", user);
            [SVProgressHUD dismiss];
            [self onDone:nil];
        } errorBlock:^(QBResponse *response) {
            [SVProgressHUD showErrorWithStatus:@"Failed to save your profile info"];
        }];
    }
}

- (IBAction)onNudgeSetted:(id)sender {
    
}

//- (IBAction)onEditProfile:(id)sender {
//    if ([self.delegate respondsToSelector:@selector(onSettingDone:)]) {
//        [self.delegate onSettingDone:1];
//    }
//}

- (IBAction)onBack:(id)sender {
    NSLog(@"onBack");
    [UIView transitionWithView:contentView duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [contentView setFrame:CGRectMake(0, 0, contentView.frame.size.width, contentView.frame.size.height)];
    } completion:nil];
}

- (void) initView:(BOOL) night {
    if (night) {
        integrationView.hidden = YES;
        autoNudgeView.hidden   = NO;
        [contentView setFrame:CGRectMake(-320, 0, contentView.frame.size.width, contentView.frame.size.height)];
        return;
    }
    [contentView setFrame:CGRectMake(0, 0, contentView.frame.size.width, contentView.frame.size.height)];
}

- (IBAction)onPhoto:(id)sender {
    ViewController *vc = (ViewController *)self.parentViewController;
    iPH = [[UIImagePickerHelper alloc] init];
    [iPH imagePickerInView:vc WithSuccess:^(UIImage *image) {
        CGSize newSize = CGSizeMake(RESIZE_WIDTH, RESIZE_HEIGHT);
        UIGraphicsBeginImageContext(newSize);
        [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [profileBtn setBackgroundImage:newImage forState:UIControlStateNormal];
        profileImgData = UIImageJPEGRepresentation(newImage, 1.0f);
        g_var.profileImg = profileImgData;
        profilePictureUpdate = YES;
    } failure:^(NSError *error) {
        //[self error:err_later];
    }];
}

- (void)setAcademies:(NSArray *)academyArr
{
    if (g_center.currentNudger.alertSound > 0) {
        NSDictionary *alertDic = [[AlertCtrl initWithAlerts] objectAtIndex:g_center.currentNudger.alertSound];
        [downPicker setText:alertDic[@"name"]];
    }
    
    downPicker = [[DownPicker alloc] initWithTextField:nudgeDropTxt];
    [downPicker setPlaceholder:@"Select Alert Sound."];
    NSArray *sortArr = [academyArr linq_sort:^id(NSDictionary* academy) {
        return academy[@"name"];
    }];
    
    NSArray *titleArr = [sortArr linq_select:^id(NSDictionary *dic) {
        return dic[@"name"];
    }];
    
    [downPicker setData:titleArr];
}

-(void)dp_Selected:(id)dp {
    g_center.currentNudger.alertSound = downPicker.selectedIndex;
    [g_var saveLocalVal:g_center.currentNudger.alertSound key:USER_ALERT];
}

- (IBAction)dismissKey:(id)sender
{
    [(UITextField *)sender resignFirstResponder];
}

- (IBAction)onPickerBtn:(id)sender {
    UIButton *button = (UIButton *)sender;
    
    if (button.tag == 2) {
        [nightToBtn setBackgroundColor:[UIColor colorWithRed:170/255.0 green:170/255.0 blue:170/255.0 alpha:.62]];
        [nightFromBtn setBackgroundColor:[UIColor whiteColor]];
        isFrom = NO;
        [nightDatePicker setDate:[g_var loadLocalDate:USER_NIGHT_TO]];
    } else {
        [nightFromBtn setBackgroundColor:[UIColor colorWithRed:170/255.0 green:170/255.0 blue:170/255.0 alpha:.62]];
        [nightToBtn setBackgroundColor:[UIColor whiteColor]];
        isFrom = YES;
        [nightDatePicker setDate:[g_var loadLocalDate:USER_NIGHT_FROM]];
    }
}

- (void)dateChanged:(id)sender {
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"h:mm a"];
    if (isFrom) {
        [g_var saveLocalDate:nightDatePicker.date key:USER_NIGHT_FROM];
        nightFromLab.text = [dateFormatter stringFromDate:[g_var loadLocalDate:USER_NIGHT_FROM]];
        [nightFromBtn setTitle:nightFromLab.text forState:UIControlStateNormal];
    } else {
        [g_var saveLocalDate:nightDatePicker.date key:USER_NIGHT_TO];
        nightToLab.text = [dateFormatter stringFromDate:[g_var loadLocalDate:USER_NIGHT_TO]];
        [nightToBtn setTitle:nightToLab.text forState:UIControlStateNormal];
    }
}

@end
