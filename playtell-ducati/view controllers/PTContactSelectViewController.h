//
//  PTContactSelectViewController.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 7/18/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTContactsSelectedViewController.h"

@interface PTContactSelectViewController : UIViewController <UITextFieldDelegate, UITableViewDelegate> {
    UIBarButtonItem *buttonBack;
    UIBarButtonItem *buttonNext;
    NSArray *contacts;
    NSMutableArray *selectedContacts;
    IBOutlet UITableView *contactsTableView;
    IBOutlet UILabel *lblTotalContacts;
    IBOutlet UIView *loadingView;
    PTContactsSelectedViewController *contactsSelectedViewController;
    UIPopoverController *contactsSelectedPopover;
    
    // Filtering
    IBOutlet UITextField *textSearch;
    BOOL inSearchMode;
    NSArray *filteredContacts;
    NSString *searchString;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withContacts:(NSMutableArray *)contactList;
- (IBAction)viewSelected:(id)sender;

@end