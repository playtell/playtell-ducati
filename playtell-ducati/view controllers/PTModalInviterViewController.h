//
//  PTModalInviterViewController.h
//  playtell-ducati
//
//  Created by Adam Horne on 3/29/13.
//  Copyright (c) 2013 PlayTell. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PTContactsTableBigCell.h"

@protocol PTModalInviterDelegate <NSObject>

- (void)modalShouldClose:(id)sender;

@end

@interface PTModalInviterViewController : UIViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, PTContactSelectDelegate> {
    UIView *searchContainer;
    UIButton *btnClose;
    UITextField *txtSearch;
    UIButton *btnSearch;
    
    UITableView *tblResults;
    UIView *loadingView;
    
    NSMutableArray *contacts;
    NSMutableArray *selectedContacts;
}

@property (nonatomic, weak) id<PTModalInviterDelegate> delegate;
@property (nonatomic, strong) NSArray *addressBookContacts;

@end
