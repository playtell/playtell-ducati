//
//  PTHangmanLetterView.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 12/17/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTHangmanDelegate.h"

@interface PTHangmanLetterView : UIView {
    UILabel *lblLetter;
    id<PTHangmanDelegate> delegate;
}

@property (nonatomic, retain) NSString *letter;
@property (nonatomic, retain) id<PTHangmanDelegate> delegate;

- (id)initWithFrame:(CGRect)frame letter:(NSString*)letter;

@end