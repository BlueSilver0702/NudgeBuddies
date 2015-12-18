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
//    [noti1Img setHidden:YES];
//    [noti2Img setHidden:YES];
    noti1Img.alpha = 1.0;
    noti2Img.alpha = 0.0;
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
    [self.delegate onNudgeClicked:userInfo frame:CGRectMake(self.view.frame.origin.x+imgBtn.frame.origin.x, self.view.frame.origin.y+imgBtn.frame.origin.y, imgBtn.frame.size.width,imgBtn.frame.size.height)];
    [noti1Img.layer removeAllAnimations];
    [noti2Img.layer removeAllAnimations];
        noti1Img.alpha = 0.0f;
        noti2Img.alpha = 0.0f;
}

- (void)notify {
    [noti1Img setHidden:NO];
    [noti2Img setHidden:NO];
    noti2Img.alpha = 0.0f;
    [UIView animateWithDuration:1.5 delay:0 options:(UIViewAnimationOptionRepeat|UIViewAnimationOptionAutoreverse) animations:^(){
        [UIView setAnimationRepeatCount:6];
        noti2Img.alpha = 1.0f;
    } completion:^(BOOL success) {
        noti2Img.alpha = 0.0f;
        [self performSelector:@selector(removeNoti) withObject:nil afterDelay:20];
    }];
    
}

- (void)removeNoti {
    [UIView animateWithDuration:1.0 animations:^(){
        noti1Img.alpha = 0.0f;
        noti2Img.alpha = 0.0f;
    }];
}

@end
