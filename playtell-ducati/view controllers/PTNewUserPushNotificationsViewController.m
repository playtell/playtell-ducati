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
#import "PTLoginRequest.h"
#import "PTUser.h"

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
    self.title = @"";
    
    // Nav buttons
    self.navigationItem.hidesBackButton = YES;
    
//    PTContactsNavNextButton *buttonFinishView = [PTContactsNavNextButton buttonWithType:UIButtonTypeCustom];
//    buttonFinishView.frame = CGRectMake(0.0f, 0.0f, 75.0f, 33.0f);
//    [buttonFinishView setTitle:@"Finish" forState:UIControlStateNormal];
//    [buttonFinishView addTarget:self action:@selector(finishDidPress:) forControlEvents:UIControlEventTouchUpInside];
//    buttonFinish = [[UIBarButtonItem alloc] initWithCustomView:buttonFinishView];
//    buttonFinish.enabled = NO;
//    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:buttonFinish, nil]];
    
    // Content container style
    contentContainerMain.backgroundColor = [UIColor clearColor];
    contentContainer.backgroundColor = [UIColor clearColor];
    contentContainer2.backgroundColor = [UIColor clearColor];
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:contentContainer.bounds
                                                   byRoundingCorners:UIRectCornerAllCorners
                                                         cornerRadii:CGSizeMake(4.0f, 4.0f)];
    
    // Create the shadow layer (1)
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

    // Create the shadow layer (2)
    CAShapeLayer *shadowLayer2 = [CAShapeLayer layer];
    [shadowLayer2 setFrame:contentContainer.bounds];
    [shadowLayer2 setMasksToBounds:NO];
    [shadowLayer2 setShadowPath:maskPath.CGPath];
    shadowLayer2.shadowColor = [UIColor blackColor].CGColor;
    shadowLayer2.shadowOffset = CGSizeMake(0.0f, 0.0f);
    shadowLayer2.shadowOpacity = 0.2f;
    shadowLayer2.shadowRadius = 10.0f;
    CALayer *roundedLayer2 = [CALayer layer];
    [roundedLayer2 setFrame:contentContainer.bounds];
    [roundedLayer2 setBackgroundColor:[UIColor colorFromHex:@"#e4ecef"].CGColor];
    CAShapeLayer *maskLayer2 = [CAShapeLayer layer];
    maskLayer2.frame = contentContainer.bounds;
    maskLayer2.path = maskPath.CGPath;
    roundedLayer2.mask = maskLayer2;
    [contentContainer2.layer insertSublayer:shadowLayer2 atIndex:0];
    [contentContainer2.layer insertSublayer:roundedLayer2 atIndex:1];

    // Show creating account view
    viewAccountCreating.hidden = NO;
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated {
    // Create a new user
    PTNewUserNavigationController *newUserNavigationController = (PTNewUserNavigationController *)self.navigationController;
    PTUserCreateRequest *userCreateRequest = [[PTUserCreateRequest alloc] init];
    [userCreateRequest userCreateWithName:newUserNavigationController.currentUser.name
                                    email:newUserNavigationController.currentUser.email
                                 password:newUserNavigationController.currentUser.password
                                    photo:newUserNavigationController.currentUser.photo
                                birthdate:newUserNavigationController.currentUser.birthday
                                  success:^(NSDictionary *result) {
                                      NSLog(@"New user creation success!");
                                      isAccountSuccessfullyCreated = YES;
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          viewAccountCreating.hidden = YES;
                                          viewAccountSuccess.hidden = NO;
                                          [self performSelector:@selector(proceedWithPushNotificationPrompt) withObject:nil afterDelay:2.0f];
                                      });
                                  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                      NSLog(@"New user creation failure!! %@ - %@", error, JSON);
                                      isAccountSuccessfullyCreated = NO;
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          // Change Finish button title
                                          PTContactsNavNextButton *buttonFinishView = (PTContactsNavNextButton *)buttonFinish.customView;
                                          [buttonFinishView setTitle:@"Retry" forState:UIControlStateNormal];

                                          viewAccountCreating.hidden = YES;
                                          viewAccountFailure.hidden = NO;
                                          
                                          [self performSelector:@selector(accountCreationFailed) withObject:nil afterDelay:2.0f];
                                      });
                                  }];
    
//    isAccountSuccessfullyCreated = YES;
//    dispatch_async(dispatch_get_main_queue(), ^{
//        viewAccountCreating.hidden = YES;
//        viewAccountSuccess.hidden = NO;
//        [self performSelector:@selector(proceedWithPushNotificationPrompt) withObject:nil afterDelay:2.0f];
//    });
}

- (void)viewWillAppear:(BOOL)animated {
    // Hide navigation bar
    [self.navigationController setNavigationBarHidden:YES animated:YES];

    // Hide page control
    PTNewUserNavigationController *newUserNavigationController = (PTNewUserNavigationController *)self.navigationController;
    [newUserNavigationController hidePageControl];
}

- (void)dealloc {
    // Notifications cleanup
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - Success/failure cases of account creation

- (void)accountCreatedSuccessfully {
    PTNewUserNavigationController *newUserNavigationController = (PTNewUserNavigationController *)self.navigationController;

    // Log the person in and transition directly to dialpad
    PTLoginRequest *loginRequest = [[PTLoginRequest alloc] init];
    [loginRequest loginWithUsername:newUserNavigationController.currentUser.email
                           password:newUserNavigationController.currentUser.password
                          pushToken:@""
                          onSuccess:^(NSDictionary *result) {
//                              NSLog(@"Login result: %@", result);
                              NSString* token = [result valueForKey:@"token"];
                              NSNumber* userID = [result valueForKey:@"user_id"];
                              NSURL* photoURL = [NSURL URLWithString:[result valueForKey:@"profilePhoto"]];
                              
                              [[PTUser currentUser] setUsername:newUserNavigationController.currentUser.email];
                              [[PTUser currentUser] setEmail:newUserNavigationController.currentUser.email];
                              [[PTUser currentUser] setAuthToken:token];
                              [[PTUser currentUser] setUserID:[userID unsignedIntValue]];
                              [[PTUser currentUser] setPhotoURL:photoURL];
                              
//                              NSLog(@"Current user: %@", [PTUser currentUser]);

                              dispatch_async(dispatch_get_main_queue(), ^{
                                  PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
                                  [appDelegate loginControllerDidLogin:nil];
                              });
                          }
                          onFailure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                              NSLog(@"Login error: %@", JSON);

                              dispatch_async(dispatch_get_main_queue(), ^{
                                  // Not sure how to handle this one...
                                  // Load the login view controller for now
                                  PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
                                  PTLoginViewController* loginController = [[PTLoginViewController alloc] initWithNibName:@"PTLoginViewController" bundle:nil];
                                  loginController.delegate = appDelegate;
                                  
                                  // Transition to it
                                  [appDelegate.transitionController transitionToViewController:loginController
                                                                                   withOptions:UIViewAnimationOptionTransitionCrossDissolve];
                              });
                          }];
}

- (void)accountCreationFailed {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Push Notification handlers

- (void)proceedWithPushNotificationPrompt {
    // Push notification status
    UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    if (types & UIRemoteNotificationTypeAlert) {
        // Transition to dialpad to start using app
        [self accountCreatedSuccessfully];
    } else {
        // Transition to push notification views
        [UIView transitionFromView:contentContainer
                            toView:contentContainer2
                          duration:0.8f
                           options:(UIViewAnimationOptionShowHideTransitionViews|UIViewAnimationOptionTransitionFlipFromLeft)
                        completion:nil];
    }
}

- (IBAction)showPushNotificationPrompt:(id)sender {
    NSLog(@"showPushNotificationPrompt");
    // Ask the user for push notification access
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound)];
}

- (void)pushNotificationRequestDidSucceed:(NSNotification *)notification {
    // Transition to dialpad to start using app
    [self accountCreatedSuccessfully];
}

- (void)pushNotificationRequestDidFail:(NSNotification *)notification {
    // TODO: Ping server that this failed!
    
    // Transition to dialpad to start using app
    [self accountCreatedSuccessfully];
}

@end