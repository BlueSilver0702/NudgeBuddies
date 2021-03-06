//
//  Global.h
//  NudgeBuddies
//
//  Created by Hans Adler on 10/12/15.
//  Copyright © 2015 Blue Silver. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, NudgerType) {
    NTNil = 0,
    NTIndividual,
    NTGroup
};

typedef NS_ENUM(NSInteger, NudgerStatus) {
    NSNil = 0,
    NSFriend,
    NSInvite,
    NSInvited,
    NSReject,
    NSRejected
};

typedef NS_ENUM(NSInteger, ResponseType) {
    RTNil = 0,
    RTNudge,
    RTRumble,
    RTSilent,
    RTAnnoy,
    RTAnnoyRumble,
    RTAnnoySilent
};

typedef NS_ENUM(NSInteger, MenuType) {
    MTNil = 0,
    MTBuddy,
    MTBuddyStream,
    MTGroup,
    MTGroupStream,
    MTAdd,
    MTNudge,
    MTNudged,
};

typedef NS_ENUM(NSInteger, MenuReturn) {
    MRNil = 0,
    MRNudge,
    MRRumble,
    MRRumbleSilent,
    MRAnnoy,
    MRAnnoyRumble,
    MRAnnoySilent,
    MRStreamGroup,
    MRStream,
    MRAddGroup,
    MRViewGroup,
    MRBlock,
    MRSilent,
    MRAuto,
    MREdit,
    MREditGroup,
    MRAdd,
    MRReject
};

typedef NS_ENUM(NSInteger, ViewTag) {
    VTNil = 0,
    VTSetting,
    VTAuto,
    VTProfile,
    VTSearch,
    VTAdd,
    VTMenu,
    VTStart,
    VTGroup,
    VTGroupSelect,
    VTNP,
    VTViewGroup,
    VTStream,
    VTInfo,
    VTNudged,
};

typedef NS_ENUM(NSInteger, DisplayType) {
    DTNil = 0,
    DTMessage,
    DTNOContactChanged,
};

@interface Global : NSObject

@property (nonatomic, retain) NSDictionary *profileImg;

// App Settings
@property (nonatomic) BOOL sRemoveNudgeCount;
@property (nonatomic) BOOL sAutoNudge;
@property (nonatomic) BOOL sLocationServices;
@property (nonatomic) BOOL sNightMode;
@property (nonatomic, retain) NSDate *fromDate;
@property (nonatomic, retain) NSDate *toDate;
@property (nonatomic, retain) NSString *sDefaultNudge;
@property (nonatomic, retain) NSString *sDefaultReply;
@property (nonatomic, retain) NSString *sDefaultRumble;
@property (nonatomic) BOOL sFacebook;
@property (nonatomic) BOOL sInstagram;
@property (nonatomic) BOOL sSnapchat;
@property (nonatomic) BOOL sTwitter;

- (void)initSet;
- (void)saveFile:(NSData *)data uid:(NSUInteger)uid;
- (NSData *)loadFile:(NSUInteger)uid;
- (void)saveLocalStr:(NSString *)str key:(NSString *)key;
- (NSString *)loadLocalStr:(NSString *)key;
- (void)saveLocalVal:(NSInteger)val key:(NSString *)key;
- (NSInteger)loadLocalVal:(NSString *)key;
- (void)saveLocalBool:(BOOL)truth key:(NSString *)key;
- (BOOL)loadLocalBool:(NSString *)key;
- (void)saveLocalDate:(NSDate *)date key:(NSString *)key;
- (NSDate *)loadLocalDate:(NSString *)key;

@end

#define kQBRingThickness                         1.f
#define kQBAnswerTimeInterval                    90.f
#define kQBRTCDisconnectTimeInterval             90.f
#define kQBChatPresenceTimeInterval              20

#define kQBApplicationID                         31721
#define kQBRegisterServiceKey                    @"hLk88-npEA7Dj4A"
#define kQBRegisterServiceSecret                 @"W4VuhkT5mty49hV"
#define kQBAccountKey                            @"Jwf3LjW3k7vhqNzX6Vhq"

#define kQBClassConnections                      @"Connections"

//*****************Notification center String**************
#define N_ConferenceRequested                       @"N_ConferenceRequested"
#define N_SINCH_MESSAGE_RECIEVED                    @"N_SINCH_MESSAGE_RECIEVED"
#define N_SINCH_MESSAGE_SENT                        @"N_SINCH_MESSAGE_SENT"
#define N_SINCH_MESSAGE_DELIVERED                   @"N_SINCH_MESSAGE_DELIVERED"
#define N_SINCH_MESSAGE_FAILED                      @"N_SINCH_MESSAGE_DELIVERED"

//*****************Other Constants**************
#define NUM_TOPICS                                   8
#define RESIZE_WIDTH                                 80
#define RESIZE_HEIGHT                                80
#define COMMON_PWD                                   kQBAccountKey
#define USER_RESPONSE                               @"user_response"
#define USER_NUDGE                                  @"user_nudge"
#define USER_ACKNOWLEDGE                            @"user_acknowledge"
#define USER_NIGHT                                  @"user_night"
#define USER_COUNT                                  @"user_count"
#define USER_ALERT                                  @"user_alert"
#define USER_NIGHT_FROM                             @"user_night_from"
#define USER_NIGHT_TO                               @"user_night_to"

#define FAV_1                                       CGPointMake(116, 128+82)
#define FAV_2                                       CGPointMake(15, 20+82)
#define FAV_3                                       CGPointMake(200, 221+82)
#define FAV_4                                       CGPointMake(38, 221+82)
#define FAV_5                                       CGPointMake(220, 20+82)
#define FAV_6                                       CGPointMake(0, 120+82)
#define FAV_7                                       CGPointMake(230, 120+82)
#define FAV_8                                       CGPointMake(116, 43+82)

#define IAP1                                        @"com.nudgebuddies.nudgebuddies.iap1";
#define IAP2                                        @"com.nudgebuddies.nudgebuddies.iap2";

#define err_later                                         @"An error occured. Please try later."