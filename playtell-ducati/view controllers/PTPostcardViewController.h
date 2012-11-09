//
//  PTPostcardViewController.h
//  playtell-ducati
//
//  Created by Adam Horne on 11/1/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PTChatViewController.h"
#import "PTPostcardView.h"

@protocol PTPostcardControllerDelegate <NSObject>
@optional
- (void)postcardDidSend;
@end

@interface PTPostcardViewController : UIViewController <PTPostcardViewDelegate>

@property (nonatomic, assign) int playdateId;
@property (nonatomic, strong) id<PTPostcardControllerDelegate> delegate;

- (void)startPhotoCountdown;

@end
