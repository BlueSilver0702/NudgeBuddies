//
//  UIImagePickerHelper.h
//  GYMatch
//
//  Created by Ram on 18/03/14.
//  Copyright (c) 2014 xtreem. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImagePickerHelper : NSObject <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate>

- (void)imagePickerInView:(UIViewController *)parentCtrl
              WithSuccess:(void (^)(UIImage *image))success
                  failure:(void (^)(NSError *error))failure;

- (void)done:(UIImage *)image;

@end
