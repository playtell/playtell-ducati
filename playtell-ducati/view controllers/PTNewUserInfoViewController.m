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
#import "PTUserEmailCheckRequest.h"
#import "PTErrorTableCell.h"

@interface PTNewUserInfoViewController ()

@end

@implementation PTNewUserInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Keyboard notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
        isKeyboardShown = NO;
        
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
    self.title = @"Join PlayTell";
    
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
    
    // Create the mom/kid layers
    CALayer *momLayer = [CALayer layer];
    momLayer.frame = CGRectMake(-1.0f, contentContainer.bounds.size.height - 280.0f - 150.0f, 170.0f, 280.0f);
    momLayer.contents = (id)[UIImage imageNamed:@"mom"].CGImage;
    CALayer *kidLayer = [CALayer layer];
    kidLayer.frame = CGRectMake(contentContainer.bounds.size.width - 135.0f + 1.0f, contentContainer.bounds.size.height - 203.0f - 150.0f, 135.0f, 203.0f);
    kidLayer.contents = (id)[UIImage imageNamed:@"kid"].CGImage;
    CALayer *separatorLayer = [CALayer layer];
    separatorLayer.frame = CGRectMake(0, contentContainer.bounds.size.height - 150.0f, contentContainer.bounds.size.width, 1.0f);
    separatorLayer.backgroundColor = [UIColor colorFromHex:@"#a4b6b8"].CGColor;
    [roundedLayer addSublayer:momLayer];
    [roundedLayer addSublayer:kidLayer];
    [roundedLayer addSublayer:separatorLayer];
    
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
    activityEmailView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    // Errors table view
    errorsTableView.backgroundColor = [UIColor clearColor];
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

#pragma mark - Validators

- (void)validateNameQuietly:(BOOL)skipErrors {
    [self clearErrorsWithType:@"name"];

    // Validate first & last name presence
    NSArray *nameParts = [txtName.text componentsSeparatedByString:@" "];
    if ([nameParts count] < 2) {
        [formErrors addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"name", @"type", @"Enter first AND last names", @"message", nil]];
    } else if ([nameParts count] == 2) {
        NSString *lastName = [nameParts objectAtIndex:1];
        if (lastName.length < 2) {
            [formErrors addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"name", @"type", @"Is that really your last name?", @"message", nil]];
        }
    }

    [self updateTableViewQuietly:skipErrors];
}

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
        [formErrors addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"email", @"type", @"Email is invalid, must have an \"@\" and a \".\"", @"message", nil]];
    }

    [self updateTableViewQuietly:skipErrors];
}

- (void)validatePasswordQuietly:(BOOL)skipErrors {
    [self clearErrorsWithType:@"password"];
    
    if (txtPassword.text.length < 4) {
        [formErrors addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"password", @"type", @"Password must be 4 characters or more", @"message", nil]];
    }
    
    [self updateTableViewQuietly:skipErrors];
}

- (void)validateEmailAvailability {
    // Disable Next button for now
    buttonNext.enabled = NO;
    
    // Show spinning activity
    [activityEmailView startAnimating];
    
    // API call to check email
    PTUserEmailCheckRequest *userEmailCheckRequest = [[PTUserEmailCheckRequest alloc] init];
    [userEmailCheckRequest checkEmail:txtEmail.text
                              success:^(NSDictionary *result) {
                                  BOOL isEmailAvailable = [[result objectForKey:@"available"] boolValue];
                                  if (isEmailAvailable) {
                                      // Email is available
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          buttonNext.enabled = YES;
                                          [activityEmailView stopAnimating];
                                          
                                          // Go to next step in account creation (profile photo)
                                          PTNewUserPhotoViewController *newUserPhotoViewController = [[PTNewUserPhotoViewController alloc] initWithNibName:@"PTNewUserPhotoViewController" bundle:nil];
                                          [self.navigationController pushViewController:newUserPhotoViewController animated:YES];
                                      });
                                  } else {
                                      // Email is NOT available
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          [activityEmailView stopAnimating];
                                          [formErrors addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"email", @"type", @"This email is taken, press sign in below", @"message", nil]];
                                          [self updateTableViewQuietly:NO];
                                          isEmailNotAvailable = YES;
                                          
                                          // Hide the keyboard
//                                          [self.view endEditing:YES];
                                          
//                                          // Load the login view controller
//                                          PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
//                                          PTLoginViewController* loginController = [[PTLoginViewController alloc] initWithNibName:@"PTLoginViewController" bundle:nil];
//                                          loginController.delegate = appDelegate;
//                                          loginController.initialEmailAddress = txtEmail.text;
//                                          
//                                          // Transition to it
//                                          [appDelegate.transitionController transitionToViewController:loginController
//                                                                                           withOptions:UIViewAnimationOptionTransitionCrossDissolve];
                                      });
                                  }
                              }
                              failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      // TODO: Display popup showing error
                                      buttonNext.enabled = YES;
                                      [activityEmailView stopAnimating];
                                  });
                              }];
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
        // Sort the errors: name -> email -> password
        [formErrors sortUsingComparator:^NSComparisonResult(NSDictionary *err1, NSDictionary *err2) {
            // Name
            if ([[err1 objectForKey:@"type"] isEqualToString:@"name"]) {
                if ([[err2 objectForKey:@"type"] isEqualToString:@"name"]) {
                    return NSOrderedSame;
                } else if ([[err2 objectForKey:@"type"] isEqualToString:@"email"] ||
                           [[err2 objectForKey:@"type"] isEqualToString:@"password"]) {
                    return NSOrderedAscending;
                }
            }
            
            // Email
            if ([[err1 objectForKey:@"type"] isEqualToString:@"email"]) {
                if ([[err2 objectForKey:@"type"] isEqualToString:@"email"]) {
                    return NSOrderedSame;
                } else if ([[err2 objectForKey:@"type"] isEqualToString:@"name"]) {
                    return NSOrderedDescending;
                } else if ([[err2 objectForKey:@"type"] isEqualToString:@"password"]) {
                    return NSOrderedAscending;
                }
            }
            
            // Password
            if ([[err1 objectForKey:@"type"] isEqualToString:@"password"]) {
                if ([[err2 objectForKey:@"type"] isEqualToString:@"password"]) {
                    return NSOrderedSame;
                } else if ([[err2 objectForKey:@"type"] isEqualToString:@"name"] ||
                           [[err2 objectForKey:@"type"] isEqualToString:@"email"]) {
                    return NSOrderedDescending;
                }
            }
            
            // Default case. Shouldn't happen.
            return NSOrderedSame;
        }];
        [errorsTableView reloadData];
        
        // Update text colors for each textbox
        txtName.textColor = ([self totalErrorsWithType:@"name"] > 0) ? [UIColor colorFromHex:@"#f92401"] : [UIColor colorFromHex:@"#113441"];
        txtEmail.textColor = ([self totalErrorsWithType:@"email"] > 0) ? [UIColor colorFromHex:@"#f92401"] : [UIColor colorFromHex:@"#113441"];
        txtPassword.textColor = ([self totalErrorsWithType:@"password"] > 0) ? [UIColor colorFromHex:@"#f92401"] : [UIColor colorFromHex:@"#113441"];
    }
    
    // Enable next button
    buttonNext.enabled = (![txtName.text isEqualToString:@""] && ![txtEmail.text isEqualToString:@""] && ![txtPassword.text isEqualToString:@""]) && ([formErrors count] == 0);
}

#pragma mark - Keyboard notification handlers

- (void)keyboardWillShow {
    isKeyboardShown = YES;
    [UIView animateWithDuration:0.2f animations:^{
        contentContainer.frame = CGRectOffset(contentContainer.frame, 0.0f, -80.0f);
        topShadow.alpha = 1.0f;
    }];
}

- (void)keyboardWillHide {
    isKeyboardShown = NO;
    [UIView animateWithDuration:0.2f animations:^{
        contentContainer.frame = CGRectOffset(contentContainer.frame, 0.0f, 80.0f);
        topShadow.alpha = 0.0f;
    }];
}

#pragma mark - Navigation button handlers

- (void)cancelDidPress:(id)sender {
    // Load the dialpad with no signed-in user
    PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate runNewUserWorkflow];
}

- (void)nextDidPress:(id)sender {
    [self.view endEditing:YES]; // Hides the keyboard
    
    // Verify email availability
    [self validateEmailAvailability];
}

- (IBAction)signInDidPress:(id)sender {
    // Load the login view controller
    PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
    PTLoginViewController* loginController = [[PTLoginViewController alloc] initWithNibName:@"PTLoginViewController" bundle:nil];
    loginController.delegate = appDelegate;
    if (isEmailNotAvailable == YES) {
        loginController.initialEmailAddress = txtEmail.text;
    }
    
    // Transition to it
    [appDelegate.transitionController transitionToViewController:loginController
                                                     withOptions:UIViewAnimationOptionTransitionCrossDissolve];
}

#pragma mark - Textfield delegates & notification handler

- (void)textFieldDidBeginEditing:(UITextField *)textField {
//    switch (textField.tag) {
//        case 0: // Name
//            [self clearErrorsWithType:@"name"];
//            break;
//        case 1: // Email
//            [self clearErrorsWithType:@"email"];
//            break;
//        case 2: // Password
//            [self clearErrorsWithType:@"password"];
//            break;
//    }
//    
//    // Disable next button for now
//    buttonNext.enabled = NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    switch (textField.tag) {
        case 0: // Name
            [self validateNameQuietly:NO];
            break;
        case 1: // Email
            [self validateEmailQuietly:NO];
            break;
        case 2: // Password
            [self validatePasswordQuietly:NO];
            // Submit form?
            if ([formErrors count] == 0) {
                [self nextDidPress:nil];
            }
            break;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    switch (textField.tag) {
        case 0: // Name
            [txtEmail becomeFirstResponder];
            break;
        case 1: // Email
            [txtPassword becomeFirstResponder];
            break;
        case 2: // Password
//            if (![txtName.text isEqualToString:@""] && ![txtEmail.text isEqualToString:@""] && ![txtPassword.text isEqualToString:@""]) {
//                [self nextDidPress:nil];
//            }
            [txtPassword resignFirstResponder];
            break;
    }
    
    return YES;
}

- (void)textfieldDidChange:(NSNotification *)notification {
    UITextField *textField = (UITextField *)notification.object;
    switch (textField.tag) {
        case 0: // Name
//            [self clearErrorsWithType:@"name"];
            [self validateNameQuietly:YES];
            break;
        case 1: // Email
            isEmailNotAvailable = NO;
//            [self clearErrorsWithType:@"email"];
            [self validateEmailQuietly:YES];
            break;
        case 2: // Password
//            [self clearErrorsWithType:@"password"];
            [self validatePasswordQuietly:YES];
            break;
    }
}

#pragma mark - Grouped table view delegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView.tag == 0) { // Textbox table view
        return 3;
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
                txtName.frame = CGRectMake(0.0f, 0.0f, 220.0f, 21.0f);
                txtName.font = [UIFont boldSystemFontOfSize:16.0f];
                txtName.placeholder = @"Full Name";
                txtName.autocorrectionType = UITextAutocorrectionTypeNo;
                [txtName setClearButtonMode:UITextFieldViewModeNever];
                txtName.returnKeyType = UIReturnKeyNext;
                txtName.autocapitalizationType = UITextAutocapitalizationTypeWords;
                txtName.tag = 0;
                txtName.delegate = self;
                cell.accessoryView = txtName;
                break;
            }
            case 1: {
                UIView *txtEmailContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 220.0f, 21.0f)];
                txtEmail.frame = CGRectMake(0.0f, 0.0f, 220.0f, 21.0f);
                txtEmail.font = [UIFont boldSystemFontOfSize:16.0f];
                txtEmail.placeholder = @"Email";
                txtEmail.autocorrectionType = UITextAutocorrectionTypeNo;
                [txtEmail setClearButtonMode:UITextFieldViewModeNever];
                txtEmail.keyboardType = UIKeyboardTypeEmailAddress;
                txtEmail.returnKeyType = UIReturnKeyNext;
                txtEmail.autocapitalizationType = UITextAutocapitalizationTypeNone;
                txtEmail.tag = 1;
                txtEmail.delegate = self;
                
                activityEmailView.frame = CGRectMake(200.0f, 1.0f, 20.0f, 20.0f);
                activityEmailView.hidesWhenStopped = YES;
                
                [txtEmailContainer addSubview:txtEmail];
                [txtEmailContainer addSubview:activityEmailView];
                cell.accessoryView = txtEmailContainer;
                break;
            }
            case 2: {
                txtPassword.frame = CGRectMake(0.0f, 0.0f, 220.0f, 21.0f);
                txtPassword.font = [UIFont boldSystemFontOfSize:16.0f];
                txtPassword.secureTextEntry = YES;
                txtPassword.placeholder = @"Password";
                txtPassword.autocorrectionType = UITextAutocorrectionTypeNo;
                [txtPassword setClearButtonMode:UITextFieldViewModeNever];
                txtPassword.returnKeyType = UIReturnKeyDone;
                txtPassword.autocapitalizationType = UITextAutocapitalizationTypeNone;
                txtPassword.tag = 2;
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