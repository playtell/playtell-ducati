//
//  PTCreatePostcardViewController.h
//  playtell-ducati
//
//  Created by Adam Horne on 11/1/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PTChatViewController.h"
#import "PTCreatePostcardView.h"

@protocol PTCreatePostcardControllerDelegate <NSObject>
@optional
- (void)postcardDidSend;
@end

@interface PTCreatePostcardViewController : UIViewController <PTCreatePostcardViewDelegate>

@property (nonatomic, assign) int playmateId;
@property (nonatomic, strong) id<PTCreatePostcardControllerDelegate> delegate;

- (void)startPhotoCountdown;

@end
