//
//  PTHangmanViewController.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 12/12/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTPlaydate.h"
#import "PTPlaymate.h"

@interface PTHangmanViewController : UIViewController {
    // Game config
    PTPlaydate *playdate;
    NSInteger boardId;
    PTPlaymate *initiator;
    PTPlaymate *playmate;
    BOOL myTurn;
}

@end