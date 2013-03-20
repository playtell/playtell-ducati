//
//  PTDialpadViewController.h
//  PlayTell
//
//  Created by Ricky Hussmann on 5/25/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UAPushNotificationHandler.h"
#import "PTConnectionLossViewController.h"
#import "PTPlaymateView.h"
#import "PTShowPostcardsView.h"

@interface PTDialpadViewController : UIViewController <UIGestureRecognizerDelegate, PTPlaymateDelegate> {
    BOOL playdateRequestedViaPush;
    NSInteger playdateRequestedViaPushId;
    UIImageView* background;
    UIView *loadingView;
    UIView *shimView; // Shim used behind ringing playmate view
    UIView *signUpBubbleContainer; // Shown only when user isn't logged in
    UIImageView *ttInviteBuddies; // "Invite Buddies" tooltip
    PTShowPostcardsView *postcardsView;
    
    PTConnectionLossViewController *connectionLossController;
    NSTimer *connectionLossTimer;
    BOOL showingConnectionLossController;
}

@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, strong) NSArray* playmates;
@property (nonatomic, strong) UIView *loadingView;
@property (nonatomic, strong) PTPlaydate *playdateToIgnore;

- (void)setAwaitingPlaydateRequest:(NSInteger)playdateId;
- (void)loadPlaydateDataFromPushNotification;

@end
