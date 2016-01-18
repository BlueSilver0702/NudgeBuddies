//
//  AppDelegate.m
//  NudgeBuddies
//
//  Created by Xian Lee on 3/12/2015.
//  Copyright © 2015 Blue Silver. All rights reserved.
//

#import "AppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "SigninController.h"
#import "ViewController.h"

@interface AppDelegate ()
{
    NSTimer *timer;
}
@end

Global *g_var;
AppCenter *g_center;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    g_var = [Global new];
    [g_var initSet];
    g_center = [AppCenter new];
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];

    [QBSettings setApplicationID:kQBApplicationID];
    [QBSettings setAuthKey:      kQBRegisterServiceKey];
    [QBSettings setAuthSecret:   kQBRegisterServiceSecret];
    [QBSettings setAccountKey:   kQBAccountKey];
    
    [QBSettings setAutoReconnectEnabled:YES];
    
    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6]];
    [SVProgressHUD setForegroundColor:[UIColor colorWithRed:250/255.0 green:132/255.0 blue:64/255.0 alpha:1.0]];
        
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSDKAppEvents activateApp];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *deviceIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    QBMSubscription *subscription = [QBMSubscription subscription];
    subscription.notificationChannel = QBMNotificationChannelAPNS;
    subscription.deviceUDID = deviceIdentifier;
    subscription.deviceToken = deviceToken;
    
    [QBRequest createSubscription:subscription successBlock:^(QBResponse *response, NSArray *objects) {
        
    } errorBlock:^(QBResponse *response) {

    }];
}

//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
//    AVAudioPlayer *audioPlayer;
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"effect" ofType:@"mp3"];
//    NSURL *file = [NSURL fileURLWithPath:path];
//    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:file error:nil];
//    [audioPlayer prepareToPlay];
//    [audioPlayer play];
//}

- (void)initialApp {
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
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Login Failed!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        [userDefaults setBool:NO forKey:@"remember"];
        [userDefaults synchronize];
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        SigninController *viewCtrl = (SigninController *)[mainStoryboard instantiateViewControllerWithIdentifier: @"signinCtrl"];
        self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
//        [self.window.rootViewController presentViewController:viewCtrl animated:YES completion:nil];
    }];
}

- (void)applicationWillResignActive:(UIApplication *)application {

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[QBChat instance] disconnectWithCompletionBlock:^(NSError * _Nullable error) {
        
    }];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    timer = [NSTimer scheduledTimerWithTimeInterval:30 target:[QBChat instance] selector:@selector(sendPresence) userInfo:nil repeats:YES];
//    [[QBChat instance] disconnectWithCompletionBlock:^(NSError * _Nullable error) {
//        
//    }];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    if (timer == nil) {
        [[QBChat instance] connectWithUser:g_center.currentUser  completion:^(NSError * _Nullable error) {
            
        }];
    } else {
        [timer invalidate];
        timer = nil;
    }
}

@end
