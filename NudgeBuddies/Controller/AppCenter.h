//
//  AppCenter.h
//  NudgeBuddies
//
//  Created by Blue Silver on 12/21/15.
//  Copyright © 2015 Blue Silver. All rights reserved.
//

@protocol AppCenterDelegate <NSObject>
@optional
- (void)onceConnect;
- (void)onceLoadedContactList;
- (void)startLoadContactList;
- (void)onceAddedContact:(Nudger *)nudger;
- (void)onceRemovedContact:(Nudger *)nudger;
- (void)onceAccepted:(NSString *)from;
- (void)onceRejected:(NSUInteger)from;
- (void)onceDisconnected;
- (void)onceErr;
@end

@interface AppCenter : NSObject <QBChatDelegate>

//@property (nonatomic) int notifyCount;
@property (nonatomic, retain) NSMutableArray *pendingArray;
@property (nonatomic, retain) NSMutableArray *favArray;
@property (nonatomic, retain) NSMutableArray *notificationArray;
@property (nonatomic, retain) NSMutableArray *contactsArray;
@property (nonatomic, retain) NSMutableArray *groupArray;
@property (nonatomic, retain) NSMutableArray *fbFriendsArr;

@property (nonatomic, retain) QBUUser *currentUser;
@property (nonatomic, retain) Nudger *currentNudger;
@property (nonatomic) BOOL isNight;

@property(weak) id <AppCenterDelegate> delegate;

- (void)initCenter:(QBUUser *)user;
- (void)add:(Nudger *)user;
- (void)remove:(Nudger *)user;
- (void) addBuddy:(Nudger *)buddy success:(void (^)(BOOL))success;

- (void)createChatNotificationForGroupChatCreation:(QBChatDialog *)dialog;

@end
