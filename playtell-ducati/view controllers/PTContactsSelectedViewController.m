//
//  PTContactsSelectedViewController.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 7/25/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTContactsSelectedViewController.h"

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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)setSelectedContacts:(NSMutableArray *)selectedContacts {
    _selectedContacts = selectedContacts;
    [contactsTableView reloadData];
}

#pragma mark - Table View delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.selectedContacts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ContactDetailCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    PTInviteContactButton *addButton;
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        // Button
//        addButton = [PTInviteContactButton buttonWithType:UIButtonTypeCustom];
//        addButton.frame = CGRectMake(382.0f, 9.0f, 120.0f, 33.0f);
//        addButton.tag = 100;
//        addButton.layer.borderColor = [UIColor blackColor].CGColor;
//        addButton.layer.borderWidth = 1.0f;
//        addButton.layer.cornerRadius = 10.0f;
//        [addButton addTarget:self action:@selector(contactAction:) forControlEvents:UIControlEventTouchUpInside];
//        [cell addSubview:addButton];
    }
    
    // Contact description
    NSDictionary *contact = [self.selectedContacts objectAtIndex:indexPath.row];
    cell.textLabel.text = [contact objectForKey:@"name"];
//    addButton = (PTInviteContactButton *)[cell viewWithTag:100];
//    addButton.contact = contact;
    if ([[contact objectForKey:@"user_id"] isKindOfClass:[NSNull class]]) {
        cell.detailTextLabel.text = [contact objectForKey:@"email"];
//        [addButton setTitle:@"Invite contact" forState:UIControlStateNormal];
//        addButton.backgroundColor = [UIColor blueColor];
    } else {
        BOOL isFriend = [[contact objectForKey:@"is_friend"] boolValue];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Existing user! (%i)", [[contact objectForKey:@"user_id"] integerValue]];
        if (isFriend) {
//            [addButton setTitle:@"A friend!" forState:UIControlStateNormal];
//            [addButton setEnabled:NO];
//            addButton.backgroundColor = [UIColor blackColor];
        } else {
//            [addButton setTitle:@"Add as friend" forState:UIControlStateNormal];
//            addButton.backgroundColor = [UIColor redColor];
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

- (IBAction)closeThyself:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"selectedContactsPopoverShouldDismiss" object:nil];
}

@end
