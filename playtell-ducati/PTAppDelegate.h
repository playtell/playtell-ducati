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

@class PTDialpadViewController;
@interface PTAppDelegate : UIResponder <UIApplicationDelegate, PTLoginViewControllerDelegate, PTPLayTellPusherDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) PTDialpadViewController *viewController;

@end
