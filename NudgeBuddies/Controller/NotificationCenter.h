//
//  NotificationCenter.h
//  NudgeBuddies
//
//  Created by Hans Adler on 13/12/15.
//  Copyright © 2015 Blue Silver. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AppCenterDelegate <NSObject>
@optional
- (void)onceLogin;
- (void)onceLoadedContactList;
- (Nudger *)onceLoadedContact;
@end

@interface NotificationCenter : NSObject <QBChatDelegate>

//@property (nonatomic) int notifyCount;
@property (nonatomic, retain) NSMutableArray *pendingArray;
@property (nonatomic, retain) NSMutableArray *favArray;
@property (nonatomic, retain) NSMutableArray *notificationArray;
@property (nonatomic, retain) NSMutableArray *contactsArray;

@property(weak) id <AppCenterDelegate> delegate;

- (void)initCenter;
- (Menu *)getMenu:(CGRect)frame menuSize:(CGSize)size;
- (void)refresh;
- (void)update:(Nudger *)user;
- (void)sort;

@end
