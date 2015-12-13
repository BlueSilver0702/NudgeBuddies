//
//  UIImagePickerHelper.m
//  GYMatch
//
//  Created by Ram on 18/03/14.
//  Copyright (c) 2014 xtreem. All rights reserved.
//

#import "UIImagePickerHelper.h"
#import "UIImageCropper.h"

@implementation UIImagePickerHelper{
    UIViewController *presentingViewCtrl;
    void (^successBlock)(UIImage *);
    UIImagePickerController *sharePicker;
}

- (void)imagePickerInView:(UIViewController *)parentCtrl
              WithSuccess:(void (^)(UIImage *image))success
                  failure:(void (^)(NSError *error))failure{
    presentingViewCtrl = parentCtrl;
    successBlock = success;
    [self showActionSheetinView:parentCtrl.view];
}

- (void)showActionSheetinView:(UIView *)view{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Photo Library", nil];
    
    [actionSheet showInView:view];
}

#pragma mark - UIActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    UIImagePickerControllerSourceType sourceType;
    
    switch (buttonIndex) {
        case 0:
            sourceType = UIImagePickerControllerSourceTypeCamera;
            break;
        
        case 1:
            
            sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            break;
            
        default:
            return;
            break;
    }
    
    
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
    
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = 500.0/500.0;
    
//    if(imgRatio!=maxRatio)
    {
        if(imgRatio < maxRatio){
            imgRatio = 500.0 / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = 500.0;
        }
        else{
            imgRatio = 500.0 / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = 500.0;
        }
    }
    NSLog(@"Template:::::");
    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageCropper *cropView = [[UIImageCropper alloc] init];
    cropView.cropImg = img;
    cropView.pickerCtrl = self;
    [picker pushViewController:cropView animated:YES];

    sharePicker = picker;
}

- (void)done:(UIImage *)image {
    successBlock(image);
   [sharePicker dismissViewControllerAnimated:YES completion:nil];
}

@end
