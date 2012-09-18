//
//  PTNewUserPushNotificationsViewController.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 9/14/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PTNewUserPushNotificationsViewController.h"
#import "UIColor+HexColor.h"
#import "PTContactsNavCancelButton.h"
#import "PTContactsNavBackButton.h"
#import "PTContactsNavNextButton.h"
#import "PTAppDelegate.h"
#import "TransitionController.h"
#import "PTLoginViewController.h"
#import "PTNewUserNavigationController.h"
#import "PTUserCreateRequest.h"

@interface PTNewUserPushNotificationsViewController ()

@end

@implementation PTNewUserPushNotificationsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Push notification request notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotificationRequestDidSucceed:) name:@"PushNotificationRequestDidSucceed" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotificationRequestDidFail:) name:@"PushNotificationRequestDidFail" object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Background
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"date_bg.png"]];
    
    // Nav setup
    self.title = @"Push Notifications";
    
    // Nav buttons
    self.navigationItem.hidesBackButton = YES;
    
    PTContactsNavNextButton *buttonFinishView = [PTContactsNavNextButton buttonWithType:UIButtonTypeCustom];
    buttonFinishView.frame = CGRectMake(0.0f, 0.0f, 75.0f, 33.0f);
    [buttonFinishView setTitle:@"Finish" forState:UIControlStateNormal];
    [buttonFinishView addTarget:self action:@selector(finishDidPress:) forControlEvents:UIControlEventTouchUpInside];
    buttonFinish = [[UIBarButtonItem alloc] initWithCustomView:buttonFinishView];
    buttonFinish.enabled = NO;
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:buttonFinish, nil]];
    
    // Content container style
    contentContainer.backgroundColor = [UIColor clearColor];
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:contentContainer.bounds
                                                   byRoundingCorners:(UIRectCornerBottomLeft|UIRectCornerBottomRight)
                                                         cornerRadii:CGSizeMake(4.0f, 4.0f)];
    
    // Create the shadow layer
    CAShapeLayer *shadowLayer = [CAShapeLayer layer];
    [shadowLayer setFrame:contentContainer.bounds];
    [shadowLayer setMasksToBounds:NO];
    [shadowLayer setShadowPath:maskPath.CGPath];
    shadowLayer.shadowColor = [UIColor blackColor].CGColor;
    shadowLayer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    shadowLayer.shadowOpacity = 0.2f;
    shadowLayer.shadowRadius = 10.0f;
    
    CALayer *roundedLayer = [CALayer layer];
    [roundedLayer setFrame:contentContainer.bounds];
    [roundedLayer setBackgroundColor:[UIColor colorFromHex:@"#e4ecef"].CGColor];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = contentContainer.bounds;
    maskLayer.path = maskPath.CGPath;
    roundedLayer.mask = maskLayer;
    
    [contentContainer.layer insertSublayer:shadowLayer atIndex:0];
    [contentContainer.layer insertSublayer:roundedLayer atIndex:1];
    
    // Show creating account view
    viewAccountCreating.hidden = NO;
    
    // Page control
    UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(485.0f, 642.0f, 54.0f, 36.0f)];
    pageControl.numberOfPages = 4;
    pageControl.currentPage = 3;
    [self.view addSubview:pageControl];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated {
    PTNewUserNavigationController *newUserNavigationController = (PTNewUserNavigationController *)self.navigationController;

    // Create a new user
    PTUserCreateRequest *userCreateRequest = [[PTUserCreateRequest alloc] init];
    [userCreateRequest userCreateWithName:newUserNavigationController.currentUser.name
                                    email:newUserNavigationController.currentUser.email
                                 password:newUserNavigationController.currentUser.password
                                    photo:newUserNavigationController.currentUser.photo
                                birthdate:newUserNavigationController.currentUser.birthday
                        isAccountForChild:newUserNavigationController.currentUser.isAccountForChild
                                  success:^(NSDictionary *result) {
                                      NSLog(@"New user creation success!");
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          viewAccountCreating.hidden = YES;
                                          [self proceedWithPushNotificationPrompt];
                                      });
                                  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                      NSLog(@"New user creation failure!! %@ - %@", error, JSON);
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          viewAccountCreating.hidden = YES;
                                          viewAccountFailure.hidden = NO;
                                          buttonFinish.enabled = YES;
                                      });
                                  }];
}

- (void)dealloc {
    // Notifications cleanup
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - Navigation button handlers

- (void)finishDidPress:(id)sender {
    // TODO: Log the person in and transition directly to dialpad?

    // Load the login view controller
    PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
    PTLoginViewController* loginController = [[PTLoginViewController alloc] initWithNibName:@"PTLoginViewController" bundle:nil];
    loginController.delegate = appDelegate;
    
    // Transition to it
    [appDelegate.transitionController transitionToViewController:loginController
                                                     withOptions:UIViewAnimationOptionTransitionCrossDissolve];
}

#pragma mark - Push Notification handlers

- (void)proceedWithPushNotificationPrompt {
    // Push notification status
    UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    if (types & UIRemoteNotificationTypeAlert) {
        viewAlreadyEnabled.hidden = NO;
        buttonFinish.enabled = YES;
    } else {
        viewPushNotificationInfo.hidden = NO;
    }
}

- (IBAction)showPushNotificationPrompt:(id)sender {
    NSLog(@"showPushNotificationPrompt");
    // Ask the user for push notification access
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound)];
}

- (void)pushNotificationRequestDidSucceed:(NSNotification *)notification {
    NSLog(@"pushNotificationRequestDidSucceed");
    viewPushNotificationInfo.hidden = YES;
    viewPushNotificationSuccess.hidden = NO;
    buttonFinish.enabled = YES;
}

- (void)pushNotificationRequestDidFail:(NSNotification *)notification {
    NSLog(@"pushNotificationRequestDidFail");
    viewPushNotificationInfo.hidden = YES;
    viewPushNotificationFailure.hidden = NO;
    buttonFinish.enabled = YES;
}

@end