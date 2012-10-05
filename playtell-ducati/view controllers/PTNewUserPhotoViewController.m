//
//  PTNewUserPhotoViewController.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 9/12/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PTNewUserPhotoViewController.h"
#import "UIColor+HexColor.h"
#import "PTContactsNavCancelButton.h"
#import "PTContactsNavBackButton.h"
#import "PTContactsNavNextButton.h"
#import "PTAppDelegate.h"
#import "TransitionController.h"
#import "PTLoginViewController.h"
#import "PTNewUserNavigationController.h"
#import "PTNewUserBirthdateViewController.h"
#import "UIImage+Resize.h"

@interface PTNewUserPhotoViewController ()

@end

@implementation PTNewUserPhotoViewController

@synthesize cameraPopoverController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Keyboard notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
        
        // Textfield change notification
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
        
        // Camera control
        camera = [[UIImagePickerController alloc] init];
        camera.delegate = self;
        camera.allowsEditing = YES;
        self.cameraPopoverController = [[UIPopoverController alloc] initWithContentViewController:camera];
        self.cameraPopoverController.delegate = self;

        // Initial photo status
        hasPhotoChanged = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Background
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"date_bg.png"]];
    
    // Nav setup
    self.title = @"Pick a photo";
    
    // Nav buttons
    self.navigationItem.hidesBackButton = YES;
    
    PTContactsNavBackButton *buttonBackView = [PTContactsNavBackButton buttonWithType:UIButtonTypeCustom];
    buttonBackView.frame = CGRectMake(0.0f, 0.0f, 75.0f, 33.0f);
    [buttonBackView addTarget:self action:@selector(backDidPress:) forControlEvents:UIControlEventTouchUpInside];
    buttonBack = [[UIBarButtonItem alloc] initWithCustomView:buttonBackView];
    
    PTContactsNavNextButton *buttonNextView = [PTContactsNavNextButton buttonWithType:UIButtonTypeCustom];
    buttonNextView.frame = CGRectMake(0.0f, 0.0f, 75.0f, 33.0f);
    [buttonNextView addTarget:self action:@selector(nextDidPress:) forControlEvents:UIControlEventTouchUpInside];
    buttonNext = [[UIBarButtonItem alloc] initWithCustomView:buttonNextView];
    buttonNext.enabled = NO;
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:buttonNext, buttonBack, nil]];
    
    // Content container style
    contentContainer.backgroundColor = [UIColor clearColor];
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:contentContainer.bounds
                                                   byRoundingCorners:(UIRectCornerBottomLeft|UIRectCornerBottomRight)
                                                         cornerRadii:CGSizeMake(4.0f, 4.0f)];
    
    // Create the shadow layer
    CAShapeLayer *shadowLayer = [CAShapeLayer layer];
    [shadowLayer setFrame:contentContainer.bounds];
    [shadowLayer setMasksToBounds:NO];
    [shadowLayer setShadowPath:maskPath.CGPath];
    shadowLayer.shadowColor = [UIColor blackColor].CGColor;
    shadowLayer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    shadowLayer.shadowOpacity = 0.2f;
    shadowLayer.shadowRadius = 10.0f;
    
    CALayer *roundedLayer = [CALayer layer];
    [roundedLayer setFrame:contentContainer.bounds];
    [roundedLayer setBackgroundColor:[UIColor colorFromHex:@"#e4ecef"].CGColor];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = contentContainer.bounds;
    maskLayer.path = maskPath.CGPath;
    roundedLayer.mask = maskLayer;
    
    [contentContainer.layer insertSublayer:shadowLayer atIndex:0];
    [contentContainer.layer insertSublayer:roundedLayer atIndex:1];
    
    // Init the top shadow line
    topShadow = [[UIView alloc] initWithFrame:CGRectMake(-20.0f, -20.0f, 1024.0f + 40.0f, 20.0f)];
    topShadow.backgroundColor = [UIColor whiteColor];
    topShadow.layer.shadowColor = [UIColor blackColor].CGColor;
    topShadow.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    topShadow.layer.shadowOpacity = 0.9f;
    topShadow.layer.shadowRadius = 5.0f;
    topShadow.alpha = 0.0f;
    [self.view insertSubview:topShadow aboveSubview:contentContainer];
    
    // Photo view (white bg + round corners)
    UIView *photoInnerContainer = [[UIView alloc] initWithFrame:photoContainer.bounds];
    photoInnerContainer.backgroundColor = [UIColor whiteColor];
    photoInnerContainer.layer.cornerRadius = 12.0f;
    photoInnerContainer.layer.masksToBounds = YES;
    [photoContainer addSubview:photoInnerContainer];
    // Contents view (holds profile photo)
    UIView *photoContentsView = [[UIView alloc] initWithFrame:CGRectMake(3.0f, 3.0f, photoInnerContainer.bounds.size.width-6.0f, photoInnerContainer.bounds.size.height-6.0f)];
    photoContentsView.layer.cornerRadius = 10.0f;
    photoContentsView.layer.masksToBounds = YES;
    photoContentsView.backgroundColor = [UIColor clearColor];
    [photoInnerContainer addSubview:photoContentsView];
    // Init the photo view (and its container for shadow)
    profilePhotoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profile_default_2"]];
    profilePhotoView.frame = photoContentsView.bounds;
    profilePhotoView.layer.borderColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.1f].CGColor;
    profilePhotoView.layer.borderWidth = 1.0f;
    profilePhotoView.layer.cornerRadius = 10.0f;
    profilePhotoView.layer.masksToBounds = YES;
    [photoContentsView addSubview:profilePhotoView];
    // View shadow
    photoContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    photoContainer.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    photoContainer.layer.shadowOpacity = 0.3f;
    photoContainer.layer.shadowRadius = 1.0f;
    photoContainer.layer.shouldRasterize = YES;
    photoContainer.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    // Camera-
    buttonTakePhoto.enabled = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    buttonChoosePhoto.enabled = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
}

- (void)viewDidUnload {
    self.cameraPopoverController = nil;
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    // Retrieve user data
    PTNewUserNavigationController *newUserNavigationController = (PTNewUserNavigationController *)self.navigationController;
    if (newUserNavigationController.currentUser.photo != nil) {
        profilePhotoView.image = newUserNavigationController.currentUser.photo;
        buttonNext.enabled = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    // Save user data
    PTNewUserNavigationController *newUserNavigationController = (PTNewUserNavigationController *)self.navigationController;
    if (hasPhotoChanged == YES) {
        newUserNavigationController.currentUser.photo = profilePhotoView.image;
    }
}

- (void)dealloc {
    // Notifications cleanup
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - Keyboard notification handlers

- (void)keyboardWillShow {
    [UIView animateWithDuration:0.2f animations:^{
        contentContainer.frame = CGRectOffset(contentContainer.frame, 0.0f, -250.0f);
        topShadow.alpha = 1.0f;
    }];
}

- (void)keyboardWillHide {
    [UIView animateWithDuration:0.2f animations:^{
        contentContainer.frame = CGRectOffset(contentContainer.frame, 0.0f, 250.0f);
        topShadow.alpha = 0.0f;
    }];
}

#pragma mark - Navigation button handlers

- (void)backDidPress:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)nextDidPress:(id)sender {
    PTNewUserBirthdateViewController *newUserBirthdateViewController = [[PTNewUserBirthdateViewController alloc] initWithNibName:@"PTNewUserBirthdateViewController" bundle:nil];
    [self.navigationController pushViewController:newUserBirthdateViewController animated:YES];
}

#pragma mark - Textfield notification handler

- (BOOL)textFieldDidChange:(NSNotification *)notification {
    buttonNext.enabled = (![txtName.text isEqualToString:@""] && ![txtEmail.text isEqualToString:@""] && ![txtPassword.text isEqualToString:@""]);
    return YES;
}

#pragma mark - Photo actions

- (IBAction)takePhotoDidPress:(id)sender {
    camera.sourceType = UIImagePickerControllerSourceTypeCamera;
    camera.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    [self.cameraPopoverController presentPopoverFromRect:photoContainer.frame inView:contentContainer permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (IBAction)choosePhotoDidPress:(id)sender {
    camera.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [self.cameraPopoverController presentPopoverFromRect:photoContainer.frame inView:contentContainer permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

#pragma mark - UIImagePicker delegates

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    // Resize and crop to 200x150
    UIImage *resizedImage = [image scaleProportionallyToSize:CGSizeMake(200.0f, 200.0f)];
    resizedImage = [resizedImage croppedImage:CGRectMake(0.0f, 25.0f, 200.0f, 150.0f)];
    
//    // Generate random filename and upload picture to S3
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        // Resize
//        UIImage *s3Image = [UIImage imageWithImage:image scaledToSize:CGSizeMake(640.0f, 852.0f)];
//        
//        // S3 client
//        //        AmazonS3Client *s3 = [[AmazonS3Client alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY];
//        NSString *fileName = [NSString stringWithFormat:@"%@.png", [JDConstants generateUniqueId]];
//        
//        @try {
//            // Upload image data
//            S3PutObjectRequest *por = [[S3PutObjectRequest alloc] initWithKey:fileName inBucket:PICTURE_BUCKET];
//            por.contentType = @"image/png";
//            por.data        = UIImagePNGRepresentation(s3Image);
//            por.cannedACL   = [S3CannedACL publicRead];
//            
//            //[s3 putObject:por];
//            NSLog(@"Photo URL: %@", [por.url absoluteString]);
//        } @catch (AmazonClientException *exception) {
//            [JDConstants showAlertMessage:exception.message withTitle:@"Upload Error"];
//        }
//    });
    
    // Update status
    hasPhotoChanged = YES;
    
    // Display photo
    profilePhotoView.image = resizedImage;
    
    // Get rid of camera
    [self.cameraPopoverController dismissPopoverAnimated:YES];
    
    // Enable next button
    buttonNext.enabled = YES;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    // Get rid of camera
    [self.cameraPopoverController dismissPopoverAnimated:YES];
}

@end