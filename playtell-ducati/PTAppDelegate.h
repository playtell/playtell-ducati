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

#import <UIKit/UIKit.h>

@class PTDiagnosticViewController;
@class PTDialpadViewController;
@class TransitionController;
@interface PTAppDelegate : UIResponder <UIApplicationDelegate, PTLoginViewControllerDelegate> {
    NSArray *books;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) PTLoginViewController *viewController;
@property (strong, nonatomic) TransitionController *transitionController;
@property (strong, nonatomic) PTDialpadViewController *dialpadController;

@end
