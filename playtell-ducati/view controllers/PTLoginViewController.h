//
//  PTLoginViewController.h
//  PlayTell
//
//  Created by Ricky Hussmann on 3/13/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PTLoginViewController;

@protocol PTLoginViewControllerDelegate <NSObject>
- (void)loginControllerDidLogin:(PTLoginViewController*)controller;
- (void)createNewAccount:(PTLoginViewController*)controller;
@end

@interface PTLoginViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, retain) IBOutlet UITextField* nicknameField;
@property (nonatomic, retain) IBOutlet UITextField* emailField;
@property (nonatomic, retain) IBOutlet UITextField* passwordField;
@property (nonatomic, retain) IBOutlet UITextField* confirmPasswordField;

@property (nonatomic, retain) IBOutlet UIScrollView* scrollView;

@property (nonatomic, retain) IBOutlet UIImageView* nicknameError;
@property (nonatomic, retain) IBOutlet UIImageView* emailError;
@property (nonatomic, retain) IBOutlet UIImageView* firstPasswordError;
@property (nonatomic, retain) IBOutlet UIImageView* secondPasswordError;
@property (nonatomic, retain) IBOutlet UIImageView* errorHeaderBackground;
@property (nonatomic, retain) IBOutlet UIImageView* errorExclamation;
@property (nonatomic, retain) IBOutlet UILabel* errorTextLabel;
@property (nonatomic, retain) IBOutlet UIImageView* passwordFieldBackground;

@property (nonatomic) id<PTLoginViewControllerDelegate> delegate;

- (IBAction)doneButtonPressed:(id)sender;
- (IBAction)createAccount:(id)sender;
- (IBAction)testShowErrors:(id)sender;

@end
