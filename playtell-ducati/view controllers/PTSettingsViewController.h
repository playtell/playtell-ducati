//
//  PTSettingsViewController.h
//  playtell-ducati
//
//  Created by Adam Horne on 1/31/13.
//  Copyright (c) 2013 PlayTell. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PTAccountViewController.h"
#import "PTConnectionLossViewController.h"
#import "PTPasswordViewController.h"
#import "PTPictureViewController.h"

@interface PTSettingsViewController : UIViewController {
    // View controllers for settings tabs
    PTAccountViewController *accountViewController;
    PTPasswordViewController *passwordViewController;
    PTPictureViewController *pictureViewController;
    
    // Nav bar buttons
    UIBarButtonItem *buttonBack;
    UIBarButtonItem *buttonSave;
    
    // Buttons
    IBOutlet UIButton *btnAccount;
    IBOutlet UIButton *btnPassword;
    IBOutlet UIButton *btnPicture;
    
    // Container view
    IBOutlet UIView *containerView;
    
    PTConnectionLossViewController *connectionLossController;
    NSTimer *connectionLossTimer;
    BOOL showingConnectionLossController;
}

- (IBAction)accountButtonPressed:(id)sender;
- (IBAction)passwordButtonPressed:(id)sender;
- (IBAction)pictureButtonPressed:(id)sender;

@end
