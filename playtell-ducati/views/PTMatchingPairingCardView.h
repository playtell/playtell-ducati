//
//  PTMatchingPairingCardView.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 10/26/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PTMatchingPairingCardView : UIView {
    NSInteger cardIndex;
}

- (id)initWithFrame:(CGRect)frame cardIndex:(NSInteger)_cardIndex;
- (void)setFocusLevel:(CGFloat)focus;

@end