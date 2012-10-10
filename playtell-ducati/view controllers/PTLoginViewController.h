//
//  PTLoginViewController.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 9/24/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PTLoginViewController;

@protocol PTLoginViewControllerDelegate <NSObject>
    - (void)loginControllerDidLogin:(PTLoginViewController*)controller;
@end

@interface PTLoginViewController : UIViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate> {
    // Nav button
    UIBarButtonItem *buttonBack;

    // Nav bar
    IBOutlet UINavigationBar *navigationBar;
    
    // Content container
    IBOutlet UIView *contentContainer;
    UIView *topShadow;
    
    // Textfield
    UITextField *txtEmail;
    UITextField *txtPassword;
    UIActivityIndicatorView *activityEmailView;
    IBOutlet UITableView *groupedTableView;
    IBOutlet UITableView *errorsTableView;
    NSMutableArray *formErrors;
    IBOutlet UIButton *buttonSignIn;
}

@property (nonatomic) id<PTLoginViewControllerDelegate> delegate;
@property (nonatomic, strong) NSString *initialEmailAddress;

- (IBAction)signInDidPress:(id)sender;

@end