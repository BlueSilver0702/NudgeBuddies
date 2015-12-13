//
//  UIImageCropper.m
//  GYMatch
//
//  Created by User on 12/8/14.
//  Copyright (c) 2014 xtreem. All rights reserved.
//

#import "UIImageCropper.h"

@interface UIImageCropper ()

@end

@implementation UIImageCropper

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"hahahahah");
    // Do any additional setup after loading the view.
    
    _cropImageView = [[KICropImageView alloc] initWithFrame:self.view.bounds];
    [_cropImageView setCropSize:CGSizeMake(200, 200)];
    [_cropImageView setImage:self.cropImg];
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:_cropImageView];
    
    self.navigationItem.title = @"Scale & Crop";
    
    UIBarButtonItem *btnSave = [[UIBarButtonItem alloc]
                                initWithTitle:@"Crop"
                                style:UIBarButtonItemStyleDone
                                target:self
                                action:@selector(aa)];
    
    self.navigationItem.rightBarButtonItem = btnSave;
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    UIImageView *imTouchView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"touch1"]];
    imTouchView.frame = CGRectMake(self.view.frame.size.width-110.0f, self.view.frame.size.height-125.0f, 120.0f, 135.0f);
    [self.view addSubview:imTouchView];
    imTouchView.alpha = 0.0f;
    
    [UIView animateWithDuration:1.0
        delay:0.8
        options:UIViewAnimationCurveEaseIn
        animations:^{
            imTouchView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:3.0
            delay:3
            options:UIViewAnimationCurveEaseOut
            animations:^{
            imTouchView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            
        }];
    }];
}

- (void)aa {
    
    UIImage *img = [_cropImageView cropImage];

    [self.pickerCtrl done:img];

//    NSData *data = UIImagePNGRepresentation([_cropImageView cropImage]);
//    [data writeToFile:[NSString stringWithFormat:@"%@/Documents/test.png", NSHomeDirectory()] atomically:YES];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
