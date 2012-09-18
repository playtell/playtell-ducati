//
//  PTNewUserBirthdateViewController.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 9/13/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PTNewUserBirthdateViewController.h"
#import "UIColor+HexColor.h"
#import "PTContactsNavCancelButton.h"
#import "PTContactsNavBackButton.h"
#import "PTContactsNavNextButton.h"
#import "PTAppDelegate.h"
#import "TransitionController.h"
#import "PTLoginViewController.h"
#import "PTNewUserNavigationController.h"
#import "PTNewUserPushNotificationsViewController.h"

@interface PTNewUserBirthdateViewController ()

@end

@implementation PTNewUserBirthdateViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initial date status
        hasDateChanged = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Background
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"date_bg.png"]];
    
    // Nav setup
    self.title = @"Birthdate";
    
    // Nav buttons
    PTContactsNavCancelButton *buttonCancelView = [PTContactsNavCancelButton buttonWithType:UIButtonTypeCustom];
    buttonCancelView.frame = CGRectMake(0.0f, 0.0f, 65.0f, 33.0f);
    [buttonCancelView addTarget:self action:@selector(cancelDidPress:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithCustomView:buttonCancelView];
    [self.navigationItem setLeftBarButtonItem:cancelButton];
    
    PTContactsNavBackButton *buttonBackView = [PTContactsNavBackButton buttonWithType:UIButtonTypeCustom];
    buttonBackView.frame = CGRectMake(0.0f, 0.0f, 75.0f, 33.0f);
    [buttonBackView addTarget:self action:@selector(backDidPress:) forControlEvents:UIControlEventTouchUpInside];
    buttonBack = [[UIBarButtonItem alloc] initWithCustomView:buttonBackView];
    
    PTContactsNavNextButton *buttonNextView = [PTContactsNavNextButton buttonWithType:UIButtonTypeCustom];
    buttonNextView.frame = CGRectMake(0.0f, 0.0f, 75.0f, 33.0f);
    [buttonNextView addTarget:self action:@selector(nextDidPress:) forControlEvents:UIControlEventTouchUpInside];
    buttonNext = [[UIBarButtonItem alloc] initWithCustomView:buttonNextView];
    buttonNext.enabled = NO;
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:buttonNext, buttonBack, nil]];
    
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
    
    // Date picker setup
    UIView *datePickerView = [datePicker.subviews objectAtIndex:0];
    datePickerView.layer.cornerRadius = 4.0f;
    datePickerView.layer.masksToBounds = YES;
    [datePicker addTarget:self action:@selector(datePickerDidUpdate:) forControlEvents:UIControlEventValueChanged];
    
    // Child switch setup
    childAccountSwitch = [[DCRoundSwitch alloc] initWithFrame:CGRectMake(335.0f, 150.0f, 78.0f, 30.0f)];
    childAccountSwitch.onText = @"Yes";
    childAccountSwitch.offText = @"No";
    [self.view addSubview:childAccountSwitch];
    
    // Page control
    UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(485.0f, 642.0f, 54.0f, 36.0f)];
    pageControl.numberOfPages = 4;
    pageControl.currentPage = 2;
    [self.view addSubview:pageControl];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    // Retrieve user data
    PTNewUserNavigationController *newUserNavigationController = (PTNewUserNavigationController *)self.navigationController;
    if (newUserNavigationController.currentUser.birthday != nil) {
        datePicker.date = newUserNavigationController.currentUser.birthday;
        buttonNext.enabled = YES;
        [self updateLabelUsingDate:datePicker.date];
    }
    [childAccountSwitch setOn:newUserNavigationController.currentUser.isAccountForChild];
}

- (void)viewWillDisappear:(BOOL)animated {
    // Save user data
    PTNewUserNavigationController *newUserNavigationController = (PTNewUserNavigationController *)self.navigationController;
    if (hasDateChanged == YES) {
        newUserNavigationController.currentUser.birthday = datePicker.date;
    }
    newUserNavigationController.currentUser.isAccountForChild = childAccountSwitch.on;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - Navigation button handlers

- (void)cancelDidPress:(id)sender {
    // Load the login view controller
    PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
    PTLoginViewController* loginController = [[PTLoginViewController alloc] initWithNibName:@"PTLoginViewController" bundle:nil];
    loginController.delegate = appDelegate;
    
    // Transition to it
    [appDelegate.transitionController transitionToViewController:loginController
                                                     withOptions:UIViewAnimationOptionTransitionCrossDissolve];
}

- (void)backDidPress:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)nextDidPress:(id)sender {
    PTNewUserPushNotificationsViewController *newUserPushNotificationsViewController = [[PTNewUserPushNotificationsViewController alloc] initWithNibName:@"PTNewUserPushNotificationsViewController" bundle:nil];
    [self.navigationController pushViewController:newUserPushNotificationsViewController animated:YES];
}

#pragma mark - Date picker handler

- (void)datePickerDidUpdate:(id)sender {
    hasDateChanged = YES;
    buttonNext.enabled = YES;
    [self updateLabelUsingDate:datePicker.date];
}

- (void)updateLabelUsingDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    lblDate.text = [dateFormatter stringFromDate:date];
}

@end