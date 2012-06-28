//
//  PTPlaymateButton.h
//  PlayTell
//
//  Created by Ricky Hussmann on 5/25/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTPlaymate.h"

#import <UIKit/UIKit.h>

@interface PTPlaymateButton : UIButton {
    BOOL isPending;
}

@property (nonatomic, strong) PTPlaymate* playmate;
@property (nonatomic, assign) BOOL isActivated;
@property (nonatomic, assign) BOOL isPending;

+(PTPlaymateButton*)playmateButtonWithPlaymate:(PTPlaymate*)aPlaymate;

- (void)setRequestingPlaydate;
- (void)resetButton;
- (void)setPending;
- (void)setPlaydating;
- (void)setNormal;

@end
