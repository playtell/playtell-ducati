//
//  PTSettingsViewController.h
//  playtell-ducati
//
//  Created by Adam Horne on 1/31/13.
//  Copyright (c) 2013 PlayTell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PTSettingsViewController : UIViewController {
    // Nav bar buttons
    UIBarButtonItem *buttonBack;
    UIBarButtonItem *buttonSave;
    
    // Buttons
    IBOutlet UIButton *btnAccount;
    IBOutlet UIButton *btnPassword;
    
    // Container view
    IBOutlet UIView *containerView;
}

@end
