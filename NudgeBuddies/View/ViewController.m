//
//  ViewController.m
//  NudgeBuddies
//
//  Created by Xian Lee on 3/12/2015.
//  Copyright © 2015 Blue Silver. All rights reserved.
//

#import "ViewController.h"
#import "SettingController.h"
#import "MenuController.h"
#import "SearchController.h"
#import <iAd/iAd.h>
#import <CoreMotion/CoreMotion.h>
#import "UIImagePickerHelper.h"

@interface ViewController () <SettingControllerDelegate, SearchControllerDelegate, ADBannerViewDelegate, UITextFieldDelegate, MenuControllerDelegate, NudgeButtonDelegate, AppCenterDelegate>
{
    // general
    QBUUser *currentUser;
    MBProgressHUD *HUD;
    
    // nudgebuddies
    IBOutlet UIScrollView *nudgebuddiesBar;
    IBOutlet UIView *notificationView;
    IBOutlet UIView *initSearchView;
    IBOutlet UIView *initFavView;
    IBOutlet UIView *initControlView;
    IBOutlet UIButton *nightBtn;
    NSMutableArray *favViewArray;
    
    // group pages
    IBOutlet UIView *groupSelectView;
    IBOutlet UIView *groupView;
    IBOutlet UITextField *groupNudgeTxt;
    IBOutlet UITextField *groupAcknowledgeTxt;
    IBOutlet UITextField *groupNameTxt;
    IBOutlet UIButton *groupPicBtn;
    IBOutlet UILabel *groupNameLab;
    IBOutlet UIButton *groupNudgeBtn;
    IBOutlet UIButton *groupRumbleBtn;
    IBOutlet UIButton *groupSilentBtn;
    IBOutlet UIButton *groupAnnoyBtn;
    IBOutlet UIScrollView *groupContactScr;
    IBOutlet UIButton *groupFavBtn;
    Nudger *openGroup;
    NSData *groupPicData;
    BOOL groupPicUpdate;
    NSMutableArray *groupContacts;
    
    IBOutlet UIScrollView *gSelectScroll;
    IBOutlet UIScrollView *gSelectActiveScroll;
    NSMutableArray *gSelectGroupArr;
    NSMutableArray *gSelectActiveArr;
    Nudger *gSelectNudger;
    
    
    // favorite page
    CMMotionManager *motionManager;
    // setting page
    SettingController *settingCtrl;
    IBOutlet UIView *settingView;
    IBOutlet UIView *settingCoverView;
    
    // iAD page
    ADBannerView *bannerView;
    
    // alert page
    IBOutlet UIView *alertView;
    IBOutlet UILabel *alertLab;
    
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
    
    // N profile page
    IBOutlet UIView *nProfileView;
    IBOutlet UILabel *nProfileName;
    IBOutlet UITextField *nProfileNudgeTxt;
    IBOutlet UITextField *nProfileReplyTxt;
    IBOutlet UIButton *nProfileNudgeBtn;
    IBOutlet UIButton *nProfileRumbleBtn;
    IBOutlet UIButton *nProfileSilentBtn;
    IBOutlet UISwitch *nProfileSilentSwitch;
    IBOutlet UISwitch *nProfileBlockSwitch;
    IBOutlet UIButton *nProfileFavBtn;
    IBOutlet UIButton *nProfilePicBtn;
    Nudger *openNP;
    
    // add nudgers page
    IBOutlet UIView *addView;
    
    // start page
    IBOutlet UIView *startView;
    IBOutlet UIButton *startNudgeBtn;
    IBOutlet UIButton *startRumbleBtn;
    IBOutlet UIButton *startSilentBtn;
    IBOutlet UITextField *startNudgeTxt;
    IBOutlet UITextField *startAcknowledgeTxt;
    NSInteger startTag;
    
    // menus module
    MenuController *menuCtrl;
    IBOutlet UIView *menuView;
    NSMutableArray *nudgeButtonArr;
    BOOL stopAccel;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    stopAccel = NO;
    iPH = [[UIImagePickerHelper alloc] init];
    // **********  alert page  ************
    alertView.hidden = YES;
    
    // **********  setting page  ************
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    settingCtrl = (SettingController *)[mainStoryboard instantiateViewControllerWithIdentifier: @"settingCtrl"];
    [self addChildViewController:settingCtrl];
    [settingView addSubview:settingCtrl.view];
    [settingView setFrame:CGRectMake(0, settingView.frame.size.height*(-1), settingView.frame.size.width, settingView.frame.size.height)];
    [settingCoverView setHidden:YES];
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
    
    // **********  menu module  ************
    menuView.hidden = YES;
    menuCtrl = (MenuController *)[mainStoryboard instantiateViewControllerWithIdentifier: @"menuCtrl"];
    [self addChildViewController:menuCtrl];
    [menuView addSubview:menuCtrl.view];
    menuCtrl.delegate = self;

    // **********  group module  ************
    groupView.hidden = YES;
    profileView.hidden = YES;
    groupSelectView.hidden = YES;

    // **********  nProfile module  ************
    nProfileView.hidden = YES;
    
    // **********  start module  ************
    startView.hidden = YES;
    
    // **********  init module  ************
    if (g_center.isNight) {
        [nightBtn setImage:[UIImage imageNamed:@"bottom-night-active"] forState:UIControlStateNormal];
    } else {
        [nightBtn setImage:[UIImage imageNamed:@"bottom-night"] forState:UIControlStateNormal];
    }
    
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [HUD setMode:MBProgressHUDModeIndeterminate];
    [HUD setDetailsLabelText:@"Connecting..."];
    [HUD show:YES];
    
    [g_center setDelegate:self];
    nudgebuddiesBar.hidden = YES;
    notificationView.hidden = YES;
    initFavView.hidden = YES;
    [initSearchView setFrame:CGRectMake(0, initSearchView.frame.origin.y - initSearchView.frame.size.height, initSearchView.frame.size.width, initSearchView.frame.size.height)];
    [initControlView setFrame:CGRectMake(0, initControlView.frame.origin.y + initControlView.frame.size.height, initControlView.frame.size.width, initControlView.frame.size.height)];
    
    nudgeButtonArr = [NSMutableArray new];
}

- (void) initLogger {
    // **********  profile module  ************
    NSData *profileData = [g_var loadFile:currentUser.blobID];
    uname.text = currentUser.fullName;
    email.text = currentUser.email;
    [email setEnabled:NO];
    passwd.text = currentUser.password;
    if (profileData) {
        [profileBtn setBackgroundImage:[UIImage imageWithData:profileData] forState:UIControlStateNormal];
    } else {
        NSData *imgData = [g_var loadFile:currentUser.blobID];
        if (imgData) {
            [profileBtn setBackgroundImage:[UIImage imageWithData:imgData] forState:UIControlStateNormal];
        } else {
            [QBRequest downloadFileWithID:g_center.currentUser.blobID successBlock:^(QBResponse *response, NSData *fileData) {
                [g_var saveFile:fileData uid:g_center.currentUser.blobID];
                UIImage *img = [UIImage imageWithData:fileData];
                [profileBtn setBackgroundImage:img forState:UIControlStateNormal];
                NSLog(@"profile loaded");
            } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
                // handle progress
            } errorBlock:^(QBResponse *response) {
                NSLog(@"error: %@", response.error);
            }];
        }
    }
    
    if (g_center.isNight) {
        [nightBtn setImage:[UIImage imageNamed:@"bottom-night"] forState:UIControlStateNormal];
    }
}

- (IBAction)onNightClick:(id)sender {
    if (g_center.isNight) {
        g_center.isNight = NO;
        [g_var saveLocalBool:NO key:USER_NIGHT];
        [nightBtn setImage:[UIImage imageNamed:@"bottom-night"] forState:UIControlStateNormal];
    } else {
        g_center.isNight = YES;
        [g_var saveLocalBool:YES key:USER_NIGHT];
        [nightBtn setImage:[UIImage imageNamed:@"bottom-night-active"] forState:UIControlStateNormal];
    }
}

#pragma mark - App Center
- (void)onceConnect {
    currentUser = g_center.currentUser;
    __weak typeof(self) weakSelf = self;
    if (currentUser != nil) {
        [self initLogger];
        [weakSelf registerForRemoteNotifications];
    }
    [UIView animateWithDuration:0.5 animations:^(){
        nudgebuddiesBar.hidden = NO;
        notificationView.hidden = NO;
        initFavView.hidden = NO;
        [initSearchView setFrame:CGRectMake(0, initSearchView.frame.origin.y + initSearchView.frame.size.height, initSearchView.frame.size.width, initSearchView.frame.size.height)];
        [initControlView setFrame:CGRectMake(0, initControlView.frame.origin.y - initControlView.frame.size.height, initControlView.frame.size.width, initControlView.frame.size.height)];
    }];
    if ([QBChat instance].contactList.contacts.count == 0) {
        [HUD hide:YES];
    }
    if (g_center.currentNudger.defaultNudge == nil) {
        [self onStartOpen];
    }
}

- (void)startLoadContactList {
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [HUD setMode:MBProgressHUDModeIndeterminate];
    [HUD setDetailsLabelText:@"Loading contacts..."];
    [HUD show:YES];
    [self performSelector:@selector(onLoadingClose) withObject:self afterDelay:2.0];
}

- (void)onceLoadedContactList {
    NSLog(@"%@",g_center.notificationArray);
    [HUD hide:YES];
    [self display:NO];
    // **********  favorite module  ************
    motionManager = [CMMotionManager new];
    motionManager.accelerometerUpdateInterval = .05;
    motionManager.gyroUpdateInterval = .05;
    [motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
        [self outputAccelerometer:accelerometerData.acceleration];
        if (error) {
            NSLog(@"%@", error);
        }
    }];
}

- (void)onceLoadedGroupList {
    [self display:NO];
}

- (void)onceAddedContact:(Nudger *)nudger {
    [self display:NO];
}

- (void)onceRemovedContact:(Nudger *)nudger {
    [self display:YES];
}

- (void)onceAccepted:(NSUInteger)fromID {
    [self display:YES];
}

- (void)onceRejected:(NSUInteger)fromID {
    NSLog(@"You're rejected.");
    [self display:YES];
}

- (void)registerForRemoteNotifications{
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else{
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
    }
#else
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
#endif
}

- (void) onLoadingClose {
    [HUD hide:YES];
}

- (void) display:(BOOL)animatable {
    int lastIndex = 0;
    int barWidth = 0;
    int width = nudgebuddiesBar.frame.size.height;
    int notificationTmp = 0;
    int favTmp = 0;
    favViewArray = [NSMutableArray new];
    
    [[nudgebuddiesBar subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [[initFavView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, initFavView.frame.size.width, initFavView.frame.size.height)];
    [closeButton addTarget:self action:@selector(onMenuClose) forControlEvents:UIControlEventTouchUpInside];
    [initFavView addSubview:closeButton];
    
    for (int i=(int)g_center.notificationArray.count-1; i>=0; i--) {
        Nudger *nudger = [g_center.notificationArray objectAtIndex:i];
        lastIndex ++;
        NudgeButton *nudgeBtn = [NudgeButton new];
        [self addChildViewController:nudgeBtn];
        nudgeBtn.delegate = self;
        if (nudger.isNew && !nudger.isFavorite) {
            notificationTmp ++;
            if (notificationTmp > 3) {
                [nudgebuddiesBar addSubview:nudgeBtn.view];
                nudger.menuPos = 1;
                [nudgeBtn.view setFrame:CGRectMake(barWidth, 0, width, width)];
                barWidth += (width + 70);
                [nudgebuddiesBar setContentSize:CGSizeMake(barWidth, width)];
                [nudgeBtn initNudge:nudger notify:NO];
            } else {
                nudger.menuPos = 0;
                if (nudgeButtonArr.count == 0) {
                    [nudgeBtn.view setFrame:CGRectMake(112, 0, width, width)];
                    [notificationView addSubview:nudgeBtn.view];
                    [nudgeBtn initNudge:nudger notify:YES];
                    nudgeBtn.index = 0;
                    [nudgeButtonArr addObject:nudgeBtn];
                } else if (nudgeButtonArr.count == 1) {
                    NudgeButton *oldBtn = [nudgeButtonArr objectAtIndex:0];
                    if (oldBtn.userInfo.user.ID == nudger.user.ID || [oldBtn.userInfo.group.gName isEqualToString:nudger.group.gName]) {
                        [oldBtn initNudge:nudger notify:YES];
                    } else {
                        [notificationView addSubview:nudgeBtn.view];
                        [nudgeBtn.view setHidden:YES];
                        [nudgeButtonArr addObject:nudgeBtn];
                        if (animatable) {
                            [UIView transitionWithView:oldBtn.view duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                                [oldBtn.view setFrame:CGRectMake(15, 0, width, width)];
                            } completion:^(BOOL complete){
                                [nudgeBtn initNudge:nudger notify:YES];
                                [nudgeBtn.view setFrame:CGRectMake(112, 0, width, width)];
                                [nudgeBtn.view setHidden:NO];
                            }];
                        } else {
                            [oldBtn.view setFrame:CGRectMake(15, 0, width, width)];
                            [nudgeBtn initNudge:nudger notify:YES];
                            [nudgeBtn.view setFrame:CGRectMake(112, 0, width, width)];
                            [nudgeBtn.view setHidden:NO];
                        }
                    }
                } else if (nudgeButtonArr.count == 2) {
                    NudgeButton *old1Btn = [nudgeButtonArr objectAtIndex:0];
                    NudgeButton *old2Btn = [nudgeButtonArr objectAtIndex:1];
                    if (old1Btn.userInfo.user.ID == nudger.user.ID || [old1Btn.userInfo.group.gName isEqualToString:nudger.group.gName]) {
                        nudgeButtonArr = [NSMutableArray arrayWithObjects:old2Btn, old1Btn, nil];
                        [old1Btn initNudge:nudger notify:YES];
                        [old1Btn.view setFrame:CGRectMake(112, 0, width, width)];
                        [old1Btn.view setHidden:YES];
                        if (animatable) {
                            [UIView animateWithDuration:0.3 animations:^(){
                                [old2Btn.view setFrame:CGRectMake(15, 0, width, width)];
                            } completion:^(BOOL complete) {
                                [UIView animateWithDuration:0.3 animations:^(void){
                                    [old1Btn.view setHidden:NO];
                                }];
                            }];
                        } else {
                            [old2Btn.view setFrame:CGRectMake(15, 0, width, width)];
                            [old1Btn.view setHidden:NO];
                        }
                    } else if (old2Btn.userInfo.user.ID == nudger.user.ID || [old2Btn.userInfo.group.gName isEqualToString:nudger.group.gName]) {
                        [old2Btn initNudge:nudger notify:YES];
                    } else {
                        [notificationView addSubview:nudgeBtn.view];
                        [nudgeBtn.view setHidden:YES];
                        [nudgeButtonArr addObject:nudgeBtn];
                        if (animatable) {
                            [UIView animateWithDuration:0.3 animations:^(){
                                [old2Btn.view setFrame:CGRectMake(211, 0, width, width)];
                            } completion:^(BOOL complete) {
                                [UIView animateWithDuration:0.3 animations:^(void){
                                    [nudgeBtn initNudge:nudger notify:YES];
                                    [nudgeBtn.view setFrame:CGRectMake(112, 0, width, width)];
                                    [nudgeBtn.view setHidden:NO];
                                }];
                            }];
                        } else {
                            [old2Btn.view setFrame:CGRectMake(211, 0, width, width)];
                            [nudgeBtn initNudge:nudger notify:YES];
                            [nudgeBtn.view setFrame:CGRectMake(112, 0, width, width)];
                            [nudgeBtn.view setHidden:NO];
                        }
                    }
                } else if (nudgeButtonArr.count == 3) {
                    NudgeButton *old1Btn = [nudgeButtonArr objectAtIndex:0];
                    NudgeButton *old2Btn = [nudgeButtonArr objectAtIndex:1];
                    NudgeButton *old3Btn = [nudgeButtonArr objectAtIndex:2];
                    if (old1Btn.userInfo.user.ID == nudger.user.ID || [old1Btn.userInfo.group.gName isEqualToString:nudger.group.gName]) {
                        nudgeButtonArr = [NSMutableArray arrayWithObjects:old2Btn, old3Btn, old1Btn, nil];
                        [old1Btn initNudge:nudger notify:YES];
                        [old1Btn.view setFrame:CGRectMake(112, 0, width, width)];
                        [old1Btn.view setHidden:YES];
                        if (animatable) {
                            [UIView animateWithDuration:0.3 animations:^(){
                                [old2Btn.view setFrame:CGRectMake(15, 0, width, width)];
                            } completion:^(BOOL complete) {
                                [UIView animateWithDuration:0.3 animations:^(void){
                                    [old1Btn.view setHidden:NO];
                                }];
                            }];
                            [UIView animateWithDuration:0.3 animations:^(){
                                [old3Btn.view setFrame:CGRectMake(211, 0, width, width)];
                            } completion:nil];
                        } else {
                            [old2Btn.view setFrame:CGRectMake(15, 0, width, width)];
                            [old1Btn.view setHidden:NO];
                            [old3Btn.view setFrame:CGRectMake(211, 0, width, width)];
                        }
                    } else if (old2Btn.userInfo.user.ID == nudger.user.ID || [old2Btn.userInfo.group.gName isEqualToString:nudger.group.gName]) {
                        nudgeButtonArr = [NSMutableArray arrayWithObjects:old1Btn, old3Btn, old2Btn, nil];
                        [old2Btn initNudge:nudger notify:YES];
                        [old2Btn.view setFrame:CGRectMake(112, 0, width, width)];
                        [old2Btn.view setHidden:YES];
                        if (animatable) {
                            [UIView animateWithDuration:0.3 animations:^(){
                                [old3Btn.view setFrame:CGRectMake(211, 0, width, width)];
                            } completion:^(BOOL complete) {
                                [UIView animateWithDuration:0.3 animations:^(void){
                                    [old2Btn.view setHidden:NO];
                                }];
                            }];
                        } else {
                            [old3Btn.view setFrame:CGRectMake(211, 0, width, width)];
                            [old2Btn.view setHidden:NO];
                        }
                    } else if (old3Btn.userInfo.user.ID == nudger.user.ID || [old3Btn.userInfo.group.gName isEqualToString:nudger.group.gName]) {
                        [old3Btn initNudge:nudger notify:YES];
                    } else {
                        NudgeButton *old1Btn = [nudgeButtonArr objectAtIndex:0];
                        NudgeButton *old2Btn = [nudgeButtonArr objectAtIndex:1];
                        NudgeButton *old3Btn = [nudgeButtonArr objectAtIndex:2];
                        [notificationView addSubview:nudgeBtn.view];
                        [nudgeBtn.view setHidden:YES];
                        nudgeButtonArr = [NSMutableArray arrayWithObjects:old2Btn, old3Btn, nudgeBtn, nil];
                        [old1Btn.view removeFromSuperview];
                        if (animatable) {
                            [UIView animateWithDuration:0.3 animations:^(){
                                [old2Btn.view setFrame:CGRectMake(15, 0, width, width)];
                            } completion:^(BOOL complete) {
                                [UIView animateWithDuration:0.3 animations:^(void){
                                    [nudgeBtn initNudge:nudger notify:YES];
                                    [nudgeBtn.view setFrame:CGRectMake(112, 0, width, width)];
                                    [nudgeBtn.view setHidden:NO];
                                }];
                            }];
                            [UIView animateWithDuration:0.3 animations:^(){
                                [old3Btn.view setFrame:CGRectMake(211, 0, width, width)];
                            } completion:nil];
                        } else {
                            [old2Btn.view setFrame:CGRectMake(15, 0, width, width)];
                            [nudgeBtn initNudge:nudger notify:YES];
                            [nudgeBtn.view setFrame:CGRectMake(112, 0, width, width)];
                            [nudgeBtn.view setHidden:NO];
                            [old3Btn.view setFrame:CGRectMake(211, 0, width, width)];
                        }
                    }
                }
            }
        } else if (nudger.isFavorite) {
            nudger.menuPos = 2;
            favTmp ++;
            if (favTmp == 1) [nudgeBtn.view setFrame:CGRectMake(FAV_1.x, FAV_1.y, nudgeBtn.view.frame.size.width, nudgeBtn.view.frame.size.height)];
            else if (favTmp == 2) [nudgeBtn.view setFrame:CGRectMake(FAV_2.x, FAV_2.y, nudgeBtn.view.frame.size.width, nudgeBtn.view.frame.size.height)];
            else if (favTmp == 3) [nudgeBtn.view setFrame:CGRectMake(FAV_3.x, FAV_3.y, nudgeBtn.view.frame.size.width, nudgeBtn.view.frame.size.height)];
            else if (favTmp == 4) [nudgeBtn.view setFrame:CGRectMake(FAV_4.x, FAV_4.y, nudgeBtn.view.frame.size.width, nudgeBtn.view.frame.size.height)];
            else if (favTmp == 5) [nudgeBtn.view setFrame:CGRectMake(FAV_5.x, FAV_5.y, nudgeBtn.view.frame.size.width, nudgeBtn.view.frame.size.height)];
            else if (favTmp == 6) [nudgeBtn.view setFrame:CGRectMake(FAV_6.x, FAV_6.y, nudgeBtn.view.frame.size.width, nudgeBtn.view.frame.size.height)];
            else if (favTmp == 7) [nudgeBtn.view setFrame:CGRectMake(FAV_7.x, FAV_7.y, nudgeBtn.view.frame.size.width, nudgeBtn.view.frame.size.height)];
            else if (favTmp == 8) [nudgeBtn.view setFrame:CGRectMake(FAV_8.x, FAV_8.y, nudgeBtn.view.frame.size.width, nudgeBtn.view.frame.size.height)];
            else {
                nudger.menuPos = 1;
                [nudgebuddiesBar addSubview:nudgeBtn.view];
                [nudgeBtn.view setFrame:CGRectMake(barWidth, 0, width, width)];
                barWidth += 70;
                [nudgebuddiesBar setContentSize:CGSizeMake(barWidth, width)];
                [nudgeBtn initNudge:nudger notify:NO];
            }
            if (favTmp <= 8) {
                [favViewArray addObject:nudgeBtn.view];
                [nudgeBtn initNudge:nudger notify:NO];
                [initFavView addSubview:nudgeBtn.view];
            }
        } else {
            nudger.menuPos = 1;
            [nudgebuddiesBar addSubview:nudgeBtn.view];
            [nudgeBtn.view setFrame:CGRectMake(barWidth, 0, width, width)];
            barWidth += 70;
            [nudgebuddiesBar setContentSize:CGSizeMake(barWidth, width)];
            [nudgeBtn initNudge:nudger notify:NO];
        }
    }
}

#pragma mark - Menu
////////////////////////////////////// --------- Menu Views ----------- ////////////////////////////////////////
- (void)onMenuClose {
    [nudgebuddiesBar setScrollEnabled:YES];
    menuCtrl.isOpen = NO;
    [UIView transitionWithView:self.view duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [menuView setHidden:YES];
    } completion:nil];
}

- (void)onSendNudge:(Nudger *)nudger {
    [self onMenuClose];
    menuCtrl.isOpen = NO;
    [self showAlert:[NSString stringWithFormat:@"You sent nudge to %@",nudger.type==NTGroup?nudger.group.gName:nudger.user.fullName]];
}

- (void)onNudgeClicked:(Nudger *)nudger frame:(CGRect)rect {
    [self hide:VTMenu];

    if (menuCtrl.isOpen && [menuCtrl.tUser isEqualNudger:nudger]) {
        [self onMenuClose];
        return;
    }
    openNP = nudger;
    menuCtrl.isOpen = YES;
    [nudgebuddiesBar setScrollEnabled:NO];
    CGSize size = [menuCtrl createMenu:nudger];
    CGRect newRect;
    if (nudger.menuPos == 0) {
        newRect = CGRectMake(rect.origin.x, rect.origin.y+notificationView.frame.origin.y, rect.size.width, rect.size.height);
    } else if (nudger.menuPos == 1) {
        newRect = CGRectMake(rect.origin.x, rect.origin.y+nudgebuddiesBar.frame.origin.y, rect.size.width, rect.size.height);
    } else {
        newRect = CGRectMake(rect.origin.x, rect.origin.y+initFavView.frame.origin.y, rect.size.width, rect.size.height);
    }
    Menu *menu = [self getMenu:newRect menuSize:size];
    if (nudger.menuPos == 0) {
        [menuView setFrame:CGRectMake(menu.menuPoint.x, menu.menuPoint.y, size.width, size.height+15)];
    } else if (nudger.menuPos == 1){
        [menuView setFrame:CGRectMake(menu.menuPoint.x, menu.menuPoint.y-15, size.width, size.height+15)];
    } else {
        [menuView setFrame:CGRectMake(menu.menuPoint.x, menu.menuPoint.y, size.width, size.height+15)];
    }
    UIImageView *triImg = (UIImageView *)[menuView viewWithTag:100];
    if (menu.triDirection) {
        [triImg setImage:[UIImage imageNamed:@"menu-tri"]];
        [menuCtrl.view setFrame:CGRectMake(0, triImg.frame.size.height, size.width, size.height)];
        [triImg setFrame:CGRectMake(menu.triPoint.x, 0, triImg.frame.size.width, triImg.frame.size.height)];
    } else {
        [triImg setImage:[UIImage imageNamed:@"menu-tri-down"]];
        [menuCtrl.view setFrame:CGRectMake(0, 0, size.width, size.height)];
        [triImg setFrame:CGRectMake(menu.triPoint.x, size.height, triImg.frame.size.width, triImg.frame.size.height)];
    }
    [UIView transitionWithView:self.view duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [menuView setHidden:NO];
    } completion:nil];
}

- (void)onMenuClicked:(MenuReturn)menuReturn nudger:(Nudger *)nudger{
    if (menuReturn == MRNudge) {
        NSLog(@"MRNudge");
        nudger.response = RTNudge;
    } else if (menuReturn == MRRumble) {
        NSLog(@"MRRumble");
        nudger.response = RTRumble;
    } else if (menuReturn == MRRumbleSilent) {
        NSLog(@"MRRumbleSilent");
        nudger.response = RTSilent;
    } else if (menuReturn == MRAnnoy) {
        NSLog(@"MRAnnoy");
        nudger.response = RTAnnoy;
    } else if (menuReturn == MRAddGroup) {
        [self onMenuClose];
        menuCtrl.isOpen = NO;
        NSLog(@"MRAddGroup");
        gSelectNudger = nudger;
        [self onGroupSelectOpen:nil];
    } else if (menuReturn == MRAuto) {
        [self onMenuClose];
        menuCtrl.isOpen = NO;
        NSLog(@"MRAuto");
    } else if (menuReturn == MRBlock) {
        NSLog(@"MRBlock");
    } else if (menuReturn == MREdit) {
        [self onMenuClose];
        menuCtrl.isOpen = NO;
        NSLog(@"MREdit");
        openNP = nudger;
        [self onNPOpen:nil];
    } else if (menuReturn == MREditGroup) {
        [self onMenuClose];
        menuCtrl.isOpen = NO;
        NSLog(@"MREditGroup");
    } else if (menuReturn == MRSilent) {
        NSLog(@"MRSilent");
    } else if (menuReturn == MRStream) {
        [self onMenuClose];
        menuCtrl.isOpen = NO;
        NSLog(@"MRStream");
    } else if (menuReturn == MRStreamGroup) {
        [self onMenuClose];
        menuCtrl.isOpen = NO;
        NSLog(@"MRStreamGroup");
    } else if (menuReturn == MRViewGroup) {
        [self onMenuClose];
        menuCtrl.isOpen = NO;
        NSLog(@"MRViewGroup");
    } else if (menuReturn == MRAdd) {
        [self onMenuClose];
        menuCtrl.isOpen = NO;
        NSLog(@"MRAdd");
        [[QBChat instance] confirmAddContactRequest:nudger.user.ID completion:^(NSError * _Nullable error) {
            [g_center add:nudger];
        }];
    } else if (menuReturn == MRReject) {
        [self onMenuClose];
        menuCtrl.isOpen = NO;
        NSLog(@"MRReject");
        [[QBChat instance] rejectAddContactRequest:nudger.user.ID completion:^(NSError * _Nullable error) {
            [g_center remove:nudger];
        }];
    }
}

- (Menu *)getMenu:(CGRect)frame menuSize:(CGSize)size{
    Menu *menu = [Menu new];
    if (frame.origin.y > 568/2.0) {
        menu.menuPoint = CGPointMake(frame.origin.x+frame.size.width/2.0-size.width/2.0, frame.origin.y-size.height);
        if (menu.menuPoint.x < 0) {
            menu.menuPoint = CGPointMake(12, menu.menuPoint.y);
        } else if (frame.origin.x + size.width > 320) {
            menu.menuPoint = CGPointMake(320-12-size.width, menu.menuPoint.y);
        }
        menu.triDirection = NO;
        menu.triPoint = CGPointMake(frame.origin.x+frame.size.width/2.0-9 - menu.menuPoint.x, frame.origin.y+frame.size.height);
    } else {
        menu.menuPoint = CGPointMake(frame.origin.x+frame.size.width/2.0-size.width/2.0, frame.origin.y+frame.size.height);
        if (menu.menuPoint.x < 0) {
            menu.menuPoint = CGPointMake(12, menu.menuPoint.y);
        } else if (menu.menuPoint.x + size.width > 320) {
            menu.menuPoint = CGPointMake(320-12-size.width, menu.menuPoint.y);
        }
        menu.triDirection = YES;
        menu.triPoint = CGPointMake(frame.origin.x+frame.size.width/2.0-9 - menu.menuPoint.x, frame.origin.y+frame.size.height);
    }
    return menu;
}

#pragma mark - profile
////////////////////////////////////// --------- edit profile ----------- ////////////////////////////////////////
- (IBAction)onPhoto:(id)sender {
    [iPH imagePickerInView:self WithSuccess:^(UIImage *image) {
        CGSize newSize = CGSizeMake(RESIZE_WIDTH, RESIZE_HEIGHT);
        UIGraphicsBeginImageContext(newSize);
        [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [profileBtn setBackgroundImage:newImage forState:UIControlStateNormal];
        profileImgData = UIImageJPEGRepresentation(newImage, 1.0f);
        g_var.profileImg = profileImgData;
        profilePictureUpdate = YES;
    } failure:^(NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }];
}

- (IBAction)onProfileSave:(id)sender {
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [HUD setMode:MBProgressHUDModeIndeterminate];
    [HUD show:YES];
    if (profilePictureUpdate) {
        [QBRequest TUploadFile:g_var.profileImg fileName:@"profile.jpg" contentType:@"image/jpeg" isPublic:NO successBlock:^(QBResponse *response, QBCBlob *blob) {
            [g_var saveFile:g_var.profileImg uid:blob.ID];
            QBUpdateUserParameters *updateParameters = [QBUpdateUserParameters new];
            updateParameters.blobID = blob.ID;
            updateParameters.oldPassword = currentUser.password;
            updateParameters.password = passwd.text;
            [QBRequest updateCurrentUser:updateParameters successBlock:^(QBResponse *response, QBUUser *user) {
                [HUD hide:YES];
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
            [HUD hide:YES];
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
////////////////////////////////////// --------- favorite views ----------- ////////////////////////////////////////
- (void)outputAccelerometer:(CMAcceleration)acceleration {
    for (int i=0; i<favViewArray.count; i++) {
        UIView *favView = [favViewArray objectAtIndex:i];
        CGPoint size;
        if (i==0) size = CGPointMake(FAV_1.x + acceleration.x*15, FAV_1.y + acceleration.y*15);
        else if (i==1) size = CGPointMake(FAV_2.x - acceleration.x*25*0.8, FAV_2.y - acceleration.y*25*0.9);
        else if (i==2) size = CGPointMake(FAV_3.x + acceleration.x*25*(-0.9), FAV_3.y + acceleration.y*25*0.8);
        else if (i==3) size = CGPointMake(FAV_4.x + acceleration.x*30*(-0.5), FAV_4.y + acceleration.y*30*0.86);
        else if (i==4) size = CGPointMake(FAV_5.x + acceleration.x*30*(-0.86), FAV_5.y + acceleration.y*30*(-0.5));
        else if (i==5) size = CGPointMake(FAV_6.x + acceleration.x*35*(0.9), FAV_6.y + acceleration.y*25*(0.9));
        else if (i==6) size = CGPointMake(FAV_7.x + acceleration.x*35*(-0.5), FAV_7.y + acceleration.y*30*(0.8));
        else if (i==7) size = CGPointMake(FAV_8.x + acceleration.x*35*(0.4), FAV_8.y + acceleration.y*35*(-0.9));
        [UIView animateWithDuration:1.0
                              delay:0.0
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^(){
                                  [favView setFrame:CGRectMake(size.x, size.y, favView.frame.size.width, favView.frame.size.height)];
                              }
                         completion:^(BOOL finished) {
                             
                         }];
    }
}

#pragma mark - setting
//////////////////////////////////////// --------- setting Views ----------- //////////////////////////////////////
- (IBAction)onSettingOpen:(id)sender {
    [self hide:VTSetting];
    UIButton *senderBtn = (UIButton *)sender;
    if (senderBtn.tag == 2) {
        [settingCtrl initView:YES];
    }
    [settingCoverView setHidden:NO];
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
        [settingCoverView setHidden:YES];
    }];
}

- (void)onSettingDone:(int)status {
    [UIView transitionWithView:settingView duration:0.1 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
    [settingView setFrame:CGRectMake(0, settingView.frame.size.height*(-1), settingView.frame.size.width, settingView.frame.size.height)];
    } completion:^(BOOL finished){
        [settingCoverView setHidden:YES];
    }];
    if (status == 1) {
        [self hide:VTProfile];
        if (profileView.hidden == NO) {
            [self onProfileClose:nil];
        }
        [UIView transitionWithView:profileView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            profileView.hidden = NO;
        } completion:nil];
    }
}

#pragma mark - Search
////////////////////////////////////// --------- search view ----------- ////////////////////////////////////////
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
    [self hide:VTSearch];
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

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    searchView.hidden = NO;
    int size = [searchCtrl searchResult:textField.text];
    [self hide:VTSearch];
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

#pragma mark - Add Friend
/////////////////////////////////////// --------- Add Friend ----------- ///////////////////////////////////////
- (IBAction)onAddOpen:(id)sender {
    [self hide:VTAdd];
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

#pragma mark - Select Group
/////////////////////////////////// --------- Auto Group view ----------- ///////////////////////////////////////////
- (IBAction)onGroupSelectOpen:(id)sender {
    [self hide:VTGroupSelect];
    if (groupSelectView.hidden == NO) {
        [self onGroupSelectClose:nil];
        return;
    }
    gSelectGroupArr = [NSMutableArray new];
    gSelectActiveArr = [NSMutableArray new];
    [gSelectGroupArr addObjectsFromArray:g_center.groupArray];
    
    [self initGroupSelect];
    [UIView transitionWithView:self.view duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        groupSelectView.hidden = NO;
    } completion:nil];
}

- (void)initGroupSelect {
    [[gSelectScroll subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [[gSelectActiveScroll subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for (int i=0; i<gSelectGroupArr.count; i++) {
        Nudger *group = [gSelectGroupArr objectAtIndex:i];
        int row = (int)i/3.0;
        int cell = i%3;
        int page = (int)i/6.0;
        UIView *gView = [[UIView alloc] initWithFrame:CGRectMake(5+cell*91+page*290, 3+row*78, 91, 78)];
        UIButton *grBtn = [[UIButton alloc] initWithFrame:CGRectMake(21, 10, 48, 48)];
        [grBtn setBackgroundImage:[UIImage imageNamed:@"user-group-empty"] forState:UIControlStateNormal];
        if (group.group.gBlobID) {
            [grBtn setImage:[UIImage imageWithData:[g_var loadFile:group.group.gBlobID]] forState:UIControlStateNormal];
        }
        [grBtn setTag:i];
        [grBtn addTarget:self action:@selector(addGSelect:) forControlEvents:UIControlEventTouchUpInside];
        [gView addSubview:grBtn];
        UIImageView *plusImg = [[UIImageView alloc] initWithFrame:CGRectMake(55, 6, 18, 18)];
        [plusImg setImage:[UIImage imageNamed:@"icon-plus"]];
        grBtn.layer.masksToBounds = YES;
        grBtn.layer.cornerRadius = 24.0;
        [gView addSubview:plusImg];
        UILabel *gLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 57, 83, 21)];
        gLabel.text = group.group.gName;
        gLabel.textAlignment = NSTextAlignmentCenter;
        [gLabel setFont:[gLabel.font fontWithSize:11]];
        [gView addSubview:gLabel];
        [gSelectScroll addSubview:gView];
    }
    for (int i=0; i<gSelectActiveArr.count; i++) {
        Nudger *group = [gSelectActiveArr objectAtIndex:i];
        UIView *gView = [[UIView alloc] initWithFrame:CGRectMake(i*91, 0, 91, 78)];
        UIButton *grBtn = [[UIButton alloc] initWithFrame:CGRectMake(21, 10, 48, 48)];
        [grBtn setBackgroundImage:[UIImage imageNamed:@"user-group-empty"] forState:UIControlStateNormal];
        if (group.group.gBlobID) {
            [grBtn setImage:[UIImage imageWithData:[g_var loadFile:group.group.gBlobID]] forState:UIControlStateNormal];
        }
        [grBtn setTag:i];
        [grBtn addTarget:self action:@selector(removeGSelect:) forControlEvents:UIControlEventTouchUpInside];
        [gView addSubview:grBtn];
        UIImageView *plusImg = [[UIImageView alloc] initWithFrame:CGRectMake(55, 6, 18, 18)];
        [plusImg setImage:[UIImage imageNamed:@"icon-minus"]];
        grBtn.layer.masksToBounds = YES;
        grBtn.layer.cornerRadius = 24.0;
        [gView addSubview:plusImg];
        UILabel *gLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 57, 83, 21)];
        gLabel.text = group.group.gName;
        gLabel.textAlignment = NSTextAlignmentCenter;
        [gLabel setFont:[gLabel.font fontWithSize:11]];
        [gView addSubview:gLabel];
        [gSelectActiveScroll addSubview:gView];
    }
}

- (void)addGSelect:(id)sender {
    UIButton *btn = (UIButton *)sender;
    Nudger *group = [gSelectGroupArr objectAtIndex:btn.tag];
    [gSelectGroupArr removeObjectAtIndex:btn.tag];
    [gSelectActiveArr addObject:group];
    [self initGroupSelect];
}

- (void)removeGSelect:(id)sender {
    UIButton *btn = (UIButton *)sender;
    Nudger *group = [gSelectActiveArr objectAtIndex:btn.tag];
    [gSelectActiveArr removeObjectAtIndex:btn.tag];
    [gSelectGroupArr addObject:group];
    [self initGroupSelect];
}

- (IBAction)onGroupSelectClose:(id)sender {
    [UIView transitionWithView:self.view duration:0.1 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        groupSelectView.hidden = YES;
    } completion:nil];
}

- (IBAction)onGroupSelectSave:(id)sender {
    QBCOCustomObject *object = [QBCOCustomObject customObject];
    object.className = @"Movie";
    [object.fields setObject:@"7.88" forKey:@"rating"];
    object.ID = @"502f7c4036c9ae2163000002";
    
    for (Nudger *group in gSelectActiveArr) {
        QBChatDialog *updateDialog = [[QBChatDialog alloc] initWithDialogID:group.group.gID type:QBChatDialogTypeGroup];
        updateDialog.pushOccupantsIDs = @[[NSString stringWithFormat:@"%lu",gSelectNudger.user.ID]];
        [QBRequest updateDialog:updateDialog successBlock:^(QBResponse *responce, QBChatDialog *dialog) {
            
        } errorBlock:^(QBResponse *response) {
            
        }];
    }
    [self onGroupSelectClose:nil];
}

#pragma mark - Add Group
//////////////////////////////////// --------- Add Group View ----------- //////////////////////////////////////////
- (IBAction)onGropOpen:(id)sender {
    [self hide:VTGroup];
    if (groupView.hidden == NO) {
        [self onGroupClose:nil];
        return;
    }
    openGroup = [[Nudger alloc] initWithGroup:nil];
    groupFavBtn.hidden = YES;
    groupPicUpdate = NO;
    [UIView transitionWithView:groupView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        groupView.hidden = NO;
    } completion:nil];
    groupContacts = [NSMutableArray arrayWithArray:g_center.contactsArray];
    [self addGroupItems];
    groupNudgeTxt.text = g_center.currentNudger.defaultNudge;
    groupAcknowledgeTxt.text = g_center.currentNudger.defaultReply;
}

- (void)onGroupItemRemoved:(id)sender {
    UIButton *minusBtn = (UIButton *)sender;
    for (int i=0; i< groupContacts.count; i++) {
        Nudger *nudger = [groupContacts objectAtIndex:i];
        if (nudger.user.ID == minusBtn.tag) {
            [groupContacts removeObjectAtIndex:i];
            break;
        }
    }
    [self addGroupItems];
}

- (void) addGroupItems {
    int initPosX = 8;
    [[groupContactScr subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for (Nudger *nudger in groupContacts) {
        UIView *contactView = [[UIView alloc] initWithFrame:CGRectMake(initPosX, 0, 63, 59)];
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(3, 10, 48, 48)];
        NSData *profileData = [g_var loadFile:nudger.user.blobID];
        [imgView setImage:[UIImage imageWithData:profileData]];
        imgView.layer.masksToBounds = YES;
        imgView.layer.cornerRadius = imgView.frame.size.width/2.0;
        UIButton *minusBtn = [[UIButton alloc] initWithFrame:CGRectMake(35, 5, 18, 18)];
        [minusBtn setImage:[UIImage imageNamed:@"icon-minus"] forState:UIControlStateNormal];
        [minusBtn setTag:nudger.user.ID];
        [minusBtn addTarget:self action:@selector(onGroupItemRemoved:) forControlEvents:UIControlEventTouchUpInside];
        [contactView addSubview:imgView];
        [contactView addSubview:minusBtn];
        initPosX += 72;
        [groupContactScr addSubview:contactView];
    }
}

- (IBAction)onGroupClose:(id)sender {
    [UIView transitionWithView:groupView duration:0.1 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        groupView.hidden = YES;
    } completion:nil];
}

- (IBAction)onGroupDelete:(id)sender {
    
    [self onGroupClose:nil];
}

- (IBAction)onGroupSave:(id)sender {
    
    [self onGroupClose:nil];
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [HUD setMode:MBProgressHUDModeIndeterminate];
    [HUD show:YES];
//    return;
    QBChatDialog *chatDialog = [[QBChatDialog alloc] initWithDialogID:nil type:QBChatDialogTypeGroup];
    chatDialog.name = groupNameTxt.text;
    NSMutableArray *contactIDs = [NSMutableArray new];
    for (Nudger *nudger in groupContacts) {
        [contactIDs addObject:[NSString stringWithFormat:@"%lu", nudger.user.ID]];
    }
    chatDialog.occupantIDs = (NSArray *)contactIDs;
    
    [QBRequest createDialog:chatDialog successBlock:^(QBResponse *response, QBChatDialog *createdDialog) {
        openGroup.defaultNudge = groupNudgeTxt.text;
        openGroup.defaultReply = groupAcknowledgeTxt.text;
        openGroup.isFavorite = groupFavBtn.hidden?NO:YES;
        QBCOCustomObject *object = [QBCOCustomObject customObject];
        object.className = @"NudgerBuddy"; // your Class name
        [object.fields setObject:createdDialog.ID forKey:@"_parent_id"];
        [object.fields setObject:openGroup.defaultNudge forKey:@"NudgeTxt"];
        [object.fields setObject:openGroup.defaultReply forKey:@"AcknowledgeTxt"];
        [object.fields setObject:[NSNumber numberWithBool:openGroup.isFavorite] forKey:@"Favorite"];
        [object.fields setObject:[NSNumber numberWithInteger:openGroup.response] forKey:@"NudgerType"];
        [object.fields setObject:[NSNumber numberWithBool:openGroup.silent] forKey:@"Silent"];
        [object.fields setObject:[NSNumber numberWithBool:openGroup.block] forKey:@"Block"];
        openGroup.group.gID = createdDialog.ID;
        if (groupPicUpdate) {
            [QBRequest TUploadFile:groupPicData fileName:@"group.jpg" contentType:@"image/jpeg" isPublic:NO successBlock:^(QBResponse *response, QBCBlob *uploadedBlob) {
                NSUInteger uploadedFileID = uploadedBlob.ID;
                createdDialog.photo = [NSString stringWithFormat:@"%lu", uploadedFileID];
                openGroup.group.gBlobID = uploadedFileID;
                [QBRequest updateDialog:createdDialog successBlock:^(QBResponse *responce, QBChatDialog *dialog) {
                    [QBRequest createObject:object successBlock:^(QBResponse *response, QBCOCustomObject *object) {
                        [HUD hide:YES];
                        [self onGroupClose:nil];
                        [self sendGroupInvite:createdDialog];
                    } errorBlock:^(QBResponse *response) {
                        [HUD hide:YES];
                        // error handling
                        NSLog(@"Response error: %@", [response.error description]);
                    }];
                } errorBlock:^(QBResponse *response) {
                    NSLog(@"error: %@", response.error);
                }];
            } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
            } errorBlock:^(QBResponse *response) {
                [HUD hide:YES];
                NSLog(@"error: %@", response.error);
            }];
        } else {
            [QBRequest createObject:object successBlock:^(QBResponse *response, QBCOCustomObject *object) {
                [HUD hide:YES];
                [self onGroupClose:nil];
                [self sendGroupInvite:createdDialog];
            } errorBlock:^(QBResponse *response) {
                // error handling
                [HUD hide:YES];
                NSLog(@"Response error: %@", [response.error description]);
            }];
        }
    } errorBlock:^(QBResponse *response) {
        [HUD hide:YES];
        NSLog(@"Response error: %@", [response.error description]);
    }];
}

- (void) sendGroupInvite:(QBChatDialog *)dialog {
    for (NSString *occupantID in dialog.occupantIDs) {
        
        QBChatMessage *inviteMessage = [g_center createChatNotificationForGroupChatCreation:dialog];
        NSTimeInterval timestamp = (unsigned long)[[NSDate date] timeIntervalSince1970];
        inviteMessage.customParameters[@"date_sent"] = (NSString *)@(timestamp);
        inviteMessage.customParameters[@"sender"] = currentUser.fullName;
        inviteMessage.recipientID = [occupantID integerValue];
        [[QBChat instance] sendSystemMessage:inviteMessage completion:^(NSError * _Nullable error) {}];
    }
}

- (IBAction)onGroupPic:(id)sender {
    [iPH imagePickerInView:self WithSuccess:^(UIImage *image) {
        CGSize newSize = CGSizeMake(RESIZE_WIDTH, RESIZE_HEIGHT);
        UIGraphicsBeginImageContext(newSize);
        [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [groupPicBtn setBackgroundImage:newImage forState:UIControlStateNormal];
//        groupPicBtn.layer.masksToBounds = YES;
//        groupPicBtn.layer.cornerRadius = groupPicBtn.frame.size.width / 2.0;
        groupPicData = UIImageJPEGRepresentation(newImage, 1.0f);
        groupPicUpdate = YES;
    } failure:^(NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }];
}

- (IBAction)onGroupFav:(id)sender {
    groupFavBtn.hidden = YES;
    openGroup.isFavorite = NO;
}

- (IBAction)onGroupFavEmp:(id)sender {
    groupFavBtn.hidden = NO;
    openGroup.isFavorite = YES;
}

- (IBAction)onGroupNudge:(id)sender {
    UIButton *senderBtn = (UIButton *)sender;
    [groupNudgeBtn setImage:[UIImage imageNamed:@"icon-nudge"] forState:UIControlStateNormal];
    [groupRumbleBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble"] forState:UIControlStateNormal];
    [groupSilentBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble-silent"] forState:UIControlStateNormal];
    [groupAnnoyBtn setImage:[UIImage imageNamed:@"icon-nudge-annoy"] forState:UIControlStateNormal];
    if (senderBtn.tag == 4) {
        [groupAnnoyBtn setImage:[UIImage imageNamed:@"icon-nudge-annoy-active"] forState:UIControlStateNormal];
        openGroup.response = RTAnnoy;
    } else if (senderBtn.tag == 3) {
        [groupSilentBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble-silent-active"] forState:UIControlStateNormal];
        openGroup.response = RTSilent;
    } else if (senderBtn.tag == 2) {
        [groupRumbleBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble-active"] forState:UIControlStateNormal];
        openGroup.response = RTRumble;
    } else {
        [groupNudgeBtn setImage:[UIImage imageNamed:@"icon-nudge-active"] forState:UIControlStateNormal];
        openGroup.response = RTNudge;
    }
}

#pragma mark - nProfile
/////////////////////////////////// --------- nProfile View ----------- ///////////////////////////////////////////
- (IBAction)onNPOpen:(id)sender {
    [self hide:VTNP];
    if (nProfileView.hidden == NO) {
        [self onNPClose:nil];
        return;
    }
//    openGroup = [[Nudger alloc] initWithGroup:nil];
    [UIView transitionWithView:self.view duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        nProfileView.hidden = NO;
    } completion:nil];
    if (openNP.isFavorite) nProfileFavBtn.hidden = NO;
    else nProfileFavBtn.hidden = YES;

    if (openNP.silent) [nProfileSilentSwitch setOn:YES];
    else [nProfileSilentSwitch setOn:NO];

    if (openNP.block) [nProfileBlockSwitch setOn:YES];
    else [nProfileBlockSwitch setOn:NO];

    if (openNP.response == RTNudge) [nProfileNudgeBtn setImage:[UIImage imageNamed:@"icon-nudge-active"] forState:UIControlStateNormal];
    else if (openNP.response == RTRumble) [nProfileNudgeBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble-active"] forState:UIControlStateNormal];
    else if (openNP.response == RTSilent) [nProfileNudgeBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble-silent-active"] forState:UIControlStateNormal];
    nProfileNudgeTxt.text = openNP.defaultNudge;
    nProfileReplyTxt.text = openNP.defaultReply;
    nProfileName.text = openNP.user.fullName;
    
    NSData *imgData = [g_var loadFile:openNP.user.blobID];
    if (imgData) {
        [nProfilePicBtn setBackgroundImage:[UIImage imageWithData:imgData] forState:UIControlStateNormal];
    } else {
        [QBRequest downloadFileWithID:openNP.user.blobID successBlock:^(QBResponse *response, NSData *fileData) {
            [g_var saveFile:fileData uid:openNP.user.blobID];
            UIImage *img = [UIImage imageWithData:fileData];
            [nProfilePicBtn setBackgroundImage:img forState:UIControlStateNormal];
        } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
            // handle progress
        } errorBlock:^(QBResponse *response) {
            NSLog(@"error: %@", response.error);
        }];
    }
}

- (IBAction)onNPClose:(id)sender {
    [UIView transitionWithView:nProfileView duration:0.1 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        nProfileView.hidden = YES;
    } completion:nil];
}

- (IBAction)onNPDelete:(id)sender {
    [[QBChat instance] removeUserFromContactList:openNP.user.ID completion:^(NSError * _Nullable error) {
        [self onNPClose:nil];
        [self display:YES];
    }];
}

- (IBAction)onNPSave:(id)sender {
    openNP.defaultNudge = nProfileNudgeTxt.text;
    openNP.defaultReply = nProfileReplyTxt.text;
    openNP.silent = nProfileSilentSwitch.on;
    openNP.block = nProfileBlockSwitch.on;

    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [HUD setMode:MBProgressHUDModeIndeterminate];
    [HUD show:YES];
    
    if (openNP.metaID != nil) {
        QBCOCustomObject *object = [QBCOCustomObject customObject];
        object.className = @"NudgerBuddy"; // your Class name
        object.ID = openNP.metaID;
        [object.fields setObject:[NSString stringWithFormat:@"%lu",openNP.user.ID] forKey:@"_parent_id"];
        [object.fields setObject:openNP.defaultNudge forKey:@"NudgeTxt"];
        [object.fields setObject:openNP.defaultReply forKey:@"AcknowledgeTxt"];
        [object.fields setObject:[NSNumber numberWithBool:openNP.isFavorite] forKey:@"Favorite"];
        [object.fields setObject:[NSNumber numberWithInteger:openNP.response] forKey:@"NudgerType"];
        [object.fields setObject:[NSNumber numberWithBool:openNP.silent] forKey:@"Silent"];
        [object.fields setObject:[NSNumber numberWithBool:openNP.block] forKey:@"Block"];
        [QBRequest updateObject:object successBlock:^(QBResponse *response, QBCOCustomObject *object) {
            [HUD hide:YES];
            [self onNPClose:nil];
            [self display:NO];
        } errorBlock:^(QBResponse *response) {
            // error handling
            [HUD hide:YES];
            NSLog(@"Response error: %@", [response.error description]);
        }];
    } else {
        QBCOCustomObject *object = [QBCOCustomObject customObject];
        object.className = @"NudgerBuddy"; // your Class name
        [object.fields setObject:[NSString stringWithFormat:@"%lu",openNP.user.ID] forKey:@"_parent_id"];
        [object.fields setObject:openNP.defaultNudge forKey:@"NudgeTxt"];
        [object.fields setObject:openNP.defaultReply forKey:@"AcknowledgeTxt"];
        [object.fields setObject:[NSNumber numberWithBool:openNP.isFavorite] forKey:@"Favorite"];
        [object.fields setObject:[NSNumber numberWithInteger:openNP.response] forKey:@"NudgerType"];
        [object.fields setObject:[NSNumber numberWithBool:openNP.silent] forKey:@"Silent"];
        [object.fields setObject:[NSNumber numberWithBool:openNP.block] forKey:@"Block"];
        
        [QBRequest createObject:object successBlock:^(QBResponse *response, QBCOCustomObject *object) {
            [HUD hide:YES];
            [self onNPClose:nil];
            [self display:NO];
        } errorBlock:^(QBResponse *response) {
            // error handling
            [HUD hide:YES];
            NSLog(@"Response error: %@", [response.error description]);
        }];
    }
    //    return;
}

- (IBAction)onNPFav:(id)sender {
    nProfileFavBtn.hidden = YES;
    openNP.isFavorite = NO;
}

- (IBAction)onNPFavEmp:(id)sender {
    nProfileFavBtn.hidden = NO;
    openNP.isFavorite = YES;
}

- (IBAction)onNPNudge:(id)sender {
    UIButton *senderBtn = (UIButton *)sender;
    [nProfileNudgeBtn setImage:[UIImage imageNamed:@"icon-nudge"] forState:UIControlStateNormal];
    [nProfileRumbleBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble"] forState:UIControlStateNormal];
    [nProfileSilentBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble-silent"] forState:UIControlStateNormal];
    
    if (senderBtn.tag == 3) {
        [nProfileSilentBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble-silent-active"] forState:UIControlStateNormal];
        openNP.response = RTSilent;
    } else if (senderBtn.tag == 2) {
        [nProfileRumbleBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble-active"] forState:UIControlStateNormal];
        openNP.response = RTRumble;
    } else {
        [nProfileNudgeBtn setImage:[UIImage imageNamed:@"icon-nudge-active"] forState:UIControlStateNormal];
        openNP.response = RTNudge;
    }
}

#pragma mark - Add Start
///////////////////////////////// --------- Add Start View ----------- /////////////////////////////////////////////
- (void)onStartOpen {
    [UIView transitionWithView:self.view duration:1.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        startView.hidden = NO;
    } completion:nil];
}

- (IBAction)onStartClose:(id)sender {
    [UIView transitionWithView:self.view duration:0.1 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        startView.hidden = YES;
    } completion:nil];
}

- (IBAction)onStartSave:(id)sender {
    [UIView transitionWithView:self.view duration:0.1 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        startView.hidden = YES;
    } completion:nil];
    if (startTag == 1) {
        g_center.currentNudger.response = RTNudge;
    } else if (startTag == 2) {
        g_center.currentNudger.response = RTRumble;
    } else if (startTag == 3) {
        g_center.currentNudger.response = RTSilent;
    }
    g_center.currentNudger.defaultNudge = startNudgeTxt.text;
    g_center.currentNudger.defaultReply = startAcknowledgeTxt.text;
    
    [g_var saveLocalVal:g_center.currentNudger.response key:USER_RESPONSE];
    [g_var saveLocalStr:g_center.currentNudger.defaultNudge key:USER_NUDGE];
    [g_var saveLocalStr:g_center.currentNudger.defaultReply key:USER_ACKNOWLEDGE];
}

- (IBAction)onStartNudge:(id)sender {
    UIButton *senderBtn = (UIButton *)sender;
    startTag = senderBtn.tag;
    [startNudgeBtn setImage:[UIImage imageNamed:@"icon-nudge"] forState:UIControlStateNormal];
    [startRumbleBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble"] forState:UIControlStateNormal];
    [startSilentBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble-silent"] forState:UIControlStateNormal];
    if (senderBtn.tag == 3) {
        [startSilentBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble-silent-active"] forState:UIControlStateNormal];
    } else if (senderBtn.tag == 2) {
        [startRumbleBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble-active"] forState:UIControlStateNormal];
    } else {
        [startNudgeBtn setImage:[UIImage imageNamed:@"icon-nudge-active"] forState:UIControlStateNormal];
    }
}

#pragma mark - General
/////////////////////////////////// --------- General ----------- ///////////////////////////////////////////
- (void)hide:(ViewTag)viewTag {
    if (viewTag != VTSetting) [self hideSetting];
//    if (viewTag != VTAuto) [self on];
    if (viewTag != VTProfile) [self onProfileClose:nil];
    if (viewTag != VTSearch) [self onSearchClose:nil];
    if (viewTag != VTAdd) [self onAddClose:nil];
    if (viewTag != VTMenu) [self onMenuClose];
    if (viewTag != VTStart) [self onStartClose:nil];
    if (viewTag != VTGroup) [self onGroupClose:nil];
    if (viewTag != VTGroupSelect) [self onGroupSelectClose:nil];
    if (viewTag != VTNP) [self onNPClose:nil];
}

- (void)showAlert:(NSString *)text {
    alertLab.text = text;
    [UIView transitionWithView:self.view duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        alertView.hidden = NO;
    } completion:^(BOOL completion){
        [self performSelector:@selector(hideAlert) withObject:self afterDelay:3.0];
    }];
}

- (void)hideAlert {
    [UIView transitionWithView:self.view duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        alertView.hidden = YES;
    } completion:^(BOOL completion){
        [self performSelector:@selector(hideAlert) withObject:self afterDelay:3.0];
    }];
}

#pragma mark - iAd
/////////////////////////////// --------- iAd ----------- ///////////////////////////////////////////////
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
