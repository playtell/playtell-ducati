//
//  PTPictureViewController.h
//  playtell-ducati
//
//  Created by Adam Horne on 2/18/13.
//  Copyright (c) 2013 PlayTell. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PTErrorTableView.h"

@interface PTPictureViewController : UIViewController {
    UIView *pictureContainer;
    UIImageView *pictureView;
    UIButton *btnTakePicture;
    UIButton *btnChoosePicture;
    
    PTErrorTableView *errorTable;
    
    NSMutableArray *errorsShown;
}

@end
