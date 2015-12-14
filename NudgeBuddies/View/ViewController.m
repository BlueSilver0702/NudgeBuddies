//
//  ViewController.m
//  NudgeBuddies
//
//  Created by Xian Lee on 3/12/2015.
//  Copyright © 2015 Blue Silver. All rights reserved.
//

#import "ViewController.h"
#import "SettingController.h"
#import "SearchController.h"
#import <iAd/iAd.h>
#import <CoreMotion/CoreMotion.h>
#import "UIImagePickerHelper.h"
#import "NotificationCenter.h"

@interface ViewController () <SettingControllerDelegate, SearchControllerDelegate, ADBannerViewDelegate, UITextFieldDelegate, QBChatDelegate>
{
    // general
    QBUUser *currentUser;
    NotificationCenter *center;
    
    // nudgebuddies
    IBOutlet UIScrollView *nudgebuddiesBar;
    
    // group pages
    IBOutlet UIView *autoView;
    IBOutlet UIView *groupView;
    
    // favorite page
    CGRect rectFav1, rectFav2, rectFav3, rectFav4, rectFav5;
    CMMotionManager *motionManager;
    IBOutlet UIView *user1;
    IBOutlet UIView *user2;
    IBOutlet UIView *user3;
    IBOutlet UIView *user4;
    IBOutlet UIView *user5;
    
    // setting page
    SettingController *settingCtrl;
    IBOutlet UIView *settingView;
    
    // iAD page
    ADBannerView *bannerView;
    
    // search page
    SearchController *searchCtrl;
    IBOutlet UIView *searchView;
    IBOutlet UIButton *searchDoneButton;
    IBOutlet UITextField *searchBox;
    
    // profile page
    IBOutlet UIView *profileView;
    UIImagePickerHelper *iPH;
    NSData *profileImgData;
    IBOutlet UIButton *profileBtn;
    IBOutlet UILabel *uname;
    IBOutlet UITextField *email;
    IBOutlet UITextField *passwd;
    BOOL profilePictureUpdate;
    
    // add nudgers page
    IBOutlet UIView *addView;
    
    // menus module
    IBOutlet UIView *menuView;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    currentUser = g_var.currentUser;
    // **********  nudgebuddies horizontal scroll  ************
    [nudgebuddiesBar setContentSize: CGSizeMake(nudgebuddiesBar.frame.size.width*1.3, nudgebuddiesBar.frame.size.height)];
    int width = nudgebuddiesBar.frame.size.height;
    UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(14, 0, width, width)];
    button1.backgroundColor = [UIColor colorWithRed:78/255.0 green:96/255.0 blue:110/255.0 alpha:1.0];
    button1.layer.cornerRadius = width/2.0;
    button1.layer.masksToBounds = YES;
    [button1 setImage:[UIImage imageNamed:@"user-5"] forState:UIControlStateNormal];
    
    UIButton *button2 = [[UIButton alloc] initWithFrame:CGRectMake(button1.frame.origin.x+70, 0, width, width)];
    button2.backgroundColor = [UIColor colorWithRed:78/255.0 green:96/255.0 blue:110/255.0 alpha:1.0];
    button2.layer.cornerRadius = width/2.0;
    button2.layer.masksToBounds = YES;
    [button2 setImage:[UIImage imageNamed:@"user-4"] forState:UIControlStateNormal];

    UIButton *button3 = [[UIButton alloc] initWithFrame:CGRectMake(button2.frame.origin.x+70, 0, width, width)];
    button3.backgroundColor = [UIColor colorWithRed:78/255.0 green:96/255.0 blue:110/255.0 alpha:1.0];
    button3.layer.cornerRadius = width/2.0;
    button3.layer.masksToBounds = YES;
    [button3 setTitle:@"WP" forState:UIControlStateNormal];
    [button3 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    UIButton *button4 = [[UIButton alloc] initWithFrame:CGRectMake(button3.frame.origin.x+70, 0, width, width)];
    button4.backgroundColor = [UIColor colorWithRed:78/255.0 green:96/255.0 blue:110/255.0 alpha:1.0];
    button4.layer.cornerRadius = width/2.0;
    button4.layer.masksToBounds = YES;
    [button4 setImage:[UIImage imageNamed:@"user-3"] forState:UIControlStateNormal];

    UIButton *button5 = [[UIButton alloc] initWithFrame:CGRectMake(button4.frame.origin.x+70, 0, width, width)];
    button5.backgroundColor = [UIColor colorWithRed:78/255.0 green:96/255.0 blue:110/255.0 alpha:1.0];
    button5.layer.cornerRadius = width/2.0;
    button5.layer.masksToBounds = YES;
    [button5 setTitle:@"WP" forState:UIControlStateNormal];
    [button5 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [nudgebuddiesBar addSubview:button1];
    [nudgebuddiesBar addSubview:button2];
    [nudgebuddiesBar addSubview:button3];
    [nudgebuddiesBar addSubview:button4];
    [nudgebuddiesBar addSubview:button5];
    
    // **********  setting page  ************
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    settingCtrl = (SettingController *)[mainStoryboard instantiateViewControllerWithIdentifier: @"settingCtrl"];
    [self addChildViewController:settingCtrl];
    [settingView addSubview:settingCtrl.view];
    [settingView setFrame:CGRectMake(0, settingView.frame.size.height*(-1), settingView.frame.size.width, settingView.frame.size.height)];
    settingCtrl.delegate = self;
    
    // **********  iAD module  ************
    bannerView = [[ADBannerView alloc]initWithFrame:
                  CGRectMake(0, 518, 320, 50)];
    // Optional to set background color to clear color
    [bannerView setBackgroundColor:[UIColor clearColor]];
//    [self.view addSubview: bannerView];
//    [self performSelector:@selector(removeIAD) withObject:nil afterDelay:15];
    
    // **********  search module  ************
    searchDoneButton.hidden = YES;
    searchView.hidden = YES;
    addView.hidden = YES;
    [searchBox addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    searchCtrl = (SearchController *)[mainStoryboard instantiateViewControllerWithIdentifier: @"searchCtrl"];
    [self addChildViewController:searchCtrl];
    [searchView addSubview:searchCtrl.view];
    searchCtrl.delegate = self;
    int tableSize = [searchCtrl searchResult:@""];
    if (tableSize > 320) {
        [searchView setFrame:CGRectMake(searchView.frame.origin.x, searchView.frame.origin.y, searchView.frame.size.width, 320)];
    } else {
        [searchView setFrame:CGRectMake(searchView.frame.origin.x, searchView.frame.origin.y, searchView.frame.size.width, tableSize)];
    }
    // **********  group module  ************
    groupView.hidden = YES;
    profileView.hidden = YES;
    autoView.hidden = YES;
    // **********  favorite module  ************
    rectFav1 = user1.frame;
    rectFav2 = user2.frame;
    rectFav3 = user3.frame;
    rectFav4 = user4.frame;
    rectFav5 = user5.frame;
    motionManager = [CMMotionManager new];
    motionManager.accelerometerUpdateInterval = .05;
    motionManager.gyroUpdateInterval = .05;
    [motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
        [self outputAccelerometer:accelerometerData.acceleration];
        if (error) {
            NSLog(@"%@", error);
        }
    }];
    
    // **********  profile module  ************
    NSData *profileData = [g_var loadFile:g_var.currentUser.ID];
    uname.text = g_var.currentUser.fullName;
    email.text = g_var.currentUser.email;
    [email setEnabled:NO];
    passwd.text = g_var.currentUser.password;
    if (profileData) {
        [profileBtn setBackgroundImage:[UIImage imageWithData:profileData] forState:UIControlStateNormal];
    } else {
        [QBRequest downloadFileWithID:g_var.currentUser.blobID successBlock:^(QBResponse *response, NSData *fileData) {
            UIImage *img = [UIImage imageWithData:fileData];
            [profileBtn setBackgroundImage:img forState:UIControlStateNormal];
            NSLog(@"profile loaded");
        } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
            // handle progress
        } errorBlock:^(QBResponse *response) {
            NSLog(@"error: %@", response.error);
        }];
    }
    
    // **********  chat module  ************
    [[QBChat instance] connectWithUser:g_var.currentUser  completion:^(NSError *error) {
        if (error) {
            [[[UIAlertView alloc] initWithTitle:@"Couldn't connect to chat" message:[NSString stringWithFormat:@"%@", error.description] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        }
    }];
}

#pragma mark - Menu
///// --------- Menu Views ----------- /////////////////////////////////////////////////////////////////////////

#pragma mark - profile
///// --------- edit profile ----------- /////////////////////////////////////////////////////////////////////////
- (IBAction)onPhoto:(id)sender {
    iPH = [[UIImagePickerHelper alloc] init];
    [iPH imagePickerInView:self WithSuccess:^(UIImage *image) {
        CGSize newSize = CGSizeMake(RESIZE_WIDTH, RESIZE_HEIGHT);
        UIGraphicsBeginImageContext(newSize);
        [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [profileBtn setBackgroundImage:newImage forState:UIControlStateNormal];
        profileImgData = UIImagePNGRepresentation(newImage);
        g_var.profileImg = profileImgData;
        profilePictureUpdate = YES;
    } failure:^(NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }];
}

- (IBAction)onProfileSave:(id)sender {
    [[MBProgressHUD showHUDAddedTo:self.view animated:YES] show:YES];
    if (profilePictureUpdate) {
        [QBRequest TUploadFile:g_var.profileImg fileName:@"profile.png" contentType:@"image/png" isPublic:NO successBlock:^(QBResponse *response, QBCBlob *blob) {
            [g_var saveFile:g_var.profileImg uid:g_var.currentUser.ID];
            QBUpdateUserParameters *updateParameters = [QBUpdateUserParameters new];
            updateParameters.blobID = blob.ID;
            updateParameters.oldPassword = currentUser.password;
            updateParameters.password = passwd.text;
            [QBRequest updateCurrentUser:updateParameters successBlock:^(QBResponse *response, QBUUser *user) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [self onProfileClose:nil];
            } errorBlock:^(QBResponse *response) {
                NSLog(@"error: %@", response.error);
                [[[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"%@", response.error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            }];
        } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
            // handle progress
            NSLog(@"profile status err");
        } errorBlock:^(QBResponse *response) {
            NSLog(@"error: %@", response.error);
            [[[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"%@", response.error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        }];
    } else {
        QBUpdateUserParameters *updateParameters = [QBUpdateUserParameters new];
        updateParameters.oldPassword = currentUser.password;
        updateParameters.password = passwd.text;
        [QBRequest updateCurrentUser:updateParameters successBlock:^(QBResponse *response, QBUUser *user) {
            // User updated successfully
            NSLog(@"%@", user);
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [self onProfileClose:nil];
        } errorBlock:^(QBResponse *response) {
            // Handle error
            [[[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"%@", response.error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        }];
    }
}

- (IBAction)onProfileClose:(id)sender {
    [UIView transitionWithView:profileView duration:0.1 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        profileView.hidden = YES;
    } completion:nil];
}

#pragma mark - favorite
///// --------- favorite views ----------- /////////////////////////////////////////////////////////////////////////
- (void)outputAccelerometer:(CMAcceleration)acceleration {

    [UIView transitionWithView:user1 duration:.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [user1 setFrame:CGRectMake(rectFav1.origin.x+acceleration.x*10, rectFav1.origin.y+acceleration.y*10, rectFav1.size.width, rectFav1.size.height)];
    } completion:nil];
    [UIView transitionWithView:user2 duration:.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [user2 setFrame:CGRectMake(rectFav2.origin.x+acceleration.x*20*0.8, rectFav2.origin.y+acceleration.y*20*0.9, rectFav2.size.width, rectFav2.size.height)];
    } completion:nil];
    [UIView transitionWithView:user3 duration:.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [user3 setFrame:CGRectMake(rectFav3.origin.x-acceleration.x*20*0.9, rectFav3.origin.y+acceleration.y*20*0.8, rectFav3.size.width, rectFav3.size.height)];
    } completion:nil];
    [UIView transitionWithView:user4 duration:.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [user4 setFrame:CGRectMake(rectFav4.origin.x-acceleration.x*30*0.5, rectFav4.origin.y+acceleration.y*30*0.86, rectFav4.size.width, rectFav4.size.height)];
    } completion:nil];
    [UIView transitionWithView:user5 duration:.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [user5 setFrame:CGRectMake(rectFav5.origin.x-acceleration.x*30*0.86, rectFav5.origin.y-acceleration.y*30*0.5, rectFav5.size.width, rectFav5.size.height)];
    } completion:nil];
}

#pragma mark - setting
///// --------- setting Views ----------- /////////////////////////////////////////////////////////////////////////
- (IBAction)onSettingOpen:(id)sender {
    [self onGroupClose:nil];
    [self onAutoClose:nil];
    [self onProfileClose:nil];
    [self onSearchDone];
    [self onAddClose:nil];
    UIButton *senderBtn = (UIButton *)sender;
    if (senderBtn.tag == 2) {
        [settingCtrl initView:YES];
    }
    if (settingView.frame.origin.y < 0) {
        [UIView transitionWithView:settingView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            [settingView setFrame:CGRectMake(0, 0, settingView.frame.size.width, settingView.frame.size.height)];        settingView.hidden = NO;
        } completion:nil];
    } else {
        [self hideSetting];
    }
}

- (void)hideSetting {
    [UIView transitionWithView:settingView duration:0.1 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [settingView setFrame:CGRectMake(0, settingView.frame.size.height*(-1), settingView.frame.size.width, settingView.frame.size.height)];        settingView.hidden = NO;
    } completion:^(BOOL finished){
        [settingCtrl initView:NO];
    }];
}

- (void)onSettingDone:(int)status {
    [UIView transitionWithView:settingView duration:0.1 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
    [settingView setFrame:CGRectMake(0, settingView.frame.size.height*(-1), settingView.frame.size.width, settingView.frame.size.height)];
    } completion:nil];
    if (status == 1) {
        [self onGroupClose:nil];
        [self onAutoClose:nil];
        [self onSearchDone];
        [self onAddClose:nil];
        if (profileView.hidden == NO) {
            [self onProfileClose:nil];
        }
        [UIView transitionWithView:profileView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            profileView.hidden = NO;
        } completion:nil];
    }
}

#pragma mark - Search
///// --------- search view ----------- /////////////////////////////////////////////////////////////////////////
- (IBAction)onSearchClose:(id)sender {
    [searchBox resignFirstResponder];
    [UIView transitionWithView:searchDoneButton duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        searchDoneButton.hidden = YES;
    } completion:nil];
    
    [UIView transitionWithView:searchView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [searchView setFrame:CGRectMake(searchView.frame.origin.x, searchView.frame.origin.y, searchView.frame.size.width, 0)];
    } completion:^(BOOL flag){
        searchView.hidden = YES;
        [searchCtrl emptyTable];
        searchBox.text = @"";
    }];
}

- (void)onSearchDone {
    NSLog(@"search done");
    [self onSearchClose:nil];
}

- (void)textFieldDidChange:(UITextField *)textField {
    NSLog(@"changed");
    searchView.hidden = NO;
    [self hideSetting];
    [self onGroupClose:nil];
    [self onAutoClose:nil];
    [self onProfileClose:nil];
    [self onAddClose:nil];
    int size = [searchCtrl searchResult:textField.text];
    [searchView setFrame:CGRectMake(searchView.frame.origin.x, searchView.frame.origin.y, searchView.frame.size.width, 0)];
    [UIView transitionWithView:searchView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [searchView setFrame:CGRectMake(searchView.frame.origin.x, searchView.frame.origin.y, searchView.frame.size.width, size)];
        [searchCtrl.view setFrame:CGRectMake(0, 0, searchCtrl.view.frame.size.width, size)];
    } completion:nil];
    [UIView transitionWithView:searchDoneButton duration:0.8 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        searchDoneButton.hidden = NO;
    } completion:nil];
}

#pragma mark - Add Friend
///// --------- Add Friend ----------- /////////////////////////////////////////////////////////////////////////
- (IBAction)onAddOpen:(id)sender {
    [self hideSetting];
    [self onGroupClose:nil];
    [self onProfileClose:nil];
    [self onSearchDone];
    [self onAutoClose:nil];
    if (addView.hidden == NO) {
        [self onAddClose:nil];
        return;
    }
    [UIView transitionWithView:addView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        addView.hidden = NO;
    } completion:nil];
}

- (IBAction)onAddClose:(id)sender {
    if (sender) {
        [searchBox becomeFirstResponder];
    } else {
        [UIView transitionWithView:addView duration:0.1 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            addView.hidden = YES;
        } completion:nil];
    }
}

#pragma mark - Auto Group
///// --------- Auto Group view ----------- /////////////////////////////////////////////////////////////////////////
- (IBAction)onAutoOpen:(id)sender {
    [self hideSetting];
    [self onGroupClose:nil];
    [self onProfileClose:nil];
    [self onSearchDone];
    [self onAddClose:nil];
    if (autoView.hidden == NO) {
        [self onAutoClose:nil];
        return;
    }
    [UIView transitionWithView:autoView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        autoView.hidden = NO;
    } completion:nil];
}

- (IBAction)onAutoClose:(id)sender {
    [UIView transitionWithView:autoView duration:0.1 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        autoView.hidden = YES;
    } completion:nil];
}

#pragma mark - Add Group
///// --------- Add Group View ----------- /////////////////////////////////////////////////////////////////////////
- (IBAction)onGropOpen:(id)sender {
    [self hideSetting];
    [self onAutoClose:nil];
    [self onProfileClose:nil];
    [self onSearchDone];
    [self onAddClose:nil];
    if (groupView.hidden == NO) {
        [self onGroupClose:nil];
        return;
    }
    [UIView transitionWithView:groupView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        groupView.hidden = NO;
    } completion:nil];
}

- (IBAction)onGroupClose:(id)sender {
    [UIView transitionWithView:groupView duration:0.1 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        groupView.hidden = YES;
    } completion:nil];
}

#pragma mark - Delegates
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    searchView.hidden = NO;
    int size = [searchCtrl searchResult:textField.text];
    [self hideSetting];
    [self onGroupClose:nil];
    [self onAutoClose:nil];
    [self onProfileClose:nil];
    [self onAddClose:nil];
    [searchView setFrame:CGRectMake(searchView.frame.origin.x, searchView.frame.origin.y, searchView.frame.size.width, 0)];
    [UIView transitionWithView:searchView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [searchView setFrame:CGRectMake(searchView.frame.origin.x, searchView.frame.origin.y, searchView.frame.size.width, size)];
        [searchCtrl.view setFrame:CGRectMake(0, 0, searchCtrl.view.frame.size.width, size)];
    } completion:nil];
    [UIView transitionWithView:searchDoneButton duration:0.8 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        searchDoneButton.hidden = NO;
    } completion:nil];
    NSLog(@"started");
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSLog(@"edited");
}

-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
    NSLog(@"Error loading");
}

-(void)bannerViewDidLoadAd:(ADBannerView *)banner{
    NSLog(@"Ad loaded");
}
-(void)bannerViewWillLoadAd:(ADBannerView *)banner{
    NSLog(@"Ad will load");
}
-(void)bannerViewActionDidFinish:(ADBannerView *)banner{
    NSLog(@"Ad did finish");
}

-(void)removeIAD {
    bannerView.hidden = YES;
}

@end
