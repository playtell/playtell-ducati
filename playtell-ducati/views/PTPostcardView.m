//
//  PTPostcardView.m
//  playtell-ducati
//
//  Created by Adam Horne on 11/1/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTPostcardView.h"
#import "PTUser.h"
#import "PTVideoPhone.h"

#import "UIView+PlayTell.h"

#define LABEL_HEIGHT    40.0
#define LABEL_SPACING_X 75.0
#define LABEL_SPACING_Y 25.0
#define PHOTO_HEIGHT    300.0
#define PHOTO_WIDTH     400.0
#define BUTTON_HEIGHT   49.0
#define BUTTON_SPACING  20.0

@interface PTPostcardView ()

@property (nonatomic, strong) UIView *background;
@property (nonatomic, strong) UILabel *lblTitle;
@property (nonatomic, strong) UIImageView *postcard;
@property (nonatomic, strong) UIImageView *photo;
@property (nonatomic, strong) UIView *video;
@property (nonatomic, strong) UIButton *btnCamera;
@property (nonatomic, strong) UIButton *btnSend;

// Subviews for the video view for use when taking a picture
@property (nonatomic, strong) UIView *shim;
@property (nonatomic, strong) UIImageView *cameraOutline;
@property (nonatomic, strong) UILabel *lblCounter;

@end

@implementation PTPostcardView
@synthesize delegate;

@synthesize background;
@synthesize lblTitle;
@synthesize postcard;
@synthesize photo;
@synthesize video;
@synthesize btnCamera, btnSend;

@synthesize shim, cameraOutline, lblCounter;

UIView *publisherView;
CGRect originalFrame;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizesSubviews = YES;
        
        float width = frame.size.width;
        float height = frame.size.height;
        
        // Layout the background
        background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo-bg-dark.png"]];
        background.frame = CGRectMake(0.0f, 0.0f, width, height);
        background.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:background];
        
        // Layout the title label
        lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_SPACING_X, LABEL_SPACING_Y, background.frame.size.width - (LABEL_SPACING_X * 2), LABEL_HEIGHT)];
        lblTitle.backgroundColor = [UIColor clearColor];
        lblTitle.textAlignment = UITextAlignmentCenter;
        lblTitle.textColor = [UIColor blueColor];
        lblTitle.font = [UIFont boldSystemFontOfSize:LABEL_HEIGHT - 5];
        lblTitle.adjustsFontSizeToFitWidth = YES;
        lblTitle.minimumFontSize = 15.0f;
        lblTitle.text = @""; //@"SEND A CARD TO LET THEM KNOW YOU MISSED THEM";
        [self addSubview:lblTitle];
        
        // Layout the postcard
        postcard = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"postcards-a.png"]];
        postcard.center = CGPointMake(background.center.x, background.center.y);
        postcard.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:postcard];
        
        // Layout the photo
        photo = [[UIImageView alloc] initWithImage:[PTUser currentUser].userPhoto];
        photo.frame = CGRectMake((postcard.frame.size.width - PHOTO_WIDTH) / 2, ((postcard.frame.size.height - PHOTO_HEIGHT) / 2) - 50.0, PHOTO_WIDTH, PHOTO_HEIGHT);
        photo.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [postcard addSubview:photo];
        
        // Layout the video view
        video = [[UIView alloc] initWithFrame:[self convertRect:photo.frame fromView:postcard]];
        video.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        video.alpha = 0.0f;
        [self addSubview:video];
        
        // Layout the subviews for the video view
        shim = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, video.frame.size.width, video.frame.size.height)];
        shim.backgroundColor = [UIColor whiteColor];
        [video addSubview:shim];
        
        cameraOutline = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo-countdown.png"]];
        cameraOutline.center = shim.center;
        [video addSubview:cameraOutline];
        
        lblCounter = [[UILabel alloc] initWithFrame:cameraOutline.frame];
        lblCounter.backgroundColor = [UIColor clearColor];
        lblCounter.textAlignment = UITextAlignmentCenter;
        lblCounter.textColor = [UIColor whiteColor];
        lblCounter.font = [UIFont boldSystemFontOfSize:70.0f];
        lblCounter.text = @"3";
        [video addSubview:lblCounter];
        
        // Layout the buttons
        btnCamera = [[UIButton alloc] initWithFrame:CGRectMake(postcard.frame.origin.x, postcard.frame.origin.y + postcard.frame.size.height + BUTTON_SPACING, (postcard.frame.size.width - BUTTON_SPACING) / 2, BUTTON_HEIGHT)];
        [btnCamera setBackgroundImage:[UIImage imageNamed:@"photo.png"] forState:UIControlStateNormal];
        [btnCamera setBackgroundImage:[UIImage imageNamed:@"photo-press.png"] forState:UIControlStateHighlighted];
        [btnCamera addTarget:self action:@selector(cameraButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        btnCamera.hidden = YES;
        [self addSubview:btnCamera];
        
        btnSend = [[UIButton alloc] initWithFrame:CGRectMake(postcard.frame.origin.x + btnCamera.frame.size.width + BUTTON_SPACING, btnCamera.frame.origin.y, btnCamera.frame.size.width, BUTTON_HEIGHT)];
        [btnSend setBackgroundImage:[UIImage imageNamed:@"send-postcard.png"] forState:UIControlStateNormal];
        [btnSend setBackgroundImage:[UIImage imageNamed:@"send-postcard-press.png"] forState:UIControlStateHighlighted];
        [btnSend addTarget:self action:@selector(sendButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        btnSend.hidden = YES;
        [self addSubview:btnSend];
    }
    return self;
}

- (void)cameraButtonPressed {
    publisherView = [[PTVideoPhone sharedPhone] currentPublisherView];
    if (publisherView) {
        originalFrame = publisherView.frame;
        
        // Add the publisher view
        publisherView.frame = shim.frame;
        [video insertSubview:publisherView belowSubview:shim];
        
        // Setup the shim
        shim.alpha = 0.0f;
        
        // Start the countdown
        [self countdown];
    } else {
        NSLog(@"Failed to get video publisher view so couldn't take photo for postcard");
    }
}

- (void)sendButtonPressed {
    if (delegate) {
        [delegate postcardTaken:[postcard screenshotWithSave:NO] withScreenshot:photo.image];
    } else {
        NSLog(@"No delegate set so couldn't send postcards");
    }
}

- (void)startPhotoCountdown {
    publisherView = [[PTVideoPhone sharedPhone] currentPublisherView];
    if (publisherView) {
        originalFrame = publisherView.frame;
        
        // Add the publisher view
        publisherView.frame = shim.frame;
        [video insertSubview:publisherView belowSubview:shim];
        
        // Hide the camera outline and countdown label
        cameraOutline.hidden = YES;
        lblCounter.hidden = YES;
        
        // Setup the shim
        shim.alpha = 0.0f;
        
        [UIView animateWithDuration:1.0f animations:^{
            video.alpha = 1.0f;
        } completion:^(BOOL finished) {
            // Start the countdown
            [self countdown];
        }];
    } else {
        lblTitle.text = @"WANT TO SEND YOUR PICTURE?";
        btnCamera.hidden = NO;
        btnSend.hidden = NO;
    }
}

- (void)countdown {
    lblTitle.text = @"SMILE!";
    btnCamera.enabled = NO;
    btnSend.enabled = NO;
    
    // Make sure the video view and its subviews are visible
    video.alpha = 1.0f;
    cameraOutline.hidden = NO;
    lblCounter.hidden = NO;
    
    // Set the countdown time in the view
    lblCounter.text = @"3";
    
    // Set the other methods to be called at the appropriate times
    [self performSelector:@selector(setCountdownTimeTwo) withObject:nil afterDelay:1.0f];
    [self performSelector:@selector(setCountdownTimeOne) withObject:nil afterDelay:2.0f];
    [self performSelector:@selector(takePicture) withObject:nil afterDelay:3.0f];
}

- (void)takePicture {
    // Hide the camera outline and label
    cameraOutline.hidden = YES;
    lblCounter.hidden = YES;
    
    // Show the shim so it looks like it's flashing
    shim.alpha = 1.0f;
    
    // Take the picture from the video publisher view
    UIImage *snapshot = [publisherView screenshotWithSave:NO];
    photo.image = snapshot;
    
    // Animate out the video view
    [UIView animateWithDuration:1.0f animations:^{
        video.alpha = 0.0f;
    } completion:^(BOOL finished) {
        // Reset the publisher view
        publisherView.frame = originalFrame;
        
        lblTitle.text = @"WANT TO SEND YOUR PICTURE?";
        
        [btnCamera setBackgroundImage:[UIImage imageNamed:@"retake-photo.png"] forState:UIControlStateNormal];
        [btnCamera setBackgroundImage:[UIImage imageNamed:@"retake-photo-press.png"] forState:UIControlStateHighlighted];
        
        btnCamera.hidden = NO;
        btnCamera.enabled = YES;
        btnSend.hidden = NO;
        btnSend.enabled = YES;
    }];
}

- (void)setCountdownTimeOne {
    lblCounter.text = @"1";
}

- (void)setCountdownTimeTwo {
    lblCounter.text = @"2";
}

@end
