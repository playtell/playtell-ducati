//
//  PTGameView.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 10/17/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol PTGameViewDelegate;

@interface PTGameView : UIView {
    NSInteger gameId;
    UIImage *gameLogo;
    CGSize pagelet;
    NSMutableDictionary *layerActions;
    CALayer *rootLayer;
    CALayer *cover;
    
    BOOL inFocus;
    
    id<PTGameViewDelegate> delegate;
    NSInteger gamePosition;
    NSInteger position;
}

@property (nonatomic, retain) id<PTGameViewDelegate> delegate;
@property (nonatomic) BOOL inFocus;

- (id)initWithFrame:(CGRect)frame gameId:(NSInteger)_gameId gameLogo:(UIImage *)_gameLogo;
- (void)setFocusLevel:(CGFloat)level;
- (void)setPosition:(NSInteger)_position;
- (NSInteger)getPosition;

@end

// Delegate
@protocol PTGameViewDelegate
@optional
- (void)gameFocusedWithId:(NSNumber *)gameId;
- (void)gameTouchedWithId:(NSNumber *)gameId AndView:(PTGameView *)gameView;
- (void)gameOpenedWithId:(NSNumber *)gameId AndView:(PTGameView *)gameView;
- (void)gameClosedWithId:(NSNumber *)gameId AndView:(PTGameView *)gameView;
@end