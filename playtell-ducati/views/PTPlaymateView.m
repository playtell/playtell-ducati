//
//  PTPlaymateView.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 8/28/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTPlaymateView.h"
#import "AFImageRequestOperation.h"
#import "UIColor+ColorFromHex.h"
#import <QuartzCore/QuartzCore.h>

@implementation PTPlaymateView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame playmate:(PTPlaymate *)playmateObj {
    self = [super initWithFrame:frame];
    if (self) {
        // Store playmate
        playmate = playmateObj;
        
        // Background view (white bg + round corners)
        backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        backgroundView.backgroundColor = [UIColor whiteColor];
        backgroundView.layer.cornerRadius = 12.0f;
        backgroundView.layer.masksToBounds = YES;
        [self addSubview:backgroundView];
        
        // Contents view (holds profile photo & name label)
        contentsView = [[UIView alloc] initWithFrame:CGRectMake(3.0f, 3.0f, self.bounds.size.width-6.0f, self.bounds.size.height-6.0f)];
        contentsView.layer.cornerRadius = 10.0f;
        contentsView.layer.masksToBounds = YES;
        [backgroundView addSubview:contentsView];
        
        // Init the photo view (and its container for shadow)
        UIImage *profilePhotoImage;
        if ([playmate.userStatus isEqualToString:@"pending"]) {
            profilePhotoImage = [UIImage imageNamed:@"dialpad-pending"];
        } else {
            profilePhotoImage = [UIImage imageNamed:@"profile_default_2"];
        }
        profilePhotoContainer = [[UIView alloc] initWithFrame:contentsView.bounds];
        profilePhotoContainer.layer.cornerRadius = 10.0f;
        
        profilePhotoView = [[UIImageView alloc] initWithImage:profilePhotoImage];
        profilePhotoView.frame = contentsView.bounds;
        profilePhotoView.layer.borderColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.1f].CGColor;
        profilePhotoView.layer.borderWidth = 1.0f;
        profilePhotoView.layer.cornerRadius = 10.0f;
        profilePhotoView.layer.masksToBounds = YES;
        
        [profilePhotoContainer addSubview:profilePhotoView];
        [contentsView addSubview:profilePhotoContainer];
        [self loadProfilePhoto];
        
        // Add tap capability to photo
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoViewDidTap:)];
        profilePhotoView.userInteractionEnabled = YES;
        [profilePhotoView addGestureRecognizer:tapRecognizer];
        
        // Init the name label
        lblName = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 122.0f, self.bounds.size.width-20.0f, 18.0f)];
        lblName.backgroundColor = [UIColor clearColor];
        lblName.text = playmate.username;
        lblName.textColor = [UIColor whiteColor];
        lblName.textAlignment = UITextAlignmentCenter;
        lblName.font = [UIFont boldSystemFontOfSize:15.0f];
        lblName.shadowColor = [UIColor colorFromHex:@"#000000" alpha:0.6f];
        lblName.shadowOffset = CGSizeMake(0.0f, 1.0f);
        [self insertSubview:lblName aboveSubview:contentsView];
        
        // Friendship confirmation view
        if ([playmate.friendshipStatus isEqualToString:@"pending-you"]) {
            [self loadFriendshipConfirmView];
            [self showFriendshipConfirmationAnimated:NO];
        }
        
        // Friendship awaiting view
        if ([playmate.friendshipStatus isEqualToString:@"pending-them"]) {
            [self loadFriendshipAwaitingView];
            [self showFriendshipAwaitingAnimated:NO];
        }
        
        // Friend in playdate view
        isInPlaydate = NO;
        if ([playmate.userStatus isEqualToString:@"playdate"]) {
            [self loadInPlaydateView];
            [self showUserInPlaydateAnimated:NO];
        }
        
        // View shadow
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
        self.layer.shadowOpacity = 0.3f;
        self.layer.shadowRadius = 1.0f;
        self.layer.shouldRasterize = YES;
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    }
    return self;
}

- (void)photoViewDidTap:(UITapGestureRecognizer *)tapRecognizer {
    // If not confirmed friends, don't do anything
    if (![playmate.friendshipStatus isEqualToString:@"confirmed"]) {
        return;
    }
    
    // If user is in playdate, don't do anything
    if (isInPlaydate == YES) {
        return;
    }

    if ([delegate respondsToSelector:@selector(playmateDidTouch:playmate:)]) {
        [delegate playmateDidTouch:self playmate:playmate];
    }
}

- (void)loadProfilePhoto {
    NSURLRequest* urlRequest = [NSURLRequest requestWithURL:playmate.photoURL];
    AFImageRequestOperation* photoRequest = [AFImageRequestOperation imageRequestOperationWithRequest:urlRequest
                                                                                              success:^(UIImage *image) {
        playmate.userPhoto = image;
        profilePhotoView.image = image;
    }];
    [photoRequest start];
}

- (void)loadFriendshipConfirmView {
    confirmView = [[UIView alloc] initWithFrame:contentsView.frame];
    confirmView.backgroundColor = [UIColor colorFromHex:@"#2a4552"];
    confirmView.layer.cornerRadius = 10.0f;
    confirmView.layer.masksToBounds = YES;
    confirmView.layer.borderColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.3f].CGColor;
    confirmView.layer.borderWidth = 1.0f;
    confirmView.alpha = 0.0f;
    confirmView.userInteractionEnabled = YES;
    [backgroundView insertSubview:confirmView belowSubview:contentsView];
    isConfirmShown = NO;
    
    // "New Friend Request" Label
    UILabel *newFriendRequestLbl = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 6.0f, confirmView.bounds.size.width-20.0f, 18.0f)];
    newFriendRequestLbl.text = @"New Friend Request";
    newFriendRequestLbl.font = [UIFont boldSystemFontOfSize:14.0f];
    newFriendRequestLbl.textAlignment = UITextAlignmentCenter;
    newFriendRequestLbl.textColor = [UIColor colorFromHex:@"#43ccfb"];
    newFriendRequestLbl.shadowColor = [UIColor colorFromHex:@"#000000" alpha:0.6f];
    newFriendRequestLbl.shadowOffset = CGSizeMake(0.0f, 1.0f);
    newFriendRequestLbl.backgroundColor = [UIColor clearColor];
    [confirmView addSubview:newFriendRequestLbl];
    
    // Accept/Reject buttons
    rejectButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    rejectButton.frame = CGRectMake(10.0f, 30.0f, 82.0f, 20.0f);
    [rejectButton setTitle:@"Reject" forState:UIControlStateNormal];
    [confirmView addSubview:rejectButton];
    
    acceptButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    acceptButton.frame = CGRectMake(102.0f, 30.0f, 82.0f, 20.0f);
    [acceptButton setTitle:@"Accept" forState:UIControlStateNormal];
    [confirmView addSubview:acceptButton];
    
    [rejectButton addTarget:self action:@selector(friendshipDidDecline:) forControlEvents:UIControlEventTouchUpInside];
    [acceptButton addTarget:self action:@selector(friendshipDidAccept:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)loadFriendshipAwaitingView {
    awaitingView = [[UIView alloc] initWithFrame:contentsView.frame];
    awaitingView.backgroundColor = [UIColor colorFromHex:@"#2a4552"];
    awaitingView.layer.cornerRadius = 10.0f;
    awaitingView.layer.masksToBounds = YES;
    awaitingView.layer.borderColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.3f].CGColor;
    awaitingView.layer.borderWidth = 1.0f;
    awaitingView.alpha = 0.0f;
    [backgroundView insertSubview:awaitingView belowSubview:contentsView];
    
    // "Invitation sent" Label
    UILabel *invitationSentLbl = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 6.0f, awaitingView.bounds.size.width-20.0f, 18.0f)];
    invitationSentLbl.text = @"Invitation sent";
    invitationSentLbl.font = [UIFont boldSystemFontOfSize:14.0f];
    invitationSentLbl.textAlignment = UITextAlignmentCenter;
    invitationSentLbl.textColor = [UIColor whiteColor];
    invitationSentLbl.shadowColor = [UIColor colorFromHex:@"#000000" alpha:0.6f];
    invitationSentLbl.shadowOffset = CGSizeMake(0.0f, 1.0f);
    invitationSentLbl.backgroundColor = [UIColor clearColor];
    [awaitingView addSubview:invitationSentLbl];
}

- (void)loadInPlaydateView {
    inPlaydateView = [[UIView alloc] initWithFrame:contentsView.frame];
    inPlaydateView.backgroundColor = [UIColor colorFromHex:@"#2a4552"];
    inPlaydateView.layer.cornerRadius = 10.0f;
    inPlaydateView.layer.masksToBounds = YES;
    inPlaydateView.layer.borderColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.3f].CGColor;
    inPlaydateView.layer.borderWidth = 1.0f;
    inPlaydateView.alpha = 0.0f;
    [backgroundView insertSubview:inPlaydateView belowSubview:contentsView];
    
    // "Invitation sent" Label
    UILabel *invitationSentLbl = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 6.0f, inPlaydateView.bounds.size.width-20.0f, 18.0f)];
    invitationSentLbl.text = @"In playdate";
    invitationSentLbl.font = [UIFont boldSystemFontOfSize:14.0f];
    invitationSentLbl.textAlignment = UITextAlignmentCenter;
    invitationSentLbl.textColor = [UIColor whiteColor];
    invitationSentLbl.shadowColor = [UIColor colorFromHex:@"#000000" alpha:0.6f];
    invitationSentLbl.shadowOffset = CGSizeMake(0.0f, 1.0f);
    invitationSentLbl.backgroundColor = [UIColor clearColor];
    [inPlaydateView addSubview:invitationSentLbl];
}

- (void)showFriendshipConfirmationAnimated:(BOOL)animated {
    if (confirmView == nil) {
        [self loadFriendshipConfirmView];
    }
    
    // Turn off user interaction from contents view to let touches pass through to confirm view
    contentsView.userInteractionEnabled = NO;

    if (animated == NO) {
        confirmView.alpha = 1.0f;
        contentsView.alpha = 0.5f;
        contentsView.bounds = CGRectOffset(contentsView.bounds, 0.0f, -60.0f);
    } else {
        [UIView animateWithDuration:0.3f animations:^{
            confirmView.alpha = 1.0f;
            contentsView.alpha = 0.5f;
            contentsView.bounds = CGRectOffset(contentsView.bounds, 0.0f, -60.0f);
        }];
    }
}

- (void)hideFriendshipConfirmationAnimated:(BOOL)animated {
    // Turn on user interaction to contents view (turned off to let touches pass through to confirm view)
    contentsView.userInteractionEnabled = NO;
    
    if (animated == NO) {
        confirmView.alpha = 0.0f;
        contentsView.alpha = 1.0f;
        contentsView.bounds = CGRectOffset(contentsView.bounds, 0.0f, 60.0f);
    } else {
        [UIView animateWithDuration:0.3f animations:^{
            confirmView.alpha = 0.0f;
            contentsView.alpha = 1.0f;
            contentsView.bounds = CGRectOffset(contentsView.bounds, 0.0f, 60.0f);
        }];
    }
}

- (void)showFriendshipAwaitingAnimated:(BOOL)animated {
    if (awaitingView == nil) {
        [self loadFriendshipAwaitingView];
    }

    if (animated == NO) {
        awaitingView.alpha = 1.0f;
        contentsView.alpha = 0.5f;
        contentsView.bounds = CGRectOffset(contentsView.bounds, 0.0f, -30.0f);
    } else {
        [UIView animateWithDuration:0.3f animations:^{
            awaitingView.alpha = 1.0f;
            contentsView.alpha = 0.5f;
            contentsView.bounds = CGRectOffset(contentsView.bounds, 0.0f, -30.0f);
        }];
    }
}

- (void)hideFriendshipAwaitingAnimated:(BOOL)animated {
    if (animated == NO) {
        awaitingView.alpha = 0.0f;
        contentsView.alpha = 1.0f;
        contentsView.bounds = CGRectOffset(contentsView.bounds, 0.0f, 30.0f);
    } else {
        [UIView animateWithDuration:0.3f animations:^{
            awaitingView.alpha = 0.0f;
            contentsView.alpha = 1.0f;
            contentsView.bounds = CGRectOffset(contentsView.bounds, 0.0f, 30.0f);
        }];
    }
}

- (void)showUserInPlaydateAnimated:(BOOL)animated {
    isInPlaydate = YES;

    if (inPlaydateView == nil) {
        [self loadInPlaydateView];
    }

    if (animated == NO) {
        inPlaydateView.alpha = 1.0f;
        contentsView.alpha = 0.5f;
        contentsView.bounds = CGRectOffset(contentsView.bounds, 0.0f, -30.0f);
    } else {
        [UIView animateWithDuration:0.3f animations:^{
            inPlaydateView.alpha = 1.0f;
            contentsView.alpha = 0.5f;
            contentsView.bounds = CGRectOffset(contentsView.bounds, 0.0f, -30.0f);
        }];
    }
}

- (void)hideUserInPlaydateAnimated:(BOOL)animated {
    isInPlaydate = NO;

    if (animated == NO) {
        inPlaydateView.alpha = 0.0f;
        contentsView.alpha = 1.0f;
        contentsView.bounds = CGRectOffset(contentsView.bounds, 0.0f, 30.0f);
    } else {
        [UIView animateWithDuration:0.3f animations:^{
            inPlaydateView.alpha = 0.0f;
            contentsView.alpha = 1.0f;
            contentsView.bounds = CGRectOffset(contentsView.bounds, 0.0f, 30.0f);
        }];
    }
}

- (void)beginShake {
    // Begin snip
    NSInteger randomInt = arc4random()%500;
    float r = (randomInt/500.0)+0.5;
    
    CGAffineTransform leftWobble = CGAffineTransformMakeRotation(degreesToRadians(-1.0 - r));
    CGAffineTransform rightWobble = CGAffineTransformMakeRotation(degreesToRadians(1.0 + r));
    
    self.transform = leftWobble;
    
    [self.layer setAnchorPoint:CGPointMake(0.5, 0.5)];
    
    [UIView animateWithDuration:0.1
                          delay:0
                        options:
     UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionRepeat|UIViewAnimationOptionAutoreverse
                     animations:^{
                         [UIView setAnimationRepeatCount:NSNotFound];
                         self.transform = rightWobble;
                     }
                     completion:nil];
}

- (void)stopShake {
    self.transform = CGAffineTransformIdentity;
    [self.layer removeAllAnimations];
}

- (void)friendshipDidDecline:(id)sender {
    if ([delegate respondsToSelector:@selector(playmateDidDeclineFriendship:playmate:)]) {
        [self disableFriendshipConfirmationButtons];
        [delegate playmateDidDeclineFriendship:self playmate:playmate];
    }
}

- (void)friendshipDidAccept:(id)sender {
    if ([delegate respondsToSelector:@selector(playmateDidAcceptFriendship:playmate:)]) {
        [self disableFriendshipConfirmationButtons];
        [delegate playmateDidAcceptFriendship:self playmate:playmate];
    }
}

- (void)disableFriendshipConfirmationButtons {
    acceptButton.enabled = NO;
    rejectButton.enabled = NO;
}

- (void)enableFriendshipConfirmationButtons {
    acceptButton.enabled = NO;
    rejectButton.enabled = NO;
}

- (void)showAnimated:(BOOL)animated {
    if (animated == NO) {
        self.alpha = 1.0f;
    } else {
        [UIView animateWithDuration:0.7f
                         animations:^{
                             self.alpha = 1.0f;
                         }];
    }
}

- (void)hideAnimated:(BOOL)animated {
    if (animated == NO) {
        self.alpha = 0.0f;
    } else {
        [UIView animateWithDuration:0.7f
                         animations:^{
                             self.alpha = 0.0f;
                         }];
    }
}

@end