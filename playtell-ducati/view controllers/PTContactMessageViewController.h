//
//  PTContactMessageViewController.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 7/26/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTConnectionLossViewController.h"
#import "PTContactSelectDelegate.h"

@interface PTContactMessageViewController : UIViewController <UIAlertViewDelegate, UITableViewDelegate, PTContactSelectDelegate> {
    UIBarButtonItem *buttonBack;
    UIBarButtonItem *buttonSend;
    NSMutableArray *contacts;
    NSMutableArray *firstNames;
    NSInteger firstNameIndex;
    IBOutlet UITableView *contactsTableView;
    IBOutlet UITextView *msgBody;
    IBOutlet UIView *contactsTableContainer;
    IBOutlet UIView *leftContainer;
    IBOutlet UIView *composeBox;
    IBOutlet UILabel *mergeFieldName;
    IBOutlet UIView *linksBox;
    
    PTConnectionLossViewController *connectionLossController;
    NSTimer *connectionLossTimer;
    BOOL showingConnectionLossController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withContacts:(NSMutableArray *)contactList;
- (IBAction)didPressInviteMore:(id)sender;
- (IBAction)didPressSend:(id)sender;

@end
