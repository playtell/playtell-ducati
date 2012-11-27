//
//  PTShowPostcardsView.m
//  playtell-ducati
//
//  Created by Adam Horne on 11/21/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#define LABEL_HEIGHT    25.0
#define LABEL_SPACING_Y 25.0

#import <QuartzCore/QuartzCore.h>

#import "PTPostcard.h"
#import "PTShowPostcardsView.h"

#import "UIColor+ColorFromHex.h"

@interface PTShowPostcardsView ()

@property (nonatomic, strong) UIView *background;
@property (nonatomic, strong) UILabel *lblDetails;
@property (nonatomic, strong) NSMutableArray *postcardImageViews;

@end

@implementation PTShowPostcardsView

@synthesize background;
@synthesize lblDetails;
@synthesize postcardImageViews;

NSArray *_postcards;
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
        lblDetails.text = @""; //@"Text to test it out";
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

- (NSArray *)postcards {
    return _postcards;
}

- (void)setPostcards:(NSArray *)postcards {
    _postcards = postcards;
    
    if (postcardImageViews) {
        for (UIImageView *p in postcardImageViews) {
            [p removeFromSuperview];
        }
        postcardImageViews = nil;
    }
    
    // Load in the postcard views
    postcardImageViews = [[NSMutableArray alloc] init];
    for (PTPostcard *postcard in postcards) {
        UIImageView *p = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_loading.gif"]];
        p.layer.masksToBounds = NO;
        p.layer.shadowOffset = CGSizeMake(0.0, 3.0);
        p.layer.shadowRadius = 5.0;
        p.layer.shadowOpacity = 0.5;
        [self addSubview:p];
        [postcardImageViews addObject:p];
        
        // Asynchronously load the images from the server
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^{
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:postcard.photoURL]];
            
            // Have to update UI elements on the main thread
            dispatch_sync(dispatch_get_main_queue(), ^{
                [p setImage:image];
            });
        });
    }
    currentPostcard = 0;
    [self setPostcardFrames];
    [self setLabelText];
}

- (void)setPostcardFrames {
    for (int iter = 0; iter < postcardImageViews.count; iter++) {
        UIImageView *p = (UIImageView *)[postcardImageViews objectAtIndex:iter];
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

- (void)setLabelText {
    if ([self.postcards count] > 0) {
        PTPostcard *current = [self.postcards objectAtIndex:currentPostcard];
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"MMM dd, yyyy ● hh:mm a"];
        NSString *dateStr = [df stringFromDate:current.timestamp];
        
        lblDetails.text = [NSString stringWithFormat:@"%@ ● %@", current.sender, dateStr];
    } else {
        lblDetails.text = @"You have no postcards!";
    }
}

- (void)userSwipeLeftEvent:(UISwipeGestureRecognizer *)recognizer {
    if (currentPostcard + 1 < postcardImageViews.count) {
        currentPostcard++;
        [UIView animateWithDuration:0.5f animations:^{
            [self setPostcardFrames];
        } completion:^(BOOL finished) {
            [self setLabelText];
        }];
    }
}

- (void)userSwipeRightEvent:(UISwipeGestureRecognizer *)recognizer {
    if (currentPostcard > 0) {
        currentPostcard--;
        [UIView animateWithDuration:0.5f animations:^{
            [self setPostcardFrames];
        } completion:^(BOOL finished) {
            [self setLabelText];
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
