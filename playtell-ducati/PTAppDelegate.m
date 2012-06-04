//
//  PTAppDelegate.m
//  playtell-ducati
//
//  Created by Ricky Hussmann on 5/30/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTAppDelegate.h"
#import "PTDialpadViewController.h"
#import "PTMockPlaymateFactory.h"
#import "PTPlaydate.h"
#import "PTPlayTellPusher.h"
#import "PTPusher.h"
#import "PTUser.h"
#import "PTPusherChannel.h"
#import "PTViewController.h"
#import "UAPush.h"
#import "UAirship.h"

@interface PTAppDelegate ()
@property (nonatomic, retain) PTPusher* client;
@end

@implementation PTAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize client;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[PTDialpadViewController alloc] initWithNibName:nil bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];

    [self setupPushNotifications:launchOptions];

    PTLoginViewController* loginController = [[PTLoginViewController alloc] initWithNibName:@"PTLoginViewController" bundle:nil];
    loginController.delegate = self;

    [self.viewController presentModalViewController:loginController animated:NO];
    return YES;
}

- (void)setupPushNotifications:(NSDictionary*)theLaunchOptions {
    [self registerForAPNS];
    [self registerForUrbanAirshipNotifications:theLaunchOptions];
}

- (void)registerForAPNS {
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert |
                                                                           UIRemoteNotificationTypeBadge |
                                                                           UIRemoteNotificationTypeSound)];
}

- (void)registerForUrbanAirshipNotifications:(NSDictionary*)theLaunchOptions {
    NSMutableDictionary *takeOffOptions = [NSMutableDictionary dictionary];
    [takeOffOptions setValue:theLaunchOptions forKey:UAirshipTakeOffOptionsLaunchOptionsKey];
    [UAirship takeOff:takeOffOptions];
    [[UAPush shared] resetBadge];
}

- (void)loginControllerDidLogin:(PTLoginViewController*)controller {
    [self.viewController dismissModalViewControllerAnimated:YES];

    [[PTPlayTellPusher sharedPusher] setDelegate:self];
    [[PTPlayTellPusher sharedPusher] subscribeToRendezvousChannel];
}
                               
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.

    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)playTellPusher:(PTPlayTellPusher*)pusher receivedPlaydateJoinedEvent:(PTPlaydate*)playdate {
    LOGMETHOD;
    NSLog(@"Playdate -> %@", playdate);
}

- (void)playTellPusher:(PTPlayTellPusher*)pusher receivedPlaydateRequestedEvent:(PTPlaydate*)playdate {
    LOGMETHOD;
    NSLog(@"Playdate -> %@", playdate);
    [pusher unsubscribeFromRendezvousChannel];
}

@end
