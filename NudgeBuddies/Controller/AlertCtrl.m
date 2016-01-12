//
//  AlertCtrl.m
//  NudgeBuddies
//
//  Created by Blue Silver on 1/6/16.
//  Copyright © 2016 Blue Silver. All rights reserved.
//

#import "AlertCtrl.h"

@implementation AlertCtrl

+ (NSArray *)initWithAlerts {
    NSString *boolKey = IAP2
    BOOL isRight = [g_var loadLocalBool:boolKey];
    if (isRight) {
        return [NSArray arrayWithObjects:@{@"name":@"Apex", @"file":@"Apex.caf"},
                @{@"name":@"Audience Applause", @"file":@"Audience Applause.caf"},
                @{@"name":@"Aurora", @"file":@"Aurora.caf"},
                @{@"name":@"Chipmunks", @"file":@"Chipmunks.caf"},
                @{@"name":@"Circles", @"file":@"Circles.caf"},
                @{@"name":@"Crystals", @"file":@"Crystals.caf"},
                @{@"name":@"Descending Craft", @"file":@"Descending Craft.caf"},
                @{@"name":@"Fractal", @"file":@"Fractal.caf"},
                @{@"name":@"Hello", @"file":@"Hello.caf"},
                @{@"name":@"Input", @"file":@"Input.caf"},
                @{@"name":@"Martin Death Ray", @"file":@"Martin Death Ray.caf"},
                @{@"name":@"Metal Gong", @"file":@"Metal Gong.caf"},
                @{@"name":@"Note", @"file":@"Note.caf"},
                @{@"name":@"Phone Vibrating", @"file":@"Phone Vibrating.caf"},
                @{@"name":@"Popcorn", @"file":@"Popcorn.caf"},
                @{@"name":@"Pulse", @"file":@"Pulse.caf"},
                @{@"name":@"Stargaze", @"file":@"Stargaze.caf"},
                @{@"name":@"Thunder HD", @"file":@"Thunder HD.caf"},
                @{@"name":@"UFO Takeoff", @"file":@"UFO Takeoff.caf"},
                @{@"name":@"Alarm Rooster", @"file":@"Alarm Rooster.caf"},
                @{@"name":@"Creepy Laugh - Adam Webb", @"file":@"Creepy Laugh - Adam Webb.caf"},
                @{@"name":@"Crow Call 2 -JimBob", @"file":@"Crow Call 2 -JimBob.caf"},
                @{@"name":@"Dark Laugh - HopeinAwe", @"file":@"Dark Laugh - HopeinAwe.caf"},
                @{@"name":@"Evil Laugh 2", @"file":@"Evil Laugh 2.caf"},
                @{@"name":@"Evil Laugh Male 6 - Himan", @"file":@"Evil Laugh Male 6 - Himan.caf"},
                @{@"name":@"Evil laugh Male 9 - Himan", @"file":@"Evil laugh Male 9 - Himan.caf"},
                @{@"name":@"Incoming Suspense - Maximilien", @"file":@"Incoming Suspense - Maximilien.caf"},
                @{@"name":@"Psychotic_laugh_female - Mike Koenig", @"file":@"Psychotic_laugh_female - Mike Koenig.caf"},
                @{@"name":@"Sqeaking door - Sarasprella", @"file":@"Sqeaking door - Sarasprella.caf"},
                @{@"name":@"Sqeaking door 2 -Sarasprella", @"file":@"Sqeaking door 2 -Sarasprella.caf"},
                @{@"name":@"Thunder - Mike Koenig", @"file":@"Thunder - Mike Koenig.caf"},
                @{@"name":@"Thunder- Mark DiAngelo", @"file":@"Thunder- Mark DiAngelo.caf"},
                nil];
    } else {
        return [NSArray arrayWithObjects:@{@"name":@"Apex", @"file":@"Apex.caf"},
                @{@"name":@"Audience Applause", @"file":@"Audience Applause.caf"},
                @{@"name":@"Aurora", @"file":@"Aurora.caf"},
                @{@"name":@"Chipmunks", @"file":@"Chipmunks.caf"},
                @{@"name":@"Circles", @"file":@"Circles.caf"},
                @{@"name":@"Crystals", @"file":@"Crystals.caf"},
                @{@"name":@"Descending Craft", @"file":@"Descending Craft.caf"},
                @{@"name":@"Fractal", @"file":@"Fractal.caf"},
                @{@"name":@"Hello", @"file":@"Hello.caf"},
                @{@"name":@"Input", @"file":@"Input.caf"},
                @{@"name":@"Martin Death Ray", @"file":@"Martin Death Ray.caf"},
                @{@"name":@"Metal Gong", @"file":@"Metal Gong.caf"},
                @{@"name":@"Note", @"file":@"Note.caf"},
                @{@"name":@"Phone Vibrating", @"file":@"Phone Vibrating.caf"},
                @{@"name":@"Popcorn", @"file":@"Popcorn.caf"},
                @{@"name":@"Pulse", @"file":@"Pulse.caf"},
                @{@"name":@"Stargaze", @"file":@"Stargaze.caf"},
                @{@"name":@"Thunder HD", @"file":@"Thunder HD.caf"},
                @{@"name":@"UFO Takeoff", @"file":@"UFO Takeoff.caf"},
                nil];
    }
}

@end
