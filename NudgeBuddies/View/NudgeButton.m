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
    [imgBtn addTarget:self action:@selector(longPress) forTouchAndHoldControlEventWithTimeInterval:1.0];
}

- (void)initNudge:(Nudger *)user {
    if (user) userInfo = user;
    if (userInfo.unreadMsg > 0) {
        [badgeBtn setHidden:NO];
        [badgeBtn setTitle:[NSString stringWithFormat:@"%lu", userInfo.unreadMsg] forState:UIControlStateNormal];
    }
    if (userInfo.isFavorite) {
        [favBtn setHidden:NO];
        [nameLab setHidden:YES];
        
        if (!g_center.isCount) {
            if (user.favCount > 0) {
                [favBtn setTitle:[NSString stringWithFormat:@"%lu", user.favCount] forState:UIControlStateNormal];
            } else [favBtn setTitle:@"1" forState:UIControlStateNormal];
        } else {
            [favBtn setTitle:@"" forState:UIControlStateNormal];
        }
    }
    if (userInfo.type == NTGroup) {
        [nameLab setText:userInfo.group.gName];
        [imgBtn setBackgroundImage:[UIImage imageNamed:@"user-group"] forState:UIControlStateNormal];
        [imgBtn setTitle:@"" forState:UIControlStateNormal];
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
    
    if (user.isNew) {
        noti1Img.hidden = NO;
        noti1Img.alpha = 1.0f;
    }
    
    if (user.shouldAnimate) [self notify];
    
    if (user.isFavorite) {
        CGFloat addVal = user.favCount*50/4092.0;
        if (addVal > 50.0) {
            addVal = 50.0;
        }
        [self.view setFrame:CGRectMake(self.view.frame.origin.x-addVal/2.0, self.view.frame.origin.y-addVal/2.0, self.view.frame.size.width + addVal, self.view.frame.size.height + addVal)];
        imgBtn.layer.cornerRadius = self.view.frame.size.width / 4.0;
        favBtn.frame = CGRectMake(favBtn.frame.origin.x, imgBtn.frame.origin.y+imgBtn.frame.size.height-4, favBtn.frame.size.width, favBtn.frame.size.height);
    }
    
//    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
//    [imgBtn addGestureRecognizer:longPress];
}

- (void)longPress {
    NSLog(@"Long Press");
    [imgBtn invalidTime];
    [self.delegate onNudgeClicked:userInfo frame:CGRectMake(self.view.frame.origin.x+imgBtn.frame.origin.x, self.view.frame.origin.y+imgBtn.frame.origin.y, imgBtn.frame.size.width,imgBtn.frame.size.height)];
//    [noti1Img.layer removeAllAnimations];
//    [noti2Img.layer removeAllAnimations];
//    noti1Img.alpha = 0.0f;
//    noti2Img.alpha = 0.0f;
//    isAnimating = NO;
    isLong = YES;
}

- (IBAction)onNudgeSelected:(id)sender {
    if (userInfo.status == NSInvited && !isLong) {
        [self longPress];
//        userInfo.isNew = NO;
        userInfo.shouldAnimate = NO;
        NSLog(@"shortTouch");
        return;
    }
    
//    [noti1Img.layer removeAllAnimations];
//    [noti2Img.layer removeAllAnimations];
//    noti1Img.alpha = 0.0f;
//    noti2Img.alpha = 0.0f;
//    isAnimating = NO;
    
    if (isLong) {
        isLong = NO;
        return;
    }
    
    [self.delegate onSendNudge:userInfo frame:CGRectMake(self.view.frame.origin.x+imgBtn.frame.origin.x, self.view.frame.origin.y+imgBtn.frame.origin.y, imgBtn.frame.size.width,imgBtn.frame.size.height)];
    NSLog(@"shortTouch");
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
            userInfo.shouldAnimate = NO;
//            [self performSelector:@selector(removeNoti) withObject:nil afterDelay:20];
        }];
    }
}

- (IBAction)onFavTouch:(id)sender {
    [self.delegate onFavClicked:userInfo];
}

- (void)removeFav {
    [favBtn removeFromSuperview];
    [nameLab setHidden:YES];
}

- (void)removeNudgeCount {
    [favBtn setTitle:@"" forState:UIControlStateNormal];
}

- (void)removeNoti {
    [UIView animateWithDuration:1.0 animations:^(){
        noti1Img.alpha = 0.0f;
        noti2Img.alpha = 0.0f;
    }];
    userInfo.shouldAnimate = NO;
    isAnimating = NO;
}

- (void)addFav {
    favBtn.hidden = NO;
}

- (void)addNudgeCount {
    [favBtn setTitle:[NSString stringWithFormat:@"%lu", userInfo.favCount] forState:UIControlStateNormal];
}

@end
