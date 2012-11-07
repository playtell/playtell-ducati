//
//  PTPageView.m
//  PlayTell
//
//  Created by Dimitry Bentsionov on 5/23/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTPageView.h"

@implementation PTPageView

@synthesize delegate, hasContent;

- (id)initWithFrame:(CGRect)frame book:(NSMutableDictionary *)bookData pageNumber:(NSInteger)number {
    self = [super initWithFrame:frame];
    if (self) {
        [self initLayers];
        book = bookData;
        pageNumber = number;
        self.layer.zPosition = currentPage - (pageNumber - 1);
        hasContent = NO;
        
        // Enable pinching (to close the book)
        UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinched:)];
        [pinchRecognizer setDelegate:self];
        [self addGestureRecognizer:pinchRecognizer];
        
        // Enable long press (grandma finger concept)
        UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTouched:)];
        longPressRecognizer.minimumPressDuration = 0.1f; // Default is 0.5 sec. Too long!
        [longPressRecognizer setDelegate:self];
        [self addGestureRecognizer:longPressRecognizer];
        
        // Enable normal press (page navigation)
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        [tapRecognizer setDelegate:self];
        [self addGestureRecognizer:tapRecognizer];
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
    pagelet = CGSizeMake(self.bounds.size.width / 2.0f, self.bounds.size.height);
	[self.layer addSublayer:rootLayer];
    
    // Left
    left = [CATransformLayer layer];
    left.anchorPoint = CGPointMake(0, 0.5);
    left.frame = CGRectMake(pagelet.width, 0.0f, pagelet.width, pagelet.height);
    left.zPosition = 0;
    [left setActions:layerActions];

    // Left - front
    left_front = [CALayer layer];
    left_front.anchorPoint = CGPointMake(0, 0.5);
    left_front.frame = CGRectMake(0.0f, 0.0f, pagelet.width, pagelet.height);
    left_front.backgroundColor = [[UIColor alloc] initWithRed:251.0 / 255 green:251.0 / 255 blue:251.0 / 255 alpha:1.0].CGColor;
    left_front.zPosition = 0.1;
    [left_front setActions:layerActions];
    [left_front setShouldRasterize:YES];
    [left addSublayer:left_front];
    
    // Left - back
    left_back = [CALayer layer];
    left_back.anchorPoint = CGPointMake(0, 0.5);
    left_back.frame = CGRectMake(0.0f, 0.0f, pagelet.width, pagelet.height);
    left_back.backgroundColor = [[UIColor alloc] initWithRed:251.0 / 255 green:251.0 / 255 blue:251.0 / 255 alpha:1.0].CGColor;
    left_back.zPosition = -0.1;
    [left_back setMasksToBounds:NO];
    [left_back setActions:layerActions];
    [left_back setShouldRasterize:YES];
    [left addSublayer:left_back];
    
    // Right
    right = [CALayer layer];
    right.anchorPoint = CGPointMake(0, 0.5);
    right.frame = CGRectMake(pagelet.width, 0, pagelet.width, pagelet.height);
    right.backgroundColor = [[UIColor alloc] initWithRed:251.0 / 255 green:251.0 / 255 blue:251.0 / 255 alpha:1.0].CGColor;
    right.zPosition = -50;
    [right setMasksToBounds:NO];
    [right setActions:layerActions];
    [right setShouldRasterize:YES];
    
    // Add sublayers
    [rootLayer addSublayer:left];
    [rootLayer addSublayer:right];
    
    // Set initial 'loading' view
    UIImage *loadingImage = [UIImage imageNamed:@"page_loading.png"];
    [self setPageContentsWithImage:loadingImage];
}

- (void)open {
    // Left
    CATransform3D leftRotation = CATransform3DIdentity;
    leftRotation.m34 = 1.0 / -1000;
    leftRotation = CATransform3DTranslate(leftRotation, 0.0f, 0.0f, 0.0f);
    leftRotation = CATransform3DRotate(leftRotation, degreesToRadians(180.0f), 0.0f, 1.0f, 0.0f);
    left.transform = leftRotation;
    
    // Right
    CATransform3D rightRotation = CATransform3DIdentity;
    rightRotation.m34 = 1.0 / -1000;
    rightRotation = CATransform3DTranslate(rightRotation, 0.0f, 0.0f, 0.0f);
    right.transform = rightRotation;
}

- (void)setCurrentPage:(CGFloat)page andForceOpen:(BOOL)forceOpen {
    currentPage = page;
    
    // Hide the pages out of view for efficiency
    BOOL hidePage = ABS(pageNumber - currentPage) > 4.0f;
    [self setHidden:hidePage];
    if (hidePage) {
        return;
    }
    
    // Move each page depending on how deep it is
    CGFloat diff = pageNumber - currentPage;
    if (ABS(diff) <= 1.0f) {
        [self moveToPosition1stDegree:diff];
    } else if (ABS(diff) <= 2.0f) {
        [self moveToPosition2ndDegree:(diff)];
    } else if (ABS(diff) <= 3.0f) {
        [self moveToPosition3rdDegree:(diff)];
    } else if (ABS(diff) <= 4.0f) {
        [self moveToPosition4thDegree:(diff)];
    }
    
    // Set the z-order of visible page
    if (roundf(currentPage) == pageNumber) {
        self.layer.zPosition = 0.0f;
    } else {
        if (diff < 0.0f) {
            self.layer.zPosition = (pageNumber - 1) - currentPage;
        } else if (diff > 0.0f) {
            self.layer.zPosition = currentPage - pageNumber;
        }
    }
    
    // Force open the page?
    if (forceOpen && roundf(currentPage) == pageNumber) {
        [self open];
    }
}

- (void)moveToPosition1stDegree:(CGFloat)pos {
    CGFloat x_default = 40.0f;
    CGFloat z_default = -50.0f;
    CGFloat x = x_default * pos;
    CGFloat z = z_default * ABS(pos);
    CGPoint point = CGPointMake(x, z);
    CGFloat offset_degree = radiansToDegrees(atanf(ABS(z_default) / (pagelet.width - x_default)));
    CGFloat offset_size = pagelet.width - sqrtf(powf(pagelet.width - x_default, 2.0f) + powf(z_default, 2.0f));

    if (pos <= 0.0f) { // Left side
        CGFloat degree_right = MIN(0.0f, 180.0f * pos - offset_degree * pos);
        
        // Left
        if (pos == 0.0f) {
            left.opacity = 1.0f;
        }
        left.frame = CGRectMake(pagelet.width, 0.0f, pagelet.width, pagelet.height); // Reset width. Fix for fast page scrolls.
        left_front.frame = CGRectMake(0.0f, 0.0f, pagelet.width, pagelet.height); // Reset width. Fix for fast page scrolls.
        left_back.frame = CGRectMake(0.0f, 0.0f, pagelet.width, pagelet.height); // Reset width. Fix for fast page scrolls.

        CATransform3D leftRotation = CATransform3DIdentity;
        leftRotation.m34 = 1.0 / -1000;
        leftRotation = CATransform3DTranslate(leftRotation, x, 0.0f, z);
        leftRotation = CATransform3DRotate(leftRotation, degreesToRadians(180.0f), 0.0f, 1.0f, 0.0f);
        left.transform = leftRotation;
        
        // Right
        right.opacity = 1.0f;
        
        CGFloat width_right = pagelet.width - offset_size * ABS(pos);
        right.frame = CGRectMake(pagelet.width, 0.0f, width_right, pagelet.height);

        CATransform3D rightRotation = CATransform3DIdentity;
        rightRotation.m34 = 1.0 / -1000;
        rightRotation = CATransform3DTranslate(rightRotation, x, 0.0f, z);
        rightRotation = CATransform3DRotate(rightRotation, degreesToRadians(degree_right), 0.0f, 1.0f, 0.0f);
        right.transform = rightRotation;
    } else if (pos > 0.0f) { // Right side
        // Left
        left.opacity = 1.0f;
        
        CGFloat prevPos = pos - 1.0f;
        CGFloat prevWidth = pagelet.width - offset_size * ABS(prevPos);
        CGFloat prevX = x_default * prevPos;
        CGFloat prevZ = z_default * ABS(prevPos);
        CGFloat prevDegree = ABS(MIN(0.0f, 180.0f * prevPos - offset_degree * prevPos));
        CGPoint prevPointEnd = CGPointMake(cosf(degreesToRadians(prevDegree)) * prevWidth + prevX, sinf(degreesToRadians(prevDegree)) * prevWidth + prevZ);
        CGFloat width_left = sqrtf(powf(prevPointEnd.x - point.x, 2.0f) + powf(prevPointEnd.y - point.y, 2.0f));
        CGFloat adjacent_side = ABS(prevPointEnd.y) + ABS(point.y);
        
        CGFloat degree_left = -90.0f;
        if (prevPointEnd.x > point.x) {
            degree_left = radiansToDegrees(asinf(adjacent_side / width_left)) * -1.0f;
        } else {
            degree_left += radiansToDegrees(acosf(adjacent_side / width_left)) * -1.0f;
        }

        left.frame = CGRectMake(pagelet.width, 0.0f, width_left, pagelet.height);
        left_front.frame = CGRectMake(0.0f, 0.0f, width_left, pagelet.height);
        left_back.frame = CGRectMake(0.0f, 0.0f, width_left, pagelet.height);

        CATransform3D leftRotation = CATransform3DIdentity;
        leftRotation.m34 = 1.0 / -1000;
        leftRotation = CATransform3DTranslate(leftRotation, x, 0.0f, z);
        leftRotation = CATransform3DRotate(leftRotation, degreesToRadians(degree_left), 0.0f, 1.0f, 0.0f);
        left.transform = leftRotation;
        
        // Right
        right.frame = CGRectMake(pagelet.width, 0.0f, pagelet.width, pagelet.height); // Reset width. Fix for fast page scrolls.

        CATransform3D rightRotation = CATransform3DIdentity;
        rightRotation.m34 = 1.0 / -1000;
        rightRotation = CATransform3DTranslate(rightRotation, x, 0.0f, z);
        rightRotation = CATransform3DRotate(rightRotation, degreesToRadians(0.0f), 0.0f, 1.0f, 0.0f);
        right.transform = rightRotation;
    }
}

- (void)moveToPosition2ndDegree:(CGFloat)pos {
    if (pos < 0.0f) { // Left side
        pos = pos + 1.0f;
        CGFloat x = -40.0f + 38.0f * pos; // 40 - 78
        CGFloat z = -50.0f + 40.0f * pos; // 50 - 90

        // Left
        if (pos == 0.0f) {
            left.opacity = 1.0f;
        }

        CATransform3D leftRotation = CATransform3DIdentity;
        leftRotation.m34 = 1.0 / -1000;
        leftRotation = CATransform3DTranslate(leftRotation, x, 0.0f, z);
        leftRotation = CATransform3DRotate(leftRotation, degreesToRadians(180.0f), 0.0f, 1.0f, 0.0f);
        left.transform = leftRotation;
        
        // Right
        right.opacity = 0.0f;

        CATransform3D rightRotation = CATransform3DIdentity;
        rightRotation.m34 = 1.0 / -1000;
        rightRotation = CATransform3DTranslate(rightRotation, x, 0.0f, z);
        rightRotation = CATransform3DRotate(rightRotation, degreesToRadians(0.0f), 0.0f, 1.0f, 0.0f);
        right.transform = rightRotation;
    } else if (pos > 0.0f) { // Right side
        pos = pos - 1.0f;
        CGFloat x = 40.0f + 38.0f * pos; // 40 - 78
        CGFloat z = -50.0f - 40.0f * pos; // 50 - 90

        // Left
        left.opacity = 0.0f;
        
        CATransform3D leftRotation = CATransform3DIdentity;
        leftRotation.m34 = 1.0 / -1000;
        leftRotation = CATransform3DTranslate(leftRotation, x, 0.0f, z);
        leftRotation = CATransform3DRotate(leftRotation, degreesToRadians(0.0f), 0.0f, 1.0f, 0.0f);
        left.transform = leftRotation;
        
        // Right
        if (pos == 0.0f) {
            right.opacity = 1.0f;
        }
        
        CATransform3D rightRotation = CATransform3DIdentity;
        rightRotation.m34 = 1.0 / -1000;
        rightRotation = CATransform3DTranslate(rightRotation, x, 0.0f, z);
        rightRotation = CATransform3DRotate(rightRotation, degreesToRadians(0.0f), 0.0f, 1.0f, 0.0f);
        right.transform = rightRotation;
    }
}

- (void)moveToPosition3rdDegree:(CGFloat)pos {
    if (pos < 0.0f) { // Left side
        pos = pos + 2.0f;
        CGFloat x = -78.0f + 38.0f * pos; // 78 - 116
        CGFloat z = -90.0f + 40.0f * pos; // 90 - 130
        
        // Left
        left.opacity = 1.0f;

        CATransform3D leftRotation = CATransform3DIdentity;
        leftRotation.m34 = 1.0 / -1000;
        leftRotation = CATransform3DTranslate(leftRotation, x, 0.0f, z);
        leftRotation = CATransform3DRotate(leftRotation, degreesToRadians(180.0f), 0.0f, 1.0f, 0.0f);
        left.transform = leftRotation;
        
        // Right
        right.opacity = 0.0f;
        
        CATransform3D rightRotation = CATransform3DIdentity;
        rightRotation.m34 = 1.0 / -1000;
        rightRotation = CATransform3DTranslate(rightRotation, x, 0.0f, z);
        rightRotation = CATransform3DRotate(rightRotation, degreesToRadians(0.0f), 0.0f, 1.0f, 0.0f);
        right.transform = rightRotation;
    } else if (pos > 0.0f) { // Right side
        pos = pos - 2.0f;
        CGFloat x = 78.0f + 38.0f * pos; // 78 - 116
        CGFloat z = -90.0f - 40.0f * pos; // 90 - 130
        
        // Left
        left.opacity = 0.0f;
        
        CATransform3D leftRotation = CATransform3DIdentity;
        leftRotation.m34 = 1.0 / -1000;
        leftRotation = CATransform3DTranslate(leftRotation, x, 0.0f, z);
        leftRotation = CATransform3DRotate(leftRotation, degreesToRadians(0.0f), 0.0f, 1.0f, 0.0f);
        left.transform = leftRotation;
        
        // Right
        right.opacity = 1.0f;

        CATransform3D rightRotation = CATransform3DIdentity;
        rightRotation.m34 = 1.0 / -1000;
        rightRotation = CATransform3DTranslate(rightRotation, x, 0.0f, z);
        rightRotation = CATransform3DRotate(rightRotation, degreesToRadians(0.0f), 0.0f, 1.0f, 0.0f);
        right.transform = rightRotation;
    }
}

- (void)moveToPosition4thDegree:(CGFloat)pos {
    if (pos < 0.0f) { // Left side
        pos = pos + 3.0f;
        CGFloat x = -116.0f + 38.0f * pos; // 78 - 116
        CGFloat z = -130.0f + 40.0f * pos; // 90 - 130
        
        // Left
        left.opacity = 1.0f * (1.0f - ABS(pos));

        CATransform3D leftRotation = CATransform3DIdentity;
        leftRotation.m34 = 1.0 / -1000;
        leftRotation = CATransform3DTranslate(leftRotation, x, 0.0f, z);
        leftRotation = CATransform3DRotate(leftRotation, degreesToRadians(180.0f), 0.0f, 1.0f, 0.0f);
        left.transform = leftRotation;
        
        // Right
        right.opacity = 0.0f;
        
        CATransform3D rightRotation = CATransform3DIdentity;
        rightRotation.m34 = 1.0 / -1000;
        rightRotation = CATransform3DTranslate(rightRotation, x, 0.0f, z);
        rightRotation = CATransform3DRotate(rightRotation, degreesToRadians(0.0f), 0.0f, 1.0f, 0.0f);
        right.transform = rightRotation;
    } else if (pos > 0.0f) { // Right side
        pos = pos - 3.0f;
        CGFloat x = 116.0f + 38.0f * pos; // 78 - 116
        CGFloat z = -130.0f - 40.0f * pos; // 90 - 130
        
        // Left
        left.opacity = 0.0f;
        
        CATransform3D leftRotation = CATransform3DIdentity;
        leftRotation.m34 = 1.0 / -1000;
        leftRotation = CATransform3DTranslate(leftRotation, x, 0.0f, z);
        leftRotation = CATransform3DRotate(leftRotation, degreesToRadians(0.0f), 0.0f, 1.0f, 0.0f);
        left.transform = leftRotation;
        
        // Right
        right.opacity = 1.0f * (1.0f - pos);

        CATransform3D rightRotation = CATransform3DIdentity;
        rightRotation.m34 = 1.0 / -1000;
        rightRotation = CATransform3DTranslate(rightRotation, x, 0.0f, z);
        rightRotation = CATransform3DRotate(rightRotation, degreesToRadians(0.0f), 0.0f, 1.0f, 0.0f);
        right.transform = rightRotation;
    }
}

- (void)setPageContentsWithImage:(UIImage *)image {
    hasContent = YES;

    // Get left-side part
    CGSize size = [image size];
    CGImageRef image_quarz = CGImageCreateWithImageInRect(image.CGImage, CGRectMake(0, 0, size.width / 2, size.height));
    UIImage *leftImage = [UIImage imageWithCGImage:image_quarz];
    CGImageRelease(image_quarz);
    
    // Get right-side part
    image_quarz = CGImageCreateWithImageInRect(image.CGImage, CGRectMake(size.width / 2, 0, size.width / 2, size.height));
    UIImage *rightImage = [UIImage imageWithCGImage:image_quarz];
    CGImageRelease(image_quarz);
    
    // First add black outline to right-side
    UIGraphicsBeginImageContext(rightImage.size);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    [rightImage drawInRect:CGRectMake(0, 0, rightImage.size.width, rightImage.size.height)];
    
    CGContextSetStrokeColorWithColor(bitmap, [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.1f].CGColor);
    CGContextSetLineWidth(bitmap, 1.0);
    CGContextMoveToPoint(bitmap, 0.0f, 0.0);
    CGContextAddLineToPoint(bitmap, size.width / 2, 0.0f);
    CGContextAddLineToPoint(bitmap, size.width / 2, size.height);
    CGContextAddLineToPoint(bitmap, 0.0f, size.height);
    CGContextStrokePath(bitmap);
    
    rightImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Set right-side contents of page
    right.contents = (id)rightImage.CGImage;
    
    // First mirror left-side contents of page + add black outline
    UIGraphicsBeginImageContext(leftImage.size);
    bitmap = UIGraphicsGetCurrentContext();
    CGAffineTransform transform = CGAffineTransformMake(-1.0, 0.0, 0.0, 1.0, leftImage.size.width, 0.0);
    CGContextConcatCTM(bitmap, transform);
    [leftImage drawInRect:CGRectMake(0, 0, leftImage.size.width, leftImage.size.height)];
    
    CGContextSetStrokeColorWithColor(bitmap, [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.1f].CGColor);
    CGContextSetLineWidth(bitmap, 1.0);
    CGContextMoveToPoint(bitmap, size.width / 2, 0.0);
    CGContextAddLineToPoint(bitmap, 0.0f, 0.0f);
    CGContextAddLineToPoint(bitmap, 0.0f, size.height);
    CGContextAddLineToPoint(bitmap, size.width / 2, size.height);
    CGContextStrokePath(bitmap);
    
    UIImage *flipped = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Set left-side contents of page
    left_back.contents = (id)flipped.CGImage;
}

- (id)getLeftContent {
    return left_back.contents;
}

- (id)getRightContent {
    return right.contents;
}

- (void)pinched:(id)sender {
    UIPinchGestureRecognizer *pinchRecognizer = (UIPinchGestureRecognizer *)sender;
    if (pinchRecognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat factor = [pinchRecognizer scale];
        if (factor <= 0.6f) {
            [delegate bookPinchClose];
        }
    }
}

- (void)longTouched:(id)sender {
    UILongPressGestureRecognizer *longPressRecognizer = (UILongPressGestureRecognizer *)sender;
    if (longPressRecognizer.state == UIGestureRecognizerStateBegan) {
        fingerPoint = [longPressRecognizer locationInView:longPressRecognizer.view];
        [delegate fingerTouchStartedAtPoint:fingerPoint];
    } else if (longPressRecognizer.state == UIGestureRecognizerStateEnded) {
        [delegate fingerTouchEndedAtPoint:fingerPoint];
    }
}

- (void)tapped:(id)sender {
    UITapGestureRecognizer *tapRecognizer = (UITapGestureRecognizer *)sender;
    CGPoint point = [tapRecognizer locationInView:self];
    
    // Navigation to previous page or next page?
    if (point.x <= pagelet.width) {
        // Go to previous page
        [delegate pageShouldGoDown];
    } else {
        // Go to next page
        [delegate pageShouldGoUp];
    }
}

- (void)loadPage {
    NSString *imagePath = [self imagePathForBook];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    if (image) {
        // Send the image to page
        [self setPageContentsWithImage:image];

        // Notify delegate of page load
        [delegate pageLoaded:pageNumber];
    } else {
        NSMutableArray *pages = [book objectForKey:@"pages"];
        NSDictionary *page = [pages objectAtIndex:(pageNumber - 1)];
        NSString *page_bitmap_url = [page objectForKey:@"bitmap"];
        
        // Load from URL (using the background thread)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^() {
            NSURL *url = [NSURL URLWithString:page_bitmap_url];
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
            if (image == nil) {
                // TODO: Page not loaded right
            }
            
            // Cache image locally
            NSData *imageData = UIImageJPEGRepresentation(image, 1.0f);
            [imageData writeToFile:imagePath atomically:YES];
            
            // Make sure this file isn't backed up by iCloud
            [self addSkipBackupAttributeToItemAtURLstring:imagePath];
            
            // Apply to the book (in main thread)
            dispatch_async(dispatch_get_main_queue(), ^() {
                // Send the image to page
                [self setPageContentsWithImage:image];
                
                // Notify delegate of page load
                [delegate pageLoaded:pageNumber];
            });
        });
    }
}

- (NSString *)imagePathForBook {
    NSNumber *bookId = [book objectForKey:@"id"];
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    return [[[documentDirectory stringByAppendingPathComponent:@"Books"] stringByAppendingPathComponent:[bookId stringValue]] stringByAppendingPathComponent:[NSString stringWithFormat:@"page%i.jpg", pageNumber]];
}

- (BOOL)addSkipBackupAttributeToItemAtURLstring:(NSString *)URLstring {
    NSURL *URL = [[NSURL alloc] initFileURLWithPath:URLstring];
    assert([[NSFileManager defaultManager] fileExistsAtPath:[URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool:YES]
                                  forKey: NSURLIsExcludedFromBackupKey error:&error];
    if (!success) {
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

@end