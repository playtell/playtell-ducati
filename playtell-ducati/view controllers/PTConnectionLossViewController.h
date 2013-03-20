//
//  PTConnectionLossViewController.h
//  playtell-ducati
//
//  Created by Adam Horne on 3/15/13.
//  Copyright (c) 2013 PlayTell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PTConnectionLossViewController : UIViewController {
    UIImageView *imgConnectionLost;
    UIImageView *imgConnectionFound;
    
    BOOL blinkerShowingConnected;
    NSTimer *blinkerTimer;
}

- (void)showConnectionLost;
- (void)showConnectionFound;

- (void)startBlinking;
- (void)stopBlinking;

@end
