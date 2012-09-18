//
//  PTNewUserBirthdateViewController.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 9/13/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCRoundSwitch.h"

@interface PTNewUserBirthdateViewController : UIViewController {
    // Nav buttons
    UIBarButtonItem *buttonBack;
    UIBarButtonItem *buttonNext;
    
    // Content container
    IBOutlet UIView *contentContainer;

    // Date picker
    IBOutlet UIDatePicker *datePicker;
    BOOL hasDateChanged;
    IBOutlet UILabel *lblDate;
    
    // Parent check
    DCRoundSwitch *childAccountSwitch;
}

@end