//
//  Group.h
//  NudgeBuddies
//
//  Created by Hans Adler on 13/12/15.
//  Copyright © 2015 Blue Silver. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Group : NSObject

//@property (nonatomic, retain) NSString * gID;
@property (nonatomic, retain) NSString *gName;
@property (nonatomic, retain) NSMutableArray *gUsers;
@property (nonatomic) NSUInteger gBlobID;

@end
