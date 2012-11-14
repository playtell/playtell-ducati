//
//  PTPostcardView.m
//  playtell-ducati
//
//  Created by Adam Horne on 11/1/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTCameraButton.h"
#import "PTPostcardView.h"
#import "PTSendButton.h"
#import "PTUser.h"
#import "PTVideoPhone.h"

#import "UIColor+ColorFromHex.h"
#import "UIView+PlayTell.h"

#define LABEL_HEIGHT    40.0
#define LABEL_SPACING_Y 25.0
#define PHOTO_HEIGHT    300.0
#define PHOTO_WIDTH     400.0
#define BUTTON_HEIGHT   49.0
#define BUTTON_SPACING  20.0

@interface PTPostcardView ()

@property (nonatomic, strong) UIView *background;
@property (nonatomic, strong) UILabel *lblTitle;
@property (nonatomic, strong) UIImage *snapshot;
@property (nonatomic, strong) UIImageView *photo;
@property (nonatomic, strong) UIView *video;
@property (nonatomic, strong) PTCameraButton *btnCamera;
@property (nonatomic, strong) PTSendButton *btnSend;
@property (nonatomic, strong) NSArray *postcardNames;
@property (nonatomic, strong) NSMutableArray *postcards;

// Subviews for the video view for use when taking a picture
@property (nonatomic, strong) UIView *shim;
@property (nonatomic, strong) UIImageView *cameraOutline;
@property (nonatomic, strong) UILabel *lblCounter;

@end

@implementation PTPostcardView
@synthesize delegate;

@synthesize background;
@synthesize lblTitle;
@synthesize snapshot;
@synthesize photo;
@synthesize video;
@synthesize btnCamera, btnSend;
@synthesize postcardNames;
@synthesize postcards;

@synthesize shim, cameraOutline, lblCounter;

UIView *publisherView;
CGRect originalFrame;
int currentPostcard;
BOOL gesturesEnabled;

CGRect offLeftFrame;
CGRect leftFrame;
CGRect centerFrame;
CGRect rightFrame;
CGRect offRightFrame;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        float centerWidth = 553.0f;
        float centerHeight = 590.0f;
        centerFrame = CGRectMake((frame.size.width - centerWidth) / 2, (frame.size.height - centerHeight) / 2, centerWidth, centerHeight);
        
        float otherWidth = centerWidth * 0.8;
        float otherHeight = centerHeight * 0.8;
        float otherY = centerFrame.origin.y + otherHeight * 0.1;
        leftFrame = CGRectMake(otherWidth * -0.8, otherY, otherWidth, otherHeight);
        rightFrame = CGRectMake(frame.size.width - (otherWidth * 0.2), otherY, otherWidth, otherHeight);
        offLeftFrame = CGRectMake(-2 * otherWidth, otherY, otherWidth, otherHeight);
        offRightFrame = CGRectMake(frame.size.width + (2 * otherWidth), otherY, otherWidth, otherHeight);
        
        self.autoresizesSubviews = YES;
        
        float width = frame.size.width;
        float height = frame.size.height;
        
        // Layout the background
        background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo-bg-dark.png"]];
        background.frame = CGRectMake(0.0f, 0.0f, width, height);
        background.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:background];
        
        // Load in the postcard views
        postcards = [[NSMutableArray alloc] init];
        postcardNames = [NSArray arrayWithObjects:@"postcards-a.png", @"postcards-b.png", @"postcards-c.png", @"postcards-d.png", nil];
        for (NSString *name in postcardNames) {
            UIImageView *p = [[UIImageView alloc] initWithImage:[UIImage imageNamed:name]];
            [self addSubview:p];
            [postcards addObject:p];
        }
        currentPostcard = 1;
        [self setPostcardFrames];
        
        // Layout the title label
        lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(centerFrame.origin.x, LABEL_SPACING_Y, centerFrame.size.width, LABEL_HEIGHT)];
        lblTitle.backgroundColor = [UIColor clearColor];
        lblTitle.textAlignment = UITextAlignmentCenter;
        lblTitle.textColor = [UIColor colorFromHex:@"#223844"];
        lblTitle.shadowColor = [UIColor whiteColor];
        lblTitle.shadowOffset = CGSizeMake(0.0f, 2.0f);
        lblTitle.font = [UIFont boldSystemFontOfSize:LABEL_HEIGHT - 5];
        lblTitle.adjustsFontSizeToFitWidth = YES;
        lblTitle.minimumFontSize = 15.0f;
        lblTitle.text = @""; //@"SEND A CARD TO LET THEM KNOW YOU MISSED THEM";
        [self addSubview:lblTitle];
        
        // Layout the photo
        self.snapshot = [PTUser currentUser].userPhoto;
        photo = [[UIImageView alloc] initWithImage:snapshot];
        photo.frame = CGRectMake(centerFrame.origin.x + ((centerFrame.size.width - PHOTO_WIDTH) / 2), centerFrame.origin.y + ((centerFrame.size.height - PHOTO_HEIGHT) / 2) - 50.0, PHOTO_WIDTH, PHOTO_HEIGHT);
        photo.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:photo];
        
        // Layout the video view
        video = [[UIView alloc] initWithFrame:photo.frame];
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
        btnCamera = [[PTCameraButton alloc] initWithFrame:CGRectMake(centerFrame.origin.x, centerFrame.origin.y + centerFrame.size.height + BUTTON_SPACING, (centerFrame.size.width - BUTTON_SPACING) / 2, BUTTON_HEIGHT)];
        [btnCamera addTarget:self action:@selector(cameraButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        btnCamera.hidden = YES;
        [self addSubview:btnCamera];
        
        btnSend = [[PTSendButton alloc] initWithFrame:CGRectMake(centerFrame.origin.x + btnCamera.frame.size.width + BUTTON_SPACING, btnCamera.frame.origin.y, btnCamera.frame.size.width, BUTTON_HEIGHT)];
        [btnSend addTarget:self action:@selector(sendButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        btnSend.hidden = YES;
        [self addSubview:btnSend];
        
        // Create the gesture recognizers
        UISwipeGestureRecognizer *swipeLeftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(userSwipeLeftEvent:)];
        swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
        UISwipeGestureRecognizer *swipeRightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(userSwipeRightEvent:)];
        swipeRightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
        
        // Set self to be the delegate for all gesture recognizers
        swipeLeftRecognizer.delegate = self;
        swipeRightRecognizer.delegate = self;
        
        // Add the gesture recognizers to the view
        [self addGestureRecognizer:swipeLeftRecognizer];
        [self addGestureRecognizer:swipeRightRecognizer];
        
        // At first, we'll be taking default picture so hide anything to do with gestures
        gesturesEnabled = NO;
        for (int iter = 0; iter < postcards.count; iter++) {
            UIImageView *p = (UIImageView *)[postcards objectAtIndex:iter];
            if (iter != currentPostcard) {
                p.alpha = 0.0f;
            }
        }
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
        
        // Disable gestures
        [self disableGestures];
        
        // Start the countdown
        [self countdown];
    } else {
        NSLog(@"Failed to get video publisher view so couldn't take photo for postcard");
    }
}

- (void)sendButtonPressed {
    if (delegate) {
        UIImageView *selectedPostcard = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[postcardNames objectAtIndex:currentPostcard]]];
        UIImageView *photoCopy = [[UIImageView alloc] initWithImage:snapshot];
        photoCopy.frame = CGRectMake((centerFrame.size.width - PHOTO_WIDTH) / 2, ((centerFrame.size.height - PHOTO_HEIGHT) / 2) - 50.0, PHOTO_WIDTH, PHOTO_HEIGHT);
        [selectedPostcard addSubview:photoCopy];
        
        // Setup the animations
        [self disableGestures];
        [UIView animateWithDuration:0.5f animations:^{
            lblTitle.alpha = 0.0f;
            btnCamera.alpha = 0.0f;
            btnSend.alpha = 0.0f;
        } completion:^(BOOL finished) {
            // Animate the postcard moving up
            [UIView animateWithDuration:1.0f animations:^{
                UIImageView *postcard = (UIImageView *)[postcards objectAtIndex:currentPostcard];
                postcard.frame = CGRectOffset(postcard.frame, 0.0f, -self.frame.size.height);
                photo.frame = CGRectOffset(photo.frame, 0.0f, -self.frame.size.height);
            } completion:^(BOOL finished) {
                [delegate postcardTaken:[selectedPostcard screenshotWithSave:NO] withScreenshot:photoCopy.image];
            }];
        }];
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
    snapshot = [publisherView screenshotWithSave:NO];
    photo.image = snapshot;
    
    // Animate out the video view
    [UIView animateWithDuration:1.0f animations:^{
        video.alpha = 0.0f;
    } completion:^(BOOL finished) {
        // Reset the publisher view
        publisherView.frame = originalFrame;
        
        lblTitle.text = @"WANT TO SEND YOUR PICTURE?";
        
        btnCamera.hidden = NO;
        btnCamera.enabled = YES;
        btnSend.hidden = NO;
        btnSend.enabled = YES;
        
        [self enableGestures];
    }];
}

- (void)setCountdownTimeOne {
    lblCounter.text = @"1";
}

- (void)setCountdownTimeTwo {
    lblCounter.text = @"2";
}

- (void)setPostcardFrames {
    for (int iter = 0; iter < postcards.count; iter++) {
        UIImageView *p = (UIImageView *)[postcards objectAtIndex:iter];
        if (iter + 1 < currentPostcard) {
            p.frame = offLeftFrame;
        } else if (iter + 1 == currentPostcard) {
            p.frame = leftFrame;
        } else if (iter == currentPostcard) {
            p.frame = centerFrame;
        } else if (iter - 1 == currentPostcard) {
            p.frame = rightFrame;
        } else {
            p.frame = offRightFrame;
        }
    }
}

- (void)userSwipeLeftEvent:(UISwipeGestureRecognizer *)recognizer {
    if (currentPostcard + 1 < postcards.count) {
        currentPostcard++;
        [UIView animateWithDuration:0.5f animations:^{
            [self setPostcardFrames];
        }];
    }
}

- (void)userSwipeRightEvent:(UISwipeGestureRecognizer *)recognizer {
    if (currentPostcard > 0) {
        currentPostcard--;
        [UIView animateWithDuration:0.5f animations:^{
            [self setPostcardFrames];
        }];
    }
}

- (void)enableGestures {
    gesturesEnabled = YES;
    
    [UIView animateWithDuration:0.5f animations:^{
        for (int iter = 0; iter < postcards.count; iter++) {
            UIImageView *p = (UIImageView *)[postcards objectAtIndex:iter];
            p.alpha = 1.0f;
        }
    }];
}

- (void)disableGestures {
    gesturesEnabled = NO;
    
    [UIView animateWithDuration:0.5f animations:^{
        for (int iter = 0; iter < postcards.count; iter++) {
            UIImageView *p = (UIImageView *)[postcards objectAtIndex:iter];
            if (iter != currentPostcard) {
                p.alpha = 0.0f;
            }
        }
    }];
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch {
    // If gestures aren't enabled, ignore the touch
    if (!gesturesEnabled)
        return NO;
    
    if ([touch.view isKindOfClass:[UIControl class]]) {
        // we touched a button, slider, or other UIControl
        return NO; // ignore the touch
    }
    return YES; // handle the touch
}

@end
