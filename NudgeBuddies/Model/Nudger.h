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
@property (nonatomic, retain) QBUUser *user;
@property (nonatomic) BOOL isFavorite;
@property (nonatomic) int favCount;
@property (nonatomic) int alarmCount;
@property (nonatomic, retain) Group *group;

- (NSString *) getName;

@end
