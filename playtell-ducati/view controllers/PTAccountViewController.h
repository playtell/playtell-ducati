//
//  PTAccountViewController.h
//  playtell-ducati
//
//  Created by Adam Horne on 2/4/13.
//  Copyright (c) 2013 PlayTell. All rights reserved.
//

#define kNameTag        0
#define kEmailTag       1
#define kBirthdayTag    2

#import <UIKit/UIKit.h>

#import "PTErrorTableView.h"

@interface PTAccountViewController : UIViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UIPopoverControllerDelegate> {
    // Text fields
    UITextField *txtName;
    UITextField *txtEmail;
    UITextField *txtBirthday;
    
    UIImageView *errorName;
    UIImageView *errorEmail;
    UIImageView *errorBirthday;
    
    UIView *tableContainer;
    UITableView *inputTable;
    PTErrorTableView *errorTable;
    UIDatePicker *datePickerView;
    
    NSMutableArray *errorsShown;
}

@property (nonatomic, readwrite) NSString *name;
@property (nonatomic, readwrite) NSString *email;
@property (nonatomic, strong) NSDate *birthday;

@property (nonatomic, retain) UIPopoverController *datePopoverController;

- (void)accountHasNoBirthday;

@end
