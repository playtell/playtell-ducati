//
//  PTContactImportViewController.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 7/11/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTMOAuth2Authentication.h"

@interface PTContactImportViewController : UIViewController {
    GTMOAuth2Authentication *googleAuth;
}

- (IBAction)googleContactsStart:(id)sender;
- (IBAction)googleLogout:(id)sender;
- (IBAction)localAddressBook:(id)sender;

@end
