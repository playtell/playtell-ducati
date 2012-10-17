//
//  PTContactMessageViewController.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 7/26/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTContactMessageViewController.h"
#import "PTContactImportViewController.h"
#import "PTContactsNavBackButton.h"
#import "PTContactsNavSendButton.h"
#import "PTContactsNavCancelButton.h"
#import "UIColor+HexColor.h"
#import "PTContactsNotifyRequest.h"
#import "PTUser.h"
#import "MBProgressHUD.h"
#import "PTContactsTableMsgCell.h"
#import "PTContactSelectViewController.h"
#import "PTAnalytics.h"
#import <QuartzCore/QuartzCore.h>

@interface PTContactMessageViewController ()

@end

@implementation PTContactMessageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withContacts:(NSMutableArray *)contactList {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Save contacts
        contacts = contactList;
        
        // Keyboard notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Background
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"date_bg"]];
    
    // Navigation controller setup
    self.title = @"Compose Your Message";
    
    // Nav buttons
    PTContactsNavCancelButton *buttonCancelView = [PTContactsNavCancelButton buttonWithType:UIButtonTypeCustom];
    buttonCancelView.frame = CGRectMake(0.0f, 0.0f, 65.0f, 33.0f);
    [buttonCancelView addTarget:self action:@selector(didPressCancel:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithCustomView:buttonCancelView];
    [self.navigationItem setLeftBarButtonItem:cancelButton];
    
    PTContactsNavBackButton *buttonBackView = [PTContactsNavBackButton buttonWithType:UIButtonTypeCustom];
    buttonBackView.frame = CGRectMake(0.0f, 0.0f, 75.0f, 33.0f);
    [buttonBackView addTarget:self action:@selector(didPressBack:) forControlEvents:UIControlEventTouchUpInside];
    buttonBack = [[UIBarButtonItem alloc] initWithCustomView:buttonBackView];
    
    PTContactsNavSendButton *buttonSendView = [PTContactsNavSendButton buttonWithType:UIButtonTypeCustom];
    buttonSendView.frame = CGRectMake(0.0f, 0.0f, 65.0f, 33.0f);
    [buttonSendView addTarget:self action:@selector(didPressSend:) forControlEvents:UIControlEventTouchUpInside];
    buttonSend = [[UIBarButtonItem alloc] initWithCustomView:buttonSendView];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:buttonSend, buttonBack, nil]];
    
    // Table view style
    contactsTableView.backgroundColor = [UIColor clearColor];
    contactsTableView.separatorColor = [UIColor colorFromHex:@"#55707f"];
    CALayer *sep1 = [CALayer layer];
    sep1.backgroundColor = [UIColor colorFromHex:@"#55707f"].CGColor;
    sep1.frame = CGRectMake(0.0f, 0.0f, contactsTableView.frame.size.width, 1.0f);
    [contactsTableContainer.layer addSublayer:sep1];
    
    // Text body style
    msgBody.layer.borderColor = [UIColor colorFromHex:@"#000000" alpha:0.3f].CGColor;
    msgBody.layer.borderWidth = 1.0f;
    msgBody.layer.cornerRadius = 4.0f;
    
    // Setup left box
    leftContainer.backgroundColor = [UIColor colorFromHex:@"#f0f7f7"];
    leftContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    leftContainer.layer.shadowOffset = CGSizeMake(4.0f, 0.0f);
    leftContainer.layer.shadowOpacity = 0.3f;
    leftContainer.layer.shadowRadius = 4.0f;
    
    // Compose box
    composeBox.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"contactsComposeBox"]];
    msgBody.layer.borderWidth = 0.0f;
    myProfilePic.image = [PTUser currentUser].userPhoto;
    myProfilePic.layer.borderColor = [UIColor blackColor].CGColor;
    myProfilePic.layer.borderWidth = 1.0f;
    myProfilePic.layer.cornerRadius = 14.0f;
    
    // Name: Merge field label
    mergeFieldName.textColor = [UIColor colorFromHex:@"#3FA9F5"];
    [self setupFirstNameLbl];
    
    // Links box
    linksBox.backgroundColor = [UIColor colorFromHex:@"#DCE2E5"];
    linksBox.layer.cornerRadius = 12.0f;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    buttonBack = nil;
    buttonSend = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)dealloc {
    // Keyboard notifications cleanup
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWillShow {
    [UIView animateWithDuration:0.3f animations:^{
        self.view.frame = CGRectOffset(self.view.frame, 0.0f, -270.0f);
    }];
}

- (void)keyboardWillHide {
    [UIView animateWithDuration:0.3f animations:^{
        self.view.frame = CGRectOffset(self.view.frame, 0.0f, 270.0f);
    }];
}

#pragma mark - Navigation

- (void)didPressCancel:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didPressBack:(id)sender {
    // Manually added last contact?
    if ([self.navigationController.viewControllers count] == 2) {
        // Pass current contact list back to import view controller to keep track of all contacts
        PTContactImportViewController *importViewController = (PTContactImportViewController *)[self.navigationController.viewControllers objectAtIndex:0];
        importViewController.contacts = contacts;
    }
    
    // Go back
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)didPressInviteMore:(id)sender {
    // Manually added last contact?
    if ([self.navigationController.viewControllers count] == 2) {
        // Pass current contact list back to import view controller to keep track of all contacts
        PTContactImportViewController *importViewController = (PTContactImportViewController *)[self.navigationController.viewControllers objectAtIndex:0];
        importViewController.contacts = contacts;
    }

    // Go back
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - First name cycle

- (void)setupFirstNameLbl {
    // Get all first names
    firstNames = [NSMutableArray array];
    for (NSMutableDictionary *contact in contacts) {
        NSString *name = [contact objectForKey:@"name"];
        NSRange spaceLoc = [name rangeOfString:@" "];
        NSString *firstName;
        if (spaceLoc.location == NSNotFound) {
            firstName = name;
        } else {
            firstName = [name substringToIndex:spaceLoc.location];
        }
        [firstNames addObject:firstName];
    }
    
    // Set first name
    firstNameIndex = 0;
    mergeFieldName.text = [firstNames objectAtIndex:firstNameIndex];
    
    // Cycle through the name
    if ([firstNames count] > 1) {
        [self performSelector:@selector(showNextFirstName) withObject:nil afterDelay:2.0f];
    }
}

- (void)showNextFirstName {
    // Advance names index
    firstNameIndex++;
    if (firstNameIndex == [firstNames count]) {
        firstNameIndex = 0;
    }
    
    // Fade out, change name, fade in.
    [UIView animateWithDuration:0.5f
                     animations:^{
                         mergeFieldName.alpha = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         // Change the name
                         mergeFieldName.text = [firstNames objectAtIndex:firstNameIndex];
                         
                         // Fade in
                         [UIView animateWithDuration:0.5f
                                          animations:^{
                                              mergeFieldName.alpha = 1.0f;
                                          }
                                          completion:^(BOOL finished) {
                                              // Show next name
                                              [self performSelector:@selector(showNextFirstName) withObject:nil afterDelay:2.0f];
                                          }];
                     }];
}

#pragma mark - Temp UI Alert

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didPressSend:(id)sender {
    // Log the analytics event
    [self logAnalyticsEvent];

    // Collect contact emails
    NSMutableArray *contactEmails = [NSMutableArray arrayWithCapacity:[contacts count]];
    for (NSMutableDictionary *contact in contacts) {
        NSString *email = [contact objectForKey:@"email"];
        [contactEmails addObject:email];
    }
    
    // API call
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = @"Sending...";
    
    PTContactsNotifyRequest *contactsNotifyRequest = [[PTContactsNotifyRequest alloc] init];
    [contactsNotifyRequest notifyContacts:contactEmails
                                  message:msgBody.text
                                authToken:[PTUser currentUser].authToken
                                  success:^(NSDictionary *result) {
                                      dispatch_async(dispatch_get_main_queue(), ^() {
                                          [MBProgressHUD hideHUDForView:self.view animated:YES];
                                          UIAlertView *alert = [[UIAlertView alloc]
                                                                initWithTitle:@"Thank you"
                                                                message:@"Congratulations! Invitation emails have been sent out."
                                                                delegate:self
                                                                cancelButtonTitle:@"Ok"
                                                                otherButtonTitles:nil];
                                          [alert show];
                                      });
                                  }
                                  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                      dispatch_async(dispatch_get_main_queue(), ^() {
                                          [MBProgressHUD hideHUDForView:self.view animated:YES];
                                          UIAlertView *alert = [[UIAlertView alloc]
                                                                initWithTitle:@"Notification error"
                                                                message:@"We could not deliver your invite at this time."
                                                                delegate:self
                                                                cancelButtonTitle:@"Ok"
                                                                otherButtonTitles:nil];
                                          [alert show];
                                      });
                                  }];
}

#pragma mark - Table View delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [contacts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"PTContactsTableMsgCell";
    
    PTContactsTableMsgCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[PTContactsTableMsgCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier tableWidth:contactsTableView.frame.size.width];
    }
    
    // Contact description
    NSMutableDictionary *contact = [contacts objectAtIndex:indexPath.row];
    
    // Define cell
    cell.delegate = self;
    cell.contact = contact;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 114.0f;
}

// The following implementation gets rid of empty cells
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1.0f;
}

#pragma mark - Contact select delegates

- (void)contactDidCancelInvite:(NSMutableDictionary *)contact cell:(id)sender {
    // Remove contact from list
    [contacts removeObject:contact];
    
    // Remove cell from table
    PTContactsTableMsgCell *cell = (PTContactsTableMsgCell *)sender;
    NSIndexPath *cellPath = [contactsTableView indexPathForCell:cell];
    if (cellPath) {
        [contactsTableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:cellPath, nil] withRowAnimation:UITableViewRowAnimationMiddle];
    }
    
    // If removed all, go back
    if ([contacts count] == 0) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)logAnalyticsEvent {
    // Contact data source
    NSString *source;
    if ([self.navigationController.viewControllers count] == 2) {
        source = @"Manual Invite";
    } else {
        NSInteger totalController = [self.navigationController.viewControllers count];
        PTContactSelectViewController *contactSelectViewController = [self.navigationController.viewControllers objectAtIndex:(totalController - 2)];
        source = contactSelectViewController.sourceType;
    }
    
    // Total contacts
    NSNumber *totalContacts = [NSNumber numberWithInteger:[contacts count]];
    
    [PTAnalytics sendEventNamed:EventFriendInvitation
                 withProperties:[NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithInteger:[PTUser currentUser].userID], PropUserId,
                                 totalContacts, PropNumContacts,
                                 source, PropContactSource,
                                 nil]];
}

@end