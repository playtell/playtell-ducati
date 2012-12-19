//
//  PTHangmanDelegate.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 12/17/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PTHangmanLetterView;
@protocol PTHangmanDelegate <NSObject>

@optional
- (void)letterViewDidPress:(PTHangmanLetterView*)letterView letter:(NSString*)letter;

@end