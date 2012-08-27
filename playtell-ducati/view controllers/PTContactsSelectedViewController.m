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
    UIImageView *envelopeImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"contactsSelectedTitle"]];
    envelopeImgView.frame = CGRectMake(0.0f, 0.0f, 30.0f, 21.0f);
    navigationBar.topItem.titleView = envelopeImgView;
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [self checkForEmptyList];
}

- (void)viewDidAppear:(BOOL)animated {
    // Tap off screen functionality
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapBehind:)];
    [recognizer setNumberOfTapsRequired:1];
    recognizer.cancelsTouchesInView = NO; //So the user can still interact with controls in the modal view
    [self.view.window addGestureRecognizer:recognizer];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)setSelectedContacts:(NSMutableArray *)selectedContacts {
    _selectedContacts = selectedContacts;
}

- (void)handleTapBehind:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint location = [sender locationInView:nil]; //Passing nil gives us coordinates in the window
        
        //Then we convert the tap's location into the local view's coordinate system, and test to see if it's in or outside. If outside, dismiss the view.
        if (![self.view pointInside:[self.view convertPoint:location fromView:self.view.window] withEvent:nil]) {
            // Remove the recognizer first so it's view.window is valid.
            [self.view.window removeGestureRecognizer:sender];
            [self dismissModalViewControllerAnimated:YES];
        }
    }
}

- (void)checkForEmptyList {
    if ([self.selectedContacts count] == 0) {
        if (emptyImage == nil) {
            emptyImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"contactsSelectedNone"]];
            emptyImage.frame = CGRectMake(0.0f, 44.0f, 404.0f, 365.0f);
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
    
    // Resize self
    CGSize vcSize;
    if ([self.selectedContacts count] == 0) {
        vcSize = CGSizeMake(404.0f, 409.0f);
    } else {
        CGFloat height = MIN(614.0f, ([self.selectedContacts count] * 114.0f + 44.0f));
        vcSize = CGSizeMake(404.0f, height);
    }
    [UIView animateWithDuration:0.2 animations:^{
        self.view.superview.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - vcSize.height) / 2.0f, ([UIScreen mainScreen].bounds.size.height - vcSize.width) / 2.0f, vcSize.height, vcSize.width);
    }];
    [self checkForEmptyList];
}

@end