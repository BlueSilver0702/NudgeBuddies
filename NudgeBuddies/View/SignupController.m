//
//  SignupController.m
//  NudgeBuddies
//
//  Created by Xian Lee on 5/12/2015.
//  Copyright © 2015 Blue Silver. All rights reserved.
//

#import "SignupController.h"
#import "UIImagePickerHelper.h"

@interface SignupController () <UIAlertViewDelegate>
{
    IBOutlet UITextField *uname;
    IBOutlet UITextField *email;
    IBOutlet UITextField *passwd;
    IBOutlet UIButton *profileBtn;
    NSUserDefaults *userDefaults;
    UIImagePickerHelper *iPH;
    NSData *profileImgData;
    BOOL profileImgChanged;
}
@end

@implementation SignupController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    userDefaults = [NSUserDefaults standardUserDefaults];
    profileImgChanged = NO;
    [profileBtn setBackgroundImage:nil forState:UIControlStateNormal];
}

- (IBAction)onAlreadyHaveAccount:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)onPhoto:(id)sender {
    iPH = [[UIImagePickerHelper alloc] init];
    
    [iPH imagePickerInView:self WithSuccess:^(UIImage *image) {
        
        CGSize newSize = CGSizeMake(RESIZE_WIDTH, RESIZE_HEIGHT);
        UIGraphicsBeginImageContext(newSize);
        [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [profileBtn setBackgroundImage:newImage forState:UIControlStateNormal];
        profileImgChanged = YES;
        profileImgData = UIImageJPEGRepresentation(newImage, 1.0f);
        
        
    } failure:^(NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }];
}

- (IBAction)onRegister:(id)sender {
    
    QBUUser *user = [QBUUser user];
    user.login = email.text;
    user.fullName = uname.text;
    user.password = passwd.text;
    user.email = email.text;
    
    if (passwd.text.length < 8) {
        [[[UIAlertView alloc] initWithTitle:@"Warning" message:@"Account Password should be longer than 8 characters!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        return;
    }
    
    [SVProgressHUD showWithStatus:@"Registering..."];
    [QBRequest signUp:user successBlock:^(QBResponse *response, QBUUser *user) {
        // Success, do something
        if (profileImgChanged) {
            g_var.profileImg = @{@"ID":[NSString stringWithFormat:@"%lu", user.ID], @"file":profileImgData};
        } else g_var.profileImg = nil;
        
        NSLog(@"Success");
        [SVProgressHUD dismiss];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Successfully Registered!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        [userDefaults setObject:email.text forKey:@"email"];
        [userDefaults setObject:passwd.text forKey:@"pwd"];
        [userDefaults setBool:YES forKey:@"register"];
        [userDefaults synchronize];
        
    } errorBlock:^(QBResponse *response) {
        // error handling
        [SVProgressHUD dismiss];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Register Failed!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView setTag:10];
        [alertView show];
        NSLog(@"error: %@", response.error);
    }];
}

- (void (^)(QBResponse *response, QBUUser *user))successBlock
{
    return ^(QBResponse *response, QBUUser *user) {
        // Login succeeded
    };
}

- (QBRequestErrorBlock)errorBlock
{
    return ^(QBResponse *response) {
        // Handle error
    };
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag != 10)
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
