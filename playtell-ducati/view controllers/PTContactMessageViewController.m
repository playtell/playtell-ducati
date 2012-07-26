//
//  PTContactMessageViewController.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 7/26/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTContactMessageViewController.h"

@interface PTContactMessageViewController ()

@end

@implementation PTContactMessageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withContacts:(NSMutableArray *)contactList {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Save contacts
        contacts = contactList;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Background
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"date_bg"]];
    
    // Navigation controller setup
    self.title = @"Compose Your Message";
    
    // Cancel button
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(didPressCancel:)];
    [self.navigationItem setLeftBarButtonItem:cancelButton];
    
    buttonBack = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(didPressBack:)];
    buttonSend = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStylePlain target:self action:@selector(didPressSend:)];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:buttonSend, buttonBack, nil]];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    buttonBack = nil;
    buttonSend = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

#pragma mark - Navigation

- (void)didPressCancel:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didPressBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Temp UI Alert

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didPressSend:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Message sent"
                          message:@"Congratulations! You'll be playdating soon!"
                          delegate:self
                          cancelButtonTitle:@"Kewl"
                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - Table View delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [contacts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ContactDetailCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Contact description
    NSDictionary *contact = [contacts objectAtIndex:indexPath.row];
    cell.textLabel.text = [contact objectForKey:@"name"];
    cell.detailTextLabel.text = [contact objectForKey:@"email"];
    
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

@end