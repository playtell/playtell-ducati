//
//  PTBookView.h
//  PlayTell
//
//  Created by Dimitry Bentsionov on 5/17/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol PTBookViewDelegate;

@interface PTBookView : UIView <UIGestureRecognizerDelegate> {
    CGSize pagelet;
    NSMutableDictionary *layerActions;
    CALayer *rootLayer;
    
    CATransformLayer *cover;
    CALayer *coverOut;
    CALayer *coverIn;
    CALayer *right;

    BOOL animating;
    BOOL isOpen;
    BOOL inFocus;
    
    id<PTBookViewDelegate> delegate;
    NSMutableDictionary *book;
    NSInteger bookPosition;
}

@property (nonatomic, retain) id<PTBookViewDelegate> delegate;
@property (nonatomic) BOOL isOpen;
@property (nonatomic) BOOL inFocus;

- (id)initWithFrame:(CGRect)frame andBook:(NSMutableDictionary *)bookDict;
- (void)initLayers;
- (void)resetLayerPosition;
- (void)open;
- (void)close;
- (void)hide;
- (void)show;
- (void)setFocusLevel:(CGFloat)level;
- (NSString *)getId;
- (void)setBookPosition:(NSInteger)position;
- (NSInteger)getBookPosition;
- (void)setCoverContentsWithImage:(UIImage *)image;
- (void)setPageContentsWithImage:(UIImage *)image;

@end

// Delegate definition
@protocol PTBookViewDelegate
@optional
- (void)bookFocusedWithId:(NSString *)bookId;
- (void)bookTouchedWithId:(NSString *)bookId AndView:(PTBookView *)bookView;
- (void)bookOpenedWithId:(NSString *)bookId AndView:(PTBookView *)bookView;
- (void)bookClosedWithId:(NSString *)bookId AndView:(PTBookView *)bookView;
@end