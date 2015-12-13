//
//  UIImageCropper.h
//  GYMatch
//
//  Created by User on 12/8/14.
//  Copyright (c) 2014 xtreem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KICropImageView.h"
#import "UIImagePickerHelper.h"

@interface UIImageCropper : UIViewController {
    KICropImageView *_cropImageView;
}

@property (nonatomic, retain) UIImage *cropImg;
@property (nonatomic, retain) UIImagePickerHelper *pickerCtrl;

@end
