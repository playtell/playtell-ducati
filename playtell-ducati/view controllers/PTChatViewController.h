//
//  PTChatViewController.h
//  playtell-ducati
//
//  Created by Ricky Hussmann on 8/14/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTPlaydate.h"
#import "PTPlaymate.h"
#import "PTVideoPhone.h"

#import <Foundation/Foundation.h>

@interface PTChatViewController : NSObject

- (id)initWithplaydate:(PTPlaydate*)aPlaydate;
- (id)initWithPlaymate:(PTPlaymate*)aPlaymate;
- (id)initWithNullPlaymate;

- (void)setLeftViewAsPlaceholder;
- (void)connectToOpenTokSession;
- (void)connectToPlaceholderOpenTokSession;

- (void)setLoadingViewForPlaymate:(PTPlaymate*)aPlaymate;
- (void)playMovieURLInLeftPane:(NSURL*)movieURL;
- (void)stopPlayingMovies;

@property (nonatomic, readonly) UIView* view;
@property (nonatomic, strong) PTPlaydate* playdate;
@property (nonatomic, strong) PTPlaymate* playmate;

@end
