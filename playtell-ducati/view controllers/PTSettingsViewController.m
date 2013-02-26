//
//  PTSettingsViewController.m
//  playtell-ducati
//
//  Created by Adam Horne on 1/31/13.
//  Copyright (c) 2013 PlayTell. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "PTAppDelegate.h"
#import "PTContactsNavBackButton.h"
#import "PTContactsNavSendButton.h"
#import "PTSettingsViewController.h"
#import "PTUser.h"
#import "PTUserSettingsRequest.h"
#import "TransitionController.h"

#import "NSDate+Rails.h"
#import "UIColor+ColorFromHex.h"

@interface PTSettingsViewController ()

@end

@implementation PTSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom implementation
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Background
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"date_bg.png"]];
    
    // Navigation controller setup
    self.title = @"Account Settings";
    [self.navigationController.navigationBar setTintColor:[UIColor colorFromHex:@"#3FA9F5"]];
    
    // Nav buttons
    PTContactsNavSendButton *buttonDoneView = [PTContactsNavSendButton buttonWithType:UIButtonTypeCustom];
    [buttonDoneView setTitle:@"Done" forState:UIControlStateNormal];
    buttonDoneView.frame = CGRectMake(0.0f, 0.0f, 65.0f, 33.0f);
    [buttonDoneView addTarget:self action:@selector(navigateBack:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *navBackButton = [[UIBarButtonItem alloc] initWithCustomView:buttonDoneView];
    [self.navigationItem setLeftBarButtonItem:navBackButton];
    
    // Container view
    containerView.layer.cornerRadius = 5.0f;
    containerView.backgroundColor = [UIColor colorFromHex:@"#E4ECEF"];
    
    // Create the view controllers for the different tabs
    accountViewController = [[PTAccountViewController alloc] init];
    accountViewController.view.frame = CGRectMake(0.0f, 0.0f, containerView.frame.size.width, containerView.frame.size.height);
    passwordViewController = [[PTPasswordViewController alloc] init];
    passwordViewController.view.frame = CGRectMake(0.0f, 0.0f, containerView.frame.size.width, containerView.frame.size.height);
    passwordViewController.view.alpha = 0.0f;
    pictureViewController = [[PTPictureViewController alloc] init];
    pictureViewController.view.frame = CGRectMake(0.0f, 0.0f, containerView.frame.size.width, containerView.frame.size.height);
    pictureViewController.view.alpha = 0.0f;
    
    // Add the subviews from the view controllers
    [containerView addSubview:accountViewController.view];
    [containerView addSubview:passwordViewController.view];
    [containerView addSubview:pictureViewController.view];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Get the current settings and load those into account tab
    PTUserSettingsRequest *settingsRequest = [[PTUserSettingsRequest alloc] init];
    [settingsRequest getUserSettingsWithUserId:[PTUser currentUser].userID
                                     authToken:[PTUser currentUser].authToken
                                       success:^(NSDictionary *result)
     {
         NSDictionary *user = [result objectForKey:@"user"];
         accountViewController.name = [user objectForKey:@"displayName"];
         accountViewController.email = [user objectForKey:@"email"];
         
         // Check the date
         NSString *dateString = [user objectForKey:@"birthday"];
         if (![dateString isKindOfClass:[NSNull class]]) {
             accountViewController.birthday = [NSDate dateFromRailsString:dateString];
         } else {
             [accountViewController accountHasNoBirthday];
         }
     }
                                       failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
     {
         NSLog(@"Could not retrieve user settings");
     }];
}

- (void)navigateBack:(id)sender {
    PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.transitionController transitionToViewController:(UIViewController *)appDelegate.dialpadController
                                                     withOptions:UIViewAnimationOptionTransitionCrossDissolve];
}

#pragma mark - Button press methods

- (IBAction)accountButtonPressed:(id)sender {
    // If we're showing the right view, just return
    if (accountViewController.view.alpha == 1.0) {
        return;
    }
    
    // Setup the buttons
    btnAccount.selected = YES;
    btnAccount.userInteractionEnabled = NO;
    btnPassword.selected = NO;
    btnPassword.userInteractionEnabled = YES;
    btnPicture.selected = NO;
    btnPicture.userInteractionEnabled = YES;
    
    [UIView animateWithDuration:0.2f animations:^{
        // Hide the other views
        passwordViewController.view.alpha = 0.0f;
        pictureViewController.view.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2f animations:^{
            // Show the account view
            accountViewController.view.alpha = 1.0f;
        }];
    }];
}

- (IBAction)passwordButtonPressed:(id)sender {
    // If we're showing the right view, just return
    if (passwordViewController.view.alpha == 1.0) {
        return;
    }
    
    // Setup the buttons
    btnAccount.selected = NO;
    btnAccount.userInteractionEnabled = YES;
    btnPassword.selected = YES;
    btnPassword.userInteractionEnabled = NO;
    btnPicture.selected = NO;
    btnPicture.userInteractionEnabled = YES;
    
    [UIView animateWithDuration:0.2f animations:^{
        // Hide the other views
        accountViewController.view.alpha = 0.0f;
        pictureViewController.view.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2f animations:^{
            // Show the password view
            passwordViewController.view.alpha = 1.0f;
        }];
    }];
}

- (IBAction)pictureButtonPressed:(id)sender {
    // If we're showing the right view, just return
    if (pictureViewController.view.alpha == 1.0) {
        return;
    }
    
    // Setup the buttons
    btnAccount.selected = NO;
    btnAccount.userInteractionEnabled = YES;
    btnPassword.selected = NO;
    btnPassword.userInteractionEnabled = YES;
    btnPicture.selected = YES;
    btnPicture.userInteractionEnabled = NO;
    
    [UIView animateWithDuration:0.2f animations:^{
        // Hide the other views
        accountViewController.view.alpha = 0.0f;
        passwordViewController.view.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2f animations:^{
            // Show the picture view
            pictureViewController.view.alpha = 1.0f;
        }];
    }];
}

@end
