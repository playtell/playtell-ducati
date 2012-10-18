//
//  PTNewUserBirthdateViewController.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 9/13/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PTNewUserBirthdateViewController : UIViewController {
    // Nav buttons
    UIBarButtonItem *buttonBack;
    UIBarButtonItem *buttonFinish;
    
    // Content container
    IBOutlet UIView *contentContainer;

    // Date picker
    IBOutlet UIDatePicker *datePicker;
    BOOL hasDateChanged;
    IBOutlet UITextField *txtDate;
    
    // Tooltip
    UIImageView *ttBirthday;
    BOOL hasTooltipBeenShown;
    BOOL isTooltipShown;
    
    // Analytics
    NSDate *eventStart;
}

@end