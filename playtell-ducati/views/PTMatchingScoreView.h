//
//  PTMatchingScoreView.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 10/31/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PTMatchingScoreView : UIView {
    BOOL isMyScore;
    UIImageView *bgView;
    UILabel *lblScore;
    NSInteger score;
}

- (void)setScore:(NSInteger)score;
- (id)initWithFrame:(CGRect)frame myScore:(BOOL)myScore;

@end