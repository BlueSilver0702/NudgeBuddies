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
}
@end

@implementation SignupController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    userDefaults = [NSUserDefaults standardUserDefaults];
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
        
        profileImgData = UIImageJPEGRepresentation(newImage, 1.0f);
        g_var.profileImg = profileImgData;
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
    
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [HUD setMode:MBProgressHUDModeIndeterminate];
    [HUD setDetailsLabelText:@"Registering..."];
    [HUD show:YES];
    [QBRequest signUp:user successBlock:^(QBResponse *response, QBUUser *user) {
        // Success, do something
        NSLog(@"Success");
        [HUD hide:YES];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Successfully Registered!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        [userDefaults setObject:email.text forKey:@"email"];
        [userDefaults setObject:passwd.text forKey:@"pwd"];
        [userDefaults setBool:YES forKey:@"register"];
        [userDefaults synchronize];
    } errorBlock:^(QBResponse *response) {
        // error handling
        [HUD hide:YES];
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

- (IBAction)onFacebook:(id)sender {
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [HUD setMode:MBProgressHUDModeIndeterminate];
    //    [HUD setLabelText:@"Registering..."];
    [HUD setDetailsLabelText:@"Signing..."];
    [HUD show:YES];
    
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login
     logInWithReadPermissions: @[@"public_profile", @"email", @"user_friends"]
     fromViewController:self
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         if (error) {
             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"You can't change facebook account on this device." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
             [alertView show];
         } else if (result.isCancelled) {
             [HUD hide:YES];
         } else {
             NSLog(@"Logged in");
             if ([FBSDKAccessToken currentAccessToken]) {
                 [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{ @"fields" : [NSString stringWithFormat:@"id,name,email,picture.width(%d).height(%d)", RESIZE_WIDTH, RESIZE_HEIGHT]}]startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                     if (!error) {
                         NSString *imageStringOfLoginUser = [[[result valueForKey:@"picture"] valueForKey:@"data"] valueForKey:@"url"];
                         NSURL *url = [NSURL URLWithString:imageStringOfLoginUser];
                         NSData *imgData = [NSData dataWithContentsOfURL:url];
                         
                         QBUUser *user = [QBUUser user];
                         user.login = [result valueForKey:@"id"];
                         user.fullName = [result valueForKey:@"name"];
                         user.password = COMMON_PWD;
                         user.email = [result valueForKey:@"email"];
                         user.facebookID = [result valueForKey:@"id"];
                         
                         g_var.profileImg = imgData;
                         
                         [QBRequest signUp:user successBlock:^(QBResponse *response, QBUUser *user) {
                             // Success, do something
                             [userDefaults setObject:user.email forKey:@"email"];
                             [userDefaults setObject:COMMON_PWD forKey:@"pwd"];
                             [userDefaults synchronize];
                             
                             [QBRequest logInWithUserEmail:user.email password:COMMON_PWD successBlock:^(QBResponse *response, QBUUser *user) {
                                 // Success, do something
                                 user.password = COMMON_PWD;
                                 [g_center initCenter:user];
                                 [QBRequest TUploadFile:g_var.profileImg fileName:@"profile.jpg" contentType:@"image/jpeg" isPublic:NO successBlock:^(QBResponse *response, QBCBlob *blob) {
                                     [g_var saveFile:g_var.profileImg uid:blob.ID];
                                     QBUpdateUserParameters *updateParameters = [QBUpdateUserParameters new];
                                     updateParameters.blobID = blob.ID;
                                     [QBRequest updateCurrentUser:updateParameters successBlock:^(QBResponse *response, QBUUser *user) {
                                         [HUD hide:YES];
                                         [self performSegueWithIdentifier:@"segue-register" sender:nil];
                                     } errorBlock:^(QBResponse *response) {
                                         NSLog(@"error: %@", response.error);
                                     }];
                                 } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
                                     // handle progress
                                     NSLog(@"profile status err");
                                 } errorBlock:^(QBResponse *response) {
                                     NSLog(@"error: %@", response.error);
                                 }];
                                 
                                 //[self performSegueWithIdentifier:@"segue-register" sender:nil];
                             } errorBlock:^(QBResponse *response) {
                                 // error handling
                                 NSLog(@"error: %@", response.error);
                                 [HUD hide:YES];
                                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Login Failed!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                 [alertView show];
                             }];
                         } errorBlock:^(QBResponse *response) {
                             // error handling
                             [QBRequest logInWithUserEmail:user.email password:COMMON_PWD successBlock:^(QBResponse *response, QBUUser *user) {
                                 // Success, do something
                                 user.password = COMMON_PWD;
                                 [g_center initCenter:user];
                                 [HUD hide:YES];
                                 [self performSegueWithIdentifier:@"segue-register" sender:nil];
                             } errorBlock:^(QBResponse *response) {
                                 // error handling
                                 NSLog(@"error: %@", response.error);
                                 [HUD hide:YES];
                                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Login Failed!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                 [alertView show];
                             }];
                         }];
                     }
                 }];
             }
//             [QBRequest logInWithSocialProvider:@"facebook" accessToken:[[FBSDKAccessToken currentAccessToken] tokenString] accessTokenSecret:nil successBlock:^(QBResponse *response, QBUUser *user) {
//                 [self performSegueWithIdentifier:@"segue-register" sender:nil];
//             } errorBlock:^(QBResponse *response) {
//                 NSLog(@"Response error1: %@", response.error);
//                 //[self performSegueWithIdentifier:@"segue-register" sender:nil];
//             }];
         }
     }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag != 10)
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
