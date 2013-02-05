//
//  PTSettingsViewController.h
//  playtell-ducati
//
//  Created by Adam Horne on 1/31/13.
//  Copyright (c) 2013 PlayTell. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PTAccountViewController.h"
#import "PTPasswordViewController.h"

@interface PTSettingsViewController : UIViewController {
    // View controllers for settings tabs
    PTAccountViewController *accountViewController;
    PTPasswordViewController *passwordViewController;
    
    // Nav bar buttons
    UIBarButtonItem *buttonBack;
    UIBarButtonItem *buttonSave;
    
    // Buttons
    IBOutlet UIButton *btnAccount;
    IBOutlet UIButton *btnPassword;
    
    // Container view
    IBOutlet UIView *containerView;
}

- (IBAction)accountButtonPressed:(id)sender;
- (IBAction)passwordButtonPressed:(id)sender;

@end
