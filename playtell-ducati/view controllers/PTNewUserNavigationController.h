//
//  PTNewUserNavigationController.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 9/11/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTConnectionLossViewController.h"
#import "PTNewUser.h"
#import "PTPageIndicatorView.h"

@interface PTNewUserNavigationController : UINavigationController <UINavigationControllerDelegate> {
    PTNewUser *currentUser;
    PTPageIndicatorView *pageControl;
    
    PTConnectionLossViewController *connectionLossController;
    NSTimer *connectionLossTimer;
    BOOL showingConnectionLossController;
}

@property (nonatomic, strong) PTNewUser *currentUser;

- (id)initWithDefaultViewController;
- (void)hidePageControl;

@end