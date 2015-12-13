//
//  Global.m
//  NudgeBuddies
//
//  Created by Hans Adler on 10/12/15.
//  Copyright © 2015 Blue Silver. All rights reserved.
//

#import "Global.h"
@implementation Global

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

@end
