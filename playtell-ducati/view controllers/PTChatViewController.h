//
//  PTChatViewController.h
//  playtell-ducati
//
//  Created by Ricky Hussmann on 8/14/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTChatHUDView.h"
#import "PTPlaydate.h"
#import "PTPlaymate.h"
#import "PTVideoPhone.h"

#import <Foundation/Foundation.h>

@interface PTChatViewController : NSObject

- (id)initWithplaydate:(PTPlaydate*)aPlaydate;
- (id)initWithPlaymate:(PTPlaymate*)aPlaymate;
- (id)initWithNullPlaymate;

@property (nonatomic, readonly) UIView* view;
@property (nonatomic, strong) PTPlaydate* playdate;
@property (nonatomic, strong) PTPlaymate* playmate;

@end
