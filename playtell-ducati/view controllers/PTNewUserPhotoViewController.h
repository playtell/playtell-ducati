//
//  PTNewUserPhotoViewController.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 9/12/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PTNewUserPhotoViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate> {
    // Nav buttons
    UIBarButtonItem *buttonBack;
    UIBarButtonItem *buttonNext;
    
    // Content container
    IBOutlet UIView *contentContainer;
    UIView *topShadow;
    
    // Textfield
    IBOutlet UITextField *txtName;
    IBOutlet UITextField *txtEmail;
    IBOutlet UITextField *txtPassword;
    
    // User photo
    IBOutlet UIView *photoContainer;
    UIImageView *profilePhotoView;
    IBOutlet UIButton *buttonTakePhoto;
    IBOutlet UIButton *buttonChoosePhoto;
    UIImagePickerController *camera;
    UIPopoverController *cameraPopoverController;
    BOOL hasPhotoChanged;
    
    // Analytics
    NSDate *eventStart;
    BOOL isSourceCamera;
    BOOL isSourceLibrary;
}

@property (nonatomic, retain) UIPopoverController *cameraPopoverController;

- (IBAction)takePhotoDidPress:(id)sender;
- (IBAction)choosePhotoDidPress:(id)sender;

@end