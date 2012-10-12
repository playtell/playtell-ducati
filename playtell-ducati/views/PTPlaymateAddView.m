//
//  PTPlaymateAddView.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 10/12/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTPlaymateAddView.h"
#import "UIColor+ColorFromHex.h"
#import <QuartzCore/QuartzCore.h>

@implementation PTPlaymateAddView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
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
        UIImage *profilePhotoImage = [UIImage imageNamed:@"playmate-add-3invite"];
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
        
//        // Add tap capability to photo
//        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoViewDidTap:)];
//        profilePhotoView.userInteractionEnabled = YES;
//        [profilePhotoView addGestureRecognizer:tapRecognizer];
        
        // View shadow
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
        self.layer.shadowOpacity = 0.3f;
        self.layer.shadowRadius = 1.0f;
        self.layer.shouldRasterize = YES;
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        
        // Add the "Add Friends" view
        [self loadAddFriendView];
    }
    return self;
}

- (void)loadAddFriendView {
    addFriendView = [[UIView alloc] initWithFrame:contentsView.frame];
    addFriendView.backgroundColor = [UIColor colorFromHex:@"#40acf4"];
    addFriendView.layer.cornerRadius = 10.0f;
    addFriendView.layer.masksToBounds = YES;
    addFriendView.layer.borderColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.3f].CGColor;
    addFriendView.layer.borderWidth = 1.0f;
    addFriendView.alpha = 1.0f;
    [backgroundView insertSubview:addFriendView belowSubview:contentsView];
    
    // "Invite Buddies" Label
    UILabel *inviteBuddiesLbl = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 6.0f, addFriendView.bounds.size.width-20.0f, 18.0f)];
    inviteBuddiesLbl.text = @"Invite Buddies";
    inviteBuddiesLbl.font = [UIFont boldSystemFontOfSize:14.0f];
    inviteBuddiesLbl.textAlignment = UITextAlignmentCenter;
    inviteBuddiesLbl.textColor = [UIColor whiteColor];
    inviteBuddiesLbl.shadowColor = [UIColor colorFromHex:@"#000000" alpha:0.6f];
    inviteBuddiesLbl.shadowOffset = CGSizeMake(0.0f, 1.0f);
    inviteBuddiesLbl.backgroundColor = [UIColor clearColor];
    [addFriendView addSubview:inviteBuddiesLbl];
    
    // Shift contents view down
    contentsView.bounds = CGRectOffset(contentsView.bounds, 0.0f, -30.0f);
    
    // Add button to contents view
    UIButton *addFriendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addFriendsButton.frame = CGRectMake(67.0f, 28.0f, 58.0f, 58.0f);
    [addFriendsButton setImage:[UIImage imageNamed:@"invite-button"] forState:UIControlStateNormal];
    [addFriendsButton setImage:[UIImage imageNamed:@"invite-button-press"] forState:UIControlStateHighlighted];
    [contentsView addSubview:addFriendsButton];
    [addFriendsButton addTarget:self action:@selector(addFriendsDidPress:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)addFriendsDidPress:(id)sender {
    if ([delegate respondsToSelector:@selector(playmateDidPressAddFriends:)]) {
        [delegate playmateDidPressAddFriends:self];
    }
}

@end