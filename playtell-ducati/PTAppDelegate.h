//
//  PTAppDelegate.h
//  playtell-ducati
//
//  Created by Ricky Hussmann on 5/30/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTLoginViewController.h"
#import "PTPlayTellPusher.h"
#import "PTDateViewController.h"
#import "PTMemoryViewController.h"

#import <UIKit/UIKit.h>

@class PTDiagnosticViewController;
@class PTDialpadViewController;
@class TransitionController;
@class PTDateViewController;
@class PTMemoryViewController;
@interface PTAppDelegate : UIResponder <UIApplicationDelegate, PTLoginViewControllerDelegate> {
    BOOL playdateRequestedViaPush;
    NSInteger playdateRequestedViaPushId;
    
    // Tooltip
    BOOL ttInviteBuddiesShownThisInstance;
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

@end