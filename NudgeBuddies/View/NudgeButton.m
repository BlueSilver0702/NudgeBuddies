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
    Nudger *userInfo;
}
@end

@implementation NudgeButton

- (void)viewDidLoad {
    [super viewDidLoad];
    [badgeBtn setHidden:YES];
    [noti1Img setHidden:YES];
    [noti2Img setHidden:YES];
    [imgBtn setBackgroundColor:[UIColor colorWithRed:78/255.0 green:96/255.0 blue:110/255.0 alpha:1.0]];
}

- (void)initNudge:(Nudger *)user {
    userInfo = user;
    if (userInfo.stream.count > 0) {
        [badgeBtn setHidden:NO];
        [badgeBtn setTitle:[NSString stringWithFormat:@"%lu", userInfo.stream.count] forState:UIControlStateNormal];
    }
    [imgBtn setTitle:[userInfo getName] forState:UIControlStateNormal];
    if (userInfo.user.blobID > 0) {
        [QBRequest downloadFileWithID:userInfo.user.blobID successBlock:^(QBResponse *response, NSData *fileData) {
            [imgBtn setImage:[UIImage imageWithData:fileData] forState:UIControlStateNormal];
        } statusBlock:nil errorBlock:nil];
    }
    [self notify];
}

- (IBAction)onNudgeSelected:(id)sender {
    [self.delegate onNudgeClicked:userInfo];
    [noti1Img setHidden:YES];
    [noti2Img setHidden:YES];
}

- (void)notify {
    
}

@end
