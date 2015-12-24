//
//  Nudger.h
//  NudgeBuddies
//
//  Created by Hans Adler on 13/12/15.
//  Copyright © 2015 Blue Silver. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Nudger : NSObject

@property (nonatomic) NudgerType type;
@property (nonatomic) NudgerStatus status;
@property (nonatomic) ResponseType response;
@property (nonatomic, retain) NSString *defaultNudge;
@property (nonatomic, retain) NSString *defaultReply;
@property (nonatomic, retain) QBUUser *user;
@property (nonatomic) BOOL isFavorite;
@property (nonatomic) int favCount;
@property (nonatomic) int alarmCount;
@property (nonatomic, retain) Group *group;
@property (nonatomic, retain) NSMutableArray *stream;
@property (nonatomic) BOOL block;
@property (nonatomic) BOOL silent;
@property (nonatomic) BOOL autoNudge;
@property (nonatomic) BOOL isNew;
@property (nonatomic) BOOL shouldAnimate;
@property (nonatomic) int menuPos;
@property (nonatomic, retain) NSString *metaID;

- (id)initWithUser:(QBUUser *)userInfo;
- (id)initWithGroup:(Group *)groupInfo;
- (BOOL)isEqualNudger:(Nudger *)newNudger;
- (NSString *) getName;

@end
