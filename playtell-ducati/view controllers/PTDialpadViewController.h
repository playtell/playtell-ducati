//
//  PTDialpadViewController.h
//  PlayTell
//
//  Created by Ricky Hussmann on 5/25/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UAPushNotificationHandler.h"
#import "PTPlaymateView.h"

@interface PTDialpadViewController : UIViewController <UIGestureRecognizerDelegate, PTPlaymateDelegate> {
    BOOL playdateRequestedViaPush;
    NSInteger playdateRequestedViaPushId;
    UIView *loadingView;
    UIView *shimView; // Shim used behind ringing playmate view
    UIView *signUpBubbleContainer; // Shown only when user isn't logged in
    UIImageView *ttInviteBuddies; // "Invite Buddies" tooltip
}

@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, strong) NSArray* playmates;
@property (nonatomic, strong) UIView *loadingView;

- (void)setAwaitingPlaydateRequest:(NSInteger)playdateId;
- (void)loadPlaydateDataFromPushNotification;

@end
