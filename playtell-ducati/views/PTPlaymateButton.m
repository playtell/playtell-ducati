//
//  PTPlaymateButton.m
//  PlayTell
//
//  Created by Ricky Hussmann on 5/25/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "AFImageRequestOperation.h"
#import "Logging.h"
#import "PTPlaymateButton.h"

#import "UIView+PlayTell.h"

#import <QuartzCore/QuartzCore.h>

@interface PTPlaymateButton ()
@property (nonatomic, assign) CGRect originalFrame;
@end

@implementation PTPlaymateButton
@synthesize playmate;
@synthesize originalFrame;
@synthesize isActivated;
@synthesize isPending;

+(PTPlaymateButton*)playmateButtonWithPlaymate:(PTPlaymate*)aPlaymate {
    UIImage* placeholder = [UIImage imageNamed:@"profile_default_2.png"];

    PTPlaymateButton* playmateButton = [PTPlaymateButton buttonWithType:UIButtonTypeCustom];
    [aPlaymate addObserver:playmateButton
                forKeyPath:@"userPhoto"
                   options:NSKeyValueObservingOptionNew
                   context:NULL];
    
    [playmateButton setBackgroundImage:placeholder forState:UIControlStateNormal];
    [playmateButton setTitle:aPlaymate.username forState:UIControlStateNormal];
    playmateButton.titleLabel.font = [self playmateNameFont];
    playmateButton.layer.cornerRadius = 10.0;
//    playmateButton.clipsToBounds = YES;
    playmateButton.isActivated = NO;
    playmateButton.layer.borderColor = [UIColor whiteColor].CGColor;
    playmateButton.layer.borderWidth = 8.0f;
    playmateButton.layer.shadowColor = [UIColor blackColor].CGColor;
    playmateButton.layer.shadowOffset = CGSizeMake(-0.5, 3.0);
    playmateButton.layer.shadowOpacity = 0.9f;
    
    CGRect buttonFrame = CGRectZero;
    buttonFrame.size = placeholder.size;
    playmateButton.frame = buttonFrame;

    CGRect buttonLabelFrame = playmateButton.titleLabel.frame;
    buttonLabelFrame.origin.y = CGRectGetHeight(playmateButton.bounds) - buttonLabelFrame.size.height - 2.0;
    playmateButton.titleEdgeInsets = UIEdgeInsetsMake(CGRectGetHeight(playmateButton.bounds) - buttonLabelFrame.size.height - 10.0,
                                                     0,
                                                     0, 0);
    playmateButton.playmate = aPlaymate;

    NSURLRequest* urlRequest = [NSURLRequest requestWithURL:aPlaymate.photoURL];
    AFImageRequestOperation* reqeust;
    reqeust = [AFImageRequestOperation imageRequestOperationWithRequest:urlRequest
                                                                success:^(UIImage *image)
    {
        LogTrace(@"Setting button image for %@", aPlaymate.username);
        // Set the loaded photo only if the user doesn't have a 'pending' status (aka. they haven't installed the app yet)
        if (!playmateButton.isPending) {
            [playmateButton setBackgroundImage:image forState:UIControlStateNormal];
        }
        aPlaymate.userPhoto = image;
    }];
    
    if (aPlaymate.userPhoto && !playmateButton.isPending) {
        [playmateButton setBackgroundImage:aPlaymate.userPhoto forState:UIControlStateNormal];
    }

//    [reqeust start];

//    CGRect containerFrame = CGRectMake(0, 0, 100, 30);
//    UIView* container = [[UIView alloc] initWithFrame:containerFrame];
//    container.backgroundColor = [UIColor blueColor];
//
//    [playmateButton addSubviewAndCenter:container];
//    containerFrame = container.frame;
//    containerFrame.origin.y = buttonFrame.size.height-1;
//    container.frame = containerFrame;
    playmateButton.isPending = NO;
    return playmateButton;
}

+ (UIFont*)playmateNameFont {
    return [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
}

- (void)setRequestingPlaydate {
    self.originalFrame = self.frame;

    CGRect buttonLabelFrame = self.titleLabel.frame;

    CGFloat expandedWidth = -0.2*CGRectGetWidth(self.frame);
    CGFloat expandedHeight = -0.2*CGRectGetHeight(self.frame);
    CGRect expandedFrame = CGRectInset(self.frame, expandedWidth, expandedHeight);
    self.frame = expandedFrame;
    self.titleEdgeInsets = UIEdgeInsetsMake(CGRectGetHeight(expandedFrame) - buttonLabelFrame.size.height - 2.0,
                                            0,
                                            0, 0);
}

- (void)resetButton {
    self.frame = self.originalFrame;
    self.titleLabel.font = [[self class] playmateNameFont];
    CGRect buttonLabelFrame = self.titleLabel.frame;
    self.titleEdgeInsets = UIEdgeInsetsMake(CGRectGetHeight(self.bounds) - buttonLabelFrame.size.height - 2.0,
                                            0,
                                            0, 0);
}

- (void)setPending {
    isPending = YES;
    [self setBackgroundImage:[UIImage imageNamed:@"dialpad-pending"] forState:UIControlStateNormal];
}

- (void)setPlaydating {
    [self setBackgroundImage:[UIImage imageNamed:@"dialad-live"] forState:UIControlStateDisabled];    
    [self setEnabled:NO];
}

- (void)setNormal {
    [self setEnabled:YES];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    // Allow the superclass to handle any of it's KVO updates
    if (![keyPath isEqualToString:@"userPhoto"]) {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
        return;
    }
    
    LogDebug(@"Updated button image for: %@", self.playmate.username);
    [self setBackgroundImage:[change valueForKey:NSKeyValueChangeNewKey] forState:UIControlStateNormal];
}

@end
