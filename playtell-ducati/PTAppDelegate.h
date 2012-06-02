//
//  PTAppDelegate.h
//  playtell-ducati
//
//  Created by Ricky Hussmann on 5/30/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTLoginViewController.h"
#import "PTPusher.h"

#import <UIKit/UIKit.h>

@class PTViewController;
@interface PTAppDelegate : UIResponder <UIApplicationDelegate, PTLoginViewControllerDelegate, PTPusherDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) PTViewController *viewController;

@end
