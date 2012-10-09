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
    IBOutlet UIView *contentContainerMain;
    IBOutlet UIView *contentContainer;
    IBOutlet UIView *contentContainer2;
    
    // Push notifications
    IBOutlet UIView *viewPushNotificationInfo;
    
    // Account creation
    IBOutlet UIView *viewAccountSuccess;
    IBOutlet UIView *viewAccountCreating;
    IBOutlet UIView *viewAccountFailure;
    BOOL isAccountSuccessfullyCreated;
}

- (IBAction)showPushNotificationPrompt:(id)sender;

@end