//
//  PTContactSelectViewController.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 7/18/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTContactsSelectedViewController.h"
#import "PTContactSelectDelegate.h"
#import "PTContactsInvitationCountButton.h"
#import "GTMOAuth2Authentication.h"

@interface PTContactSelectViewController : UIViewController <UITextFieldDelegate, UITableViewDelegate, PTContactSelectDelegate> {
    GTMOAuth2Authentication *googleAuth;
    UIBarButtonItem *buttonBack;
    UIBarButtonItem *buttonNext;
    NSMutableArray *contacts;
    NSMutableArray *contactsOnPT;
    NSMutableArray *contactsNotOnPT;
    NSMutableArray *selectedContacts;
    IBOutlet UITableView *contactsTableView;
    IBOutlet UIView *loadingView;
    PTContactsSelectedViewController *contactsSelectedViewController;
    
    // Filtering
    IBOutlet UITextField *textSearch;
    BOOL inSearchMode;
    NSArray *filteredContactsOnPT;
    NSArray *filteredContactsNotOnPT;
    NSString *searchString;
    
    // Related contacts
    NSMutableArray *relatedContacts;
    IBOutlet UIView *relatedContactsContainer;
    IBOutlet UITableView *relatedContactsTableView;
    IBOutlet UIImageView *relatedHeader;
    
    // Invitation/filter box
    IBOutlet UIView *leftContainer;
    IBOutlet UIView *invitationContainer;
    PTContactsInvitationCountButton *contactsInvitationCountButton;
}

@property (nonatomic, retain) NSString *sourceType;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil usingGoogleAuth:(GTMOAuth2Authentication *)_googleAuth;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withContacts:(NSMutableArray *)contactList;
- (IBAction)viewSelected:(id)sender;

@end