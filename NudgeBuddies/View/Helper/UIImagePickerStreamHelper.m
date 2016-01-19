//
//  UIImagePickerHelper.m
//  GYMatch
//
//  Created by Ram on 18/03/14.
//  Copyright (c) 2014 xtreem. All rights reserved.
//

#import "UIImagePickerStreamHelper.h"

@implementation UIImagePickerStreamHelper{
    UIViewController *presentingViewCtrl;
    void (^successBlock)(UIImage *);
    UIImagePickerController *sharePicker;
}

- (void)imagePickerInView:(UIViewController *)parentCtrl
              WithSuccess:(void (^)(UIImage *image))success
                  failure:(void (^)(NSError *error))failure{
    presentingViewCtrl = parentCtrl;
    successBlock = success;
    
    UIImagePickerControllerSourceType sourceType;
    
//            sourceType = UIImagePickerControllerSourceTypeCamera;
    sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    if (![UIImagePickerController isSourceTypeAvailable:sourceType]) {
        return;
    }
    
    UIImagePickerController *imagePC = [[UIImagePickerController alloc]init];
    [imagePC setSourceType:sourceType];
    [imagePC setDelegate:self];
    
    // Navigation bar customization
    [imagePC.navigationBar setTintColor:[UIColor whiteColor]];
    [imagePC.navigationBar setBarTintColor:[UIColor colorWithRed:51/255.0 green:53/255.0 blue:78/255.0 alpha:1.0]];
    [imagePC.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    [presentingViewCtrl presentViewController:imagePC animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    sharePicker = picker;
    [self done:image];
}

- (void)done:(UIImage *)image {
    successBlock(image);
   [sharePicker dismissViewControllerAnimated:YES completion:nil];
}

@end
