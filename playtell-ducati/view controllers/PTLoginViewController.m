//
//  PTLoginViewController.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 9/24/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PTLoginViewController.h"
#import "UIColor+HexColor.h"
#import "PTContactsNavLongBackButton.h"
#import "PTContactsNavCancelButton.h"
#import "PTNewUserNavigationController.h"
#import "PTAppDelegate.h"
#import "TransitionController.h"
#import "PTLoginRequest.h"
#import "PTUser.h"
#import "PTErrorTableCell.h"
#import "UAirship.h"
#import "PTAnalytics.h"

@interface PTLoginViewController ()

@end

@implementation PTLoginViewController

@synthesize delegate;
@synthesize initialEmailAddress;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Keyboard notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];

        // Errors container
        formErrors = [NSMutableArray array];
        
        // Textfield notification
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textfieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Background
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"date_bg.png"]];
    
    // Nav setup
    self.title = @"Sign in to PlayTell";
    navigationBar.tintColor = [UIColor colorFromHex:@"#2e4857"];
    navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorFromHex:@"#E3F1FF"], UITextAttributeTextColor, nil];
    
    // Nav buttons
    PTContactsNavCancelButton *buttonCancelView = [PTContactsNavCancelButton buttonWithType:UIButtonTypeCustom];
    buttonCancelView.frame = CGRectMake(0.0f, 0.0f, 65.0f, 33.0f);
    [buttonCancelView addTarget:self action:@selector(cancelDidPress:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithCustomView:buttonCancelView];
    [navigationBar.topItem setLeftBarButtonItem:cancelButton];
    
    PTContactsNavLongBackButton *buttonBackView = [PTContactsNavLongBackButton buttonWithType:UIButtonTypeCustom];
    buttonBackView.frame = CGRectMake(0.0f, 0.0f, 165.0f, 33.0f);
    [buttonBackView setTitle:@"Create New Account" forState:UIControlStateNormal];
    [buttonBackView addTarget:self action:@selector(createNewAccountDidPress:) forControlEvents:UIControlEventTouchUpInside];
    buttonBack = [[UIBarButtonItem alloc] initWithCustomView:buttonBackView];
    [navigationBar.topItem setRightBarButtonItem:buttonBack];
    
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
    
    // Create the mom/kid layers
    CALayer *momLayer = [CALayer layer];
    momLayer.frame = CGRectMake(-1.0f, contentContainer.bounds.size.height - 280.0f, 170.0f, 280.0f);
    momLayer.contents = (id)[UIImage imageNamed:@"mom"].CGImage;
    CALayer *kidLayer = [CALayer layer];
    kidLayer.frame = CGRectMake(contentContainer.bounds.size.width - 135.0f + 1.0f, contentContainer.bounds.size.height - 203.0f, 135.0f, 203.0f);
    kidLayer.contents = (id)[UIImage imageNamed:@"kid"].CGImage;
    [roundedLayer addSublayer:momLayer];
    [roundedLayer addSublayer:kidLayer];
    
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
    txtEmail = [[UITextField alloc] init];
    txtEmail.text = self.initialEmailAddress == nil ? @"" : self.initialEmailAddress;
    if (self.initialEmailAddress != nil) {
        txtEmail.textColor = [UIColor colorFromHex:@"#113441"];
    }
    txtPassword = [[UITextField alloc] init];
    txtPassword.text = @"";
    activityEmailView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    // Errors table view
    errorsTableView.backgroundColor = [UIColor clearColor];
    
    // Sign in button
    buttonSignIn.enabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    // Notifications cleanup
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Validators

- (void)validateEmailQuietly:(BOOL)skipErrors {
    [self clearErrorsWithType:@"email"];

    // Verify email string
    NSString *emailRegEx =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    if (![emailTest evaluateWithObject:txtEmail.text]) {
        [formErrors addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"email", @"type", @"Email is invalid", @"message", nil]];
    }

    [self updateTableViewQuietly:skipErrors];
}

- (void)validatePasswordQuietly:(BOOL)skipErrors {
    [self clearErrorsWithType:@"password"];

    // Verify password string
    if (txtPassword.text.length < 2) {
        [formErrors addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"password", @"type", @"Password must be 2 characters or more", @"message", nil]];
    }
    
    [self updateTableViewQuietly:skipErrors];
}

- (void)clearErrorsWithType:(NSString *)type {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type != %@", type];
    formErrors = [NSMutableArray arrayWithArray:[formErrors filteredArrayUsingPredicate:predicate]];
    [self updateTableViewQuietly:NO];
}

- (NSInteger)totalErrorsWithType:(NSString *)type {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type = %@", type];
    NSMutableArray *newErrors = [NSMutableArray arrayWithArray:[formErrors filteredArrayUsingPredicate:predicate]];
    return [newErrors count];
}

- (void)updateTableViewQuietly:(BOOL)skipErrors {
    if (skipErrors == NO) {
        // Sort the errors: email -> password
        [formErrors sortUsingComparator:^NSComparisonResult(NSDictionary *err1, NSDictionary *err2) {
            // Email
            if ([[err1 objectForKey:@"type"] isEqualToString:@"email"]) {
                if ([[err2 objectForKey:@"type"] isEqualToString:@"email"]) {
                    return NSOrderedSame;
                } else if ([[err2 objectForKey:@"type"] isEqualToString:@"password"]) {
                    return NSOrderedAscending;
                }
            }
            
            // Password
            if ([[err1 objectForKey:@"type"] isEqualToString:@"password"]) {
                if ([[err2 objectForKey:@"type"] isEqualToString:@"password"]) {
                    return NSOrderedSame;
                } else if ([[err2 objectForKey:@"type"] isEqualToString:@"email"]) {
                    return NSOrderedDescending;
                }
            }
            
            // Default case. Shouldn't happen.
            return NSOrderedSame;
        }];
        [errorsTableView reloadData];
        
        
        // Update text colors for each textbox
        txtEmail.textColor = ([self totalErrorsWithType:@"email"] > 0) ? [UIColor colorFromHex:@"#f92401"] : [UIColor colorFromHex:@"#113441"];
        txtPassword.textColor = ([self totalErrorsWithType:@"password"] > 0) ? [UIColor colorFromHex:@"#f92401"] : [UIColor colorFromHex:@"#113441"];
    }
    
    // Enable next button
    buttonSignIn.enabled = (![txtEmail.text isEqualToString:@""] && ![txtPassword.text isEqualToString:@""] && [formErrors count] == 0);
}

#pragma mark - Keyboard notification handlers

- (void)keyboardWillShow {
    [UIView animateWithDuration:0.2f animations:^{
        contentContainer.frame = CGRectOffset(contentContainer.frame, 0.0f, -80.0f);
        topShadow.alpha = 1.0f;
    }];
}

- (void)keyboardWillHide {
    [UIView animateWithDuration:0.2f animations:^{
        contentContainer.frame = CGRectOffset(contentContainer.frame, 0.0f, 80.0f);
        topShadow.alpha = 0.0f;
    }];
}

#pragma mark - Button handlers

- (void)cancelDidPress:(id)sender {
    // Load the dialpad with no signed-in user
    PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate runNewUserWorkflow];
}

- (IBAction)signInDidPress:(id)sender {
    if (isSigningIn == YES) {
        return;
    }
    isSigningIn = YES;

    // End editing & show activity
    [self.view endEditing:YES];
    [activityEmailView startAnimating];
    txtEmail.enabled = NO;
    txtPassword.enabled = NO;
    
    // API login request
    PTLoginRequest *loginRequest = [[PTLoginRequest alloc] init];
    [loginRequest loginWithUsername:txtEmail.text
                           password:txtPassword.text
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
                              [currentUser setUsername:txtEmail.text];
                              [currentUser setEmail:txtEmail.text];
                              [currentUser setAuthToken:token];
                              [currentUser setUserID:[userID unsignedIntValue]];
                              [currentUser setPhotoURL:photoURL];
                              [currentUser setUserPhoto:nil];
                              
                              // Setup people attributes in analytics
                              NSMutableDictionary *attr = [[NSMutableDictionary alloc] init];
                              [attr setObject:currentUser.email forKey:PeopleEmail];
                              [attr setObject:currentUser.username forKey:PeopleUsername];
                              [PTAnalytics setPeopleProperties:attr];
                              
                              // Get Urban Airship device token
                              PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
                              [appDelegate setupPushNotifications];
                              
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  [activityEmailView stopAnimating];

                                  if (self.delegate && [self.delegate respondsToSelector:@selector(loginControllerDidLogin:)]) {
                                      [self.delegate loginControllerDidLogin:self];
                                  }
                              });
                          }
                          onFailure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                              NSLog(@"Error: %@", JSON);
                              isSigningIn = NO;
                              NSString *errorMsg = [JSON objectForKey:@"message"];
                              if ([errorMsg isEqualToString:@"User cannot be found."]) {
                                  [formErrors addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"email", @"type", @"Email entered doesn't appear to be an existing user", @"message", nil]];
                              } else if ([errorMsg isEqualToString:@"Invalid password."]) {
                                  [formErrors addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"password", @"type", @"Password is invalid. Please try again", @"message", nil]];
                              }
     
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  [self updateTableViewQuietly:NO];

                                  [activityEmailView stopAnimating];
                                  txtEmail.enabled = YES;
                                  txtPassword.enabled = YES;
                              });
                          }];
}

- (void)createNewAccountDidPress:(id)sender {
    // Load the create new user nav
    PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
    PTNewUserNavigationController *newUserNavigationController = [[PTNewUserNavigationController alloc] initWithDefaultViewController];
    
    // Transition to it
    [appDelegate.transitionController transitionToViewController:newUserNavigationController
                                                     withOptions:UIViewAnimationOptionTransitionCrossDissolve];
}

#pragma mark - Textfield delegates & notification handler

- (void)textFieldDidBeginEditing:(UITextField *)textField {
//    switch (textField.tag) {
//        case 0: // Email
//            [self clearErrorsWithType:@"email"];
//            break;
//        case 1: // Password
//            [self clearErrorsWithType:@"password"];
//            break;
//    }
//    
//    // Disable sign in button for now
//    buttonSignIn.enabled = NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    switch (textField.tag) {
        case 0: // Email
            [self validateEmailQuietly:NO];
            break;
        case 1: // Password
            [self validatePasswordQuietly:NO];
            // Submit form?
            if ([formErrors count] == 0) {
                [self signInDidPress:nil];
            }
            break;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    switch (textField.tag) {
        case 0: // Email
            [txtPassword becomeFirstResponder];
            break;
        case 1: // Passowrd
            [txtPassword resignFirstResponder];
            break;
    }
    
    return YES;
}

- (void)textfieldDidChange:(NSNotification *)notification {
    UITextField *textField = (UITextField *)notification.object;
    switch (textField.tag) {
        case 0: // Email
            [self validateEmailQuietly:YES];
            break;
        case 1: // Password
            [self validatePasswordQuietly:YES];
            break;
    }
}

#pragma mark - Grouped table view delegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView.tag == 0) { // Textbox table view
        return 2;
    } else { // Errors table view
        return [formErrors count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == 0) { // Textbox table view
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TextFieldCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TextFieldCell"];
        }
        
        switch (indexPath.row) {
            case 0: {
                UIView *txtEmailContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 220.0f, 21.0f)];
                txtEmail.frame = CGRectMake(0.0f, 0.0f, 220.0f, 21.0f);
                txtEmail.font = [UIFont boldSystemFontOfSize:16.0f];
                txtEmail.placeholder = @"Email";
                txtEmail.autocorrectionType = UITextAutocorrectionTypeNo;
                [txtEmail setClearButtonMode:UITextFieldViewModeNever];
                txtEmail.keyboardType = UIKeyboardTypeEmailAddress;
                txtEmail.returnKeyType = UIReturnKeyNext;
                txtEmail.autocapitalizationType = UITextAutocapitalizationTypeNone;
                txtEmail.tag = 0;
                txtEmail.delegate = self;
                
                activityEmailView.frame = CGRectMake(200.0f, 1.0f, 20.0f, 20.0f);
                activityEmailView.hidesWhenStopped = YES;
                
                [txtEmailContainer addSubview:txtEmail];
                [txtEmailContainer addSubview:activityEmailView];
                cell.accessoryView = txtEmailContainer;
                break;
            }
            case 1: {
                txtPassword.frame = CGRectMake(0.0f, 0.0f, 220.0f, 21.0f);
                txtPassword.font = [UIFont boldSystemFontOfSize:16.0f];
                txtPassword.secureTextEntry = YES;
                txtPassword.placeholder = @"Password";
                txtPassword.autocorrectionType = UITextAutocorrectionTypeNo;
                [txtPassword setClearButtonMode:UITextFieldViewModeNever];
                txtPassword.returnKeyType = UIReturnKeyDone;
                txtPassword.autocapitalizationType = UITextAutocapitalizationTypeNone;
                txtPassword.tag = 1;
                txtPassword.delegate = self;
                cell.accessoryView = txtPassword;
                break;
            }
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else { // Errors table view
        PTErrorTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PTErrorTableCell"];
        if (cell == nil) {
            cell = [[PTErrorTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PTErrorTableCell"];
        }
        
        // Get the error
        NSDictionary *errorDescription = [formErrors objectAtIndex:indexPath.row];
        cell.textLabel.text = [errorDescription objectForKey:@"message"];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == 0) { // Textbox table view
        return 44.0f;
    } else { // Errors table view
        return 24.0f;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// The following implementation gets rid of empty cells
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0f;
}

@end