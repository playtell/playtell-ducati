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
#import "UAirship.h"
#import "PTAnalytics.h"
#import "UIView+PlayTell.h"
#import "PTPostcardCreateRequest.h"
#import "PTSpinnerView.h"

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
    
    // Top labels green color
    NSArray *childViews1 = viewPushNotificationInfo.subviews;
    NSArray *childViews2 = viewAccountSuccess.subviews;
    NSMutableSet *allChildViews = [NSMutableSet setWithArray:childViews1];
    [allChildViews addObjectsFromArray:childViews2];
    for (UIView *childView in [allChildViews allObjects]) {
        if (childView.tag != 5) {
            continue;
        }
        UILabel *childLbl = (UILabel *)childView;
        childLbl.textColor = [UIColor colorFromHex:@"#90b81c"];
    }
    
    // Create the spinner view
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    float size = 75.0f;
    spinner = [[PTSpinnerView alloc] initWithFrame:CGRectMake((width - size) / 2, height - (size * 1.333f), size, size)];
    [spinner startSpinning];
    [self.view addSubview:spinner];
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
                                  success:^(NSDictionary *result)
     {
         NSLog(@"New user creation success!");
         
         NSString *message = [result objectForKey:@"message"];
         NSInteger userID = [[message stringByReplacingOccurrencesOfString:@"User created " withString:@""] integerValue];
         
         // Create the first postcard for the user
         UIImageView *postcard = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"postcard-new.png"]];
         UIImageView *photoCopy = [[UIImageView alloc] initWithImage:newUserNavigationController.currentUser.photo];
         photoCopy.frame = CGRectMake((postcard.frame.size.width - 480.0) / 2, ((postcard.frame.size.height - 360.0) / 2) - 70.0, 480.0, 360.0);
         [postcard addSubview:photoCopy];
         UIImage *p = [postcard screenshotWithSave:NO];
         
         // Send the postcard to the server
         dispatch_async(dispatch_get_current_queue(), ^{
             PTPostcardCreateRequest *postcardCreateRequest = [[PTPostcardCreateRequest alloc] init];
             [postcardCreateRequest postcardCreateWithUserId:userID
                                                  playmateId:userID
                                                       photo:p
                                                     success:^(NSDictionary *result)
              {
                  //NSLog(@"Postcard successfully uploaded.");
              } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                  NSLog(@"Postcard creation failure!! %@ - %@", error, JSON);
              }];
         });
         
         isAccountSuccessfullyCreated = YES;
         dispatch_async(dispatch_get_main_queue(), ^{
             // Log the analytics event
             [self logAnalyticsEventAccountWithSuccess:YES];
             
             viewAccountCreating.hidden = YES;
             viewAccountSuccess.hidden = NO;
             [self performSelector:@selector(proceedWithPushNotificationPrompt) withObject:nil afterDelay:2.0f];
         });
     } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
         NSLog(@"New user creation failure!! %@ - %@", error, JSON);
         isAccountSuccessfullyCreated = NO;
         dispatch_async(dispatch_get_main_queue(), ^{
             // Log the analytics event
             [self logAnalyticsEventAccountWithSuccess:NO];
             
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
    // Show the spinner view
    spinner.alpha = 1.0f;
    
    PTNewUserNavigationController *newUserNavigationController = (PTNewUserNavigationController *)self.navigationController;

    // Log the person in and transition directly to dialpad
    PTLoginRequest *loginRequest = [[PTLoginRequest alloc] init];
    [loginRequest loginWithUsername:newUserNavigationController.currentUser.email
                           password:newUserNavigationController.currentUser.password
                          pushToken:@""
                          onSuccess:^(NSDictionary *result) {
                              NSString* token = [result valueForKey:@"token"];
                              NSNumber* userID = [result valueForKey:@"user_id"];
                              NSURL* photoURL;
                              @try {
                                  photoURL = [NSURL URLWithString:[result valueForKey:@"profilePhoto"]];
                              }
                              @catch (NSException *exception) {
                                  photoURL = [NSURL URLWithString:@"http://ragatzi.s3.amazonaws.com/uploads/profile_default_1.png"];
                              }
                              
                              // Save logged-in status
                              PTUser *currentUser = [PTUser currentUser];
                              [currentUser setUsername:newUserNavigationController.currentUser.name];
                              [currentUser setEmail:newUserNavigationController.currentUser.email];
                              [currentUser setAuthToken:token];
                              [currentUser setUserID:[userID unsignedIntValue]];
                              [currentUser setPhotoURL:photoURL];
                              
                              // Setup people attributes in analytics
                              NSMutableDictionary *attr = [[NSMutableDictionary alloc] init];
                              [attr setObject:currentUser.email forKey:PeopleEmail];
                              [attr setObject:currentUser.username forKey:PeopleUsername];
                              [PTAnalytics setPeopleProperties:attr];
                              
                              // Get Urban Airship device token
                              PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
                              [appDelegate setupPushNotifications];

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
        spinner.alpha = 0.0f;
        
        // Transition to push notification views
        [UIView transitionFromView:contentContainer
                            toView:contentContainer2
                          duration:0.8f
                           options:(UIViewAnimationOptionShowHideTransitionViews|UIViewAnimationOptionTransitionFlipFromLeft)
                        completion:^(BOOL finished) {
                            // Start analytics event timer
                            eventStart = [NSDate date];
                        }];
    }
}

- (IBAction)showPushNotificationPrompt:(id)sender {
    NSLog(@"showPushNotificationPrompt");
    // Ask the user for push notification access
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound)];
}

- (void)pushNotificationRequestDidSucceed:(NSNotification *)notification {
    // Log the analytics event
    [self logAnalyticsEventPushWithSuccess:YES];

    // Transition to dialpad to start using app
    [self accountCreatedSuccessfully];
}

- (void)pushNotificationRequestDidFail:(NSNotification *)notification {
    // Log the analytics event
    [self logAnalyticsEventPushWithSuccess:NO];

    // TODO: Ping server that this failed!
    
    // Transition to dialpad to start using app
    [self accountCreatedSuccessfully];
}

#pragma mark - Analytics event

- (void)logAnalyticsEventAccountWithSuccess:(BOOL)isAccountCreated {
    PTNewUserNavigationController *newUserNavigationController = (PTNewUserNavigationController *)self.navigationController;
    
    [PTAnalytics sendEventNamed:EventNewUserStep4AccountCreate
                 withProperties:[NSDictionary dictionaryWithObjectsAndKeys:
                                 newUserNavigationController.currentUser.email, PropEmail,
                                 isAccountCreated ? @"YES" : @"NO", PropAccountCreation,
                                 nil]];
}

- (void)logAnalyticsEventPushWithSuccess:(BOOL)isPushSuccessful {
    if (eventStart) {
        PTNewUserNavigationController *newUserNavigationController = (PTNewUserNavigationController *)self.navigationController;
        
        NSTimeInterval interval = fabs([eventStart timeIntervalSinceNow]);
        
        [PTAnalytics sendEventNamed:EventNewUserStep5Push
                     withProperties:[NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithFloat:interval], PropDuration,
                                     newUserNavigationController.currentUser.email, PropEmail,
                                     isPushSuccessful ? @"YES" : @"NO", PropPushSuccessful,
                                     nil]];
    }
}

@end