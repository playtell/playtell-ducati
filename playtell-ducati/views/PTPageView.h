//
//  PTPageView.h
//  PlayTell
//
//  Created by Dimitry Bentsionov on 5/23/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "PTPagesScrollView.h"

@interface PTPageView : UIView <UIGestureRecognizerDelegate> {
    NSInteger pageNumber;
    NSMutableDictionary *layerActions;
    CALayer *rootLayer;
    CATransformLayer *left;
    CALayer *left_front;
    CALayer *left_back;
    CALayer *right;
    CGSize pagelet;
    
    CGFloat currentPage;
    BOOL hasContent;
    CGFloat pinchVal;
    
    id<PTPagesScrollViewDelegate> delegate;
    CGPoint fingerPoint;
}

@property (nonatomic, retain) id<PTPagesScrollViewDelegate> delegate;
@property (nonatomic) BOOL hasContent;

- (id)initWithFrame:(CGRect)frame andPageNumber:(NSInteger)number;
- (void)setCurrentPage:(CGFloat)page andForceOpen:(BOOL)forceOpen;
- (void)open;
- (void)setPageContentsWithImage:(UIImage *)image;
- (id)getLeftContent;
- (id)getRightContent;

@end
