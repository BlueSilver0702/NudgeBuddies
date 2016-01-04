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

@interface SettingController ()
{
    IBOutlet UIView *integrationView;
    IBOutlet UIView *autoNudgeView;
    IBOutlet UIView *contentView;
    IBOutlet UIView *nudgeView;
    IBOutlet UIView *responseView;
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
    [g_var saveLocalBool:g_center.isCount key:USER_NIGHT];
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
    [UIView transitionWithView:contentView duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [contentView setFrame:CGRectMake(-320, 0, contentView.frame.size.width, contentView.frame.size.height)];
    } completion:nil];
}

- (IBAction)onResponse:(id)sender {
    integrationView.hidden = YES;
    autoNudgeView.hidden   = YES;
    nudgeView.hidden = YES;
    responseView.hidden = NO;
    profileView.hidden = YES;
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

@end
