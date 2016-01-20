//
//  SigninController.m
//  NudgeBuddies
//
//  Created by Xian Lee on 5/12/2015.
//  Copyright © 2015 Blue Silver. All rights reserved.
//

#import "SigninController.h"

@interface SigninController ()
{
    IBOutlet UITextField *email;
    IBOutlet UITextField *passwd;
    IBOutlet UIButton *uncheckBtn;
    NSUserDefaults *userDefaults;
}
@end

@implementation SigninController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//        [self initialApp];

    // Do any additional setup after loading the view.
    userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults boolForKey:@"remember"]) {
//        NSString *sss = [userDefaults objectForKey:@"email"];
        email.text = (NSString *)[userDefaults objectForKey:@"email"];
        passwd.text = (NSString *)[userDefaults objectForKey:@"pwd"];
        uncheckBtn.hidden = YES;
        [self performSegueWithIdentifier:@"segue-init" sender:nil];
//        [self onLgoin:nil];
    } else {
        uncheckBtn.hidden = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    if ([userDefaults boolForKey:@"register"]) {
        email.text = (NSString *)[userDefaults objectForKey:@"email"];
        passwd.text = (NSString *)[userDefaults objectForKey:@""];
        uncheckBtn.hidden = NO;
        [userDefaults setBool:NO forKey:@"register"];
        [userDefaults synchronize];
    }
}

- (IBAction)onLgoin:(id)sender {
    
    [SVProgressHUD showWithStatus:@"Logging in..."];
    
    [QBRequest logInWithUserEmail:email.text password:passwd.text successBlock:^(QBResponse *response, QBUUser *user) {
        // Success
        user.password = passwd.text;
        if (g_var.profileImg && [[g_var.profileImg objectForKey:@"ID"] integerValue] == user.ID) {
            [QBRequest TUploadFile:[g_var.profileImg objectForKey:@"file"] fileName:@"profile.jpg" contentType:@"image/jpeg" isPublic:NO successBlock:^(QBResponse *response, QBCBlob *blob) {
                [g_var saveFile:[g_var.profileImg objectForKey:@"file"] uid:blob.ID];
                user.blobID = blob.ID;
                [g_center initCenter:user];
                QBUpdateUserParameters *updateParameters = [QBUpdateUserParameters new];
                updateParameters.blobID = blob.ID;
                [QBRequest updateCurrentUser:updateParameters successBlock:^(QBResponse *response, QBUUser *user) {
                    [SVProgressHUD dismiss];
                    if (uncheckBtn.hidden == YES) {
                        [userDefaults setObject:email.text forKey:@"email"];
                        [userDefaults setObject:passwd.text forKey:@"pwd"];
                        [userDefaults synchronize];
                    }
                    g_var.profileImg = nil;
                    [self performSegueWithIdentifier:@"segue-norm" sender:nil];
                } errorBlock:^(QBResponse *response) {
                    NSLog(@"error: %@", response.error);
                }];
            } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
                // handle progress
                NSLog(@"profile status err");
            } errorBlock:^(QBResponse *response) {
                NSLog(@"error: %@", response.error);
            }];
        } else {
            [g_center initCenter:user];
            [SVProgressHUD dismiss];
            if (uncheckBtn.hidden == YES) {
                [userDefaults setObject:email.text forKey:@"email"];
                [userDefaults setObject:passwd.text forKey:@"pwd"];
                [userDefaults synchronize];
            }
            [self performSegueWithIdentifier:@"segue-norm" sender:nil];
        }
    } errorBlock:^(QBResponse *response) {
        // error handling
        NSLog(@"error: %@", response.error);
        [SVProgressHUD dismiss];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Login Failed!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }];
}

- (IBAction)onCheck:(id)sender {
    uncheckBtn.hidden = YES;
    [userDefaults setBool:YES forKey:@"remember"];
    [userDefaults synchronize];
}

- (IBAction)onUncheck:(id)sender {
    uncheckBtn.hidden = NO;
    [userDefaults setBool:NO forKey:@"remember"];
    [userDefaults synchronize];
}

- (IBAction)onFacebook:(id)sender {
    
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login
     logInWithReadPermissions: @[@"public_profile", @"email", @"user_friends"]
     fromViewController:self
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         if (error) {
             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"You can't change facebook account on this device." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
             [alertView show];
         } else if (result.isCancelled) {
                          [SVProgressHUD dismiss];
         } else {
             NSLog(@"Logged in");
             if ([FBSDKAccessToken currentAccessToken]) {
                 
                 [SVProgressHUD showWithStatus:@"Signing..."];
                 
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
                         
                         [QBRequest signUp:user successBlock:^(QBResponse *response, QBUUser *user) {
                             // Success, do something
                             [userDefaults setObject:user.email forKey:@"email"];
                             [userDefaults setObject:COMMON_PWD forKey:@"pwd"];
                             [userDefaults synchronize];
                             
                             [QBRequest logInWithUserEmail:user.email password:COMMON_PWD successBlock:^(QBResponse *response, QBUUser *user) {
                                 // Success, do something
                                 user.password = COMMON_PWD;
                                 [g_center initCenter:user];
                                 if ([g_var loadFile:user.blobID]) {
                                     [SVProgressHUD dismiss];
                                     [self performSegueWithIdentifier:@"segue-norm" sender:nil];
                                     [userDefaults setObject:user.email forKey:@"email"];
                                     [userDefaults setObject:COMMON_PWD forKey:@"pwd"];
                                     [userDefaults setBool:YES forKey:@"remember"];
                                     [userDefaults synchronize];
                                 } else {
                                     [QBRequest TUploadFile:imgData fileName:@"profile.jpg" contentType:@"image/jpeg" isPublic:NO successBlock:^(QBResponse *response, QBCBlob *blob) {
                                         [g_var saveFile:imgData uid:blob.ID];
                                         QBUpdateUserParameters *updateParameters = [QBUpdateUserParameters new];
                                         updateParameters.blobID = blob.ID;
                                         [QBRequest updateCurrentUser:updateParameters successBlock:^(QBResponse *response, QBUUser *user) {
                                             [SVProgressHUD dismiss];
                                             [self performSegueWithIdentifier:@"segue-norm" sender:nil];
                                             [userDefaults setObject:user.email forKey:@"email"];
                                             [userDefaults setObject:COMMON_PWD forKey:@"pwd"];
                                             [userDefaults setBool:YES forKey:@"remember"];
                                             [userDefaults synchronize];
                                         } errorBlock:^(QBResponse *response) {
                                             NSLog(@"error: %@", response.error);
                                         }];
                                     } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
                                         // handle progress
                                         NSLog(@"profile status err");
                                     } errorBlock:^(QBResponse *response) {
                                         NSLog(@"error: %@", response.error);
                                     }];
                                 }
                             } errorBlock:^(QBResponse *response) {
                                 // error handling
                                 NSLog(@"error: %@", response.error);
                                 [SVProgressHUD dismiss];
                                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Login Failed!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                 [alertView show];
                             }];
                         } errorBlock:^(QBResponse *response) {
                             // error handling
                             [QBRequest logInWithUserEmail:user.email password:COMMON_PWD successBlock:^(QBResponse *response, QBUUser *user) {
                                 // Success, do something
                                 user.password = COMMON_PWD;
                                 [g_center initCenter:user];
                                 [SVProgressHUD dismiss];
                                 [userDefaults setObject:user.email forKey:@"email"];
                                 [userDefaults setObject:COMMON_PWD forKey:@"pwd"];
                                 [userDefaults setBool:YES forKey:@"remember"];
                                 [userDefaults synchronize];
                                 [self performSegueWithIdentifier:@"segue-norm" sender:nil];
                             } errorBlock:^(QBResponse *response) {
                                 // error handling
                                 NSLog(@"error: %@", response.error);
                                 [SVProgressHUD dismiss];
                                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Login Failed!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                 [alertView show];
                             }];
                         }];
                     }
                 }];
             }

         }
     }];
}

@end
