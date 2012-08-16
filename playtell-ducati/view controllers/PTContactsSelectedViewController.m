//
//  PTContactsSelectedViewController.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 7/25/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTContactsSelectedViewController.h"
#import "PTContactsTableBigCell.h"
#import "PTContactsTableRemoveCell.h"
#import "UIColor+HexColor.h"

@interface PTContactsSelectedViewController ()

@end

@implementation PTContactsSelectedViewController

@synthesize selectedContacts = _selectedContacts;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Empty selected array
        self.selectedContacts = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Table view style
    contactsTableView.backgroundColor = [UIColor colorFromHex:@"#f0f7f7"];
    contactsTableView.separatorColor = [UIColor colorFromHex:@"#55707f"];
    
    // Navigation bar
    navigationBar.tintColor = [UIColor colorFromHex:@"#2e4857"];
    navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorFromHex:@"#E3F1FF"], UITextAttributeTextColor, nil];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    if ([self.selectedContacts count] == 0) {
        if (emptyImage == nil) {
            emptyImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"contactsSelectedNone"]];
            emptyImage.frame = CGRectMake(0.0f, 44.0f, 405.0f, 364.0f);
            [self.view addSubview:emptyImage];
        }
        contactsTableView.hidden = YES;
        emptyImage.hidden = NO;
    } else {
        contactsTableView.hidden = NO;
        emptyImage.hidden = YES;
        [contactsTableView reloadData];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)setSelectedContacts:(NSMutableArray *)selectedContacts {
    _selectedContacts = selectedContacts;
}

#pragma mark - Table View delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.selectedContacts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"PTContactsTableRemoveCell";
    
    PTContactsTableRemoveCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[PTContactsTableRemoveCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier tableWidth:contactsTableView.frame.size.width];
    }
    
    // Contact description
    NSMutableDictionary *contact = [self.selectedContacts objectAtIndex:indexPath.row];
    
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

#pragma mark - Button handlers

- (IBAction)closeThyself:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Contact select delegates

- (void)contactDidCancelInvite:(NSMutableDictionary *)contact cell:(id)sender {
    // Remove contact from list
    [self.selectedContacts removeObject:contact];
    
    // Announce action
    NSDictionary *action = [NSDictionary dictionaryWithObjectsAndKeys:contact, @"contact", [NSNumber numberWithInt:PTContactsTableBigCellActionUninvited], @"action", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"actionPerformedOnContact" object:nil userInfo:action];
    
    // Remove cell
    PTContactsTableRemoveCell *cell = (PTContactsTableRemoveCell *)sender;
    NSIndexPath *indexPath = [contactsTableView indexPathForCell:cell];
    [contactsTableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationBottom];
}

@end