//
//  PTPictureViewController.h
//  playtell-ducati
//
//  Created by Adam Horne on 2/18/13.
//  Copyright (c) 2013 PlayTell. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PTErrorTableView.h"
#import "PTSpinnerView.h"

@interface PTPictureViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate> {
    UIView *pictureContainer;
    UIImageView *pictureView;
    PTSpinnerView *spinnerView;
    UIButton *btnTakePicture;
    UIButton *btnChoosePicture;
    
    PTErrorTableView *errorTable;
    
    NSMutableArray *errorsShown;
    
    UIImagePickerController *camera;
}

@property (nonatomic, retain) UIPopoverController *cameraPopoverController;

@end
