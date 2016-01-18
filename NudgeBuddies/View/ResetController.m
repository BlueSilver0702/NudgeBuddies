//
//  ResetController.m
//  NudgeBuddies
//
//  Created by Blue Silver on 1/18/16.
//  Copyright © 2016 Blue Silver. All rights reserved.
//

#import "ResetController.h"

@interface ResetController () <UIAlertViewDelegate>
{
    IBOutlet UITextField *emailTxt;
}
@end

@implementation ResetController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)onSend:(id)sender {
    if (emailTxt.text.length > 0) {
        [QBRequest resetUserPasswordWithEmail:emailTxt.text successBlock:^(QBResponse *response) {
            // Reset was successful
            [[[UIAlertView alloc] initWithTitle:@"Your password has been reset" message:[NSString stringWithFormat:@"Your password has been reset. Please check your email %@", emailTxt.text] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        } errorBlock:^(QBResponse *response) {
            // Error
            [SVProgressHUD showErrorWithStatus:@"An error has occured!"];
        }];
    }
}

- (IBAction)onCancel:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self onCancel:nil];
}

@end
