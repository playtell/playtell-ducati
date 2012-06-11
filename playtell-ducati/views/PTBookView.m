//
//  PTBookView.m
//  PlayTell
//
//  Created by Dimitry Bentsionov on 5/17/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTBookView.h"

@implementation PTBookView

@synthesize delegate, inFocus, isOpen;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Setup all the layers
        [self initLayers];
        
        // Shown by default?
        inFocus = NO;
        
        // Setup pinch detection
        UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinched:)];
        [pinchRecognizer setDelegate:self];
        [self addGestureRecognizer:pinchRecognizer];

    }
    return self;
}

- (id)initWithFrame:(CGRect)frame andBook:(NSMutableDictionary *)bookDict {
    book = bookDict;
    return [self initWithFrame:frame];
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
    pagelet = CGSizeMake(self.bounds.size.width / 2.0f, self.bounds.size.height);
	[self.layer addSublayer:rootLayer];
    
    // Cover
    cover = [CATransformLayer layer];
    cover.anchorPoint = CGPointMake(0, 0.5);
    cover.frame = CGRectMake(pagelet.width, 0.0f, pagelet.width, pagelet.height);
    cover.zPosition = -700;
    [cover setActions:layerActions];
    
    // Cover - out
    coverOut = [CALayer layer];
    coverOut.anchorPoint = CGPointMake(0, 0.5);
    coverOut.frame = CGRectMake(0.0f, 0.0f, pagelet.width, pagelet.height);
    coverOut.backgroundColor = [[UIColor alloc] initWithRed:251.0 / 255 green:251.0 / 255 blue:251.0 / 255 alpha:1.0].CGColor;
    coverOut.zPosition = 0.1;
    [coverOut setMasksToBounds:NO];
    [coverOut setActions:layerActions];
    [coverOut setShouldRasterize:YES];
    [cover addSublayer:coverOut];

    // Cover - in
    coverIn = [CALayer layer];
    coverIn.anchorPoint = CGPointMake(0, 0.5);
    coverIn.frame = CGRectMake(0.0f, 0.0f, pagelet.width, pagelet.height);
    coverIn.backgroundColor = [[UIColor alloc] initWithRed:251.0 / 255 green:251.0 / 255 blue:251.0 / 255 alpha:1.0].CGColor;
    coverIn.zPosition = -0.1;
    [coverIn setActions:layerActions];
    [coverIn setShouldRasterize:YES];
    [cover addSublayer:coverIn];
    
    // Right
    right = [CALayer layer];
    right.anchorPoint = CGPointMake(0, 0.5);
    right.frame = CGRectMake(pagelet.width, 0, pagelet.width, pagelet.height);
    right.backgroundColor = [[UIColor alloc] initWithRed:251.0 / 255 green:251.0 / 255 blue:251.0 / 255 alpha:1.0].CGColor;
    right.zPosition = -750;
    [right setMasksToBounds:NO];
    [right setActions:layerActions];
    [right setShouldRasterize:YES];

    // Add sublayers
    [rootLayer addSublayer:cover];
    [rootLayer addSublayer:right];
    
    // Set proper positions
    [self resetLayerPosition];
}

- (void)resetLayerPosition {
    animating = NO;
    isOpen = NO;
    
    // Cover
    CATransform3D coverRotation = CATransform3DIdentity;
    coverRotation.m34 = 1.0 / -1000;
    coverRotation = CATransform3DTranslate(coverRotation, -200.0f, 0.0f, -500.0f);
    coverRotation = CATransform3DRotate(coverRotation, degreesToRadians(0.0f), 0.0f, 1.0f, 0.0f);
    cover.transform = coverRotation;

    // Right
    CATransform3D rightRotation = CATransform3DIdentity;
    rightRotation.m34 = 1.0 / -1000;
    rightRotation = CATransform3DTranslate(rightRotation, -200.0f, 0.0f, -500.0f);
    right.transform = rightRotation;
    
    // Set opacities
    coverOut.opacity = 0.6f;
    coverIn.opacity = 0.0f;
    right.opacity = 0.0f;
}

- (void)open {
    // Are we still animating?
    if (animating) {
        return;
    }
    
    // Check if first page has been reset with something else
//    if (firstPageNeedsReset) {
//        [self setPageContentsWithImage:firstPageImage];
//    }
    
    animating = YES;
    isOpen = YES;
    
    // Set opacities
    coverOut.opacity = 1.0f;
    coverIn.opacity = 1.0f;
    right.opacity = 1.0f;
    
    // Cover
    CATransform3D coverRotation = CATransform3DIdentity;
    coverRotation.m34 = 1.0 / -1000;
    coverRotation = CATransform3DTranslate(coverRotation, 0.0f, 0.0f, 0.0f);
    coverRotation = CATransform3DRotate(coverRotation, degreesToRadians(-180.0f), 0.0f, 1.0f, 0.0f);

    CABasicAnimation *coverAnim = [CABasicAnimation animationWithKeyPath:@"transform"];
    coverAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    coverAnim.fromValue = [NSValue valueWithCATransform3D:cover.transform];
    coverAnim.toValue = [NSValue valueWithCATransform3D:coverRotation];
    coverAnim.repeatCount = 0;
    coverAnim.duration = BOOK_OPEN_CLOSE_ANIMATION_SPEED;
    coverAnim.removedOnCompletion = NO;
    coverAnim.delegate = self;
    cover.transform = coverRotation;
    [cover addAnimation:coverAnim forKey:nil];
    
    // Right
    CATransform3D rightRotation = CATransform3DIdentity;
    rightRotation.m34 = 1.0 / -1000;
    rightRotation = CATransform3DTranslate(rightRotation, 0.0f, 0.0f, 0.0f);
    
    CABasicAnimation *rightAnim = [CABasicAnimation animationWithKeyPath:@"transform"];
    rightAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    rightAnim.fromValue = [NSValue valueWithCATransform3D:right.transform];
    rightAnim.toValue = [NSValue valueWithCATransform3D:rightRotation];
    rightAnim.repeatCount = 0;
    rightAnim.duration = BOOK_OPEN_CLOSE_ANIMATION_SPEED;
    rightAnim.removedOnCompletion = NO;
    right.transform = rightRotation;
    [right addAnimation:rightAnim forKey:nil];
}

- (void)close {
    // Are we still animating?
    if (animating) {
        return;
    }
    
    animating = YES;
    isOpen = NO;
    
    // Cover
    CATransform3D coverRotation = CATransform3DIdentity;
    coverRotation.m34 = 1.0 / -1000;
    coverRotation = CATransform3DTranslate(coverRotation, -200.0f, 0.0f, -300.0f);
    coverRotation = CATransform3DRotate(coverRotation, degreesToRadians(0.0f), 0.0f, 1.0f, 0.0f);
    
    CABasicAnimation *coverAnim = [CABasicAnimation animationWithKeyPath:@"transform"];
    coverAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    coverAnim.fromValue = [NSValue valueWithCATransform3D:cover.transform];
    coverAnim.toValue = [NSValue valueWithCATransform3D:coverRotation];
    coverAnim.repeatCount = 0;
    coverAnim.duration = BOOK_OPEN_CLOSE_ANIMATION_SPEED;
    coverAnim.removedOnCompletion = NO;
    coverAnim.delegate = self;
    cover.transform = coverRotation;
    [cover addAnimation:coverAnim forKey:nil];

    // Right
    CATransform3D rightRotation = CATransform3DIdentity;
    rightRotation.m34 = 1.0 / -1000;
    rightRotation = CATransform3DTranslate(rightRotation, -200.0f, 0.0f, -300.0f);
    
    CABasicAnimation *rightAnim = [CABasicAnimation animationWithKeyPath:@"transform"];
    rightAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    rightAnim.fromValue = [NSValue valueWithCATransform3D:right.transform];
    rightAnim.toValue = [NSValue valueWithCATransform3D:rightRotation];
    rightAnim.repeatCount = 0;
    rightAnim.duration = BOOK_OPEN_CLOSE_ANIMATION_SPEED;
    rightAnim.removedOnCompletion = NO;
    right.transform = rightRotation;
    [right addAnimation:rightAnim forKey:nil];
}

- (void)setFocusLevel:(CGFloat)level {
    // In focus?
    inFocus = (level == 1.0f);
    if (inFocus) {
        [delegate bookFocusedWithId:[self getId]];
    }

    // Calculate needed values
    CGFloat z = -300.0f - (200.0f * (1.0f - level));
    CGFloat opacity = 0.6f + (0.4f * level);
    
    // Whole book
    coverOut.opacity = opacity;
    
    // Cover
    CATransform3D coverRotation = CATransform3DIdentity;
    coverRotation.m34 = 1.0 / -1000;
    coverRotation = CATransform3DTranslate(coverRotation, -200.0f, 0.0f, z);
    coverRotation = CATransform3DRotate(coverRotation, degreesToRadians(0.0f), 0.0f, 1.0f, 0.0f);
    cover.transform = coverRotation;
    
    // Right
    CATransform3D rightRotation = CATransform3DIdentity;
    rightRotation.m34 = 1.0 / -1000;
    rightRotation = CATransform3DTranslate(rightRotation, -200.0f, 0.0f, z);
    right.transform = rightRotation;
    
    // Set the z-order of the book
    self.layer.zPosition = level;
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
    if (flag) {
        animating = NO;
        if (isOpen) {
            // Opened
            [delegate bookOpenedWithId:[self getId] AndView:self];
        } else {
            // Closed
            coverIn.opacity = 0.0f;
            right.opacity = 0.0f;
            [delegate bookClosedWithId:[self getId] AndView:self];
        }
    }
}

- (void)pinched:(id)sender {
	NSLog(@"Pinching, ouch!");
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    //NSLog(@"Touched me: %@", [self getId]);
    [delegate bookTouchedWithId:[self getId] AndView:self];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    // Test whether touch touched cover or not
    return [coverOut hitTest:point] != nil;
}

- (NSNumber *)getId {
    return [book objectForKey:@"id"];
}

- (void)setBookPosition:(NSInteger)position {
    bookPosition = position;
    if (bookPosition == 0) {
        [self setFocusLevel:1.0f];
    }
}

- (void)hide {
    CABasicAnimation *coverAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    coverAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    coverAnim.fromValue = [NSNumber numberWithFloat:0.6f];
    coverAnim.toValue = [NSNumber numberWithFloat:0.0f];
    coverAnim.repeatCount = 0;
    coverAnim.duration = BOOK_HIDE_SHOW_ANIMATION_SPEED;
    coverAnim.removedOnCompletion = NO;
    coverOut.opacity = 0.0f;
    [coverOut addAnimation:coverAnim forKey:nil];
}

- (void)show {
    CABasicAnimation *coverAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    coverAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    coverAnim.fromValue = [NSNumber numberWithFloat:0.0f];
    coverAnim.toValue = [NSNumber numberWithFloat:0.6f];
    coverAnim.repeatCount = 0;
    coverAnim.duration = BOOK_HIDE_SHOW_ANIMATION_SPEED;
    coverAnim.removedOnCompletion = NO;
    coverOut.opacity = 0.6f;
    [coverOut addAnimation:coverAnim forKey:nil];
}

- (NSInteger)getBookPosition {
    return bookPosition;
}

- (void)setCoverContentsWithImage:(UIImage *)image {
    coverOut.contents = (id)image.CGImage;
}

- (void)setPageContentsWithImage:(UIImage *)image {
    // Get left-side part
    CGSize size = [image size];
    CGImageRef image_quarz = CGImageCreateWithImageInRect(image.CGImage, CGRectMake(0, 0, size.width / 2, size.height));
    UIImage *leftImage = [UIImage imageWithCGImage:image_quarz];
    CGImageRelease(image_quarz);
    
    // Get right-side part
    image_quarz = CGImageCreateWithImageInRect(image.CGImage, CGRectMake(size.width / 2, 0, size.width / 2, size.height));
    UIImage *rightImage = [UIImage imageWithCGImage:image_quarz];
    CGImageRelease(image_quarz);
    
    // Set right-side contents of page
    right.contents = (id)rightImage.CGImage;
    
    // First mirror left-side contents of page
    UIGraphicsBeginImageContext(leftImage.size);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    CGAffineTransform transform = CGAffineTransformMake(-1.0, 0.0, 0.0, 1.0, leftImage.size.width, 0.0);
    CGContextConcatCTM(bitmap, transform);
    [leftImage drawInRect:CGRectMake(0, 0, leftImage.size.width, leftImage.size.height)];
    UIImage *flipped = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Set left-side contents of page
    coverIn.contents = (id)flipped.CGImage;
    
    // Save first page image
    if (firstPageImage == nil) {
        firstPageImage = image;
        firstPageNeedsReset = NO;
    }
}

- (void)setPageContentsWithLeftContent:(id)leftContent andRightContent:(id)rightContent {
    firstPageNeedsReset = YES;
    coverIn.contents = leftContent;
    right.contents = rightContent;
}

@end
