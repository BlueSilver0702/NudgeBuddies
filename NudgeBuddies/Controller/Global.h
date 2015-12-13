//
//  Global.h
//  NudgeBuddies
//
//  Created by Hans Adler on 10/12/15.
//  Copyright © 2015 Blue Silver. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, NudgerType) {
    NTIndividual = 0,
    NTGroup = 1
};

typedef NS_ENUM(NSInteger, NudgerStatus) {
    NSFriend = 0,
    NSInvite = 1,
    NSInvited = 2,
    NSReject = 3,
    NSRejected = 4
};

@interface Global : NSObject

@property (nonatomic, retain) NSData *profileImg;
@property (nonatomic, retain) QBUUser *currentUser;

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

- (void)saveFile:(NSData *)data uid:(NSUInteger)uid;
- (NSData *)loadFile:(NSUInteger)uid;

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

#define kQBKeyMainUser                           @"user_id"
#define kQBKeyOtherUsr                           @"OtherUser"
#define kQBKeyIsAllowed                          @"IsAllowed"

//*****************Parse.com Table **************
#define pClassUser                                 @"User"

#define pKeyObjID                                  @"objectId"

//User Table
#define pKeyFullName                               @"FullName"
#define pKeyCollege                                @"College"
#define pKeyMajor                                  @"Major"
#define pKeyPhotoURL                               @"PhotoURL"
#define pKeyConnections                            @"Connections"

//Installation, Activity Table
#define pKeyUserObjId                              @"UserObjId"

//Activity Table
#define pClassActivity                             @"Activity"

#define pKeyCurrentTopic                           @"CurrentTopic"
#define pKeyCurrentBusy                            @"CurrentBusy"

//ConnectionRequest Table
#define pClassConnectionRequest                    @"ConnectionRequest"

#define pKeyMainUser                               @"MainUser"
#define pKeyOtherUser                              @"OtherUser"
#define pKeyOtherUserFullName                      @"OtherUserFullName"

//Connnection Table
#define pClassConnections                          @"Connections"

//SinchMessage Table
#define pClassSinchMessage                         @"SinchMessage"

#define pKeyMsgID                                  @"messageId"
#define pKeySenderID                               @"senderId"
#define pKeyRecipidentID                           @"recipientId"
#define pKeyText                                   @"text"
#define pKeyTimestamp                              @"timestamp"

//SinchMateHistory Table
#define pClassSinchMateHistory                     @"SinchMateHistory"

#define pKeyFirstUserID                            @"firstUserID"
#define pKeySecondUserID                           @"secondUserID"
#define pKeyFirstUserName                          @"firstUserName"
#define pKeySecondUserName                         @"secondUserName"
#define pKeyLastUserID                             @"lastUserID"
#define pKeyLastMsg                                @"lastMsg"
#define pKeyLastUpdateTime                         @"updateTime"


//*****************Push Notification Keys**************
#define pnUserID                                   @"userID"

//*****************Dictionary Keys**************
#define dKeyID                                     @"ID"
#define dKeyName                                   @"Name"
#define dKeyMsg                                    @"message"

//*****************NSUserDefaults **************
#define DEFAULT_USER_LOGGED                         @"UserDefaultAlreadyLogged"
#define DEFAULT_USER_EMAIL                          @"UserDefaultEmail"
#define DEFAULT_USER_PSWD                           @"UserDefaultPassword"

//*****************UI View Controllers**************
#define NC_SIGNUP                                   @"SignupNavCtrl"
#define NC_MAIN                                     @"MainNavCtrl"
#define VC_LOGIN                                    @"LoginViewCtrl"
#define VC_REGISTER                                 @"RegisterViewCtrl"
#define VC_HOME                                     @"HomeViewCtrl"
#define VC_VIDEO_ROOM                               @"VideoChatRoomViewCtrl"
#define TC_VIDEO_TOPIC                              @"VideoTopicTableViewCtrl"
#define TC_MESSAGE_LIST                             @"MessageListTableViewCtrl"
#define VC_MSG_ROOM                                 @"MsgChatRoomViewCtrl"
#define VC_CONNECTION_REQUEST                       @"ConnectionRequestViewCtrl"
#define VC_CONNECTIONS                              @"ConnectionsViewCtrl"
#define VC_SPLASH                                   @"SplashViewCtrl"
#define VC_USER_INFO                                @"UserInfoViewCtrl"
#define VC_MY_PROFILE                               @"MyProfileViewCtrl"
#define VC_SEARCH_NEW_CONNECTION                    @"SearchNewConnectionViewCtrl"
#define VC_SELECT_CONNECTION                        @"SelectConnectionViewCtrl"
#define VC_NEW_CHAT                                 @"NewMessageViewCtrl"
#define VC_EMAIL                                    @"EmailViewCtrl"
#define VC_VALIDATION                               @"ValidationViewCtrl"

//*****************UI Table View Cell**************
#define CELL_VIDEO_TOPIC                            @"VideoTopicCell"
#define CELL_MESSAGE_LIST                           @"MessageListCell"
#define CELL_CONNECT_REQUEST                        @"ConnectRequestCell"
#define CELL_CONNECTIONS                            @"ConnectionsCell"
#define CELL_MSG_SELF_LAST                          @"MsgSelfLastCell"
#define CELL_MSG_OTHER_LAST                         @"MsgOtherLastCell"
#define CELL_MSG_DATE                               @"MsgDateCell"
#define CELL_TMP                                    @"TempCell"

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

