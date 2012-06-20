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
}

@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, strong) NSArray* playmates;

- (void)setAwaitingPlaydateRequest:(NSInteger)playdateId;

@end
