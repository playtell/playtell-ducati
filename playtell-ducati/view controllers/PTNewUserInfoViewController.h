//
//  PTNewUserInfoViewController.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 9/11/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PTNewUserInfoViewController : UIViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate> {
    // Nav buttons
    UIBarButtonItem *buttonBack;
    UIBarButtonItem *buttonNext;
    
    // Content container
    IBOutlet UIView *contentContainer;
    UIView *topShadow;
    
    // Textfield
    UITextField *txtName;
    UITextField *txtEmail;
    UITextField *txtPassword;
    UIActivityIndicatorView *activityEmailView;
    IBOutlet UITableView *groupedTableView;
    IBOutlet UITableView *errorsTableView;
    NSMutableArray *formErrors;
    BOOL isKeyboardShown;
    BOOL isEmailNotAvailable;
}

- (IBAction)signInDidPress:(id)sender;

@end