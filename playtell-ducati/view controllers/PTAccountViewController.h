//
//  PTAccountViewController.h
//  playtell-ducati
//
//  Created by Adam Horne on 2/4/13.
//  Copyright (c) 2013 PlayTell. All rights reserved.
//

#define kNameTag    0
#define kEmailTag   1

#import <UIKit/UIKit.h>

#import "PTErrorTableView.h"

@interface PTAccountViewController : UIViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate> {
    // Text fields
    UITextField *txtName;
    UITextField *txtEmail;
    
    UIImageView *errorName;
    UIImageView *errorEmail;
    
    UIView *tableContainer;
    UITableView *inputTable;
    PTErrorTableView *errorTable;
    
    NSMutableArray *errorsShown;
}

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *email;

@end
