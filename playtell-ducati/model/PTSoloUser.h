//
//  PTSoloUser.h
//  playtell-ducati
//
//  Created by Ricky Hussmann on 9/6/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTDateViewController.h"
#import "PTPlaymate.h"

@interface PTSoloUser : PTPlaymate

@property (nonatomic, retain) PTDateViewController* dateController;

- (void)resetScriptState;

@end
