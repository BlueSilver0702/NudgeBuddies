//
//  Nudger.m
//  NudgeBuddies
//
//  Created by Hans Adler on 13/12/15.
//  Copyright © 2015 Blue Silver. All rights reserved.
//

#import "Nudger.h"

@implementation Nudger

- (id)initWithUser:(QBUUser *)userInfo {
    self = [super init];
    if (self) {
        self.type = NTIndividual;
        self.status = NSFriend;
        self.response = RTNudge;
        self.defaultNudge = @"You there? Give me a call";
        self.defaultReply = @"Give me 5, I'll call you back";
        self.user = userInfo;
        self.isFavorite = NO;
        self.favCount = 0;
        self.alarmCount = 0;
        self.group = nil;
        self.stream = [NSMutableArray new];
        self.block = NO;
        self.silent = NO;
        self.autoNudge = NO;
        self.isNew = NO;
        self.shouldAnimate = NO;
        self.menuPos = 0;
        self.metaID = nil;
        self.dialogID = nil;
        self.unreadMsg = 0;
    }
    return self;
}

- (id)initWithGroup:(Group *)groupInfo {
    self = [super init];
    if (self) {
        self.type = NTGroup;
        self.status = NSFriend;
        self.response = RTNudge;
        self.defaultNudge = @"You there? Give me a call";
        self.defaultReply = @"Give me 5, I'll call you back";
        self.user = nil;
        self.isFavorite = NO;
        self.favCount = 0;
        self.alarmCount = 0;
        self.group = groupInfo;
        self.stream = [NSMutableArray new];
        self.block = NO;
        self.silent = NO;
        self.autoNudge = NO;
        self.isNew = NO;
        self.shouldAnimate = NO;
        self.menuPos = 0;
        self.metaID = nil;
        self.dialogID = nil;
        self.unreadMsg = 0;
    }
    return self;
}

- (NSString *) getName {
    NSString *searchStr;
    if (self.type == NTGroup) {
        searchStr = self.group.gName;
        if (searchStr.length == 0) {
            return @"GR";
        }
    } else {
        searchStr = self.user.fullName;
    }
    searchStr = [searchStr capitalizedString];
    NSArray *arr = [searchStr componentsSeparatedByString:@" "];
    if (arr.count < 2) {
        return [searchStr substringToIndex:2];
    } else {
        return [NSString stringWithFormat:@"%@%@", [[arr objectAtIndex:0] substringToIndex:1],[[arr objectAtIndex:1] substringToIndex:1]];
    }
    return @"";
}

- (BOOL)isEqualNudger:(Nudger *)newNudger {
    if (self.type == NTGroup && newNudger.type == NTGroup) {
        if ([_group.gName isEqualToString:newNudger.group.gName]) {
            return YES;
        }
    } else if (self.type == NTIndividual && newNudger.type == NTIndividual) {
        if (_user.ID == newNudger.user.ID) {
            return YES;
        }
    }
    return NO;
}

@end
