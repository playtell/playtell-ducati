//
//  PTPictureViewController.m
//  playtell-ducati
//
//  Created by Adam Horne on 2/18/13.
//  Copyright (c) 2013 PlayTell. All rights reserved.
//

#define MARGIN  20.0

#import <QuartzCore/QuartzCore.h>

#import "NonRotatingUIImagePickerController.h"
#import "PTPictureViewController.h"
#import "PTSettingsTitleView.h"
#import "PTUpdatePhotoRequest.h"
#import "PTUser.h"

#import "UIColor+ColorFromHex.h"
#import "UIImage+Resize.h"

@interface PTPictureViewController ()

@end

@implementation PTPictureViewController

@synthesize cameraPopoverController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 500.0f, 500.0f)];
        self.view.autoresizesSubviews = YES;
        self.view.backgroundColor = [UIColor colorFromHex:@"#E4ECEF"];
        
        PTSettingsTitleView *topTitle = [[PTSettingsTitleView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 30.0f)];
        topTitle.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        topTitle.textLabel.text = @"Your Buddy Pic";
        [self.view addSubview:topTitle];
        
        // Error table view
        errorTable = [[PTErrorTableView alloc] initWithFrame:CGRectMake(0.0f, topTitle.frame.size.height + 1, self.view.frame.size.width, 1.0f)];
        errorTable.hidden = YES;
        errorTable.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        [self.view addSubview:errorTable];
        
        // Picture view
        pictureContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0f, topTitle.frame.size.height + MARGIN, self.view.frame.size.width, 400.0f)];
        pictureContainer.autoresizesSubviews = YES;
        pictureContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        pictureContainer.backgroundColor = [UIColor clearColor];
        [self.view addSubview:pictureContainer];
        
        float picWidth = 300.0f;
        float picHeight = 225.0f;
        pictureView = [[UIImageView alloc] initWithFrame:CGRectMake((pictureContainer.frame.size.width - picWidth) / 2, 0.0f, picWidth, picHeight)];
        pictureView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        pictureView.clipsToBounds = YES;
        pictureView.layer.cornerRadius = 15.0f;
        pictureView.layer.borderColor = [UIColor colorWithWhite:0.0f alpha:0.5f].CGColor;
        pictureView.layer.borderWidth = 2.0f;
        [pictureContainer addSubview:pictureView];
        
        // Set the user picture
        PTUser *currentUser = [PTUser currentUser];
        if (currentUser) {
            pictureView.image = currentUser.userPhoto;
        }
        
        // Take picture button
        btnTakePicture = [[UIButton alloc] initWithFrame:CGRectMake(pictureContainer.frame.size.width / 4, pictureView.frame.size.height + MARGIN, pictureContainer.frame.size.width / 2, 50.0f)];
        btnTakePicture.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [btnTakePicture setBackgroundImage:[UIImage imageNamed:@"buttonSendInviteNormal.png"] forState:UIControlStateNormal];
        [btnTakePicture setTitle:@"Take a photo" forState:UIControlStateNormal];
        [btnTakePicture setTitleColor:[UIColor colorFromHex:@"#223844"] forState:UIControlStateNormal];
        [btnTakePicture setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnTakePicture addTarget:self action:@selector(takePictureButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [pictureContainer addSubview:btnTakePicture];
        
        // Choose picture button
        btnChoosePicture = [[UIButton alloc] initWithFrame:CGRectMake(pictureContainer.frame.size.width / 4, btnTakePicture.frame.origin.y + btnTakePicture.frame.size.height + MARGIN, pictureContainer.frame.size.width / 2, 50.0f)];
        btnChoosePicture.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [btnChoosePicture setBackgroundImage:[UIImage imageNamed:@"buttonSendInviteNormal.png"] forState:UIControlStateNormal];
        [btnChoosePicture setTitle:@"Choose a photo" forState:UIControlStateNormal];
        [btnChoosePicture setTitleColor:[UIColor colorFromHex:@"#223844"] forState:UIControlStateNormal];
        [btnChoosePicture setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnChoosePicture addTarget:self action:@selector(choosePictureButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [pictureContainer addSubview:btnChoosePicture];
        
        // Camera control
        camera = [[NonRotatingUIImagePickerController alloc] init];
        camera.delegate = self;
        camera.allowsEditing = YES;
        self.cameraPopoverController = [[UIPopoverController alloc] initWithContentViewController:camera];
        self.cameraPopoverController.delegate = self;
        
        // Camera-
        btnTakePicture.enabled = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
        btnChoosePicture.enabled = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    }
    return self;
}

- (void)showErrors:(NSMutableArray *)errorsToShow {
    if ([errorsToShow count] == 0) {
        // Hide the error table
        [UIView animateWithDuration:0.2f animations:^{
            errorTable.frame = CGRectMake(errorTable.frame.origin.x, errorTable.frame.origin.y, errorTable.frame.size.width, 1.0f);
            pictureContainer.frame = CGRectMake(pictureContainer.frame.origin.x, errorTable.frame.origin.y + errorTable.frame.size.height + MARGIN, pictureContainer.frame.size.width, pictureContainer.frame.size.height);
        } completion:^(BOOL finished) {
            errorTable.hidden = YES;
        }];
    } else {
        // Show the error table and change it to its new size
        [errorTable reloadWithErrors:errorsToShow];
        errorTable.hidden = NO;
        [UIView animateWithDuration:0.2f animations:^{
            errorTable.frame = CGRectMake(errorTable.frame.origin.x, errorTable.frame.origin.y, errorTable.frame.size.width, [errorsToShow count] * 24 + errorsToShow.count);
            pictureContainer.frame = CGRectMake(pictureContainer.frame.origin.x, errorTable.frame.origin.y + errorTable.frame.size.height + MARGIN, pictureContainer.frame.size.width, pictureContainer.frame.size.height);
        }];
    }
}

#pragma mark - Button pressed methods

- (void)takePictureButtonPressed {
    camera.sourceType = UIImagePickerControllerSourceTypeCamera;
    camera.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    [self.cameraPopoverController presentPopoverFromRect:pictureView.frame inView:pictureContainer permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (void)choosePictureButtonPressed {
    camera.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [self.cameraPopoverController presentPopoverFromRect:pictureView.frame inView:pictureContainer permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

#pragma mark - UIImagePicker delegates

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    // Resize and crop to 200x150
    UIImage *resizedImage = [image scaleProportionallyToSize:CGSizeMake(200.0f, 200.0f)];
    resizedImage = [resizedImage croppedImage:CGRectMake(0.0f, 25.0f, 200.0f, 150.0f)];
    
    // Display photo
    pictureView.image = resizedImage;
    
    // Get rid of camera
    [self.cameraPopoverController dismissPopoverAnimated:YES];
    
    // Send updated photo to the server
    PTUser *currentUser = [PTUser currentUser];
    PTUpdatePhotoRequest *updatePhotoRequest = [[PTUpdatePhotoRequest alloc] init];
    [updatePhotoRequest updatePhotoWithUserId:currentUser.userID
                                    authToken:currentUser.authToken
                                        photo:resizedImage
                                      success:^(NSDictionary *result)
     {
         NSLog(@"Successfully updated photo");
     }
                                      failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
     {
         NSLog(@"Failed to update photo");
     }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    // Get rid of camera
    [self.cameraPopoverController dismissPopoverAnimated:YES];
}

@end
