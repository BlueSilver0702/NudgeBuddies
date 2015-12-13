//
//  SettingController.m
//  NudgeBuddies
//
//  Created by Xian Lee on 5/12/2015.
//  Copyright © 2015 Blue Silver. All rights reserved.
//

#import "SettingController.h"

@interface SettingController ()
{
    IBOutlet UIView *integrationView;
    IBOutlet UIView *autoNudgeView;
    IBOutlet UIView *contentView;
}
@end

@implementation SettingController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    integrationView.hidden = YES;
    autoNudgeView.hidden = YES;
    [contentView setFrame:CGRectMake(0, 0, contentView.frame.size.width, contentView.frame.size.height)];
}

- (IBAction)onDone:(id)sender {
    if ([self.delegate respondsToSelector:@selector(onSettingDone:)]) {
        [self.delegate onSettingDone:0];
    }
}

- (IBAction)onIntegration:(id)sender {
    integrationView.hidden = NO;
    autoNudgeView.hidden   = YES;
    [UIView transitionWithView:contentView duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [contentView setFrame:CGRectMake(-320, 0, contentView.frame.size.width, contentView.frame.size.height)];
    } completion:nil];
}

- (IBAction)onAutoNudge:(id)sender {
    integrationView.hidden = YES;
    autoNudgeView.hidden   = NO;
    [UIView transitionWithView:contentView duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [contentView setFrame:CGRectMake(-320, 0, contentView.frame.size.width, contentView.frame.size.height)];
    } completion:nil];
}

- (IBAction)onEditProfile:(id)sender {
    if ([self.delegate respondsToSelector:@selector(onSettingDone:)]) {
        [self.delegate onSettingDone:1];
    }
}

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

@end
