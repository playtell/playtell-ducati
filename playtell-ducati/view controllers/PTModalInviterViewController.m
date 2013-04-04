//
//  PTModalInviterViewController.m
//  playtell-ducati
//
//  Created by Adam Horne on 3/29/13.
//  Copyright (c) 2013 PlayTell. All rights reserved.
//

#define CELL_HEIGHT     114.0
#define SCREEN_MARGIN   20.0

#import <QuartzCore/QuartzCore.h>

#import "PTContactsSearchRequest.h"
#import "PTModalInviterViewController.h"
#import "PTUser.h"
#import "PTUsersCreateFriendshipRequest.h"

#import "UIColor+ColorFromHex.h"

@interface PTModalInviterViewController ()

@end

@implementation PTModalInviterViewController

@synthesize delegate;
@synthesize addressBookContacts;

- (id)init {
    self = [super init];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationFullScreen;
        self.addressBookContacts = [NSArray array];
    }
    return self;
}

- (void)loadView {
    // Create the main view
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 1024.0f, 768.0f)];
    self.view.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.7f];
    self.view.autoresizesSubviews = YES;
    
    // Common properties
    float cornerRadius = 5.0f;
    float borderMargin = 10.0f;
    float tableShrink = 10.0f; // amount to make the table smaller on each side
    
    // Add the search container
    CGSize containerSize = CGSizeMake(626.0f, 250.0f);
    searchContainer = [[UIView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - containerSize.width) / 2, SCREEN_MARGIN, containerSize.width, containerSize.height)];
    searchContainer.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = searchContainer.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorFromHex:@"#D9D9D9"] CGColor], (id)[[UIColor colorFromHex:@"#CCDBE6"] CGColor], nil];
    gradient.cornerRadius = cornerRadius;
    [searchContainer.layer insertSublayer:gradient atIndex:0];
    [searchContainer.layer setCornerRadius:cornerRadius];
    [searchContainer.layer setShadowColor:[UIColor blackColor].CGColor];
    [searchContainer.layer setShadowOpacity:0.75f];
    [searchContainer.layer setShadowRadius:2.0f];
    [searchContainer.layer setShadowOffset:CGSizeMake(0.0f, 1.0f)];
    [self.view addSubview:searchContainer];
    
    // Title label
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(borderMargin, borderMargin, searchContainer.frame.size.width - (borderMargin * 2), 40.0f)];
    lblTitle.textColor = [UIColor colorFromHex:@"A3B6B7"];
    lblTitle.shadowColor = [UIColor whiteColor];
    lblTitle.shadowOffset = CGSizeMake(0.0f, 1.0f);
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.font = [UIFont boldSystemFontOfSize:30.0f];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.text = @"Invite PlayPal";
    [searchContainer addSubview:lblTitle];
    
    // Close button
    UIImage *closeImage = [UIImage imageNamed:@"close.png"];
    UIImage *closePress = [UIImage imageNamed:@"close-press.png"];
    btnClose = [[UIButton alloc] initWithFrame:CGRectMake(searchContainer.frame.size.width - closeImage.size.width - borderMargin, borderMargin, closeImage.size.width, closeImage.size.height)];
    btnClose.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
    [btnClose setImage:closeImage forState:UIControlStateNormal];
    [btnClose setImage:closePress forState:UIControlStateHighlighted];
    [btnClose addTarget:self action:@selector(closeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [searchContainer addSubview:btnClose];
    
    // Text field
    CGSize searchFieldSize = CGSizeMake(440.0f, 31.0f);
    txtSearch = [[UITextField alloc] initWithFrame:CGRectMake((searchContainer.frame.size.width - searchFieldSize.width) / 2, (searchContainer.frame.size.height - searchFieldSize.height) / 2 - 20.0, searchFieldSize.width, searchFieldSize.height)];
    txtSearch.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    txtSearch.borderStyle = UITextBorderStyleRoundedRect;
    txtSearch.font = [UIFont boldSystemFontOfSize:16.0f];
    txtSearch.placeholder = @"Email or full name";
    txtSearch.autocapitalizationType = UITextAutocapitalizationTypeNone;
    txtSearch.autocorrectionType = UITextAutocorrectionTypeNo;
    txtSearch.keyboardType = UIKeyboardTypeEmailAddress;
    txtSearch.returnKeyType = UIReturnKeyDone;
    txtSearch.clearButtonMode = UITextFieldViewModeWhileEditing;
    txtSearch.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    txtSearch.delegate = self;
    txtSearch.text = @"";
    [searchContainer addSubview:txtSearch];
    
    // Magnifying glass image view
    UIImage *magnifyingGlass = [UIImage imageNamed:@"search-icon.png"];
    UIImageView *magnifyingGlassIcon = [[UIImageView alloc] initWithFrame:CGRectMake(txtSearch.frame.origin.x - borderMargin - magnifyingGlass.size.width, txtSearch.frame.origin.y - ((magnifyingGlass.size.height - txtSearch.frame.size.height) / 2), magnifyingGlass.size.width, magnifyingGlass.size.height)];
    magnifyingGlassIcon.image = magnifyingGlass;
    [searchContainer addSubview:magnifyingGlassIcon];
    
    // Search button
    UIImage *buttonImage = [UIImage imageNamed:@"find.png"];
    UIImage *buttonPress = [UIImage imageNamed:@"find-press.png"];
    btnSearch = [[UIButton alloc] initWithFrame:CGRectMake((searchContainer.frame.size.width - buttonImage.size.width) / 2, searchContainer.frame.size.height - buttonImage.size.height - borderMargin - 40.0, buttonImage.size.width, buttonImage.size.height)];
    btnSearch.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [btnSearch setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [btnSearch setBackgroundImage:buttonPress forState:UIControlStateHighlighted];
    [btnSearch setTitle:@"Find PlayPal" forState:UIControlStateNormal];
    [btnSearch setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnSearch setTitleShadowColor:[UIColor grayColor] forState:UIControlStateNormal];
    [btnSearch addTarget:self action:@selector(searchButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [searchContainer addSubview:btnSearch];
    
    // Down arrow to show where table view is
    UIImage *downArrow = [UIImage imageNamed:@"arrow.png"];
    UIImageView *downArrowIcon = [[UIImageView alloc] initWithFrame:CGRectMake((searchContainer.frame.size.width - downArrow.size.width) / 2, searchContainer.frame.size.height - downArrow.size.height - borderMargin, downArrow.size.width, downArrow.size.height)];
    downArrowIcon.image = downArrow;
    [searchContainer addSubview:downArrowIcon];
    
    // Add the table view
    tblResults = [[UITableView alloc] initWithFrame:CGRectMake(searchContainer.frame.origin.x + tableShrink, searchContainer.frame.origin.y + searchContainer.frame.size.height, searchContainer.frame.size.width - (2 * tableShrink), 300.0f)];
    tblResults.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    tblResults.autoresizesSubviews = YES;
    tblResults.dataSource = self;
    tblResults.delegate = self;
    tblResults.allowsSelection = NO;
    tblResults.alpha = 0.0f;
    tblResults.hidden = YES;
    [self.view insertSubview:tblResults belowSubview:searchContainer];
    
    // Loading view
    loadingView = [[UIView alloc] initWithFrame:CGRectMake(tblResults.frame.origin.x, tblResults.frame.origin.y, tblResults.frame.size.width, [self heightForTableWithResultCount:100])];
    loadingView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    loadingView.autoresizesSubviews = YES;
    loadingView.backgroundColor = [UIColor grayColor];
    loadingView.alpha = 0.0f;
    loadingView.hidden = YES;
    [self.view insertSubview:loadingView aboveSubview:tblResults];
    UILabel *lblLoading = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, (loadingView.frame.size.height - 15.0) / 2, loadingView.frame.size.width, 30.0f)];
    lblLoading.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    lblLoading.backgroundColor = [UIColor clearColor];
    lblLoading.textAlignment = UITextAlignmentCenter;
    lblLoading.textColor = [UIColor whiteColor];
    lblLoading.font = [UIFont boldSystemFontOfSize:25.0f];
    lblLoading.text = @"Loading";
    [loadingView addSubview:lblLoading];
}

- (void)closeButtonPressed {
    [self.delegate modalShouldClose:self];
}

- (void)searchButtonPressed {
    [txtSearch resignFirstResponder];
    [self startSearch];
}

- (BOOL)isValidEmailString:(NSString *)testString {
    // Verify email string
    NSString *emailRegEx =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    return [emailTest evaluateWithObject:testString];
}

- (float)heightForTableWithResultCount:(NSInteger)count {
    float maxSize = 768.0 - searchContainer.frame.size.height - (2 * SCREEN_MARGIN);
    float minSize = 1 * CELL_HEIGHT;
    float ret = count * CELL_HEIGHT;
    if (ret > maxSize) {
        ret = maxSize;
    }
    if (ret < minSize) {
        ret = minSize;
    }
    return ret;
}

- (void)startSearch {
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
    
    // Trim the string
    NSString *searchString = [txtSearch.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([searchString isEqualToString:@""]) {
        [UIView animateWithDuration:0.2f animations:^{
            // Hide table
            tblResults.alpha = 0.0f;
        } completion:^(BOOL finished) {
            tblResults.hidden = YES;
            return;
        }];
        return;
    }
    
    // Show the results from the local address book
    NSPredicate *resultPredicate = [NSPredicate
                                    predicateWithFormat:@"name contains[cd] %@ || email contains[cd] %@",
                                    searchString, searchString];
    
    // Filtered contacts for each contact type
    NSArray *filteredAddressBookContacts = [addressBookContacts filteredArrayUsingPredicate:resultPredicate];
    
    loadingView.alpha = 0.0f;
    [UIView animateWithDuration:0.2f animations:^{
        // Show the loading view
        loadingView.hidden = NO;
        loadingView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        // Search on the server
        PTContactsSearchRequest *contactsSearchRequest = [[PTContactsSearchRequest alloc] init];
        [contactsSearchRequest searchWithAuthToken:[PTUser currentUser].authToken
                                      searchString:searchString
                                           success:^(NSArray *matches, NSString *responseSearchString)
         {
             // Add the results from the search to the ones we know from the address book
             NSMutableArray *mutableFiltered = [NSMutableArray arrayWithArray:filteredAddressBookContacts];
             for (NSDictionary *match in matches) {
                 [mutableFiltered addObject:[NSMutableDictionary dictionaryWithDictionary:match]];
             }
             [mutableFiltered sortUsingComparator:contactsCompareBlock];
             contacts = mutableFiltered;
             
             // Reload table
             [tblResults reloadData];
             
             // Show the table view
             [UIView animateWithDuration:0.2f animations:^{
                 tblResults.hidden = NO;
                 tblResults.alpha = 1.0f;
                 tblResults.frame = CGRectMake(tblResults.frame.origin.x, tblResults.frame.origin.y, tblResults.frame.size.width, [self heightForTableWithResultCount:[contacts count]]);
             } completion:^(BOOL finished) {
                 [UIView animateWithDuration:0.2f animations:^{
                     loadingView.alpha = 0.0f;
                 } completion:^(BOOL finished) {
                     loadingView.hidden = YES;
                 }];
             }];
         } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
             // Reload table
             contacts = [NSArray array];
             [tblResults reloadData];
             
             // Show the table view
             [UIView animateWithDuration:0.2f animations:^{
                 tblResults.hidden = NO;
                 tblResults.alpha = 1.0f;
                 tblResults.frame = CGRectMake(tblResults.frame.origin.x, tblResults.frame.origin.y, tblResults.frame.size.width, [self heightForTableWithResultCount:[contacts count]]);
             } completion:^(BOOL finished) {
                 [UIView animateWithDuration:0.2f animations:^{
                     loadingView.alpha = 0.0f;
                 } completion:^(BOOL finished) {
                     loadingView.hidden = YES;
                 }];
             }];
         }];
    }];
}

#pragma mark - TextField delegates

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self startSearch];
    return YES;
}

#pragma mark - Table view delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (contacts.count > 0) {
        return contacts.count;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < contacts.count) {
        // Load big cells
        static NSString *CellIdentifier = @"PTContactsTableBigCell";
        PTContactsTableBigCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[PTContactsTableBigCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier tableWidth:tblResults.frame.size.width];
        }
        
        // Contact description
        NSMutableDictionary *contact = [contacts objectAtIndex:indexPath.row];
        
        // Define cell
        cell.delegate = self;
        cell.contact = contact;
        
        if ([contact objectForKey:@"user_id"] == nil) { // Not a PT user
            //if ([selectedContacts indexOfObject:contact] == NSNotFound) { // Contact NOT already selected
                [cell setMode:PTContactsTableBigCellModeInvite];
            //} else { // Contact already selected
            //    [cell setMode:PTContactsTableBigCellModeUninvite];
            //}
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
    } else {
        if ([self isValidEmailString:txtSearch.text]) {
            // Load big cells
            static NSString *CellIdentifier = @"PTContactsTableBigCell";
            PTContactsTableBigCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[PTContactsTableBigCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier tableWidth:tblResults.frame.size.width];
            }
            
            // Contact description
            NSMutableDictionary *contact = [[NSMutableDictionary alloc] init];
            [contact setObject:txtSearch.text forKey:@"name"];
            [contact setObject:txtSearch.text forKey:@"email"];
            [contact setObject:@"http://ragatzi.s3.amazonaws.com/uploads/profile_default_1.png" forKey:@"profile_photo"];
            
            // Define cell
            cell.delegate = self;
            cell.contact = contact;
            [cell setMode:PTContactsTableBigCellModeInvite];
            
            return cell;
        } else {
            static NSString *CellIdentifier = @"PTContactsTableBigCell-ErrorCell";
            PTContactsTableBigCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[PTContactsTableBigCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier tableWidth:tblResults.frame.size.width];
            }
            
            // Set the details
            cell.textLabel.text = @"We don't recognize this name.";
            cell.textLabel.textColor = [UIColor redColor];
            cell.detailTextLabel.text = @"Try typing an email instead.";
            cell.detailTextLabel.textColor = [UIColor redColor];
            // TODO: add avatar image
            
            return cell;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CELL_HEIGHT;
}

#pragma mark - Contact select delegates

- (void)contactDidInvite:(NSMutableDictionary *)contact cell:(id)sender {
    // TODO: will have to add way to add friend without going to message compose controller
    //[self showComposeMessageController:sender];
    
    PTContactsTableBigCell *cell = (PTContactsTableBigCell *)sender;
    [cell setMode:PTContactsTableBigCellModeAlreadyFriend];
    
    // Add contact to list
//    [selectedContacts addObject:contact];
    
    // Announce action
//    NSDictionary *action = [NSDictionary dictionaryWithObjectsAndKeys:contact, @"contact", [NSNumber numberWithInt:PTContactsTableBigCellActionInvited], @"action", nil];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"actionPerformedOnContact" object:nil userInfo:action];
}

- (void)contactDidCancelInvite:(NSMutableDictionary *)contact cell:(id)sender {
    PTContactsTableBigCell *cell = (PTContactsTableBigCell *)sender;
    [cell setMode:PTContactsTableBigCellModeInvite];
    
    // Remove contact from list
    [selectedContacts removeObject:contact];
    
    // Announce action
//    NSDictionary *action = [NSDictionary dictionaryWithObjectsAndKeys:contact, @"contact", [NSNumber numberWithInt:PTContactsTableBigCellActionUninvited], @"action", nil];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"actionPerformedOnContact" object:nil userInfo:action];
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

@end
