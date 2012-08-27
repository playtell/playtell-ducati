//
//  PTContactMessageViewController.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 7/26/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTContactSelectDelegate.h"

@interface PTContactMessageViewController : UIViewController <UIAlertViewDelegate, UITableViewDelegate, PTContactSelectDelegate> {
    UIBarButtonItem *buttonBack;
    UIBarButtonItem *buttonSend;
    NSMutableArray *contacts;
    IBOutlet UITableView *contactsTableView;
    IBOutlet UITextView *msgBody;
    IBOutlet UIView *contactsTableContainer;
    IBOutlet UIView *leftContainer;
    IBOutlet UIView *composeBox;
    IBOutlet UIImageView *myProfilePic;
    IBOutlet UILabel *mergeFieldName;
    IBOutlet UIView *linksBox;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withContacts:(NSMutableArray *)contactList;

@end
