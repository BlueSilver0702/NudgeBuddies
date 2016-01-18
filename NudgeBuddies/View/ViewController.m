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
#import "StreamController.h"
#import <CoreMotion/CoreMotion.h>
#import "UIImagePickerHelper.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "DownPicker.h"

#import "AlertCtrl.h"

@import GoogleMobileAds;

@interface ViewController () <SettingControllerDelegate, SearchControllerDelegate, UITextFieldDelegate, MenuControllerDelegate, NudgeButtonDelegate, AppCenterDelegate, UIScrollViewDelegate, StreamControllerDelegate, GADBannerViewDelegate, UIAlertViewDelegate>
{
    // general
    QBUUser *currentUser;
    AVAudioPlayer *audioPlayer;
    NSArray *alertSoundArr;
    
    IBOutlet GADBannerView *gBannerView;
    
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
    IBOutlet UITextField *groupDropTxt;
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

    // View group pages
    IBOutlet UIView *vGroupView;
    IBOutlet UITextField *vGroupNudgeTxt;
    IBOutlet UITextField *vGroupAcknowledgeTxt;
    IBOutlet UIButton *vGroupPicBtn;
    IBOutlet UILabel *vGroupNameLab;
    IBOutlet UIButton *vGroupNudgeBtn;
    IBOutlet UIButton *vGroupRumbleBtn;
    IBOutlet UIButton *vGroupSilentBtn;
    IBOutlet UIScrollView *vGroupContactScr;
    IBOutlet UIButton *vGroupFavBtn;
    Nudger *vGroup;
    NSMutableArray *vGroupContacts;
    
    IBOutlet UIScrollView *gSelectScroll;
    IBOutlet UIScrollView *gSelectActiveScroll;
    NSMutableArray *gSelectGroupArr;
    NSMutableArray *gSelectActiveArr;
    Nudger *gSelectNudger;
    IBOutlet UIPageControl *gSelectPageCtrl;
    
    
    // favorite page
    CMMotionManager *motionManager;
    // setting page
    SettingController *settingCtrl;
    IBOutlet UIView *settingView;
    IBOutlet UIView *settingCoverView;
    
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
    
    // nudged page
    IBOutlet UIView *nudgedView;
    IBOutlet UILabel *nudgedLab;
    IBOutlet UITextField *nudgedTxt;
    Nudger *nudgedNudger;
    
    // N profile page
    IBOutlet UIView *nProfileView;
    IBOutlet UILabel *nProfileName;
    IBOutlet UITextField *nProfileNudgeTxt;
    IBOutlet UITextField *nProfileReplyTxt;
    IBOutlet UITextField *nProfileDropTxt;
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
    
    // stream page
    IBOutlet UIView *streamView;
    IBOutlet UIView *streamTableContainer;
    IBOutlet UITextField *streamResponseTxt;
    IBOutlet UIButton *streamPicBtn;
    IBOutlet UIButton *streamCountBtn;
    Nudger *streamNudger;
    StreamController *streamCtrl;
    
    // start page
    IBOutlet UIView *startView;
    IBOutlet UIButton *startNudgeBtn;
    IBOutlet UIButton *startRumbleBtn;
    IBOutlet UIButton *startSilentBtn;
    IBOutlet UITextField *startNudgeTxt;
    IBOutlet UITextField *startAcknowledgeTxt;
    NSInteger startTag;
    
    IBOutlet UITextField *startDropText;
    
    // Info module
    IBOutlet UIView *infoView;
    IBOutlet UIButton *infoButton;
    
    // menus module
    MenuController *menuCtrl;
    IBOutlet UIView *menuView;
    NSMutableArray *nudgeButtonArr;
    BOOL stopAccel;
    
    DownPicker        *downPicker;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6]];
//    [SVProgressHUD setForegroundColor:[UIColor colorWithRed:255/255.0 green:130/255.0 blue:64/255.0 alpha:1.0]];
    [SVProgressHUD showWithStatus:@"Connecting..."];
    
    stopAccel = NO;
    iPH = [[UIImagePickerHelper alloc] init];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Apex" ofType:@"caf"];
    NSURL *file = [NSURL fileURLWithPath:path];
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:file error:nil];
    [audioPlayer prepareToPlay];
    
    alertSoundArr = [AlertCtrl initWithAlerts];
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
//    bannerView = [[ADBannerView alloc]initWithFrame:
//                  CGRectMake(0, 518, 320, 50)];
//    // Optional to set background color to clear color
//    [bannerView setBackgroundColor:[UIColor clearColor]];
//    [self.view addSubview: bannerView];
//    [self performSelector:@selector(removeIAD) withObject:nil afterDelay:15];

    gBannerView.adUnitID = @"ca-app-pub-4438140575166637/7856806905";
    gBannerView.rootViewController = self;
    [gBannerView loadRequest:[GADRequest request]];
    gBannerView.delegate = self;
    gBannerView.hidden = YES;
    UIButton *removeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 30, 20, 20)];
    [removeBtn setBackgroundImage:[UIImage imageNamed:@"icon-admob"] forState:UIControlStateNormal];
    [gBannerView addSubview:removeBtn];
    [removeBtn addTarget:self action:@selector(hideAD:) forControlEvents:UIControlEventTouchUpInside];
    
    // **********  search module  ************
    searchDoneButton.hidden = YES;
    searchView.hidden = YES;
    addView.hidden = YES;
    [searchBox addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    searchCtrl = (SearchController *)[mainStoryboard instantiateViewControllerWithIdentifier: @"searchCtrl"];
    [self addChildViewController:searchCtrl];
    [searchView addSubview:searchCtrl.view];
    searchCtrl.delegate = self;
    int tableSize = 0;
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
    [groupNameTxt addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    // **********  view group module  ************
    vGroupView.hidden = YES;

    // **********  view stream module  ************
    streamView.hidden = YES;
    streamCtrl = (StreamController *)[mainStoryboard instantiateViewControllerWithIdentifier: @"streamCtrl"];
    [self addChildViewController:streamCtrl];
    [streamTableContainer addSubview:streamCtrl.view];
    streamCtrl.delegate = self;
    
    // **********  nProfile module  ************
    nProfileView.hidden = YES;
    
    // **********  start module  ************
    startView.hidden = YES;
    
    // **********  info module  ************
    infoView.hidden = YES;
    
    // **********  Nudged module  ************
    nudgedView.hidden = YES;
    
    // **********  init module  ************
    if ([g_var loadLocalBool:USER_NIGHT]) {
        [nightBtn setImage:[UIImage imageNamed:@"bottom-night-active"] forState:UIControlStateNormal];
        g_center.isNight = YES;
    } else {
        [nightBtn setImage:[UIImage imageNamed:@"bottom-night"] forState:UIControlStateNormal];
        g_center.isNight = NO;
    }
    
    [g_center setDelegate:self];
    nudgebuddiesBar.hidden = YES;
    notificationView.hidden = YES;
    initFavView.hidden = YES;
    [initSearchView setFrame:CGRectMake(0, initSearchView.frame.origin.y - initSearchView.frame.size.height, initSearchView.frame.size.width, initSearchView.frame.size.height)];
    [initControlView setFrame:CGRectMake(0, initControlView.frame.origin.y + initControlView.frame.size.height, initControlView.frame.size.width, initControlView.frame.size.height)];
    
    nudgeButtonArr = [NSMutableArray new];
    
    if (g_center.currentUser == nil) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *loginEmail = (NSString *)[userDefaults objectForKey:@"email"];
        NSString *loginPwd = (NSString *)[userDefaults objectForKey:@"pwd"];
        [SVProgressHUD showWithStatus:@"Signing..."];
        [QBRequest logInWithUserEmail:loginEmail password:loginPwd successBlock:^(QBResponse *response, QBUUser *user) {
            // Success, do something
            user.password = loginPwd;
            [g_center initCenter:user];
            [SVProgressHUD setStatus:@"Loading..."];
            
        } errorBlock:^(QBResponse *response) {
            // error handling
            NSLog(@"error: %@", response.error);
            [SVProgressHUD dismiss];
            
            [[[UIAlertView alloc] initWithTitle:@"Warning" message:@"Login Failed!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];

            [self.navigationController popToRootViewControllerAnimated:YES];
        }];
    }
}

- (IBAction)onNightClick:(id)sender {
    if (g_center.isNight) {
        g_center.isNight = NO;
        [g_var saveLocalBool:NO key:USER_NIGHT];
        [nightBtn setImage:[UIImage imageNamed:@"bottom-night"] forState:UIControlStateNormal];
//        AudioServicesPlayAlertSound(1104);
    } else {
        g_center.isNight = YES;
        [g_var saveLocalBool:YES key:USER_NIGHT];
        [nightBtn setImage:[UIImage imageNamed:@"bottom-night-active"] forState:UIControlStateNormal];
        AudioServicesPlayAlertSound(1104);
    }
}

#pragma mark - App Center
- (void)onceConnect {
    currentUser = g_center.currentUser;
    __weak typeof(self) weakSelf = self;
    if (currentUser != nil) {
        [weakSelf registerForRemoteNotifications];
    }
    [UIView animateWithDuration:0.5 animations:^(){
        nudgebuddiesBar.hidden = NO;
        notificationView.hidden = NO;
        initFavView.hidden = NO;
        [initSearchView setFrame:CGRectMake(0, 2, initSearchView.frame.size.width, initSearchView.frame.size.height)];
        [initControlView setFrame:CGRectMake(0, 525, initControlView.frame.size.width, initControlView.frame.size.height)];
    } completion:^(BOOL finished) {
        if (g_center.currentNudger.defaultNudge == nil) {
            [self onStartOpen];
        }
    }];

    [SVProgressHUD dismiss];
}

- (void)onceDisconnected {
//    [self showAlert:@"Accidently disconnected."];
    NSLog(@"Disconnected");
//    [initSearchView setFrame:CGRectMake(0, 2-initSearchView.frame.size.height, initSearchView.frame.size.width, initSearchView.frame.size.height)];
//    [initControlView setFrame:CGRectMake(0, 525+initControlView.frame.size.height, initControlView.frame.size.width, initControlView.frame.size.height)];
}

//- (void)startLoadContactList {
//    [SVProgressHUD showWithStatus:@"Loading contacts..."];
//    [self performSelector:@selector(onLoadingClose) withObject:self afterDelay:2.0];
//}

- (void)onceLoadedContactList {

    [SVProgressHUD dismiss];
    [self display:DTNil];
    
    // **********  favorite module  ************
    motionManager = [CMMotionManager new];
    motionManager.accelerometerUpdateInterval = .05;
    motionManager.gyroUpdateInterval = .05;
    [motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
        [self outputAccelerometer:accelerometerData.acceleration];
        if (error) {
            [self error:err_later];
        }
    }];
    
    if ([FBSDKAccessToken currentAccessToken]) {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me/friends" parameters:@{ @"fields" : @"id"}] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                NSDictionary *dictionary = (NSDictionary *)result;
                NSArray* friends = [dictionary objectForKey:@"data"];
                for (NSDictionary* friend in friends) {
                    NSLog(@"I have a friend named %@ with id", [friend objectForKey:@"id"]);
                    [g_center.fbFriendsArr addObject:friend];
                }
            }
        }];
    }
    
    [g_center connectGroupChat];
}

- (void)onceLoadedGroupList {
    [SVProgressHUD dismiss];
    [self display:DTNil];
}

- (void)onceAddedContact:(Nudger *)nudger {
    [SVProgressHUD dismiss];
    [self display:DTNil];
}

- (void)onceRemovedContact:(Nudger *)nudger {
    [SVProgressHUD dismiss];
    [self display:DTNil];
}

- (void)onceAccepted:(NSString *)from {
    [SVProgressHUD dismiss];
    [self showAlert:[NSString stringWithFormat:@"%@ accepted your buddy invite", from]];
    [self onceNudgeReceived:nil responseType:RTNil];
}

- (void)onceRejected:(NSUInteger)fromID {
    [QBRequest userWithID:fromID successBlock:^(QBResponse *response, QBUUser *user) {
        [SVProgressHUD dismiss];
        [self showAlert:[NSString stringWithFormat:@"%@ has rejected your nudgebuddy request.", user.fullName]];
        [self onceNudgeReceived:nil responseType:RTNil];
    } errorBlock:^(QBResponse *response) {
    }];
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
    [SVProgressHUD dismiss];
}

- (void)onceNudged:(Nudger *)nudger responseType:(ResponseType)type  message:(NSString *)message {
    [self onceNudgeReceived:nudger responseType:type];
    [self onNudgedOpen:nudger message:message];
    [g_center getUnreadMessages:^(NSInteger unreadCount, NSDictionary *dialogs) {
        NSLog(@"%lu, %@", unreadCount, dialogs);
        [UIApplication sharedApplication].applicationIconBadgeNumber = unreadCount;
    }];
}

- (void)onceNudgeReceived:(Nudger *)nudger responseType:(ResponseType)type {
    if (nudger == nil) {
        if (g_center.isNight) {
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        } else {
            [audioPlayer play];
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        }
        return;
    }
    if (type == RTNudge || type == RTAnnoy) {
        if (!g_center.isNight && !nudger.silent) {
            [audioPlayer play];
        }
    } else if (type == RTSilent || type == RTAnnoySilent) {
        if (!g_center.isNight) {
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        }
//    } else if (type == RTAnnoy || type ==) {
//        if (!g_center.isNight) {
//            if (!nudger.silent) [audioPlayer play];
//            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
//        }
    } else {
        if (!g_center.isNight) {
            if (!nudger.silent) [audioPlayer play];
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        }
    }
    
}

- (void) display:(DisplayType)type {
    int barWidth = 0;
    int width = nudgebuddiesBar.frame.size.height;
    int favTmp = 0;
    
    [[nudgebuddiesBar subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [[initFavView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [[notificationView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    favViewArray = [NSMutableArray new];
    
    NSMutableArray *notiArr = [NSMutableArray new];
    NSMutableArray *contArr = [NSMutableArray new];
    NSMutableArray *favoArr = [NSMutableArray new];
    
    for (NSInteger i=g_center.notificationArray.count-1; i>=0; i--) {
        Nudger *nudger = [g_center.notificationArray objectAtIndex:i];
        if (nudger.status == NSReject) {
            continue;
        } else if (nudger.isFavorite && notiArr.count <8) {
            if (notiArr.count == 0 && nudger.isNew && type == DTMessage) {
                [notiArr addObject:nudger];
            } else {
                [favoArr addObject:nudger];
            }
        } else if ((nudger.isNew || nudger.status == NSInvited) && notiArr.count <3) {
            [notiArr addObject:nudger];
        } else {
            [contArr addObject:nudger];
        }
    }
    
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, initFavView.frame.size.width, initFavView.frame.size.height)];
    [closeButton addTarget:self action:@selector(hide:) forControlEvents:UIControlEventTouchUpInside];
    [initFavView addSubview:closeButton];
    
//    UIButton *closeNotiButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, notificationView.frame.size.width, notificationView.frame.size.height)];
//    [closeNotiButton addTarget:self action:@selector(hide:) forControlEvents:UIControlEventTouchUpInside];
//    [notificationView addSubview:closeNotiButton];
    
    // contact list
    contArr = (NSMutableArray *)[self sort:contArr];
    for (Nudger *nudger in contArr) {
        NudgeButton *nudgeBtn = [NudgeButton new];
        [self addChildViewController:nudgeBtn];
        nudgeBtn.delegate = self;
        
        nudger.menuPos = 1;
        [nudgebuddiesBar addSubview:nudgeBtn.view];
        [nudgeBtn.view setFrame:CGRectMake(barWidth, 0, width, width)];
        barWidth += 70;
        [nudgebuddiesBar setContentSize:CGSizeMake(barWidth+40, width)];
        [nudgeBtn initNudge:nudger];
    }

    // favorite list
    for (Nudger *nudger in favoArr) {
        NudgeButton *nudgeBtn = [NudgeButton new];
        [self addChildViewController:nudgeBtn];
        nudgeBtn.delegate = self;
        
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
            [nudgeBtn initNudge:nudger];
        }
        if (favTmp <= 8) {
            [favViewArray addObject:nudgeBtn.view];
            [nudgeBtn initNudge:nudger];
            [initFavView addSubview:nudgeBtn.view];
        }
    }

    // notification list
    for (int arrIndex=0; arrIndex<notiArr.count; arrIndex ++) {
        Nudger *nudger = [notiArr objectAtIndex:arrIndex];
        NudgeButton *nudgeBtn = [NudgeButton new];
        [self addChildViewController:nudgeBtn];
        nudgeBtn.delegate = self;
        nudger.menuPos = 0;
        
        switch (arrIndex) {
            case 0:
                if (notiArr.count == 3) {
                    [nudgeBtn.view setFrame:CGRectMake(112, 0, width, width)];
                } else if (notiArr.count == 2) {
                    [nudgeBtn.view setFrame:CGRectMake(112, 0, width, width)];
                } else {
                    [nudgeBtn.view setFrame:CGRectMake(112, 0, width, width)];
                }
                if (nudger.status == NSFriend && type == DTMessage) {
                    nudger.shouldAnimate = NO;
                    UIView *oldView = [nudgedView viewWithTag:1000];
                    if (oldView)
                        [oldView removeFromSuperview];
                    [nudgeBtn removeFav];
                    [nudgeBtn.view setTag:1000];
                    [nudgedView addSubview:nudgeBtn.view];
                } else {
                    [initFavView addSubview:nudgeBtn.view];
                }
                break;
            case 1:
                if (notiArr.count == 2) {
                    [nudgeBtn.view setFrame:CGRectMake(15, 0, width, width)];
                } else {
                    [nudgeBtn.view setFrame:CGRectMake(211, 0, width, width)];
                }
                [initFavView addSubview:nudgeBtn.view];
                break;
            case 2:
            default:
                [nudgeBtn.view setFrame:CGRectMake(15, 0, width, width)];
                [initFavView addSubview:nudgeBtn.view];
                break;
        }
        
        [nudgeBtn initNudge:nudger];
    }
}

- (NSMutableArray *)sort:(NSMutableArray *)sourceArr {
    NSMutableArray *retArr;
    retArr = (NSMutableArray *)[sourceArr sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        Nudger *nuObj1 = (Nudger *)obj1;
        Nudger *nuObj2 = (Nudger *)obj2;
        NSString *user1 = nuObj1.type==NTGroup?nuObj1.group.gName:nuObj1.user.fullName;
        NSString *user2 = nuObj2.type==NTGroup?nuObj2.group.gName:nuObj2.user.fullName;
        user1 = [user1 uppercaseString];
        user2 = [user2 uppercaseString];
        if (nuObj1.isNew && nuObj2.isNew) return NSOrderedSame;
        else if (nuObj1.isNew && !nuObj2.isNew) return NSOrderedAscending;
        else if (!nuObj1.isNew && nuObj2.isNew) return NSOrderedDescending;
        else if (nuObj1.isNew && nuObj2.status == NSInvited) return NSOrderedAscending;
        else if (nuObj1.status == NSInvited && nuObj2.status == NSFriend) return NSOrderedAscending;
        else return [user1 compare:user2];
    }];
    return retArr;
}

- (void)onceErr {
    [self error:err_later];
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

- (void)onSendNudge:(Nudger *)nudger frame:(CGRect)rect {

    [self onMenuNudged:nudger];
//    nudger.favCount += 30;
//    [self display];
    
}

- (void)onFavClicked:(Nudger *)nudger {
    nudger.isFavorite = NO;
    [self display:DTNil];
    
    QBCOCustomObject *object = [QBCOCustomObject customObject];
    object.className = @"NudgerBuddy"; // your Class name
    object.ID = nudger.metaID;

    [object.fields setObject:[NSNumber numberWithBool:NO] forKey:@"Favorite"];
    [QBRequest updateObject:object successBlock:^(QBResponse *response, QBCOCustomObject *object) {
        NSLog(@"Favorite Removed!");
    } errorBlock:^(QBResponse *response) {
        [self error:err_later];
    }];
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
        newRect = CGRectMake(rect.origin.x-nudgebuddiesBar.contentOffset.x, rect.origin.y+nudgebuddiesBar.frame.origin.y, rect.size.width, rect.size.height);
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
        if (!menu.triDirection) [menuView setFrame:CGRectMake(menu.menuPoint.x, menu.menuPoint.y-15, size.width, size.height+15)];
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

    CGRect menuRect = menuView.frame;
    if (menuRect.origin.y + menuRect.size.height > 568) {
        [menuView setFrame:CGRectMake(menuRect.origin.x, 558-menuRect.size.height, menuRect.size.width, menuRect.size.height)];
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
        [g_center updateContact:nudger success:^(BOOL success) {}];
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
        openNP = nudger;
        [self onNPOpen:nil];
    } else if (menuReturn == MRSilent) {
        NSLog(@"MRSilent");
        [g_center updateContact:nudger success:^(BOOL success) {}];
    } else if (menuReturn == MRStream || menuReturn == MRStreamGroup) {
        [self onMenuClose];
        menuCtrl.isOpen = NO;
        streamNudger = nudger;
        [self onStreamOpen:nil];
        NSLog(@"MRStream");
    } else if (menuReturn == MRViewGroup) {
        [self onMenuClose];
        menuCtrl.isOpen = NO;
        NSLog(@"MRViewGroup");
        vGroup = nudger;
        [self onVGropOpen:nil];
    } else if (menuReturn == MRAdd) {
        [self onMenuClose];
        menuCtrl.isOpen = NO;

        if (nudger.type == NTGroup) {
            [SVProgressHUD show];
            nudger.accept = YES;
            [g_center updateContact:nudger success:^(BOOL success) {
                nudger.type = NTGroup;
                nudger.shouldAnimate = NO;
                nudger.isNew = NO;
                [g_center add:nudger];
            }];
        } else {
            [g_center addBuddy:nudger success:^(BOOL success){
                if (!success) {
                    [SVProgressHUD showErrorWithStatus:err_later];
                } else {
                    [SVProgressHUD showSuccessWithStatus:@"Successfully added to your contact list."];
                }
            }];
        }
    } else if (menuReturn == MRReject) {
        [self onMenuClose];
        menuCtrl.isOpen = NO;
        NSLog(@"MRReject");
        [SVProgressHUD showWithStatus:@"Please wait..."];
        if (nudger.type == NTGroup) {
            [SVProgressHUD show];
            [g_center removeGroup:nudger success:^(BOOL success) {
                
            }];
        } else {
            [[QBChat instance] rejectAddContactRequest:nudger.user.ID completion:^(NSError * _Nullable error) {
                [g_center remove:nudger];
            }];
        }
    }
}

- (void)onMenuNudged:(Nudger *)nudger {
    if (nudger != nil) {
//        NSLog(@"%@", nudger);
//    AudioServicesPlaySystemSound(1103);
        [g_center isBlock:nudger success:^(BOOL isBlock) {
            if (isBlock) {
                [self showAlert:@"Your nudge was unable to be delivered due to the blocked status."];
            } else {
                [g_center sendMessage:nudger txt:nil success:^(BOOL success) {
                    
                    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
                    [self showAlert:[NSString stringWithFormat:@"You sent nudge to %@",nudger.type==NTGroup?nudger.group.gName:nudger.user.fullName]];
                    
                    if (success) {
                        nudger.favCount ++;
                        QBCOCustomObject *object = [QBCOCustomObject customObject];
                        object.className = @"NudgerBuddy"; // your Class name
                        object.ID = nudger.metaID;
                        
                        [object.fields setObject:[NSNumber numberWithInteger:nudger.favCount] forKey:@"FavCount"];
                        [QBRequest updateObject:object successBlock:^(QBResponse *response, QBCOCustomObject *object) {
                            if (nudger.isFavorite) [self display:DTNil];
                        } errorBlock:^(QBResponse *response) {
                            NSLog(@"Empty Meta");
                        }];
                    } else {
                        [SVProgressHUD showErrorWithStatus:@"Failed to send nudge. Please try later."];
                    }
                }];
            }
        }];
    }
    [self onMenuClose];
    menuCtrl.isOpen = NO;
}

- (void)onMenuNudged:(Nudger *)nudger message:(NSString *)text {
    if (nudger != nil) {
        [g_center isBlock:nudger success:^(BOOL isBlock) {
            if (isBlock) {
                [self showAlert:@"Your nudge was unable to be delivered due to the blocked status."];
            } else {
                
                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
                [self showAlert:[NSString stringWithFormat:@"You sent nudge to %@",nudger.type==NTGroup?nudger.group.gName:nudger.user.fullName]];
                
                [g_center sendMessage:nudger txt:text success:^(BOOL success) {
                    if (success) {
                        nudger.favCount ++;
                        QBCOCustomObject *object = [QBCOCustomObject customObject];
                        object.className = @"NudgerBuddy"; // your Class name
                        object.ID = nudger.metaID;
                        
                        [object.fields setObject:[NSNumber numberWithInteger:nudger.favCount] forKey:@"FavCount"];
                        [QBRequest updateObject:object successBlock:^(QBResponse *response, QBCOCustomObject *object) {
                            if (nudger.isFavorite) [self display:DTNil];
                        } errorBlock:^(QBResponse *response) {
                            NSLog(@"Empty Meta");
                        }];
                    } else {
                        [SVProgressHUD showErrorWithStatus:@"Failed to send nudge. Please try later."];
                    }
                }];
            }
        }];
    }
    [self onMenuClose];
    menuCtrl.isOpen = NO;
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
        [self error:err_later];
    }];
}

- (IBAction)onProfileSave:(id)sender {
    [SVProgressHUD show];
    if (profilePictureUpdate) {
        [QBRequest TUploadFile:g_var.profileImg fileName:@"profile.jpg" contentType:@"image/jpeg" isPublic:NO successBlock:^(QBResponse *response, QBCBlob *blob) {
            [g_var saveFile:g_var.profileImg uid:blob.ID];
            QBUpdateUserParameters *updateParameters = [QBUpdateUserParameters new];
            updateParameters.blobID = blob.ID;
            updateParameters.oldPassword = currentUser.password;
            updateParameters.password = passwd.text;
            [QBRequest updateCurrentUser:updateParameters successBlock:^(QBResponse *response, QBUUser *user) {
                [SVProgressHUD dismiss];
                [self onProfileClose:nil];
            } errorBlock:^(QBResponse *response) {
                [self error:err_later];
            }];
        } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
            // handle progress
            NSLog(@"profile status err");
        } errorBlock:^(QBResponse *response) {
            [self error:err_later];
        }];
    } else {
        QBUpdateUserParameters *updateParameters = [QBUpdateUserParameters new];
        updateParameters.oldPassword = currentUser.password;
        updateParameters.password = passwd.text;
        [QBRequest updateCurrentUser:updateParameters successBlock:^(QBResponse *response, QBUUser *user) {
            // User updated successfully
            NSLog(@"%@", user);
            [SVProgressHUD dismiss];
            [self onProfileClose:nil];
        } errorBlock:^(QBResponse *response) {
            [self error:err_later];
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
    if (menuCtrl.isOpen) return;
    for (int i=0; i<favViewArray.count; i++) {
        UIView *favView = [favViewArray objectAtIndex:i];
        CGPoint size;
        if (i==0) size = CGPointMake(FAV_1.x + acceleration.x*15, FAV_1.y + acceleration.y*15);
        else if (i==1) size = CGPointMake(FAV_2.x + acceleration.x*25*(-0.8) - acceleration.z*8, FAV_2.y + acceleration.y*25*(-0.9) - acceleration.z*10);
        else if (i==2) size = CGPointMake(FAV_3.x + acceleration.x*25*(0.9) - acceleration.z*12, FAV_3.y + acceleration.y*25*(-0.8) + acceleration.z*8);
        else if (i==3) size = CGPointMake(FAV_4.x + acceleration.x*30*(-0.5) + acceleration.z*15, FAV_4.y + acceleration.y*30*0.86 - acceleration.z*2);
        else if (i==4) size = CGPointMake(FAV_5.x + acceleration.x*30*(0.86) - acceleration.z*8, FAV_5.y + acceleration.y*30*(0.5) + acceleration.z*12);
        else if (i==5) size = CGPointMake(FAV_6.x + acceleration.x*35*(0.9) - acceleration.z*4, FAV_6.y + acceleration.y*25*(-0.9) - acceleration.z*8);
        else if (i==6) size = CGPointMake(FAV_7.x + acceleration.x*35*(-0.5) + acceleration.z*2, FAV_7.y + acceleration.y*30*(0.8) - acceleration.z*10);
        else if (i==7) size = CGPointMake(FAV_8.x + acceleration.x*35*(0.4) - acceleration.z*5, FAV_8.y + acceleration.y*35*(-0.9) + acceleration.z*5);
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
    } else if (status == 2) {
        [g_center logout:^(BOOL success) {
            if (success) {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }];
    }
}

- (void)onSettingUpdate {
    if (g_center.isNight) {
        [nightBtn setImage:[UIImage imageNamed:@"bottom-night-active"] forState:UIControlStateNormal];
    } else {
        [nightBtn setImage:[UIImage imageNamed:@"bottom-night"] forState:UIControlStateNormal];
    }
    
    [self display:DTNil];
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
    [self onSearchClose:nil];
}

- (void)textFieldDidChange:(UITextField *)textField {
    if (textField.tag == 100) {
        groupNameLab.text = textField.text;
        return;
    }
    if (textField.text.length < 3) {
        if (textField.text.length ==1) {
            [self showAlert:@"Search text should longer than 3 characters."];
        }
        return;
    }
    searchView.hidden = NO;
    [self hide:VTSearch];
    
    [QBRequest usersWithFullName:textField.text page:[QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:10]
                    successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
                        NSMutableArray *searchArr = [NSMutableArray new];
                        for (QBUUser *searched in users) {
                            if (searched.ID != currentUser.ID) {
                                [searchArr addObject:searched];
                            }
                        }
                        int size = [searchCtrl searchResult:searchArr];
                        [searchView setFrame:CGRectMake(searchView.frame.origin.x, searchView.frame.origin.y, searchView.frame.size.width, 0)];
                        [UIView transitionWithView:searchView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                            [searchView setFrame:CGRectMake(searchView.frame.origin.x, searchView.frame.origin.y, searchView.frame.size.width, size)];
                            [searchCtrl.view setFrame:CGRectMake(0, 0, searchCtrl.view.frame.size.width, size)];
                        } completion:nil];
                        [UIView transitionWithView:searchDoneButton duration:0.8 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                            searchDoneButton.hidden = NO;
                        } completion:nil];
                    } errorBlock:^(QBResponse *response) {
                        [self error:@"No Result."];
                    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
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
    }
        [UIView transitionWithView:addView duration:0.1 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            addView.hidden = YES;
        } completion:nil];

}

#pragma mark - Nudged Page
/////////////////////////////////////// --------- Nudged Page ----------- ///////////////////////////////////////
- (void)onNudgedOpen:(Nudger *)nudger message:(NSString *)msg {
    [self hide:VTNudged];
    nudgedNudger = nudger;
    [nudgedLab setText:msg];
    [nudgedTxt setText:nudger.defaultReply];
    [UIView transitionWithView:nudgedView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        nudgedView.hidden = NO;
    } completion:^(BOOL success) {
        [self display:DTMessage];
    }];
    
    [self performSelector:@selector(removeNudged) withObject:nil afterDelay:5];
}

- (void)removeNudged {
    [self onNudgedClose:nil];
    [self display:DTNil];
}

- (IBAction)onNudgedClose:(id)sender {
    [UIView transitionWithView:nudgedView duration:0.1 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        nudgedView.hidden = YES;
    } completion:nil];
    
}

- (IBAction)onNudgedResponse:(id)sender {
    [self onMenuNudged:nudgedNudger message:nudgedTxt.text];
    [self onNudgedClose:nil];
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
    
    for (Nudger *group in g_center.notificationArray) {
        if (group.type == NTGroup && group.status == NSFriend) {
            BOOL isActive = [group.group.gUsers linq_any:^BOOL(id item) {
                return [item isEqualToNumber:[NSNumber numberWithInteger:gSelectNudger.user.ID]];
            }];
            if (isActive) {
                group.other = 1;
                [gSelectActiveArr addObject:group];
            } else {
                [gSelectGroupArr addObject:group];
            }
        }
    }
    
    
    [self initGroupSelect];
    [UIView transitionWithView:self.view duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        groupSelectView.hidden = NO;
    } completion:nil];
    //[gSelectScroll setDelegate:self];
}

- (void)initGroupSelect {
    [[gSelectScroll subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [[gSelectActiveScroll subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for (int i=0; i<gSelectGroupArr.count; i++) {
        Nudger *group = [gSelectGroupArr objectAtIndex:i];
        
        int row = (int)i/3.0;
        int cell = i%3;
        int page = (int)i/6.0;
        [gSelectScroll setContentSize:CGSizeMake((page+1)*gSelectScroll.frame.size.width, gSelectScroll.frame.size.height)];
        UIView *gView = [[UIView alloc] initWithFrame:CGRectMake(5+cell*91+page*290, 3+row*78-page*78*2, 91, 78)];
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
    
    gSelectPageCtrl.numberOfPages = (int)gSelectGroupArr.count/6.0+1;
    
    [gSelectActiveScroll setContentSize:CGSizeMake(gSelectActiveArr.count*91, gSelectActiveScroll.frame.size.height)];
    for (int i=0; i<gSelectActiveArr.count; i++) {
        Nudger *group = [gSelectActiveArr objectAtIndex:i];
        UIView *gView = [[UIView alloc] initWithFrame:CGRectMake(i*91, 0, 91, 78)];
        UIButton *grBtn = [[UIButton alloc] initWithFrame:CGRectMake(21, 10, 48, 48)];
        [grBtn setBackgroundImage:[UIImage imageNamed:@"user-group-empty"] forState:UIControlStateNormal];
        if (group.group.gBlobID) {
            [grBtn setImage:[UIImage imageWithData:[g_var loadFile:group.group.gBlobID]] forState:UIControlStateNormal];
        }
        [grBtn setTag:i];
        if (group.other != 1) [grBtn addTarget:self action:@selector(removeGSelect:) forControlEvents:UIControlEventTouchUpInside];
        [gView addSubview:grBtn];
        UIImageView *plusImg = [[UIImageView alloc] initWithFrame:CGRectMake(55, 6, 18, 18)];
        [plusImg setImage:[UIImage imageNamed:@"icon-minus"]];
        grBtn.layer.masksToBounds = YES;
        grBtn.layer.cornerRadius = 24.0;
        if (group.other != 1) [gView addSubview:plusImg];
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
    [SVProgressHUD show];
    for (Nudger *group in gSelectActiveArr) {
        if (group.other == 1) {
            continue;
        }
        QBChatDialog *updateDialog = [[QBChatDialog alloc] initWithDialogID:group.group.gID type:QBChatDialogTypeGroup];
        updateDialog.pushOccupantsIDs = @[[NSString stringWithFormat:@"%lu",gSelectNudger.user.ID]];
        
        [group.group.gUsers addObject:[NSNumber numberWithInteger:gSelectNudger.user.ID]];

        [QBRequest updateDialog:updateDialog successBlock:^(QBResponse *responce, QBChatDialog *dialog) {

            QBChatMessage *inviteMessage = [self createChatNotificationForGroupChat:dialog];
            inviteMessage.recipientID = gSelectNudger.user.ID;
            
            [[QBChat instance] sendSystemMessage:inviteMessage completion:^(NSError * _Nullable error) {
                [SVProgressHUD dismiss];
                [self onGroupSelectClose:nil];
            }];
        } errorBlock:^(QBResponse *response) {
            [self error:err_later];
        }];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    gSelectPageCtrl.currentPage = scrollView.contentOffset.x/scrollView.frame.size.width;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    gSelectPageCtrl.currentPage = scrollView.contentOffset.x/scrollView.frame.size.width;
}

#pragma mark - Add Group
//////////////////////////////////// --------- Add Group View ----------- //////////////////////////////////////////
- (IBAction)onGropOpen:(id)sender {
    [self setAcademies:alertSoundArr textField:groupDropTxt];
    [downPicker setValueAtIndex:-1];
    
    [self hide:VTGroup];
    if (groupView.hidden == NO) {
        [self onGroupClose:nil];
        return;
    }
    
    groupNameLab.text = @"";
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
    groupFavBtn.hidden = YES;
    [groupNameTxt setText:@""];
    [groupNudgeBtn setImage:[UIImage imageNamed:@"icon-nudge-active"] forState:UIControlStateNormal];
    [groupRumbleBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble"] forState:UIControlStateNormal];
    [groupSilentBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble-silent"] forState:UIControlStateNormal];
    [groupAnnoyBtn setImage:[UIImage imageNamed:@"icon-nudge-annoy"] forState:UIControlStateNormal];
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
//        if (!nudger.isFavorite) continue;
        
        UIView *contactView = [[UIView alloc] initWithFrame:CGRectMake(initPosX, 0, 63, 59)];
        UIButton *imgView = [[UIButton alloc] initWithFrame:CGRectMake(3, 10, 48, 48)];
        [imgView setBackgroundColor:[UIColor colorWithRed:78/255.0 green:96/255.0 blue:110/255.0 alpha:1.0]];
        [imgView setTitle:[nudger getName] forState:UIControlStateNormal];
        NSData *profileData = [g_var loadFile:nudger.user.blobID];
        [imgView setImage:[UIImage imageWithData:profileData] forState:UIControlStateNormal];
        imgView.layer.masksToBounds = YES;
        imgView.layer.cornerRadius = imgView.frame.size.width/2.0;
        [imgView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        imgView.titleLabel.font = [UIFont systemFontOfSize:18.0];
        [imgView addTarget:self action:@selector(onGroupItemRemoved:) forControlEvents:UIControlEventTouchUpInside];
        UIButton *minusBtn = [[UIButton alloc] initWithFrame:CGRectMake(35, 5, 18, 18)];
        [minusBtn setImage:[UIImage imageNamed:@"icon-minus"] forState:UIControlStateNormal];
        [minusBtn setTag:nudger.user.ID];
        [minusBtn addTarget:self action:@selector(onGroupItemRemoved:) forControlEvents:UIControlEventTouchUpInside];
        [contactView addSubview:imgView];
        [contactView addSubview:minusBtn];
        initPosX += 72;
        [groupContactScr addSubview:contactView];
        [groupContactScr setContentSize:CGSizeMake(initPosX+10, groupContactScr.frame.size.height)];
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
    [SVProgressHUD show];

    QBChatDialog *chatDialog = [[QBChatDialog alloc] initWithDialogID:nil type:QBChatDialogTypeGroup];
    chatDialog.name = groupNameTxt.text;

    NSMutableArray *contactIDs = [NSMutableArray new];
    for (Nudger *nudger in groupContacts) {
        [contactIDs addObject:[NSNumber numberWithInteger:nudger.user.ID]];
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
        [object.fields setObject:[NSNumber numberWithInteger:openGroup.favCount] forKey:@"FavCount"];
        [object.fields setObject:[NSNumber numberWithInteger:openGroup.response] forKey:@"NudgerType"];
        [object.fields setObject:[NSNumber numberWithBool:openGroup.silent] forKey:@"Silent"];
        [object.fields setObject:[NSNumber numberWithBool:openGroup.block] forKey:@"Block"];
        [object.fields setObject:[NSNumber numberWithBool:YES] forKey:@"Accept"];
        [object.fields setObject:[NSNumber numberWithInteger:downPicker.selectedIndex] forKey:@"Alert"];
        Group *nGroup = [Group new];
        nGroup.gID = createdDialog.ID;
        nGroup.gName = groupNameTxt.text;
        nGroup.gUsers = contactIDs;
        openGroup.group = nGroup;
        if (groupPicUpdate) {
            [QBRequest TUploadFile:groupPicData fileName:@"group.jpg" contentType:@"image/jpeg" isPublic:NO successBlock:^(QBResponse *response, QBCBlob *uploadedBlob) {
                NSUInteger uploadedFileID = uploadedBlob.ID;
                nGroup.gBlobID = uploadedFileID;
                createdDialog.photo = [NSString stringWithFormat:@"%lu", uploadedFileID];
                openGroup.group.gBlobID = uploadedFileID;
                [g_var saveFile:groupPicData uid:uploadedFileID];
                [QBRequest updateDialog:createdDialog successBlock:^(QBResponse *responce, QBChatDialog *dialog) {
                    [QBRequest createObject:object successBlock:^(QBResponse *response, QBCOCustomObject *object) {
                        [SVProgressHUD dismiss];
                        [self onGroupClose:nil];
                        openGroup.isNew = NO;
                        openGroup.shouldAnimate = NO;
                        openGroup.alertSound = downPicker.selectedIndex;
                        [g_center add:openGroup];
                        [self sendGroupInvite:createdDialog];
                    } errorBlock:^(QBResponse *response) {
                        [SVProgressHUD dismiss];
                        [self error:err_later];
                    }];
                } errorBlock:^(QBResponse *response) {
                    [self error:err_later];
                }];
            } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
            } errorBlock:^(QBResponse *response) {
                [self error:err_later];
            }];
        } else {
            [QBRequest createObject:object successBlock:^(QBResponse *response, QBCOCustomObject *object) {
                [SVProgressHUD dismiss];
                [self onGroupClose:nil];
                openGroup.isNew = NO;
                openGroup.shouldAnimate = NO;
                openGroup.alertSound = downPicker.selectedIndex;
                [g_center add:openGroup];
                [self sendGroupInvite:createdDialog];
            } errorBlock:^(QBResponse *response) {
                [self error:err_later];
            }];
        }
    } errorBlock:^(QBResponse *response) {
        [self error:err_later];
    }];
}

- (void) sendGroupInvite:(QBChatDialog *)dialog {
    for (NSString *occupantID in dialog.occupantIDs) {
        
        QBChatMessage *inviteMessage = [self createChatNotificationForGroupChat:dialog];
        
        // send notification
        //
        inviteMessage.recipientID = [occupantID integerValue];
        
        [[QBChat instance] sendSystemMessage:inviteMessage completion:^(NSError * _Nullable error) {
            
        }];
    }
}

- (QBChatMessage *)createChatNotificationForGroupChat:(QBChatDialog *)dialog
{
    // create message:
    QBChatMessage *inviteMessage = [QBChatMessage message];
    
    NSMutableDictionary *customParams = [NSMutableDictionary new];
    customParams[@"name"] = dialog.name;
    customParams[@"_id"] = dialog.ID;
    customParams[@"blob"] = dialog.photo;
    NSMutableArray *occuIDs = [NSMutableArray new];
    for (NSNumber *num in dialog.occupantIDs) {
        if (num.integerValue != currentUser.ID) {
            [occuIDs addObject:num];
        }
    }
    customParams[@"occupants_ids"] = [occuIDs componentsJoinedByString:@","];
    customParams[@"notification_type"] = @"1";
    
    inviteMessage.customParameters = customParams;
    
    return inviteMessage;
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
        [self error:err_later];
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

#pragma mark - View Group
//////////////////////////////////// --------- View Group Page ----------- //////////////////////////////////////////
- (IBAction)onVGropOpen:(id)sender {
    [self hide:VTGroup];
    if (vGroupView.hidden == NO) {
        [self onVGroupClose:nil];
        return;
    }
    [SVProgressHUD show];
    vGroupContacts = [NSMutableArray new];
    
    [vGroupNameLab setText:vGroup.group.gName];
    if (vGroup.isFavorite) vGroupFavBtn.hidden = NO;
    else vGroupFavBtn.hidden = YES;

    vGroupNudgeTxt.text = vGroup.defaultNudge;
    vGroupAcknowledgeTxt.text = vGroup.defaultReply;
    if (vGroup.group.gBlobID) [vGroupPicBtn setBackgroundImage:[UIImage imageWithData:[g_var loadFile:vGroup.group.gBlobID]] forState:UIControlStateNormal];
    else [vGroupPicBtn setBackgroundImage:[UIImage imageNamed:@"user-group"] forState:UIControlStateNormal];
    [vGroupNudgeBtn setImage:[UIImage imageNamed:@"icon-nudge"] forState:UIControlStateNormal];
    [vGroupRumbleBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble"] forState:UIControlStateNormal];
    [vGroupSilentBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble-silent"] forState:UIControlStateNormal];
    if (vGroup.response == RTNudge) [vGroupNudgeBtn setImage:[UIImage imageNamed:@"icon-nudge-active"] forState:UIControlStateNormal];
    else if (vGroup.response == RTRumble) [vGroupRumbleBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble-active"] forState:UIControlStateNormal];
    else if (vGroup.response == RTSilent) [vGroupSilentBtn setImage:[UIImage imageNamed:@"icon-nudge-rumble-silent-active"] forState:UIControlStateNormal];

    [QBRequest usersWithIDs:vGroup.group.gUsers page:[QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:20] successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
        for (QBUUser *user in users) {
            Nudger *nUser = [[Nudger alloc] initWithUser:user];
            [vGroupContacts addObject:nUser];
        }
        [self addVGroupItems];
        [UIView transitionWithView:vGroupView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            vGroupView.hidden = NO;
        } completion:nil];
        [SVProgressHUD dismiss];
    } errorBlock:^(QBResponse *response) {
        [self error:@"Connection Error"];
    }];
}

- (void) addVGroupItems {
    int initPosX = 8;
    [[vGroupContactScr subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for (Nudger *nudger in vGroupContacts) {
        UIView *contactView = [[UIView alloc] initWithFrame:CGRectMake(initPosX, 0, 63, 59)];
        UIButton *imgView = [[UIButton alloc] initWithFrame:CGRectMake(3, 10, 48, 48)];
        [imgView setBackgroundColor:[UIColor colorWithRed:78/255.0 green:96/255.0 blue:110/255.0 alpha:1.0]];
        [imgView setTitle:[nudger getName] forState:UIControlStateNormal];
        NSData *profileData = [g_var loadFile:nudger.user.blobID];
        if (profileData == nil) {
            [QBRequest downloadFileWithID:nudger.user.blobID successBlock:^(QBResponse *response, NSData *fileData) {
                [g_var saveFile:fileData uid:nudger.user.blobID];
                UIImage *img = [UIImage imageWithData:fileData];
                [imgView setBackgroundImage:img forState:UIControlStateNormal];
            } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
            } errorBlock:^(QBResponse *response) {
            }];
        } else {
            [imgView setImage:[UIImage imageWithData:profileData] forState:UIControlStateNormal];
        }
        imgView.layer.masksToBounds = YES;
        imgView.layer.cornerRadius = imgView.frame.size.width/2.0;
        [imgView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        imgView.titleLabel.font = [UIFont systemFontOfSize:18.0];
//        [imgView addTarget:self action:@selector(onGroupItemRemoved:) forControlEvents:UIControlEventTouchUpInside];
//        UIButton *minusBtn = [[UIButton alloc] initWithFrame:CGRectMake(35, 5, 18, 18)];
//        [minusBtn setImage:[UIImage imageNamed:@"icon-minus"] forState:UIControlStateNormal];
//        [minusBtn setTag:nudger.user.ID];
//        [minusBtn addTarget:self action:@selector(onGroupItemRemoved:) forControlEvents:UIControlEventTouchUpInside];
        [contactView addSubview:imgView];
//        [contactView addSubview:minusBtn];
        initPosX += 72;
        [vGroupContactScr addSubview:contactView];
        [vGroupContactScr setContentSize:CGSizeMake(initPosX+10, vGroupContactScr.frame.size.height)];
    }
}

- (IBAction)onVGroupClose:(id)sender {
    [UIView transitionWithView:vGroupView duration:0.1 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        vGroupView.hidden = YES;
    } completion:nil];
}

- (IBAction)onVGroupDelete:(id)sender {
    [SVProgressHUD show];
    [QBRequest deleteDialogsWithIDs:[NSSet setWithObject:vGroup.group.gID] forAllUsers:YES
                       successBlock:^(QBResponse *response, NSArray *deletedObjectsIDs, NSArray *notFoundObjectsIDs, NSArray *wrongPermissionsObjectsIDs) {
                           //[SVProgressHUD showSuccessWithStatus:@"Successfully removed!"];
                           [g_center remove:vGroup];
                           [self onVGroupClose:nil];
                       } errorBlock:^(QBResponse *response) {
                           [SVProgressHUD showErrorWithStatus:@"You are not allowed to delete this Group."];
                           [self onVGroupClose:nil];
                       }];
}

#pragma mark - nProfile
/////////////////////////////////// --------- nProfile View ----------- ///////////////////////////////////////////
- (IBAction)onNPOpen:(id)sender {
    [self setAcademies:alertSoundArr textField:nProfileDropTxt];
    [downPicker setValueAtIndex:openNP.alertSound];
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
    nProfileName.text = openNP.type==NTGroup?openNP.group.gName:openNP.user.fullName;
    
    NSUInteger blobID = openNP.type==NTGroup?openNP.group.gBlobID:openNP.user.blobID;
    NSData *imgData = [g_var loadFile:blobID];
    if (imgData != nil) {
        [nProfilePicBtn setBackgroundImage:[UIImage imageWithData:imgData] forState:UIControlStateNormal];
    } else if (!blobID) {
        if (openNP.type == NTGroup) {
            [nProfilePicBtn setBackgroundImage:[UIImage imageNamed:@"user-group"] forState:UIControlStateNormal];
        } else {
            [nProfilePicBtn setBackgroundImage:[UIImage imageNamed:@"empty"] forState:UIControlStateNormal];
        }
    } else {
        [QBRequest downloadFileWithID:blobID successBlock:^(QBResponse *response, NSData *fileData) {
            [g_var saveFile:fileData uid:blobID];
            UIImage *img = [UIImage imageWithData:fileData];
            [nProfilePicBtn setBackgroundImage:img forState:UIControlStateNormal];
        } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
            // handle progress
        } errorBlock:^(QBResponse *response) {
            [self error:err_later];
        }];
    }
}

- (IBAction)onNPClose:(id)sender {
    [UIView transitionWithView:nProfileView duration:0.1 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        nProfileView.hidden = YES;
    } completion:nil];
}

- (IBAction)onNPDelete:(id)sender {
    if (openNP == nil) {
        return;
    }

    [[[UIAlertView alloc] initWithTitle:@"Confirm" message:[NSString stringWithFormat:@"Do you want to really delete %@?", nProfileName.text] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil] show];
}

- (IBAction)onNPSave:(id)sender {
    openNP.defaultNudge = nProfileNudgeTxt.text;
    openNP.defaultReply = nProfileReplyTxt.text;
    openNP.silent = nProfileSilentSwitch.on;
    openNP.block = nProfileBlockSwitch.on;
    openNP.alertSound = downPicker.selectedIndex;

    [SVProgressHUD show];
    
    if (openNP.metaID != nil) {
        QBCOCustomObject *object = [QBCOCustomObject customObject];
        object.className = @"NudgerBuddy"; // your Class name
        object.ID = openNP.metaID;
        NSString *parentID;
        if (openNP.type == NTGroup) parentID = openNP.group.gID;
        else parentID = [NSString stringWithFormat:@"%lu",openNP.user.ID];
        [object.fields setObject:parentID forKey:@"_parent_id"];
        [object.fields setObject:openNP.defaultNudge forKey:@"NudgeTxt"];
        [object.fields setObject:openNP.defaultReply forKey:@"AcknowledgeTxt"];
        [object.fields setObject:[NSNumber numberWithBool:openNP.isFavorite] forKey:@"Favorite"];
        [object.fields setObject:[NSNumber numberWithInteger:openNP.favCount] forKey:@"FavCount"];
        [object.fields setObject:[NSNumber numberWithInteger:openNP.response] forKey:@"NudgerType"];
        [object.fields setObject:[NSNumber numberWithBool:openNP.silent] forKey:@"Silent"];
        [object.fields setObject:[NSNumber numberWithBool:openNP.block] forKey:@"Block"];
        [object.fields setObject:[NSNumber numberWithInteger:openNP.alertSound] forKey:@"Alert"];
        
        [QBRequest updateObject:object successBlock:^(QBResponse *response, QBCOCustomObject *object) {
            [SVProgressHUD dismiss];
            [self onNPClose:nil];
            [self display:DTNil];
        } errorBlock:^(QBResponse *response) {
            [self error:err_later];
        }];
    } else {
        QBCOCustomObject *object = [QBCOCustomObject customObject];
        object.className = @"NudgerBuddy"; // your Class name
        NSString *parentID;
        if (openNP.type == NTGroup) parentID = openNP.group.gID;
        else parentID = [NSString stringWithFormat:@"%lu",openNP.user.ID];
        [object.fields setObject:parentID forKey:@"_parent_id"];
        [object.fields setObject:openNP.defaultNudge forKey:@"NudgeTxt"];
        [object.fields setObject:openNP.defaultReply forKey:@"AcknowledgeTxt"];
        [object.fields setObject:[NSNumber numberWithBool:openNP.isFavorite] forKey:@"Favorite"];
        [object.fields setObject:[NSNumber numberWithInteger:openNP.favCount] forKey:@"FavCount"];
        [object.fields setObject:[NSNumber numberWithInteger:openNP.response] forKey:@"NudgerType"];
        [object.fields setObject:[NSNumber numberWithBool:openNP.silent] forKey:@"Silent"];
        [object.fields setObject:[NSNumber numberWithBool:openNP.block] forKey:@"Block"];
        [object.fields setObject:[NSNumber numberWithInteger:openNP.alertSound] forKey:@"Alert"];
        
        [QBRequest createObject:object successBlock:^(QBResponse *response, QBCOCustomObject *object) {
            [SVProgressHUD dismiss];
            [self onNPClose:nil];
            [self display:DTNil];
            openNP.metaID = object.ID;
        } errorBlock:^(QBResponse *response) {
            [self error:err_later];
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

#pragma mark - Stream
/////////////////////////////////// --------- Stream View ----------- ///////////////////////////////////////////
- (void)onUnreadCount:(NSInteger)count {
    [streamCountBtn setTitle:[NSString stringWithFormat:@"%lu", count] forState:UIControlStateNormal];
    streamNudger.unreadMsg = count;
    if (count == 0) {
        streamCountBtn.hidden = YES;
    }
}

- (IBAction)onStreamOpen:(id)sender {
    [self hide:VTStream];
    if (streamView.hidden == NO) {
        [self onStreamClose:nil];
        return;
    }
    
    NSUInteger fileID = streamNudger.type==NTGroup?streamNudger.group.gBlobID:streamNudger.user.blobID;
    [streamPicBtn setTitle:[streamNudger getName] forState:UIControlStateNormal];
    [streamPicBtn setBackgroundColor:[UIColor colorWithRed:78/255.0 green:96/255.0 blue:110/255.0 alpha:1.0]];
    
    if (fileID) [streamPicBtn setImage:[UIImage imageWithData:[g_var loadFile:fileID]] forState:UIControlStateNormal];
    else if (streamNudger.type == NTGroup) [streamPicBtn setImage:[UIImage imageNamed:@"user-group"] forState:UIControlStateNormal];
    
    [streamCountBtn setTitle:[NSString stringWithFormat:@"%lu", streamNudger.unreadMsg] forState:UIControlStateNormal];
    streamResponseTxt.text = streamNudger.defaultReply;
    [streamCtrl streamResult:streamNudger];
    
    [UIView transitionWithView:streamView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        streamView.hidden = NO;
    } completion:^(BOOL success){
        
    }];
}

- (IBAction)onStreamClose:(id)sender {
    //streamNudger.unreadMsg = 0;
    if  (streamView.hidden) return;
    streamNudger.isNew = NO;
    streamNudger.shouldAnimate = NO;
    [g_center getUnreadMessages:^(NSInteger unreadCount, NSDictionary *dialogs) {
        NSLog(@"%lu, %@", unreadCount, dialogs);
        [UIApplication sharedApplication].applicationIconBadgeNumber = unreadCount;
        for (Nudger *nudger in g_center.notificationArray) {
            nudger.unreadMsg = [[dialogs valueForKey:nudger.dialogID] integerValue];
        }
        [self display:DTNil];
    }];
//    [self display:NO];
    [UIView transitionWithView:streamView duration:0.1 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        streamView.hidden = YES;
        
    } completion:^(BOOL success){
        
    }];
}

- (IBAction)onStreamSend:(id)sender {
    [g_center sendMessage:streamNudger txt:streamResponseTxt.text success:^(BOOL success) {
        if (success) {
            [audioPlayer play];
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
            [self showAlert:[NSString stringWithFormat:@"You sent nudge to %@",streamNudger.type==NTGroup?streamNudger.group.gName:streamNudger.user.fullName]];
        } else {
            [SVProgressHUD showErrorWithStatus:@"Failed to send nudge. Please try later."];
        }
    }];

    [self onStreamClose:nil];
    menuCtrl.isOpen = NO;
}

#pragma mark - Start
///////////////////////////////// --------- Add Start View ----------- /////////////////////////////////////////////
- (void)onStartOpen {
    [UIView transitionWithView:self.view duration:1.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        startView.hidden = NO;
    } completion:nil];

    [self setAcademies:alertSoundArr textField:startDropText];
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
    g_center.currentNudger.alertSound =   downPicker.selectedIndex;
    
    [g_var saveLocalVal:g_center.currentNudger.response key:USER_RESPONSE];
    [g_var saveLocalStr:g_center.currentNudger.defaultNudge key:USER_NUDGE];
    [g_var saveLocalStr:g_center.currentNudger.defaultReply key:USER_ACKNOWLEDGE];
    [g_var saveLocalVal:g_center.currentNudger.alertSound key:USER_ALERT];
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

#pragma mark - Info Page
///////////////////////////////// --------- Add Start View ----------- /////////////////////////////////////////////
- (IBAction)onInfoOpen:(id)sender {
    [UIView transitionWithView:self.view duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        infoView.hidden = NO;
    } completion:^(BOOL success) {
        [UIView animateWithDuration:0.6 delay:0 options:(UIViewAnimationOptionRepeat|UIViewAnimationOptionAutoreverse) animations:^(){
            infoButton.alpha = 0.0f;
        } completion:^(BOOL success) {
            infoButton.alpha = 1.0f;
        }];
    }];
}

- (IBAction)onInfoClose:(id)sender {
    [UIView transitionWithView:self.view duration:0.1 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        infoView.hidden = YES;
    } completion:nil];
    [infoButton.layer removeAllAnimations];
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
    if (viewTag != VTViewGroup) [self onVGroupClose:nil];
    if (viewTag != VTStream && viewTag != VTMenu) [self onStreamClose:nil];
    if (viewTag != VTInfo) [self onInfoClose:nil];
    if (viewTag != VTNudged) [self onNudgedClose:nil];
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
    } completion:nil];
}

- (void)error:(NSString *)err {
    [SVProgressHUD showErrorWithStatus:err];
}

- (void)setAcademies:(NSArray *)academyArr textField:txtCtrl
{
    downPicker = [[DownPicker alloc] initWithTextField:txtCtrl];
    [downPicker setPlaceholder:@"Select Alert Sound."];
    NSArray *sortArr = [academyArr linq_sort:^id(NSDictionary* academy) {
        return academy[@"name"];
    }];
    
    NSArray *titleArr = [sortArr linq_select:^id(NSDictionary *dic) {
        return dic[@"name"];
    }];
    
    [downPicker setData:titleArr];
}

- (NSString *)relativeDateStringForDate:(NSDate *)date
{
    NSCalendarUnit units = NSCalendarUnitDay | NSCalendarUnitWeekOfYear |
    NSCalendarUnitMonth | NSCalendarUnitYear;
    
    // if `date` is before "now" (i.e. in the past) then the components will be positive
    NSDateComponents *components = [[NSCalendar currentCalendar] components:units
                                                                   fromDate:date
                                                                     toDate:[NSDate date]
                                                                    options:0];
    
    if (components.year > 0) {
        return [NSString stringWithFormat:@"%ld years ago", (long)components.year];
    } else if (components.month > 0) {
        return [NSString stringWithFormat:@"%ld months ago", (long)components.month];
    } else if (components.weekOfYear > 0) {
        return [NSString stringWithFormat:@"%ld weeks ago", (long)components.weekOfYear];
    } else if (components.day > 0) {
        if (components.day > 1) {
            return [NSString stringWithFormat:@"%ld days ago", (long)components.day];
        } else {
            return @"Yesterday";
        }
    } else {
        return @"Today";
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        if (openNP.type == NTGroup) {
            [SVProgressHUD show];
            [g_center removeGroup:openNP success:^(BOOL success) {
                [self onNPClose:nil];
                [self display:DTNil];
            }];
        } else {
            [[QBChat instance] removeUserFromContactList:openNP.user.ID completion:^(NSError * _Nullable error) {
                [g_center remove:openNP];
                [self onNPClose:nil];
                [self display:DTNil];
            }];
        }
    }
}

- (void)onSettingADPurchased {
    gBannerView.hidden = YES;
}

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
    NSString *str = IAP1;
    if (![g_var loadLocalBool:str]) {
        gBannerView.hidden = NO;
    }
}

- (void)hideAD:(id)sender {
    gBannerView.hidden = YES;
    [self performSelector:@selector(showAD:) withObject:nil afterDelay:60];
}

- (void)showAD:(id)sender {
    NSString *str = IAP1;
    if (![g_var loadLocalBool:str]) {
        gBannerView.hidden = NO;
    }
}

@end
