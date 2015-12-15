//
//  NudgeButton.m
//  NudgeBuddies
//
//  Created by Hans Adler on 14/12/15.
//  Copyright © 2015 Blue Silver. All rights reserved.
//

#import "NudgeButton.h"

@interface NudgeButton ()
{
    IBOutlet UIButton *imgBtn;
    IBOutlet UIButton *badgeBtn;
    IBOutlet UIImageView *noti1Img;
    IBOutlet UIImageView *noti2Img;
}
@end

@implementation NudgeButton

@synthesize userInfo;
- (void)viewDidLoad {
    [super viewDidLoad];
    [badgeBtn setHidden:YES];
    [noti1Img setHidden:YES];
    [noti2Img setHidden:YES];
    [imgBtn setBackgroundColor:[UIColor colorWithRed:78/255.0 green:96/255.0 blue:110/255.0 alpha:1.0]];
}

- (void)initNudge:(Nudger *)user notify:(BOOL)isNotify {
    if (user) userInfo = user;
    if (userInfo.stream.count > 0) {
        [badgeBtn setHidden:NO];
        [badgeBtn setTitle:[NSString stringWithFormat:@"%lu", userInfo.stream.count] forState:UIControlStateNormal];
    }
    [imgBtn setTitle:[userInfo getName] forState:UIControlStateNormal];
    if (userInfo.user.blobID > 0) {
        NSData *imgData = [g_var loadFile:userInfo.user.blobID];
        if (imgData) {
            [imgBtn setImage:[UIImage imageWithData:imgData] forState:UIControlStateNormal];
        } else {
            [QBRequest downloadFileWithID:userInfo.user.blobID successBlock:^(QBResponse *response, NSData *fileData) {
                [g_var saveFile:fileData uid:userInfo.user.blobID];
                [imgBtn setImage:[UIImage imageWithData:fileData] forState:UIControlStateNormal];
            } statusBlock:nil errorBlock:nil];
        }
    }
    if (isNotify) [self notify];
}

- (IBAction)onNudgeSelected:(id)sender {
    [self.delegate onNudgeClicked:userInfo index:self.index];
    [noti1Img setHidden:YES];
    [noti2Img setHidden:YES];
}

- (void)notify {
    [noti1Img setHidden:NO];
    [UIView animateWithDuration:0.5 delay:0 options:(UIViewAnimationOptionRepeat|UIViewAnimationOptionAutoreverse) animations:^(){
        [noti2Img setHidden:NO];
    } completion:^(BOOL success) {
        [self performSelector:@selector(stop) withObject:self afterDelay:5];
    }];
}

- (void)stop {
    [UIView animateWithDuration:0.5 animations:^(void){
        [noti1Img setHidden:YES];
        [noti2Img setHidden:YES];
    }];
}

@end
