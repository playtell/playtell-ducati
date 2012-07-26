//
//  PTContactSelectViewController.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 7/18/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTContactSelectViewController.h"
#import "PTContactMessageViewController.h"
#import "PTContactsCreateListRequest.h"
#import "PTContactsGetListRequest.h"
#import "PTUser.h"
#import "PTInviteContactButton.h"
#import <QuartzCore/QuartzCore.h>

@interface PTContactSelectViewController ()

@end

@implementation PTContactSelectViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withContacts:(NSMutableArray *)contactList {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Create new selected contacts array
        selectedContacts = [NSMutableArray array];
        
        // Listen for popover dismiss event
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissSelectedContactsPopover) name:@"selectedContactsPopoverShouldDismiss" object:nil];
        
        // Filtering
        inSearchMode = NO;
        filteredContacts = [NSMutableArray array];
        
        // Save contacts to server
        PTContactsCreateListRequest *contactsCreateListRequest = [[PTContactsCreateListRequest alloc] init];
        [contactsCreateListRequest createList:contactList
                                    authToken:[PTUser currentUser].authToken
                                      success:^(NSDictionary *result) {
                                          // Now retrieve contact list from server (with metadata about each contact)
                                          [self getContactList];
                                      } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                          NSLog(@"Contacts error: %i, %@", response.statusCode, JSON);
                                      }];
    }
    return self;
}

- (void)getContactList {
    PTContactsGetListRequest *contactsGetListRequest = [[PTContactsGetListRequest alloc] init];
    [contactsGetListRequest getListWithAuthToken:[PTUser currentUser].authToken
                                         success:^(NSArray *contactList, NSInteger total) {
                                             contacts = contactList;
                                             dispatch_async(dispatch_get_main_queue(), ^() {
                                                 // Update table view and fade out the loading sign
                                                 [contactsTableView reloadData];
                                                 [UIView animateWithDuration:0.2f animations:^{
                                                     loadingView.alpha = 0.0f;
                                                 } completion:^(BOOL finished) {
                                                     loadingView.hidden = YES;
                                                 }];
                                             });
                                         } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                             NSLog(@"Contacts error: %@, %@", error, JSON);
                                         }];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Background
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"date_bg"]];
    
    // Navigation controller setup
    self.title = @"Invite your family members to PlayTell";
    
    // Cancel button
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(navigateBack:)];
    [self.navigationItem setLeftBarButtonItem:cancelButton];
    
    buttonBack = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil];
    buttonBack.enabled = NO;
    buttonNext = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(showComposeMessageController:)];
    buttonNext.enabled = NO;
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:buttonNext, buttonBack, nil]];
    
    // TEMP
    lblTotalContacts.text = [NSString stringWithFormat:@"%i", [contacts count]];
    
    // Filtering
    [textSearch addTarget:self action:@selector(searchStringDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    buttonBack = nil;
    buttonNext = nil;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)navigateBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)searchStringDidChange:(id)sender {
    // Trim the string
    searchString = [textSearch.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([searchString isEqualToString:@""]) {
        inSearchMode = NO;
        [contactsTableView reloadData];
        return;
    }

    // Filter contacts
    NSPredicate *resultPredicate = [NSPredicate
                                    predicateWithFormat:@"name contains[cd] %@ || email contains[cd] %@",
                                    searchString, searchString];
    
    filteredContacts = [contacts filteredArrayUsingPredicate:resultPredicate];
    inSearchMode = YES;
    
    // Reload table
    [contactsTableView reloadData];
}

- (void)showComposeMessageController:(id)sender {
    PTContactMessageViewController *contactMessageViewController = [[PTContactMessageViewController alloc] initWithNibName:@"PTContactMessageViewController"
                                                                                                                    bundle:nil
                                                                                                              withContacts:selectedContacts];
    [self.navigationController pushViewController:contactMessageViewController animated:YES];
}

#pragma mark - TextField delegates

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [textSearch resignFirstResponder];
    return YES;
}

#pragma mark - Table View delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (inSearchMode) {
        return [filteredContacts count];
    } else {
        return [contacts count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ContactDetailCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    PTInviteContactButton *addButton;
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];

        // Button
        addButton = [PTInviteContactButton buttonWithType:UIButtonTypeCustom];
        addButton.frame = CGRectMake(382.0f, 9.0f, 120.0f, 33.0f);
        addButton.tag = 100;
        addButton.layer.borderColor = [UIColor blackColor].CGColor;
        addButton.layer.borderWidth = 1.0f;
        addButton.layer.cornerRadius = 10.0f;
        [addButton addTarget:self action:@selector(contactAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:addButton];
    }
    
    // Contact description
    NSDictionary *contact;
    if (inSearchMode) {
        contact = [filteredContacts objectAtIndex:indexPath.row];
    } else {
        contact = [contacts objectAtIndex:indexPath.row];
    }
    
    // Define cell
    cell.textLabel.text = [contact objectForKey:@"name"];
    addButton = (PTInviteContactButton *)[cell viewWithTag:100];
    addButton.contact = contact;
    if ([[contact objectForKey:@"user_id"] isKindOfClass:[NSNull class]]) {
        cell.detailTextLabel.text = [contact objectForKey:@"email"];
        [addButton setTitle:@"Invite contact" forState:UIControlStateNormal];
        addButton.backgroundColor = [UIColor blueColor];
    } else {
        BOOL isFriend = [[contact objectForKey:@"is_friend"] boolValue];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Existing user! (%i)", [[contact objectForKey:@"user_id"] integerValue]];
        if (isFriend) {
            [addButton setTitle:@"A friend!" forState:UIControlStateNormal];
            [addButton setEnabled:NO];
            addButton.backgroundColor = [UIColor blackColor];
        } else {
            [addButton setTitle:@"Add as friend" forState:UIControlStateNormal];
            addButton.backgroundColor = [UIColor redColor];
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0f;
}

// The following implementation gets rid of empty cells
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1.0f;
}

#pragma mark - Button handlers

- (void)contactAction:(id)sender {
    PTInviteContactButton *button = (PTInviteContactButton *)sender;
    
    if ([[button.contact objectForKey:@"user_id"] isKindOfClass:[NSNull class]]) {
        // Not an existing user
        if (button.selected) {
            [button setSelected:NO];
            button.backgroundColor = [UIColor blueColor];
            [selectedContacts removeObject:button.contact];
        } else {
            [button setSelected:YES];
            button.backgroundColor = [UIColor blackColor];
            [selectedContacts addObject:button.contact];
        }
        
        // Update total selected contacts label
        lblTotalContacts.text = [NSString stringWithFormat:@"%i", [selectedContacts count]];
        
        // Navigation buttons
        buttonNext.enabled = [selectedContacts count] > 0;
    } else {
        // Existing user
        if (button.selected) {
            [button setSelected:NO];
            // TODO: Create friendship request
        } else {
            [button setSelected:YES];
            // TODO: Remove friendship request
        }
    }
}

- (IBAction)viewSelected:(id)sender {
    if (contactsSelectedPopover == nil) {
        contactsSelectedViewController = [[PTContactsSelectedViewController alloc] initWithNibName:@"PTContactsSelectedViewController" bundle:nil];
        contactsSelectedPopover = [[UIPopoverController alloc] initWithContentViewController:contactsSelectedViewController];
        [contactsSelectedPopover setPopoverContentSize:CGSizeMake(300.0f, 300.0f)];
    }
    
    UIButton *button = (UIButton *)sender;
    contactsSelectedViewController.selectedContacts = selectedContacts;
    [contactsSelectedPopover presentPopoverFromRect:button.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)dismissSelectedContactsPopover {
    [contactsSelectedPopover dismissPopoverAnimated:YES];
}

@end
