//
//  PTContactSelectViewController.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 7/18/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTAppDelegate.h"
#import "TransitionController.h"
#import "PTContactImportViewController.h"
#import "PTContactSelectViewController.h"
#import "PTContactMessageViewController.h"
#import "PTContactsCreateListRequest.h"
#import "PTContactsGetListRequest.h"
#import "PTContactsGetRelatedRequest.h"
#import "PTUser.h"
#import "PTInviteContactButton.h"
#import "PTContactsTableBigCell.h"
#import "PTContactsTableSmallCell.h"
#import "PTContactsTableManualInviteCell.h"
#import "UIColor+HexColor.h"
#import "PTContactsNavBackButton.h"
#import "PTContactsNavNextButton.h"
#import "PTContactsNavCancelButton.h"
#import "PTUsersCreateFriendshipRequest.h"
#import "GTMOAuth2Authentication.h"
#import <QuartzCore/QuartzCore.h>

@interface PTContactSelectViewController ()

@end

@implementation PTContactSelectViewController

@synthesize sourceType;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil usingGoogleAuth:(GTMOAuth2Authentication *)_googleAuth {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Create new selected contacts array
        selectedContacts = [NSMutableArray array];
        
        // Filtering
        inSearchMode = NO;
        
        // Monitor contact selection actions
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveContactAction:)
                                                     name:@"actionPerformedOnContact"
                                                   object:nil];
        
        // Retrieve Google Contacts
        googleAuth = _googleAuth;
        [self getGoogleContacts];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withContacts:(NSMutableArray *)contactList {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Create new selected contacts array
        selectedContacts = [NSMutableArray array];
        
        // Filtering
        inSearchMode = NO;
        
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

        // Monitor contact selection actions
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveContactAction:)
                                                     name:@"actionPerformedOnContact"
                                                   object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Background
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"photo-bg-dark.png"]];
    
    // Header view container
    headerContainer.backgroundColor = [UIColor colorFromHex:@"#3FA9F5"];
    headerContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    headerContainer.layer.shadowOpacity = 0.8f;
    headerContainer.layer.shadowRadius = 8.0f;
    headerContainer.layer.borderColor = [UIColor blackColor].CGColor;
    headerContainer.layer.borderWidth = 1.0f;
    
    // Navigation controller setup
    self.title = @"Invite Your Family To Play";
    [self.navigationController.navigationBar setTintColor:[UIColor colorFromHex:@"#3FA9F5"]];
    
    // Nav buttons
    PTContactsNavBackButton *buttonBackView = [PTContactsNavBackButton buttonWithType:UIButtonTypeCustom];
    buttonBackView.frame = CGRectMake(0.0f, 0.0f, 75.0f, 33.0f);
    [buttonBackView setTitle:@"Cancel" forState:UIControlStateNormal];
    [buttonBackView addTarget:self action:@selector(navigateBack:) forControlEvents:UIControlEventTouchUpInside];
    buttonBack = [[UIBarButtonItem alloc] initWithCustomView:buttonBackView];
    [self.navigationItem setLeftBarButtonItem:buttonBack];
    
    // Filtering
    [textSearch addTarget:self action:@selector(searchStringDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    // Setup left box
    leftContainer.backgroundColor = [UIColor colorFromHex:@"#f0f7f7"];
    leftContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    leftContainer.layer.shadowOpacity = 0.8f;
    leftContainer.layer.shadowRadius = 8.0f;
    
    // Table view style
    contactsTableView.backgroundColor = [UIColor colorFromHex:@"#f0f7f7"];
    contactsTableView.separatorColor = [UIColor colorFromHex:@"#55707f"];
    contactsTableView.hidden = YES;
    
    // Setup loading view
    UILabel *loadingLbl = [[loadingView subviews] objectAtIndex:0];
    loadingLbl.textColor = [UIColor colorFromHex:@"#123542"];
    UIView *loadingCrank = [self createLoadingCrank];
    loadingCrank.center = CGPointMake(loadingView.bounds.size.width / 2.0f, (loadingView.bounds.size.height / 2.0f) - 55.0f);
    [loadingView addSubview:loadingCrank];
    
    // Setup bottom bar
    bottomBar.layer.shadowColor = [UIColor blackColor].CGColor;
    bottomBar.layer.shadowOpacity = 0.3f;
    bottomBar.layer.shadowRadius = 4.0f;
    bottomBar.layer.borderColor = [UIColor blackColor].CGColor;
    bottomBar.layer.borderWidth = 1.0f;
    lblManualInvite.shadowColor = [UIColor whiteColor];
    lblManualInvite.shadowOffset = CGSizeMake(0.0f, 1.0f);
}

- (void)viewDidUnload {
    [super viewDidUnload];
    buttonBack = nil;
    buttonNext = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    selectedContacts = [NSArray array];
    [contactsTableView reloadData];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (UIView *)createLoadingCrank {
    UIImage *loadingIcon = [UIImage imageNamed:@"logo_loading.gif"];
    UIImageView *iconImageview = [[UIImageView alloc] initWithImage:loadingIcon];
    iconImageview.frame = CGRectMake(0, 0, loadingIcon.size.width, loadingIcon.size.height);
    
    CATransform3D rotationsTransform = CATransform3DMakeRotation(1.0f * M_PI, 0, 0, 1.0);
    CABasicAnimation *rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    
    rotationAnimation.toValue = [NSValue valueWithCATransform3D:rotationsTransform];
    rotationAnimation.duration = 2.0f;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = 10000;
    
    [iconImageview.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    return iconImageview;
}

- (void)getContactList {
    // Define comparison block (so we can reuse it)
    typedef NSComparisonResult (^ContactsCompareBlock)(NSMutableDictionary *, NSMutableDictionary *);
    ContactsCompareBlock contactsCompareBlock = ^NSComparisonResult(NSMutableDictionary *contact1, NSMutableDictionary *contact2) {
        NSString *name1 = [contact1 objectForKey:@"name"];
        NSRange spaceLoc = [name1 rangeOfString:@" "];
        NSString *compare1;
        if (spaceLoc.location == NSNotFound) {
            compare1 = name1;
        } else {
            NSString *last_name1 = [name1 substringFromIndex:(spaceLoc.location + spaceLoc.length)];
            NSString *first_name1 = [name1 substringToIndex:spaceLoc.location];
            compare1 = [NSString stringWithFormat:@"%@ %@", last_name1, first_name1];
        }
        
        NSString *name2 = [contact2 objectForKey:@"name"];
        spaceLoc = [name2 rangeOfString:@" "];
        NSString *compare2;
        if (spaceLoc.location == NSNotFound) {
            compare2 = name2;
        } else {
            NSString *last_name2 = [name2 substringFromIndex:(spaceLoc.location + spaceLoc.length)];
            NSString *first_name2 = [name2 substringToIndex:spaceLoc.location];
            compare2 = [NSString stringWithFormat:@"%@ %@", last_name2, first_name2];
        }
        
        return [compare1 compare:compare2];
    };
    
    PTContactsGetListRequest *contactsGetListRequest = [[PTContactsGetListRequest alloc] init];
    [contactsGetListRequest getListWithAuthToken:[PTUser currentUser].authToken
                                         success:^(NSArray *contactList, NSInteger total) {
                                             // Modify to mutable objects
                                             contacts = [[NSMutableArray alloc] initWithCapacity:[contactList count]];
                                             contactsOnPT = [[NSMutableArray alloc] init];
                                             contactsNotOnPT = [[NSMutableArray alloc] init];
                                             for (NSDictionary *contact in contactList) {
                                                 [contacts addObject:[NSMutableDictionary dictionaryWithDictionary:contact]];
                                                 
                                                 // Split contacts into two types
                                                 if ([[contact objectForKey:@"user_id"] isKindOfClass:[NSNull class]]) {
                                                     // Not on Playtell
                                                     [contactsNotOnPT addObject:[NSMutableDictionary dictionaryWithDictionary:contact]];
                                                 } else {
                                                     // On Playtell
                                                     [contactsOnPT addObject:[NSMutableDictionary dictionaryWithDictionary:contact]];
                                                 }
                                             }
                                             
                                             // Sort contacts
                                             [contacts sortUsingComparator:contactsCompareBlock];
                                             [contactsOnPT sortUsingComparator:contactsCompareBlock];
                                             [contactsNotOnPT sortUsingComparator:contactsCompareBlock];
                                             
                                             // Show the contacts table
                                             dispatch_async(dispatch_get_main_queue(), ^() {
                                                 // Enable search box & Update table view and fade out the loading sign
                                                 [contactsTableView reloadData];
                                                 [UIView animateWithDuration:0.2f animations:^{
                                                     textSearch.alpha = 1.0f;
                                                     loadingView.alpha = 0.0f;
                                                 } completion:^(BOOL finished) {
                                                     textSearch.enabled = YES;
                                                     [textSearch becomeFirstResponder];
                                                     loadingView.hidden = YES;
                                                     
                                                     // Show table
                                                     contactsTableView.alpha = 0.0f;
                                                     contactsTableView.hidden = NO;
                                                     [UIView animateWithDuration:0.5f animations:^{
                                                         contactsTableView.alpha = 1.0f;
                                                     }];
                                                 }];
                                             });
                                         } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                             NSLog(@"Contacts error: %@, %@", error, JSON);
                                         }];
}

- (void)navigateBack:(id)sender {
    PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.transitionController transitionToViewController:(UIViewController *)appDelegate.dialpadController
                                                     withOptions:UIViewAnimationOptionTransitionCrossDissolve];
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
    
    // Filtered contacts for each contact type
    filteredContactsOnPT = [contactsOnPT filteredArrayUsingPredicate:resultPredicate];
    filteredContactsNotOnPT = [contactsNotOnPT filteredArrayUsingPredicate:resultPredicate];
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

- (void)receiveContactAction:(NSNotification *)notification {    
    // Navigation buttons
    buttonNext.enabled = [selectedContacts count] > 0;
}

#pragma mark - Google Contacts

- (void)getGoogleContacts {
    NSURL *url = [NSURL URLWithString:@"https://www.google.com/m8/feeds/contacts/default/full?alt=json&max-results=2000"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    GTMHTTPFetcher* fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
    [fetcher setAuthorizer:googleAuth];
    [fetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
        if (error == nil) {
            NSError *jsonError;
            NSDictionary *contactsJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            if (jsonError == nil) {
                NSArray *entries = [[contactsJSON objectForKey:@"feed"] objectForKey:@"entry"];
                NSMutableArray *contactList = [NSMutableArray array];
                for (NSDictionary *entry in entries) {
                    // Verify name exists
                    if ([entry objectForKey:@"title"] == nil || [[[entry objectForKey:@"title"] objectForKey:@"$t"] length] == 0) {
                        continue;
                    }
                    NSString *title = [[[entry objectForKey:@"title"] objectForKey:@"$t"] copy];
                    
                    // Verify at least one email exists
                    if ([entry objectForKey:@"gd$email"] == nil) {
                        continue;
                    }
                    NSArray *entryEmails = [entry objectForKey:@"gd$email"];
                    for (NSDictionary *entryEmail in entryEmails) {
                        // Save this contact
                        NSDictionary *contact = [NSDictionary dictionaryWithObjectsAndKeys:
                                                 title,                                                  @"name",
                                                 [[entryEmail objectForKey:@"address"] lowercaseString], @"email",
                                                 @"Google Contacts",                                     @"source",
                                                 nil];
                        [contactList addObject:contact];
                    }
                    
                }
                
                NSLog(@"---> Google Contacts: %i", [contactList count]);
                
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
            } else {
                // TODO: Handle error
                NSLog(@"JSON ERROR: %@", jsonError);
            }
        } else {
            // TODO: Handle error
            NSLog(@"ERROR: %@", error);
        }
    }];
}

#pragma mark - TextField delegates

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [textField performSelector:@selector(resignFirstResponder) withObject:nil afterDelay:0.1f];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textSearch resignFirstResponder];
    return YES;
}

#pragma mark - Table View delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Your friends already on Playtell";
    } else {
        return @"Your friends from [Source]";
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 7.0f, 27.0f, 19.0f)];
    if (section == 0) {
        img.image = [UIImage imageNamed:@"contactsHeader2"];
    } else {
        img.image = [UIImage imageNamed:@"contactsHeader1"];
    }
    
    UIView *header = [[UIView alloc] init];
    header.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"contactsHeaderBg"]];
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 7.0f, 100.0f, 19.0f)];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.textColor = [UIColor colorFromHex:@"#2e4958"];
    lbl.shadowColor = [UIColor colorFromHex:@"#e1e7eb"];
    lbl.shadowOffset = CGSizeMake(0.0f, 1.0f);
    lbl.font = [UIFont systemFontOfSize:16.0f];
    lbl.numberOfLines = 1;
    if (section == 0) {
        lbl.text = @"Your friends already on Playtell";
    } else {
        lbl.text = [NSString stringWithFormat:@"Your friends from %@", self.sourceType];
    }
    [lbl sizeToFit];
    lbl.frame = CGRectMake((tableView.bounds.size.width - lbl.bounds.size.width) / 2.0f, (32.0f - lbl.bounds.size.height) / 2.0f, lbl.bounds.size.width, lbl.bounds.size.height);
    img.frame = CGRectMake(lbl.frame.origin.x - 37.0f, img.frame.origin.y, img.frame.size.width, img.frame.size.height);
    [header addSubview:lbl];
    [header addSubview:img];
    
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 32.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (inSearchMode) {
        // Filtered contacts
        if (section == 0) {
            return [filteredContactsOnPT count];
        } else {
            return [filteredContactsNotOnPT count]; // The extra one is the "Manual Invite" cell.
        }
    } else {
        // All contacts
        if (section == 0) {
            return [contactsOnPT count];
        } else {
            return [contactsNotOnPT count];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {    
    // Load normal cells
    static NSString *CellIdentifier = @"PTContactsTableBigCell";
    PTContactsTableBigCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[PTContactsTableBigCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier tableWidth:contactsTableView.frame.size.width];
    }
    
    // Contact description
    NSMutableDictionary *contact;
    if (inSearchMode) {
        if (indexPath.section == 0) {
            contact = [filteredContactsOnPT objectAtIndex:indexPath.row];
        } else {
            contact = [filteredContactsNotOnPT objectAtIndex:indexPath.row];
        }
    } else {
        if (indexPath.section == 0) {
            contact = [contactsOnPT objectAtIndex:indexPath.row];
        } else {
            contact = [contactsNotOnPT objectAtIndex:indexPath.row];
        }
    }
    
    // Define cell
    cell.delegate = self;
    cell.contact = contact;
    
    if ([[contact objectForKey:@"user_id"] isKindOfClass:[NSNull class]]) { // Not a PT user
        if ([selectedContacts indexOfObject:contact] == NSNotFound) { // Contact NOT already selected
            [cell setMode:PTContactsTableBigCellModeInvite];
        } else { // Contact already selected
            [cell setMode:PTContactsTableBigCellModeUninvite];
        }
    } else { // Existing PT user
        BOOL isConfirmedFriend = [[contact objectForKey:@"is_confirmed_friend"] boolValue];
        BOOL isPendingFriend = [[contact objectForKey:@"is_pending_friend"] boolValue];
        if (isConfirmedFriend || isPendingFriend) { // Already a friend (confirmed or pending)
            [cell setMode:PTContactsTableBigCellModeAlreadyFriend];
        } else { // Not a friend
            [cell setMode:PTContactsTableBigCellModeFriend];
        }
    }
    
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
    return 0.0f;
}

#pragma mark - Button handlers

- (IBAction)viewSelected:(id)sender {
    if (contactsSelectedViewController == nil) {
        contactsSelectedViewController = [[PTContactsSelectedViewController alloc] initWithNibName:@"PTContactsSelectedViewController" bundle:nil];
        contactsSelectedViewController.selectedContacts = selectedContacts;
        contactsSelectedViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [self presentModalViewController:contactsSelectedViewController animated:YES];
    
    // Properly size the view controller
    CGSize vcSize;
    if ([selectedContacts count] == 0) {
        vcSize = CGSizeMake(404.0f, 409.0f);
    } else {
        CGFloat height = MIN(614.0f, ([selectedContacts count] * 114.0f + 44.0f));
        vcSize = CGSizeMake(404.0f, height);
    }
    contactsSelectedViewController.view.superview.frame = CGRectMake(([UIScreen mainScreen].bounds.size.height - vcSize.width) / 2.0f, ([UIScreen mainScreen].bounds.size.width - vcSize.height) / 2.0f, vcSize.width, vcSize.height);
}

- (IBAction)didPressManualInvite:(id)sender {
    PTContactImportViewController *contactImportViewController = [[PTContactImportViewController alloc] initWithNibName:@"PTContactImportViewController" bundle:nil];
    [self.navigationController pushViewController:contactImportViewController animated:YES];
}

#pragma mark - Contact select delegates

- (void)contactDidInvite:(NSMutableDictionary *)contact cell:(id)sender {
    selectedContacts = [NSArray arrayWithObject:contact];
    [self showComposeMessageController:sender];
    //PTContactsTableBigCell *cell = (PTContactsTableBigCell *)sender;
    //[cell setMode:PTContactsTableBigCellModeUninvite];
    //NSLog(@"Cell: %@", NSStringFromCGRect(cell.frame));

    // Add contact to list
    //[selectedContacts addObject:contact];
    
    // Announce action
    //NSDictionary *action = [NSDictionary dictionaryWithObjectsAndKeys:contact, @"contact", [NSNumber numberWithInt:PTContactsTableBigCellActionInvited], @"action", nil];
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"actionPerformedOnContact" object:nil userInfo:action];
}

- (void)contactDidCancelInvite:(NSMutableDictionary *)contact cell:(id)sender {
    //PTContactsTableBigCell *cell = (PTContactsTableBigCell *)sender;
    //[cell setMode:PTContactsTableBigCellModeInvite];

    // Remove contact from list
    [selectedContacts removeObject:contact];
    
    // Announce action
    NSDictionary *action = [NSDictionary dictionaryWithObjectsAndKeys:contact, @"contact", [NSNumber numberWithInt:PTContactsTableBigCellActionUninvited], @"action", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"actionPerformedOnContact" object:nil userInfo:action];
}

- (void)contactDidAddFriend:(NSMutableDictionary *)contact cell:(id)sender {
    // API call to create friendship
    PTUsersCreateFriendshipRequest *usersCreateFriendshipRequest = [[PTUsersCreateFriendshipRequest alloc] init];
    [usersCreateFriendshipRequest userCreateFriendship:[[contact objectForKey:@"user_id"] integerValue]
                                             authToken:[[PTUser currentUser] authToken]
                                               success:^(NSDictionary *result) {
                                                   // Now retrieve contact list from server (with metadata about each contact)
                                                   NSLog(@"Successfully added friend");
                                               } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                   NSLog(@"Failed to add friend: %i, %@", response.statusCode, JSON);
                                               }];
    
    // Mark as pending friend locally
    [contact setObject:[NSNumber numberWithBool:YES] forKey:@"is_pending_friend"];
    
    // Announce action
    NSDictionary *action = [NSDictionary dictionaryWithObjectsAndKeys:contact, @"contact", [NSNumber numberWithInt:PTContactsTableBigCellActionFriended], @"action", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"actionPerformedOnContact" object:nil userInfo:action];
}

- (void)contactDidPressManualInvite:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end