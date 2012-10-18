//
//  PTPlaymateView.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 8/28/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTPlaymate.h"

@protocol PTPlaymateDelegate;

@interface PTPlaymateView : UIView {
    PTPlaymate *playmate;
    id<PTPlaymateDelegate> delegate;
    
    // Main contents
    UIView *profilePhotoContainer;
    UIImageView *profilePhotoView;
    UIView *backgroundView;
    UIView *contentsView;
    UILabel *lblName;
    
    // Friendship confirmation
    UIView *confirmView;
    BOOL isConfirmShown;
    UIButton *rejectButton;
    UIButton *acceptButton;
    
    // Friendship awaiting
    UIView *awaitingView;
    BOOL isAwaitingShown;
    
    // In playdate
    UIView *inPlaydateView;
    BOOL isInPlaydate;
    
    // Shaking
    BOOL isShaking;
}

@property (nonatomic, retain) id<PTPlaymateDelegate> delegate;

- (id)initWithFrame:(CGRect)frame playmate:(PTPlaymate *)playmate;
- (void)showFriendshipConfirmationAnimated:(BOOL)animated;
- (void)hideFriendshipConfirmationAnimated:(BOOL)animated;
- (void)showFriendshipAwaitingAnimated:(BOOL)animated;
- (void)hideFriendshipAwaitingAnimated:(BOOL)animated;
- (void)showUserInPlaydateAnimated:(BOOL)animated;
- (void)hideUserInPlaydateAnimated:(BOOL)animated;
- (void)beginShake;
- (void)stopShake;
- (void)disableFriendshipConfirmationButtons;
- (void)enableFriendshipConfirmationButtons;
- (void)showAnimated:(BOOL)animated;
- (void)hideAnimated:(BOOL)animated;

@end

@protocol PTPlaymateDelegate <NSObject>
- (void)playmateDidTouch:(PTPlaymateView *)playmateView playmate:(PTPlaymate *)playmate;
- (void)playmateDidAcceptFriendship:(PTPlaymateView *)playmateView playmate:(PTPlaymate *)playmate;
- (void)playmateDidDeclineFriendship:(PTPlaymateView *)playmateView playmate:(PTPlaymate *)playmate;
- (void)playmateDidPressAddFriends:(PTPlaymateView *)playmateView;
@end