//
//  PTErrorTableView.h
//  playtell-ducati
//
//  Created by Adam Horne on 2/7/13.
//  Copyright (c) 2013 PlayTell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PTErrorTableView : UIView <UITableViewDataSource, UITableViewDelegate> {
    UITableView *errorTable;
    
    NSMutableArray *errors;
}

- (void)reloadWithErrors:(NSMutableArray *)theErrors;

@end
