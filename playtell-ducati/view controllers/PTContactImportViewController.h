//
//  PTContactImportViewController.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 7/11/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTMOAuth2Authentication.h"

@interface PTContactImportViewController : UIViewController <UITextFieldDelegate> {
    GTMOAuth2Authentication *googleAuth;
    IBOutlet UINavigationBar *inviteNavigationBar;
    IBOutlet UIView *inviteContainer;
    IBOutlet UIView *inviteContainerOuter;
    IBOutlet UIView *inviteContainerTexts;
    IBOutlet UIView *inviteExternal;
    IBOutlet UIView *inviteExternalOuter;
    IBOutlet UITextField *textName;
    IBOutlet UITextField *textEmail;
    IBOutlet UIButton *buttonSendInvite;
    IBOutlet UIButton *buttonGoogle;
    IBOutlet UIButton *buttonAddressBook;
    BOOL isKeyboardShown;
}

- (IBAction)googleContactsStart:(id)sender;
- (IBAction)googleLogout:(id)sender;
- (IBAction)localAddressBook:(id)sender;
- (IBAction)manualInvite:(id)sender;

@end
