//
//  Global.m
//  NudgeBuddies
//
//  Created by Hans Adler on 10/12/15.
//  Copyright © 2015 Blue Silver. All rights reserved.
//

#import "Global.h"
@implementation Global {
    NSUserDefaults *userDefaults;
}

- (void)initSet {
    userDefaults = [NSUserDefaults standardUserDefaults];
}

- (void)saveFile:(NSData *)data uid:(NSUInteger)uid {
    NSString *docsDir;
    NSArray *dirPaths;
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    NSString *databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%lu.png", uid]]];
    [data writeToFile:databasePath atomically:YES];
}

- (NSData *)loadFile:(NSUInteger)uid {
    NSString *docsDir;
    NSArray *dirPaths;
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    NSString *databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%lu.png", uid]]];
    NSData *retData = [NSData dataWithContentsOfFile:databasePath options:NSDataReadingMappedIfSafe error:nil];
    return retData;
}

- (void)saveLocalStr:(NSString *)str key:(NSString *)key {
    [userDefaults setObject:str forKey:key];
    [userDefaults synchronize];
}

- (NSString *)loadLocalStr:(NSString *)key {
    return (NSString *)[userDefaults objectForKey:key];
}

- (void)saveLocalVal:(NSInteger)val key:(NSString *)key {
    [userDefaults setInteger:val forKey:key];
    [userDefaults synchronize];
}

- (NSInteger)loadLocalVal:(NSString *)key {
    return [userDefaults integerForKey:key];
}

- (void)saveLocalBool:(BOOL)truth key:(NSString *)key {
    [userDefaults setBool:truth forKey:key];
    [userDefaults synchronize];
}

- (BOOL)loadLocalBool:(NSString *)key {
    return [userDefaults boolForKey:key];
}

- (void)saveLocalDate:(NSDate *)date key:(NSString *)key {
    [userDefaults setObject:date forKey:key];
    [userDefaults synchronize];
}

- (NSDate *)loadLocalDate:(NSString *)key {
    return (NSDate *)[userDefaults objectForKey:key];
}

@end
