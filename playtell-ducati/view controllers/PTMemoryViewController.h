//
//  PTMemoryViewController.h
//  playtell-ducati
//
//  Created by Giancarlo D on 9/16/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTChatViewController.h"
#import "PTPlaydate.h"


@interface PTMemoryViewController : UIViewController {
    IBOutlet UIButton *closeMemory, *card0, *card1, *card2, *card3;
}

// Board stuff
@property (nonatomic, retain) IBOutlet UIButton *card0, *card1, *card2, *card3, *closeMemory;

// Chat view controller
@property (nonatomic, strong) PTChatViewController* chatController;

//playdate specific
@property (nonatomic) PTPlaydate *playdate;

- (id) initWithPlaydate:(PTPlaydate *)playdateP
                 myTurn:(BOOL)myTurn
                boardID:(int)boardID
             playmateID:(int)playmateID
            initiatorID:(int)initiatorID;

@end
