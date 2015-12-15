//
//  Menu.h
//  NudgeBuddies
//
//  Created by Hans Adler on 15/12/15.
//  Copyright © 2015 Blue Silver. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Menu : NSObject

@property (nonatomic) int index;
@property (nonatomic) CGPoint menuPoint;
@property (nonatomic) CGPoint triPoint;
@property (nonatomic) BOOL triDirection;

@end
