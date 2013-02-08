//
//  PTPasswordViewController.h
//  playtell-ducati
//
//  Created by Adam Horne on 2/4/13.
//  Copyright (c) 2013 PlayTell. All rights reserved.
//

#define kCurrentTag 0
#define kNewTag     1
#define kConfirmTag 2

#import <UIKit/UIKit.h>

#import "PTErrorTableView.h"

@interface PTPasswordViewController : UIViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate> {
    // Text fields
    UITextField *txtCurrent;
    UITextField *txtNew;
    UITextField *txtConfirm;
    
    UIImageView *errorCurrent;
    UIImageView *errorNew;
    UIImageView *errorConfirm;
    
    UIView *tableContainer;
    UITableView *inputTable;
    PTErrorTableView *errorTable;
    
    UIButton *resetButton;
    
    NSMutableArray *errorsShown;
}

@property (nonatomic, readonly) NSString *currentPassword;
@property (nonatomic, readonly) NSString *password;
@property (nonatomic, readonly) NSString *confirmationPassword;

@end
