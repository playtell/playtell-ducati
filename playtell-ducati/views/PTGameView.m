//
//  PTGameView.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 10/17/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTGameView.h"

@implementation PTGameView

@synthesize delegate;
@synthesize inFocus;

- (id)initWithFrame:(CGRect)frame gameId:(NSInteger)_gameId gameLogo:(UIImage *)_gameLogo {
    self = [super initWithFrame:frame];
    if (self) {
        gameId = _gameId;
        gameLogo = _gameLogo;

        // Setup all the layers
        [self initLayers];
        
        // Shown by default?
        inFocus = NO;
    }
    return self;
}

- (void)initLayers {
    // Define layer actions
    layerActions = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                    [NSNull null], @"onOrderIn",
                    [NSNull null], @"onOrderOut",
                    [NSNull null], @"sublayers",
                    [NSNull null], @"contents",
                    [NSNull null], @"bounds",
                    [NSNull null], @"position",
                    [NSNull null], @"hidden",
                    [NSNull null], @"transform",
                    [NSNull null], @"opacity",
                    nil];
    
 	// Root Layer
	rootLayer = [CALayer layer];
	rootLayer.frame = self.bounds;
    pagelet = CGSizeMake(self.bounds.size.width / 2.0f, 412.0f);//self.bounds.size.height); // 400x412
	[self.layer addSublayer:rootLayer];
    
    // Cover
    cover = [CALayer layer];
    cover.anchorPoint = CGPointMake(0, 0.5);
    cover.frame = CGRectMake(pagelet.width, 97.0f, pagelet.width, pagelet.height);
    cover.zPosition = -700;
    
    [cover setMasksToBounds:NO];
    [cover setShouldRasterize:YES];
    [cover setActions:layerActions];
    
    // Image
    imageLayer = [CALayer layer];
    imageLayer.frame = cover.bounds;
    imageLayer.contents = (id)gameLogo.CGImage;
    imageLayer.masksToBounds = NO;
    imageLayer.shouldRasterize = YES;
    [cover addSublayer:imageLayer];
    
    // Radial shadow
    shadowRadial = [CAShapeLayer layer];
    shadowRadial.frame = cover.bounds;
    shadowRadial.masksToBounds = NO;
    shadowRadial.shadowColor = [UIColor blackColor].CGColor;
    shadowRadial.shadowOffset = CGSizeMake(0.0f, 0.0f);
    shadowRadial.shadowOpacity = 0.5f;
    shadowRadial.shadowRadius = 6.0f;
    shadowRadial.shouldRasterize = YES;
    shadowRadial.shadowPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0.0f, shadowRadial.frame.size.height - 10, shadowRadial.frame.size.width, 50.0f)].CGPath;
    [cover insertSublayer:shadowRadial atIndex:0];
    
    // Highlight shadow
    shadowHighlight = [CAShapeLayer layer];
    shadowHighlight.frame = cover.bounds;
    shadowHighlight.masksToBounds = NO;
    shadowHighlight.shadowColor = [UIColor whiteColor].CGColor;
    shadowHighlight.shadowOffset = CGSizeMake(0.0f, -20.0f);
    shadowHighlight.shadowOpacity = 1.0f;
    shadowHighlight.shadowRadius = 10.0f;
    shadowHighlight.shouldRasterize = YES;
    shadowHighlight.shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(cover.bounds.origin.x - 20, cover.bounds.origin.y, cover.bounds.size.width + 40, cover.bounds.size.height)].CGPath;
    shadowHighlight.opacity = 0.0f;
    [cover insertSublayer:shadowHighlight above:shadowRadial];
    
    // Add sublayers
    [rootLayer addSublayer:cover];

    // Set proper positions
    [self resetLayerPosition];
}

- (void)resetLayerPosition {
    // Cover
    CATransform3D coverRotation = CATransform3DIdentity;
    coverRotation.m34 = 1.0 / -1000;
    coverRotation = CATransform3DTranslate(coverRotation, -200.0f, 0.0f, -500.0f);
    coverRotation = CATransform3DRotate(coverRotation, degreesToRadians(0.0f), 0.0f, 1.0f, 0.0f);
    cover.transform = coverRotation;
}

- (void)setFocusLevel:(CGFloat)level {
    // In focus?
    inFocus = (level == 1.0f);
    if (inFocus) {
        [delegate gameFocusedWithId:[self getId]];
    }
    
    // Calculate needed values
    CGFloat z = -300.0f - (200.0f * (1.0f - level));
    //CGFloat opacity = 0.6f + (0.4f * level);
    
    // Whole book
    //cover.opacity = opacity;
    shadowHighlight.opacity = level;
    
    // Cover
    CATransform3D coverRotation = CATransform3DIdentity;
    coverRotation.m34 = 1.0 / -1000;
    coverRotation = CATransform3DTranslate(coverRotation, -200.0f, 0.0f, z);
    coverRotation = CATransform3DRotate(coverRotation, degreesToRadians(0.0f), 0.0f, 1.0f, 0.0f);
    cover.transform = coverRotation;
    
    // Set the z-order of the book
    self.layer.zPosition = level;
}

- (NSNumber *)getId {
    return [NSNumber numberWithInteger:gameId];
}

- (void)setPosition:(NSInteger)_position {
    position = _position;
    if (position == 0) {
        [self setFocusLevel:1.0f];
    }
}

- (NSInteger)getPosition {
    return position;
}

#pragma mark - Touches methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (inFocus) {
        cover.opacity = 0.5f;
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (inFocus) {
        [self performSelector:@selector(fullOpacity) withObject:nil afterDelay:0.1f];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (inFocus) {
        [self performSelector:@selector(didEndTouch) withObject:nil afterDelay:0.1f];
        [self performSelector:@selector(fullOpacity) withObject:nil afterDelay:3.0f];
    } else {
        [delegate gameTouchedWithId:[self getId] AndView:self];
    }
}

- (void)fullOpacity {
    cover.opacity = 1.0f;
}

- (void)didEndTouch {
    [delegate gameTouchedWithId:[self getId] AndView:self];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    // Test whether touch touched cover or not
    return [cover hitTest:point] != nil;
}

@end