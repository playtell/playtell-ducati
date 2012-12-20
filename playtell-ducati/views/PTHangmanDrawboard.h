//
//  PTHangmanDrawboard.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 12/19/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTHangmanDelegate.h"

@interface PTHangmanDrawboard : UIView {
    BOOL isDrawing;
    UIBezierPath *path;
    UIImage *incrementalImage;
    id<PTHangmanDelegate> delegate;
    BOOL emptyPath;
}

@property (nonatomic) BOOL isDrawing;
@property (nonatomic, retain) id<PTHangmanDelegate> delegate;

- (void)addPointToBoard:(CGPoint)point;

@end