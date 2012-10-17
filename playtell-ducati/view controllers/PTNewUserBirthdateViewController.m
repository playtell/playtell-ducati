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
#import "PTAnalytics.h"

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
    self.title = @"Adult Supervision";
    
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
    
    PTContactsNavNextButton *buttonFinishView = [PTContactsNavNextButton buttonWithType:UIButtonTypeCustom];
    buttonFinishView.frame = CGRectMake(0.0f, 0.0f, 75.0f, 33.0f);
    [buttonFinishView setTitle:@"Finish" forState:UIControlStateNormal];
    [buttonFinishView addTarget:self action:@selector(finishDidPress:) forControlEvents:UIControlEventTouchUpInside];
    buttonFinish = [[UIBarButtonItem alloc] initWithCustomView:buttonFinishView];
    buttonFinish.enabled = NO;
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:buttonFinish, buttonBack, nil]];
    
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
    
    // Txtfield Date setup
    txtDate.textColor = [UIColor colorFromHex:@"#999999"];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    // Retrieve user data
    PTNewUserNavigationController *newUserNavigationController = (PTNewUserNavigationController *)self.navigationController;
    if (newUserNavigationController.currentUser.birthday != nil) {
        datePicker.date = newUserNavigationController.currentUser.birthday;
        buttonFinish.enabled = [self isAbove13:datePicker.date];
        [self updateLabelUsingDate:datePicker.date];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    // Save user data
    PTNewUserNavigationController *newUserNavigationController = (PTNewUserNavigationController *)self.navigationController;
    if (hasDateChanged == YES) {
        newUserNavigationController.currentUser.birthday = datePicker.date;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    // Start analytics event timer
    eventStart = [NSDate date];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - Navigation button handlers

- (void)cancelDidPress:(id)sender {
    // Load the dialpad with no signed-in user
    PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate runNewUserWorkflow];
}

- (void)backDidPress:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)finishDidPress:(id)sender {
    PTNewUserPushNotificationsViewController *newUserPushNotificationsViewController = [[PTNewUserPushNotificationsViewController alloc] initWithNibName:@"PTNewUserPushNotificationsViewController" bundle:nil];
    [self.navigationController pushViewController:newUserPushNotificationsViewController animated:YES];
}

#pragma mark - Date picker handler

- (BOOL)isAbove13:(NSDate *)compareDate {
    NSTimeInterval diff = [compareDate timeIntervalSinceNow];
    
    NSDate *date1 = [[NSDate alloc] init];
    NSDate *date2 = [[NSDate alloc] initWithTimeInterval:diff sinceDate:date1];
    NSDateComponents *conversionInfo = [[NSCalendar currentCalendar] components:NSYearCalendarUnit
                                                                       fromDate:date1
                                                                         toDate:date2
                                                                        options:0];
    
    NSInteger years = conversionInfo.year * -1;
    return (years >= 13);
}

- (void)datePickerDidUpdate:(id)sender {
    hasDateChanged = YES;
    buttonFinish.enabled = [self isAbove13:datePicker.date];
    [self updateLabelUsingDate:datePicker.date];
}

- (void)updateLabelUsingDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    txtDate.text = [dateFormatter stringFromDate:date];
}

#pragma mark - Analytics event

- (void)logAnalyticsEvent {
    if (eventStart) {
        PTNewUserNavigationController *newUserNavigationController = (PTNewUserNavigationController *)self.navigationController;
        
        NSTimeInterval interval = fabs([eventStart timeIntervalSinceNow]);
        
        [PTAnalytics sendEventNamed:EventNewUserStep3Birthday
                     withProperties:[NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithFloat:interval], PropDuration,
                                     newUserNavigationController.currentUser.email, PropEmail,
                                     nil]];
    }
}

@end