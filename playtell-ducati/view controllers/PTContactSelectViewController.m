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
#import "PTContactsGetRelatedRequest.h"
#import "PTUser.h"
#import "PTInviteContactButton.h"
#import "PTContactsTableBigCell.h"
#import "PTContactsTableSmallCell.h"
#import "UIColor+HexColor.h"
#import "PTContactsNavBackButton.h"
#import "PTContactsNavNextButton.h"
#import "PTContactsNavCancelButton.h"
#import "PTUsersCreateFriendshipRequest.h"
#import <QuartzCore/QuartzCore.h>

@interface PTContactSelectViewController ()

@end

@implementation PTContactSelectViewController

@synthesize sourceType;

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
                                          [self getRelatedContacts];
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
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"date_bg"]];
    
    // Navigation controller setup
    self.title = @"Invite your family members to PlayTell";
    
    // Nav buttons
    PTContactsNavCancelButton *buttonCancelView = [PTContactsNavCancelButton buttonWithType:UIButtonTypeCustom];
    buttonCancelView.frame = CGRectMake(0.0f, 0.0f, 65.0f, 33.0f);
    [buttonCancelView addTarget:self action:@selector(navigateBack:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithCustomView:buttonCancelView];
    [self.navigationItem setLeftBarButtonItem:cancelButton];
    
    PTContactsNavBackButton *buttonBackView = [PTContactsNavBackButton buttonWithType:UIButtonTypeCustom];
    buttonBackView.frame = CGRectMake(0.0f, 0.0f, 75.0f, 33.0f);
    buttonBack = [[UIBarButtonItem alloc] initWithCustomView:buttonBackView];
    buttonBack.enabled = NO;

    PTContactsNavNextButton *buttonNextView = [PTContactsNavNextButton buttonWithType:UIButtonTypeCustom];
    buttonNextView.frame = CGRectMake(0.0f, 0.0f, 75.0f, 33.0f);
    [buttonNextView addTarget:self action:@selector(showComposeMessageController:) forControlEvents:UIControlEventTouchUpInside];
    buttonNext = [[UIBarButtonItem alloc] initWithCustomView:buttonNextView];
    buttonNext.enabled = NO;
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:buttonNext, buttonBack, nil]];
    
    // Filtering
    [textSearch addTarget:self action:@selector(searchStringDidChange:) forControlEvents:UIControlEventEditingChanged];
    invitationContainer.backgroundColor = [UIColor colorWithRed:(62.0f / 255.0f) green:(169.0f / 255.0f) blue:(245.0f / 255.0f) alpha:1.0f];
    contactsInvitationCountButton = [PTContactsInvitationCountButton buttonWithType:UIButtonTypeCustom];
    [contactsInvitationCountButton setTitle:@"0" forState:UIControlStateNormal];
    contactsInvitationCountButton.frame = CGRectMake(31.0f, 12.0f, 88.0f, 82.0f);
    [contactsInvitationCountButton addTarget:self action:@selector(viewSelected:) forControlEvents:UIControlEventTouchUpInside];
    [invitationContainer addSubview:contactsInvitationCountButton];
    
    // Setup left box
    leftContainer.backgroundColor = [UIColor colorFromHex:@"#f0f7f7"];
    leftContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    leftContainer.layer.shadowOffset = CGSizeMake(4.0f, 0.0f);
    leftContainer.layer.shadowOpacity = 0.3f;
    leftContainer.layer.shadowRadius = 4.0f;
    
    // Table view style
    contactsTableView.backgroundColor = [UIColor colorFromHex:@"#f0f7f7"];
    contactsTableView.separatorColor = [UIColor colorFromHex:@"#55707f"];
    contactsTableView.hidden = YES;
    relatedContactsTableView.backgroundColor = [UIColor clearColor];
    relatedContactsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    CALayer *sep1 = [CALayer layer];
    sep1.backgroundColor = [UIColor colorFromHex:@"#55707f"].CGColor;
    sep1.frame = CGRectMake(0.0f, 0.0f, relatedContactsTableView.frame.size.width, 1.0f);
    [relatedContactsContainer.layer addSublayer:sep1];
    CALayer *sep2 = [CALayer layer];
    sep2.backgroundColor = [UIColor colorFromHex:@"#55707f"].CGColor;
    sep2.frame = CGRectMake(0.0f, relatedContactsTableView.frame.size.height - 1.0f, relatedContactsTableView.frame.size.width, 1.0f);
    [relatedContactsContainer.layer addSublayer:sep2];
    relatedContactsContainer.hidden = YES;
    relatedHeader.hidden = YES;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    buttonBack = nil;
    buttonNext = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [contactsTableView reloadData];
    [contactsInvitationCountButton setTitle:[NSString stringWithFormat:@"%i", [selectedContacts count]] forState:UIControlStateNormal];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
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
                                                 // Update table view and fade out the loading sign
                                                 [contactsTableView reloadData];
                                                 [UIView animateWithDuration:0.2f animations:^{
                                                     loadingView.alpha = 0.0f;
                                                 } completion:^(BOOL finished) {
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

- (void)getRelatedContacts {
    PTContactsGetRelatedRequest *contactsGetRelatedRequest = [[PTContactsGetRelatedRequest alloc] init];
    [contactsGetRelatedRequest getRelatedWithAuthToken:[PTUser currentUser].authToken
                                               success:^(NSArray *contactList, NSInteger total) {
                                                   if (total == 0) {
                                                       return;
                                                   }

                                                   // Modify to mutable objects
                                                   relatedContacts = [[NSMutableArray alloc] initWithCapacity:[contactList count]];
                                                   for (NSDictionary *contact in contactList) {
                                                       [relatedContacts addObject:[NSMutableDictionary dictionaryWithDictionary:contact]];
                                                   }
                                                   
                                                   dispatch_async(dispatch_get_main_queue(), ^() {
                                                       // Update table view
                                                       [relatedContactsTableView reloadData];
                                                       
                                                       // Show table view container
                                                       relatedContactsContainer.alpha = 0.0f;
                                                       relatedContactsContainer.hidden = NO;
                                                       relatedHeader.alpha = 0.0f;
                                                       relatedHeader.hidden = NO;
                                                       [UIView animateWithDuration:0.5f animations:^{
                                                           relatedContactsContainer.alpha = 1.0f;
                                                           relatedHeader.alpha = 1.0f;
                                                       }];
                                                   });
                                               }
                                               failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                   NSLog(@"Contacts error: %i, %@", response.statusCode, JSON);
                                               }];
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
    // Update label count
    [contactsInvitationCountButton setTitle:[NSString stringWithFormat:@"%i", [selectedContacts count]] forState:UIControlStateNormal];
    
    // Navigation buttons
    buttonNext.enabled = [selectedContacts count] > 0;
}

#pragma mark - TextField delegates

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [textSearch resignFirstResponder];
    return YES;
}

#pragma mark - Table View delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView.tag == 0) { // Contacts table
        return 2;
    } else { // Related contacts table
        return [relatedContacts count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView.tag == 0) { // Contacts table
        if (section == 0) {
            return @"Your friends on Playtell";
        } else {
            return @"Your friends from [Source]";
        }
    } else { // Related contacts table
        return nil;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView.tag == 1) { // Related contacts table
        return [UIView new];
    }

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
        lbl.text = @"Your friends on Playtell";
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
    if (tableView.tag == 0) { // Contacts table
        return 32.0f;
    } else { // Related contacts table
        return 0.0f;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView.tag == 0) { // Contacts table
        if (inSearchMode) {
            // Filtered contacts
            if (section == 0) {
                return [filteredContactsOnPT count];
            } else {
                return [filteredContactsNotOnPT count];
            }
        } else {
            // All contacts
            if (section == 0) {
                return [contactsOnPT count];
            } else {
                return [contactsNotOnPT count];
            }
        }
    } else { // Related contacts table
        return [relatedContacts count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == 0) { // Contacts table
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
            if ([selectedContacts indexOfObject:contact] == NSNotFound) { // Contacnt NOT already selected
                [cell setMode:PTContactsTableBigCellModeInvite];
            } else { // Contact already selected
                [cell setMode:PTContactsTableBigCellModeUninvite];
            }
        } else { // Existing PT user
            BOOL isFriend = [[contact objectForKey:@"is_friend"] boolValue];
            if (isFriend) { // Already a friend
                [cell setMode:PTContactsTableBigCellModeAlreadyFriend];
            } else { // Not a friend
                [cell setMode:PTContactsTableBigCellModeFriend];
            }
        }
        
        return cell;
    } else { // Related contacts table
        static NSString *CellIdentifier = @"PTContactsTableSmallCell";
        
        PTContactsTableSmallCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[PTContactsTableSmallCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier tableWidth:relatedContactsTableView.frame.size.width];
        }
        
        // Contact description
        NSMutableDictionary *contact = [relatedContacts objectAtIndex:indexPath.row];
        
        // Define cell
        cell.delegate = self;
        cell.contact = contact;
        
        BOOL isFriend = [[contact objectForKey:@"is_friend"] boolValue];
        if (isFriend) { // Already a friend
            [cell setMode:PTContactsTableBigCellModeAlreadyFriend];
        } else { // Not a friend
            [cell setMode:PTContactsTableBigCellModeFriend];
        }
        
        return cell;
    }
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
        vcSize = CGSizeMake(405.0f, 417.0f);
    } else {
        CGFloat height = MIN(386.0f, ([selectedContacts count] * 114.0f + 44.0f));
        vcSize = CGSizeMake(405.0f, height);
    }
    NSLog(@"%@", NSStringFromCGSize(vcSize));
    contactsSelectedViewController.view.superview.frame = CGRectMake(([UIScreen mainScreen].bounds.size.height - vcSize.width) / 2.0f, ([UIScreen mainScreen].bounds.size.width - vcSize.height) / 2.0f, vcSize.width, vcSize.height);
}

#pragma mark - Contact select delegates

- (void)contactDidInvite:(NSMutableDictionary *)contact cell:(id)sender {
    PTContactsTableBigCell *cell = (PTContactsTableBigCell *)sender;
    //[cell setMode:PTContactsTableBigCellModeUninvite];
    //NSLog(@"Cell: %@", NSStringFromCGRect(cell.frame));

    // Add contact to list
    [selectedContacts addObject:contact];
    
    // Announce action
    NSDictionary *action = [NSDictionary dictionaryWithObjectsAndKeys:contact, @"contact", [NSNumber numberWithInt:PTContactsTableBigCellActionInvited], @"action", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"actionPerformedOnContact" object:nil userInfo:action];
    
    // Envelope animation
    UIImageView *blastEnvelope = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"contactsTableInvite"]];
    CGFloat y = cell.frame.origin.y - contactsTableView.contentOffset.y + contactsTableView.frame.origin.y + 19.0f;
    blastEnvelope.frame = CGRectMake(31.0f, y, 100.0f, 75.0f);
    [self.view addSubview:blastEnvelope];
    contactsInvitationCountButton.titleLabel.textColor = [UIColor whiteColor];

    [UIView animateWithDuration:0.3f animations:^{
        blastEnvelope.frame = CGRectMake(61.0f, 33.0f, 50.0f, 39.0f);
    } completion:^(BOOL finished) {
        contactsInvitationCountButton.titleLabel.textColor = [UIColor colorWithRed:(50.0f / 255.0f) green:(137.0f / 255.0f) blue:(191.0f / 255.0f) alpha:1.0f];

        [UIView animateWithDuration:0.2f animations:^{
            blastEnvelope.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [blastEnvelope removeFromSuperview];
        }];
    }];
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
                                               success:nil
                                               failure:nil];
    
    // Mark as friend locally
    [contact setObject:[NSNumber numberWithBool:YES] forKey:@"is_friend"];
    
    // Announce action
    NSDictionary *action = [NSDictionary dictionaryWithObjectsAndKeys:contact, @"contact", [NSNumber numberWithInt:PTContactsTableBigCellActionFriended], @"action", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"actionPerformedOnContact" object:nil userInfo:action];
}

@end