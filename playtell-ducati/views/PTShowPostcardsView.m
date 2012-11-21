//
//  PTShowPostcardsView.m
//  playtell-ducati
//
//  Created by Adam Horne on 11/21/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#define LABEL_HEIGHT    40.0
#define LABEL_SPACING_Y 25.0

#import <QuartzCore/QuartzCore.h>

#import "PTShowPostcardsView.h"

#import "UIColor+ColorFromHex.h"

@interface PTShowPostcardsView ()

@property (nonatomic, strong) UIView *background;
@property (nonatomic, strong) UILabel *lblDetails;
@property (nonatomic, strong) NSMutableArray *postcards;

@end

@implementation PTShowPostcardsView

@synthesize background;
@synthesize lblDetails;
@synthesize postcards;

NSArray *_images;
int currentPostcard;

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
        
        // Layout the title label
        lblDetails = [[UILabel alloc] initWithFrame:CGRectMake(centerFrame.origin.x, centerFrame.origin.y + centerFrame.size.height + LABEL_SPACING_Y, centerFrame.size.width, LABEL_HEIGHT)];
        lblDetails.backgroundColor = [UIColor clearColor];
        lblDetails.textAlignment = UITextAlignmentCenter;
        lblDetails.textColor = [UIColor colorFromHex:@"#578DA0"];
        lblDetails.shadowColor = [UIColor whiteColor];
        lblDetails.shadowOffset = CGSizeMake(0.0f, 2.0f);
        lblDetails.font = [UIFont boldSystemFontOfSize:LABEL_HEIGHT - 5];
        lblDetails.adjustsFontSizeToFitWidth = YES;
        lblDetails.minimumFontSize = 15.0f;
        lblDetails.text = @"Text to test it out";
        [self addSubview:lblDetails];
        
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
    }
    return self;
}

- (NSArray *)postcardImages {
    return _images;
}

- (void)setPostcardImages:(NSArray *)postcardImages {
    _images = postcardImages;
    
    if (postcards) {
        for (UIImageView *p in postcards) {
            [p removeFromSuperview];
        }
        postcards = nil;
    }
    
    // Load in the postcard views
    postcards = [[NSMutableArray alloc] init];
    for (UIImage *image in postcardImages) {
        UIImageView *p = [[UIImageView alloc] initWithImage:image];
        p.layer.masksToBounds = NO;
        p.layer.shadowOffset = CGSizeMake(0.0, 3.0);
        p.layer.shadowRadius = 5.0;
        p.layer.shadowOpacity = 0.5;
        [self addSubview:p];
        [postcards addObject:p];
    }
    currentPostcard = 0;
    [self setPostcardFrames];
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
        
        if (iter != currentPostcard) {
            p.alpha = 0.6;
        } else {
            p.alpha = 1.0;
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

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIControl class]]) {
        // we touched a button, slider, or other UIControl
        return NO; // ignore the touch
    }
    return YES; // handle the touch
}

@end
