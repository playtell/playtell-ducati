//
//  PTPlaymateButton.h
//  PlayTell
//
//  Created by Ricky Hussmann on 5/25/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTPlaymate.h"

#import <UIKit/UIKit.h>

@interface PTPlaymateButton : UIButton

@property (nonatomic, strong) PTPlaymate* playmate;

+(PTPlaymateButton*)playmateButtonWithPlaymate:(PTPlaymate*)aPlaymate;

@end
