//
//  PTPostcardView.m
//  playtell-ducati
//
//  Created by Adam Horne on 11/1/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTPostcardView.h"
#import "PTUser.h"

#define LABEL_HEIGHT    40.0
#define LABEL_SPACING_X 75.0
#define LABEL_SPACING_Y 25.0
#define PHOTO_HEIGHT    300.0
#define PHOTO_WIDTH     400.0
#define BUTTON_HEIGHT   40.0
#define BUTTON_SPACING  25.0

@interface PTPostcardView ()

@property (nonatomic, strong) UIView *background;
@property (nonatomic, strong) UILabel *lblTitle;
@property (nonatomic, strong) UIImageView *postcard;
@property (nonatomic, strong) UIImageView *photo;
@property (nonatomic, strong) UIView *video;
@property (nonatomic, strong) UIButton *btnCamera;
@property (nonatomic, strong) UIButton *btnSend;

@end

@implementation PTPostcardView
@synthesize background;
@synthesize lblTitle;
@synthesize postcard;
@synthesize photo;
@synthesize video;
@synthesize btnCamera, btnSend;

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
        lblTitle.text = @"SEND A CARD TO LET THEM KNOW YOU MISSED THEM";
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
        [self addSubview:video];
        
        // Layout the buttons
        btnCamera = [[UIButton alloc] initWithFrame:CGRectMake(postcard.frame.origin.x, postcard.frame.origin.y + postcard.frame.size.height + BUTTON_SPACING, (postcard.frame.size.width - BUTTON_SPACING) / 2, BUTTON_HEIGHT)];
        [btnCamera setTitle:@"Take Photo" forState:UIControlStateNormal];
        [btnCamera setBackgroundImage:[UIImage imageNamed:@"take-a-photo.png"] forState:UIControlStateNormal];
        [btnCamera addTarget:self action:@selector(cameraButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btnCamera];
        
        btnSend = [[UIButton alloc] initWithFrame:CGRectMake(postcard.frame.origin.x + btnCamera.frame.size.width + BUTTON_SPACING, btnCamera.frame.origin.y, btnCamera.frame.size.width, BUTTON_HEIGHT)];
        [btnSend setTitle:@"Send Postcard" forState:UIControlStateNormal];
        [btnSend setBackgroundImage:[UIImage imageNamed:@"take-a-photo.png"] forState:UIControlStateNormal];
        [btnSend addTarget:self action:@selector(sendButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btnSend];
    }
    return self;
}

- (void)cameraButtonPressed {
    NSLog(@"Camera button pressed");
}

- (void)sendButtonPressed {
    NSLog(@"Send button pressed");
}

@end
