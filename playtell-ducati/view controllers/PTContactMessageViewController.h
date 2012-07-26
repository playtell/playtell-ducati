//
//  PTContactMessageViewController.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 7/26/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PTContactMessageViewController : UIViewController <UIAlertViewDelegate, UITableViewDelegate> {
    UIBarButtonItem *buttonBack;
    UIBarButtonItem *buttonSend;
    NSMutableArray *contacts;
    IBOutlet UITableView *contactsTableView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withContacts:(NSMutableArray *)contactList;

@end
