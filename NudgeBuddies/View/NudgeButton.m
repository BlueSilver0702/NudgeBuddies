//
//  NudgeButton.m
//  NudgeBuddies
//
//  Created by Hans Adler on 14/12/15.
//  Copyright © 2015 Blue Silver. All rights reserved.
//

#import "NudgeButton.h"
#import "NBTouchAndHoldButton.h"

@interface NudgeButton ()
{
    IBOutlet NBTouchAndHoldButton *imgBtn;
    IBOutlet UIButton *badgeBtn;
    IBOutlet UIImageView *noti1Img;
    IBOutlet UIImageView *noti2Img;
    IBOutlet UILabel *nameLab;
    IBOutlet UIButton *favBtn;
    BOOL isAnimating;
    BOOL isLong;
}
@end

@implementation NudgeButton

@synthesize userInfo;
- (void)viewDidLoad {
    [super viewDidLoad];
    [badgeBtn setHidden:YES];
    [noti1Img setHidden:YES];
    [noti2Img setHidden:YES];
    [favBtn setHidden:YES];
    noti1Img.alpha = 1.0;
    noti2Img.alpha = 0.0;
    isAnimating = NO;
    [imgBtn setBackgroundColor:[UIColor colorWithRed:78/255.0 green:96/255.0 blue:110/255.0 alpha:1.0]];
    [imgBtn addTarget:self action:@selector(longPress) forTouchAndHoldControlEventWithTimeInterval:0.8];
}

- (void)initNudge:(Nudger *)user notify:(BOOL)isNotify {
    if (user) userInfo = user;
    if (userInfo.stream.count > 0) {
        [badgeBtn setHidden:NO];
        [badgeBtn setTitle:[NSString stringWithFormat:@"%lu", userInfo.stream.count] forState:UIControlStateNormal];
    }
    if (userInfo.isFavorite) {
        [favBtn setHidden:NO];
        [nameLab setHidden:YES];
    }
    if (userInfo.type == NTGroup) {
        [nameLab setText:userInfo.group.gName];
        [imgBtn setTitle:[userInfo getName] forState:UIControlStateNormal];
        if (userInfo.group.gBlobID > 0) {
            NSData *imgData = [g_var loadFile:userInfo.group.gBlobID];
            if (imgData) {
                [imgBtn setImage:[UIImage imageWithData:imgData] forState:UIControlStateNormal];
            } else {
                [QBRequest downloadFileWithID:userInfo.group.gBlobID successBlock:^(QBResponse *response, NSData *fileData) {
                    [g_var saveFile:fileData uid:userInfo.group.gBlobID];
                    [imgBtn setImage:[UIImage imageWithData:fileData] forState:UIControlStateNormal];
                } statusBlock:nil errorBlock:nil];
            }
        }
    } else {
        [nameLab setText:userInfo.user.fullName];
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
    }
    
    if (user.shouldAnimate) [self notify];
    
//    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
//    [imgBtn addGestureRecognizer:longPress];
}

- (void)longPress {
    NSLog(@"Long Press");
    [self.delegate onNudgeClicked:userInfo frame:CGRectMake(self.view.frame.origin.x+imgBtn.frame.origin.x, self.view.frame.origin.y+imgBtn.frame.origin.y, imgBtn.frame.size.width,imgBtn.frame.size.height)];
    [noti1Img.layer removeAllAnimations];
    [noti2Img.layer removeAllAnimations];
    noti1Img.alpha = 0.0f;
    noti2Img.alpha = 0.0f;
    isAnimating = NO;
    isLong = YES;
}
//
//- (void)longPress:(UILongPressGestureRecognizer *)gesture {
//    if (gesture.state == UIGestureRecognizerStateEnded) {
//        NSLog(@"Long Press");
//        [self.delegate onNudgeClicked:userInfo frame:CGRectMake(self.view.frame.origin.x+imgBtn.frame.origin.x, self.view.frame.origin.y+imgBtn.frame.origin.y, imgBtn.frame.size.width,imgBtn.frame.size.height)];
//        [noti1Img.layer removeAllAnimations];
//        [noti2Img.layer removeAllAnimations];
//        noti1Img.alpha = 0.0f;
//        noti2Img.alpha = 0.0f;
//        isAnimating = NO;
//    }
//}

- (IBAction)onNudgeSelected:(id)sender {
    if (isLong) {
        isLong = NO;
        return;
    }
    NSLog(@"shortTouch");
    [self.delegate onSendNudge:userInfo];
}

- (void)notify {
    if (!isAnimating) {
        [noti1Img setHidden:NO];
        [noti2Img setHidden:NO];
        noti2Img.alpha = 0.0f;
        isAnimating = YES;
        [UIView animateWithDuration:1.5 delay:0 options:(UIViewAnimationOptionRepeat|UIViewAnimationOptionAutoreverse) animations:^(){
            [UIView setAnimationRepeatCount:6];
            noti2Img.alpha = 1.0f;
        } completion:^(BOOL success) {
            noti2Img.alpha = 0.0f;
            [self performSelector:@selector(removeNoti) withObject:nil afterDelay:20];
        }];
    }
}

- (void)removeNoti {
    [UIView animateWithDuration:1.0 animations:^(){
        noti1Img.alpha = 0.0f;
        noti2Img.alpha = 0.0f;
    }];
    userInfo.shouldAnimate = NO;
    isAnimating = NO;
}

@end
