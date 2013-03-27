//
//  PTHangmanLetterView.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 12/17/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTHangmanDelegate.h"

typedef enum {
    PTHangmanLetterTypeAvailable    = 1,
    PTHangmanLetterTypeGuessedRight = 2,
    PTHangmanLetterTypeGuessedWrong = 3
} PTHangmanLetterType;

@interface PTHangmanLetterView : UIView {
    UILabel *lblLetter;
    PTHangmanLetterType _type;
    id<PTHangmanDelegate> delegate;
}

@property (nonatomic, retain) NSString *letter;
@property (nonatomic, retain) id<PTHangmanDelegate> delegate;
@property (nonatomic) PTHangmanLetterType type;

- (id)initWithFrame:(CGRect)frame letter:(NSString*)letter;

@end