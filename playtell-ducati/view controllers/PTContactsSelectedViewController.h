//
//  PTContactsSelectedViewController.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 7/25/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PTContactsSelectedViewController : UIViewController <UITableViewDelegate> {
    NSMutableArray *_selectedContacts;
    IBOutlet UITableView *contactsTableView;
}

@property (nonatomic, retain) NSMutableArray *selectedContacts;

- (IBAction)closeThyself:(id)sender;

@end
