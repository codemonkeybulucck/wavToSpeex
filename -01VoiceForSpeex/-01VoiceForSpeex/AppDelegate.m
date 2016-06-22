//
//  AppDelegate.m
//  -01VoiceForSpeex
//
//  Created by 势必可赢 on 16/6/13.
//  Copyright © 2016年 势必可赢. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    NSUserDefaults *accountDefaults = [NSUserDefaults standardUserDefaults];
    if (!SAMPLE_RATE) {
        [accountDefaults setValue:@"16000" forKey:@"SampleRate"];
    }
    if (!CHANNEL) {
        [accountDefaults setValue:@"1" forKey:@"Channel"];
    }
    if (!BIT_DEPTH) {
        [accountDefaults setValue:@"16" forKey:@"BitDepth"];
    }
    if (!Quality_SPX) {
        [accountDefaults setValue: @"10" forKey:@"Quality_SPX"];
    }
    if (!BroadBand_TYPE) {
        [accountDefaults setValue: @"uwb" forKey:@"BroadBand_TYPE"];
    }
    if (!FRAME_SIZE) {
        [accountDefaults setValue: @"640" forKey:@"FRAME_SIZE"];
    }

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
