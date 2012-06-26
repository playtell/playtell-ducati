//
//  PTDialpadViewController.h
//  PlayTell
//
//  Created by Ricky Hussmann on 5/25/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UAPushNotificationHandler.h"

@interface PTDialpadViewController : UIViewController <UIGestureRecognizerDelegate> {
    BOOL playdateRequestedViaPush;
    NSInteger playdateRequestedViaPushId;
    UIView *loadingView;
}

@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, strong) NSArray* playmates;
@property (nonatomic, strong) UIView *loadingView;

- (void)setAwaitingPlaydateRequest:(NSInteger)playdateId;
- (void)loadPlaydateDataFromPushNotification;

@end
