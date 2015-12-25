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
    // Do any additional setup after loading the view.
    userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults boolForKey:@"remember"]) {
//        NSString *sss = [userDefaults objectForKey:@"email"];
        email.text = (NSString *)[userDefaults objectForKey:@"email"];
        passwd.text = (NSString *)[userDefaults objectForKey:@"pwd"];
        uncheckBtn.hidden = YES;
        [self onLgoin:nil];
    } else {
        uncheckBtn.hidden = NO;
    }
    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6]];
    [SVProgressHUD setForegroundColor:[UIColor colorWithRed:250/255.0 green:132/255.0 blue:64/255.0 alpha:1.0]];
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
    //    user.
    
    [QBRequest logInWithUserEmail:email.text password:passwd.text successBlock:^(QBResponse *response, QBUUser *user) {
        // Success, do something
        user.password = passwd.text;
        [g_center initCenter:user];
        [SVProgressHUD dismiss];
        if (g_var.profileImg) {
            [QBRequest TUploadFile:g_var.profileImg fileName:@"profile.jpg" contentType:@"image/jpeg" isPublic:NO successBlock:^(QBResponse *response, QBCBlob *blob) {
                [g_var saveFile:g_var.profileImg uid:blob.ID];
                QBUpdateUserParameters *updateParameters = [QBUpdateUserParameters new];
                updateParameters.blobID = blob.ID;
                [QBRequest updateCurrentUser:updateParameters successBlock:^(QBResponse *response, QBUUser *user) {
                    [self performSegueWithIdentifier:@"segue-login" sender:nil];
                    if (uncheckBtn.hidden == YES) {
                        [userDefaults setObject:email.text forKey:@"email"];
                        [userDefaults setObject:passwd.text forKey:@"pwd"];
                        [userDefaults synchronize];
                    }
                } errorBlock:^(QBResponse *response) {
                    NSLog(@"error: %@", response.error);
                }];
            } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
                // handle progress
                NSLog(@"profile status err");
            } errorBlock:^(QBResponse *response) {
                NSLog(@"error: %@", response.error);
            }];

            return;
        }
        [self performSegueWithIdentifier:@"segue-login" sender:nil];
        if (uncheckBtn.hidden == YES) {
            [userDefaults setObject:email.text forKey:@"email"];
            [userDefaults setObject:passwd.text forKey:@"pwd"];
            [userDefaults synchronize];
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

@end
