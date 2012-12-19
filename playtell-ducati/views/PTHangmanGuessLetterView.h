//
//  PTHangmanGuessLetterView.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 12/18/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTHangmanDelegate.h"

@interface PTHangmanGuessLetterView : UIView {
    UILabel *lblLetter;
    UIView *coverView;
    id<PTHangmanDelegate> delegate;
}

@property (nonatomic, retain) NSString *letter;
@property (nonatomic, retain) id<PTHangmanDelegate> delegate;

@end