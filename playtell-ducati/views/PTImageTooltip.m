//
//  PTImageTooltip.m
//  playtell-ducati
//
//  Created by Ricky Hussmann on 9/2/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTImageTooltip.h"

@interface PTImageTooltip ()
@property (nonatomic, assign) CGFloat aspectRatio;
@end

@implementation PTImageTooltip

- (id)initWithWidth:(CGFloat)toolTipWidth {
    UIImage* toolTipImage = [UIImage imageNamed:[self toolTipImageName]];
    CGFloat aspectRatio = toolTipImage.size.width / toolTipImage.size.height;
    CGFloat toolTipHeight = toolTipWidth / aspectRatio;
    
    CGRect toolTipFrame = CGRectMake(0.0f,
                                     0.0f,
                                     floorf(toolTipWidth),
                                     floorf(toolTipHeight));
    
    if (self = [super initWithFrame:toolTipFrame]) {
        self.image = toolTipImage;
        self.aspectRatio = aspectRatio;
    }
    return self;
}

- (void)addToView:(UIView*)aView withCaretAtPoint:(CGPoint)caretPoint {
    CGPoint caretRelativePosition = CGPointMake(CGRectGetWidth(self.bounds)*self.caretXFractionOfWidth,
                                                CGRectGetHeight(self.bounds)*self.caretYFractionOfHeight);
    
    CGPoint toolTipOriginInView = CGPointMake(caretPoint.x - caretRelativePosition.x,
                                              caretPoint.y - caretRelativePosition.y);
    
    CGRect curentFrame = self.frame;
    curentFrame.origin = toolTipOriginInView;
    self.frame = curentFrame;
    [aView addSubview:self];
}

- (NSString*)toolTipImageName {
    [self THROW_EXCEPTION];
    return nil;
}

- (CGFloat)caretXFractionOfWidth {
    [self THROW_EXCEPTION];
    return 0.0f;
}

- (CGFloat)caretYFractionOfHeight {
    [self THROW_EXCEPTION];
    return 0.0f;
}

- (void)THROW_EXCEPTION {
    [NSException raise:@"PTAbstractClassInstantiation"
                format:@"Trying to instantiate abstract class %@", NSStringFromClass([self class])];
}

@end
