//
//  PTAppDelegate.h
//  playtell-ducati
//
//  Created by Ricky Hussmann on 5/30/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#define PTReachabilityActiveNotification    @"PTReachabilityActiveNotification"
#define PTReachabilityInactiveNotification  @"PTReachabilityInactiveNotification"

#import "PTLoginViewController.h"
#import "PTPlayTellPusher.h"
#import "PTDateViewController.h"
#import "PTMemoryViewController.h"
#import "UA_Reachability.h"

#import <UIKit/UIKit.h>

@class PTDiagnosticViewController;
@class PTDialpadViewController;
@class TransitionController;
@class PTDateViewController;
@class PTMemoryViewController;
@interface PTAppDelegate : UIResponder <UIApplicationDelegate, PTLoginViewControllerDelegate, UIAlertViewDelegate> {
    BOOL playdateRequestedViaPush;
    NSInteger playdateRequestedViaPushId;
    NSDictionary *appLaunchOptions;
    
    // Tooltip
    BOOL ttInviteBuddiesShownThisInstance;
    
    // Reachability
    Reachability *serverReachable;
    BOOL internetActive;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) PTLoginViewController *viewController;
@property (strong, nonatomic) TransitionController *transitionController;
@property (strong, nonatomic) PTDialpadViewController *dialpadController;
@property (strong, nonatomic) PTDateViewController *dateViewController;
@property (nonatomic, retain) PTChatViewController* chatController;
@property (strong, nonatomic) PTMemoryViewController *memoryViewController;

- (void)runNewUserWorkflow;
- (BOOL)shouldShowInviteBuddiesTooltip;
- (void)setupPushNotifications;
- (void)checkNetworkStatus:(NSNotification *)notice;

@end