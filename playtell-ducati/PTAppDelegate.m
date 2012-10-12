//
//  PTAppDelegate.m
//  playtell-ducati
//
//  Created by Ricky Hussmann on 5/30/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "AFImageRequestOperation.h"
#import "Crittercism.h"
#import "Logging.h"
#import "PTAnalytics.h"
#import "PTAppDelegate.h"
#import "PTChatViewController.h"
#import "PTConcretePlaymateFactory.h"
#import "PTDateViewController.h"
#import "PTDiagnosticViewController.h"
#import "PTMemoryViewController.h"
#import "PTDialpadViewController.h"
#import "PTLoadingViewController.h"
#import "PTPlayTellPusher.h"
#import "PTPlaydate.h"
#import "PTPusher.h"
#import "PTPusherChannel.h"
#import "PTUser.h"
#import "PTVideoPhone.h"
#import "TransitionController.h"
#import "UAPush.h"
#import "UAirship.h"
#import "PTNewUserNavigationController.h"
#import "PTUpdateTokenRequest.h"

@interface PTAppDelegate ()
@property (nonatomic, retain) PTPusher* client;
@property (nonatomic, retain) PTVideoPhone* phone;
@end

@implementation PTAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize dateViewController = _dateViewController;
@synthesize memoryViewController = _memoryViewController;
@synthesize transitionController = _transitionController;
@synthesize dialpadController = _dialpadController;
@synthesize client;
@synthesize phone;
@synthesize chatController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Setup analytics
    [PTAnalytics startAnalytics];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone]; //set status bar hidden
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Check if app was opened because of a remote notification
    NSDictionary *notificationData = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (notificationData != nil) {
        // Get playdate id and store it
        playdateRequestedViaPush = YES;
        playdateRequestedViaPushId = [[[notificationData objectForKey:@"aps"] objectForKey:@"playdate_id"] integerValue];
    } else {
        playdateRequestedViaPush = NO;
    }

#ifndef DEBUG
    // Override point for customization after application launch.
    [Crittercism initWithAppID:@"4fbd111eaf4b487832000083"
                        andKey:@"suhjzchbzrertmd8yud6oma1lvqc"
                     andSecret:@"0mjxkxof9n45k3tzgzqylapf1c62naep"];
#endif

    // Store launch options for later use by push notif.
    appLaunchOptions = launchOptions;

    [PTVideoPhone sharedPhone];
    
    // Create the ChatHUD
    self.chatController = [[PTChatViewController alloc] initWithNullPlaymate];

    // Init transition controller
    PTLoadingViewController* loadingView = [[PTLoadingViewController alloc] initWithNibName:@"PTLoadingViewController" bundle:nil];
    self.transitionController = [[TransitionController alloc] initWithViewController:loadingView];
    
    // Set default controller
    self.window.rootViewController = self.transitionController;
    [self.window makeKeyAndVisible];

    if ([[PTUser currentUser] isLoggedIn]) {
        // Register for push noticication only if logged in
        [self setupPushNotifications];

        // Run logged-in workflow
        [self runLoggedInWorkflow];
    } else {
        // Run new user workflow
        [self runNewUserWorkflow];
    }
    
    // Defaults
    ttInviteBuddiesShownThisInstance = NO;
    
    return YES;
}

- (void)runLoggedInWorkflow {
    PTUser* currentUser = [PTUser currentUser];
    
    // Set the username in analytics
    [PTAnalytics setUniqueId:currentUser.username];

    // Fetch the current users's photo
    NSURLRequest* urlRequest = [NSURLRequest requestWithURL:currentUser.photoURL];
    AFImageRequestOperation* reqeust;
    reqeust = [AFImageRequestOperation imageRequestOperationWithRequest:urlRequest
                                                                success:^(UIImage *image)
               {
                   [[PTUser currentUser] setUserPhoto:image];
               }];
    [reqeust start];

    
    PTConcretePlaymateFactory* playmateFactory = [PTConcretePlaymateFactory sharedFactory];
    [playmateFactory refreshPlaymatesForUserID:currentUser.userID
                                         token:currentUser.authToken
                                       success:^
     {
         self.dialpadController = [[PTDialpadViewController alloc] initWithNibName:nil bundle:nil];
         self.dialpadController.playmates = [[PTConcretePlaymateFactory sharedFactory] allPlaymates];
         // Check if push notification came in with playdate
         if (playdateRequestedViaPush) {
             [self.dialpadController setAwaitingPlaydateRequest:playdateRequestedViaPushId];
         }
         [self.transitionController transitionToViewController:self.dialpadController
                                                   withOptions:UIViewAnimationOptionTransitionCrossDissolve];
     } failure:^(NSError *error) {
         LogError(@"%@ error: %@", NSStringFromSelector(_cmd), error);
         NSAssert(NO, @"Failed to load playmates");
     }];
}

- (void)runNewUserWorkflow {
    PTConcretePlaymateFactory* playmateFactory = [PTConcretePlaymateFactory sharedFactory];
    [playmateFactory refreshPlaymatesForUserID:0
                                         token:nil
                                       success:^
     {
         self.dialpadController = [[PTDialpadViewController alloc] initWithNibName:nil bundle:nil];
         self.dialpadController.playmates = [[PTConcretePlaymateFactory sharedFactory] allPlaymates];
         [self.transitionController transitionToViewController:self.dialpadController
                                                   withOptions:UIViewAnimationOptionTransitionCrossDissolve];
     } failure:^(NSError *error) {
         LogError(@"%@ error: %@", NSStringFromSelector(_cmd), error);
         NSAssert(NO, @"Failed to load playmates");
     }];
}

- (void)setupPushNotifications {
    [self registerForAPNS];
    [self registerForUrbanAirshipNotifications:appLaunchOptions];
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
    // Transition to the Dialpad
    [self runLoggedInWorkflow];
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

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [UAirship land];
    [PTAnalytics flush];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken");
    // Register device if user is logged in
    if ([[PTUser currentUser] isLoggedIn] == YES) {
        // Updates the device token and registers the token with UA
        [[UAirship shared] registerDeviceToken:deviceToken];
        NSString *uaToken = [[UAirship shared] deviceToken];

        // Save this token on our server
        PTUpdateTokenRequest *updateTokenRequest = [[PTUpdateTokenRequest alloc] init];
        [updateTokenRequest updateTokenWithToken:uaToken
                                       authToken:[PTUser currentUser].authToken
                                       onSuccess:nil
                                       onFailure:nil];
    } else {
        // Notify of successfull push notification registration request
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PushNotificationRequestDidSucceed" object:nil];
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"didFailToRegisterForRemoteNotificationsWithError");
    // Notify of failed push notification registration request
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PushNotificationRequestDidFail" object:nil];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if (application.applicationState != UIApplicationStateActive) {
        // Send playdate id to dialpad controller
        playdateRequestedViaPushId = [[[userInfo objectForKey:@"aps"] objectForKey:@"playdate_id"] integerValue];
        [self.dialpadController setAwaitingPlaydateRequest:playdateRequestedViaPushId];
        [self.dialpadController loadPlaydateDataFromPushNotification];
    }
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskLandscape;
}

//- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
//    return [FBSession.activeSession handleOpenURL:url];
//}

#pragma mark - Tooltip helpers

- (BOOL)shouldShowInviteBuddiesTooltip {
    // Already shown once this instance?
    if (ttInviteBuddiesShownThisInstance == YES) {
        return NO;
    }
    
    // Check how many times it's been shown overall
    NSInteger numTTInviteBuddiesShown = [[NSUserDefaults standardUserDefaults] integerForKey:@"numTTInviteBuddiesShown"];
    numTTInviteBuddiesShown++;
    [[NSUserDefaults standardUserDefaults] setInteger:numTTInviteBuddiesShown forKey:@"numTTInviteBuddiesShown"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if (numTTInviteBuddiesShown > 5) {
        return NO;
    }
    
    ttInviteBuddiesShownThisInstance = YES;
    return YES;
}

@end