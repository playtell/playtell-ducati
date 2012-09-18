//
//  PTNewUserPushNotificationsViewController.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 9/14/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PTNewUserPushNotificationsViewController : UIViewController {
    // Nav buttons
    UIBarButtonItem *buttonFinish;
    
    // Content container
    IBOutlet UIView *contentContainer;
    
    // Push notifications
    IBOutlet UIView *viewAlreadyEnabled;
    IBOutlet UIView *viewPushNotificationInfo;
    IBOutlet UIView *viewPushNotificationSuccess;
    IBOutlet UIView *viewPushNotificationFailure;
    IBOutlet UIView *viewAccountCreating;
    IBOutlet UIView *viewAccountFailure;
}

- (IBAction)showPushNotificationPrompt:(id)sender;

@end