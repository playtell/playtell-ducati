//
//  PTNewUserInfoViewController.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 9/11/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PTNewUserInfoViewController.h"
#import "UIColor+HexColor.h"
#import "PTContactsNavCancelButton.h"
#import "PTContactsNavBackButton.h"
#import "PTContactsNavNextButton.h"
#import "PTAppDelegate.h"
#import "TransitionController.h"
#import "PTLoginViewController.h"
#import "PTNewUserNavigationController.h"
#import "PTNewUserPhotoViewController.h"

@interface PTNewUserInfoViewController ()

@end

@implementation PTNewUserInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Keyboard notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
        
        // Textfield change notification
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Background
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"date_bg.png"]];
    
    // Nav setup
    self.title = @"Sign Up";
    
    // Nav buttons
    PTContactsNavCancelButton *buttonCancelView = [PTContactsNavCancelButton buttonWithType:UIButtonTypeCustom];
    buttonCancelView.frame = CGRectMake(0.0f, 0.0f, 65.0f, 33.0f);
    [buttonCancelView addTarget:self action:@selector(cancelDidPress:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithCustomView:buttonCancelView];
    [self.navigationItem setLeftBarButtonItem:cancelButton];
    
    PTContactsNavBackButton *buttonBackView = [PTContactsNavBackButton buttonWithType:UIButtonTypeCustom];
    buttonBackView.frame = CGRectMake(0.0f, 0.0f, 75.0f, 33.0f);
    buttonBack = [[UIBarButtonItem alloc] initWithCustomView:buttonBackView];
    buttonBack.enabled = NO;
    
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
    
    // Init the top shadow line
    topShadow = [[UIView alloc] initWithFrame:CGRectMake(-20.0f, -20.0f, 1024.0f + 40.0f, 20.0f)];
    topShadow.backgroundColor = [UIColor whiteColor];
    topShadow.layer.shadowColor = [UIColor blackColor].CGColor;
    topShadow.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    topShadow.layer.shadowOpacity = 0.9f;
    topShadow.layer.shadowRadius = 5.0f;
    topShadow.alpha = 0.0f;
    [self.view insertSubview:topShadow aboveSubview:contentContainer];
    
    // Textboxes and its container
    groupedTableView.backgroundView = nil;
    txtName = [[UITextField alloc] init];
    txtName.text = @"";
    txtEmail = [[UITextField alloc] init];
    txtEmail.text = @"";
    txtPassword = [[UITextField alloc] init];
    txtPassword.text = @"";
    
    // Page control
    UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(485.0f, 642.0f, 54.0f, 36.0f)];
    pageControl.numberOfPages = 4;
    pageControl.currentPage = 0;
    [self.view addSubview:pageControl];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    // Retrieve user data
    PTNewUserNavigationController *newUserNavigationController = (PTNewUserNavigationController *)self.navigationController;
    if (newUserNavigationController.currentUser.name != nil) {
        txtName.text = newUserNavigationController.currentUser.name;
    }
    if (newUserNavigationController.currentUser.email != nil) {
        txtEmail.text = newUserNavigationController.currentUser.email;
    }
    if (newUserNavigationController.currentUser.password != nil) {
        txtPassword.text = newUserNavigationController.currentUser.password;
    }
    
    // Enable next button?
    buttonNext.enabled = (![txtName.text isEqualToString:@""] && ![txtEmail.text isEqualToString:@""] && ![txtPassword.text isEqualToString:@""]);
}

- (void)viewWillDisappear:(BOOL)animated {
    // Save user data
    PTNewUserNavigationController *newUserNavigationController = (PTNewUserNavigationController *)self.navigationController;
    newUserNavigationController.currentUser.name = txtName.text;
    newUserNavigationController.currentUser.email = txtEmail.text;
    newUserNavigationController.currentUser.password = txtPassword.text;
}

- (void)dealloc {
    // Notifications cleanup
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - Keyboard notification handlers

- (void)keyboardWillShow {
    [UIView animateWithDuration:0.2f animations:^{
        contentContainer.frame = CGRectOffset(contentContainer.frame, 0.0f, -50.0f);
        topShadow.alpha = 1.0f;
    }];
}

- (void)keyboardWillHide {
    [UIView animateWithDuration:0.2f animations:^{
        contentContainer.frame = CGRectOffset(contentContainer.frame, 0.0f, 50.0f);
        topShadow.alpha = 0.0f;
    }];
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

- (void)nextDidPress:(id)sender {
    [self.view endEditing:YES]; // Hides the keyboard
    PTNewUserPhotoViewController *newUserPhotoViewController = [[PTNewUserPhotoViewController alloc] initWithNibName:@"PTNewUserPhotoViewController" bundle:nil];
    [self.navigationController pushViewController:newUserPhotoViewController animated:YES];
}

#pragma mark - Textfield delegates & notification handler

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    switch (textField.tag) {
        case 0:
            [txtEmail becomeFirstResponder];
            break;
        case 1:
            [txtPassword becomeFirstResponder];
            break;
        case 2:
            if (![txtName.text isEqualToString:@""] && ![txtEmail.text isEqualToString:@""] && ![txtPassword.text isEqualToString:@""]) {
                [self nextDidPress:nil];
            }
            break;
    }
    
    return YES;
}

- (BOOL)textFieldDidChange:(NSNotification *)notification {
    buttonNext.enabled = (![txtName.text isEqualToString:@""] && ![txtEmail.text isEqualToString:@""] && ![txtPassword.text isEqualToString:@""]);
    return YES;
}

#pragma mark - Grouped table view delegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [table dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    switch (indexPath.row) {
        case 0: {
            txtName.frame = CGRectMake(0.0f, 0.0f, 220.0f, 21.0f);
            txtName.font = [UIFont systemFontOfSize:14.0f];
            txtName.placeholder = @"Full Name";
            txtName.autocorrectionType = UITextAutocorrectionTypeNo;
            [txtName setClearButtonMode:UITextFieldViewModeWhileEditing];
            txtName.returnKeyType = UIReturnKeyNext;
            txtName.tag = 0;
            txtName.delegate = self;
            cell.accessoryView = txtName;
            break;
        }
        case 1: {
            txtEmail.frame = CGRectMake(0.0f, 0.0f, 220.0f, 21.0f);
            txtEmail.font = [UIFont systemFontOfSize:14.0f];
            txtEmail.placeholder = @"Email";
            txtEmail.autocorrectionType = UITextAutocorrectionTypeNo;
            [txtEmail setClearButtonMode:UITextFieldViewModeWhileEditing];
            txtEmail.keyboardType = UIKeyboardTypeEmailAddress;
            txtEmail.returnKeyType = UIReturnKeyNext;
            txtEmail.tag = 1;
            txtEmail.delegate = self;
            cell.accessoryView = txtEmail;
            break;
        }
        case 2: {
            txtPassword.frame = CGRectMake(0.0f, 0.0f, 220.0f, 21.0f);
            txtPassword.font = [UIFont systemFontOfSize:14.0f];
            txtPassword.secureTextEntry = YES;
            txtPassword.placeholder = @"Password";
            txtPassword.autocorrectionType = UITextAutocorrectionTypeNo;
            [txtPassword setClearButtonMode:UITextFieldViewModeWhileEditing];
            txtPassword.returnKeyType = UIReturnKeyDone;
            txtPassword.tag = 2;
            txtPassword.delegate = self;
            cell.accessoryView = txtPassword;
            break;
        }
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

@end