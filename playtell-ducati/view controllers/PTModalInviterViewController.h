//
//  PTModalInviterViewController.h
//  playtell-ducati
//
//  Created by Adam Horne on 3/29/13.
//  Copyright (c) 2013 PlayTell. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PTModalInviterDelegate <NSObject>

- (void)modalShouldClose:(id)sender;

@end

@interface PTModalInviterViewController : UIViewController <UITextFieldDelegate> {
    UIView *searchContainer;
    UIButton *btnClose;
    UITextField *txtSearch;
    UIButton *btnSearch;
    
    UITableView *tblResults;
}

@property (nonatomic, weak) id<PTModalInviterDelegate> delegate;

@end
