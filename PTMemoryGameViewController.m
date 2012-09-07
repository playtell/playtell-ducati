//
//  PTMemoryGameViewController.m
//  playtell-ducati
//
//  Created by Giancarlo Daniele on 8/16/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTMemoryGameViewController.h"
#import "PTAppDelegate.h"pt
#import "TransitionController.h"
#import "PTPlaydate.h"

#import "UIView+Animation.h"

@implementation PTMemoryGameViewController

@synthesize closeMemory, chatController, playdate;

- (id) initWithPlaydate:(PTPlaydate *)playdateP
                   myTurn:(BOOL)myTurn
                  boardID:(int)boardID
               playmateID:(int)playmateID
              initiatorID:(int)initiatorID
{
    self.playdate = playdateP;
    [self drawNewGame];
    
    return nil;
    
}

- (void) drawNewGame
{
#if !(TARGET_IPHONE_SIMULATOR)
    [self setChatController:self.chatController];
    [self.view addSubview:self.chatController.view];
#endif
}

- (IBAction)cardTouched:(id)sender
{
    UIButton *card = (UIButton *)sender;
    [card earthquake];
}

- (void)pusherMemoryGameEndGame:(NSNotification *)notification {
    // # TODO IMPLEMENT ENDGAME ONCE API FINISHED #

    
//    NSLog(@"End game pusher call received");
//    
//    NSDictionary *eventData = notification.userInfo;
//    NSInteger initiatorId = [[eventData objectForKey:@"playmate_id"] integerValue]; //person who ended the game
//    
//    if (initiatorId != [[PTUser currentUser] userID]) { //if we weren't the ones who just placed!
//        PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
//        [appDelegate.transitionController transitionToViewController:[appDelegate dateViewController] withOptions:UIViewAnimationOptionTransitionCrossDissolve];
//    }
}

-(IBAction)endGame:(id)sender
{
    // # TODO IMPLEMENT ENDGAME ONCE API FINISHED #
    
//    NSString *boardID = [NSString stringWithFormat:@"%d", self.board_id];
//    
//    PTTictactoeEndGameRequest *endGameRequest = [[PTTictactoeEndGameRequest alloc] init];
//        
//    [endGameRequest endGameWithBoardId:boardID
//                             authToken:[[PTUser currentUser] authToken]
//                                userId:[NSString stringWithFormat:@"%d", [[PTUser currentUser] userID]]
//                            playdateId:[NSString stringWithFormat:@"%d", self.playdate.playdateID]
//                             onSuccess:^(NSDictionary *result) {
//                                 NSLog(@"End game API call success");
//                                 
//                             }
//                             onFailure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
//                                 NSLog(@"End game API call failure");
//                             }];
    
    PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.transitionController transitionToViewController:[appDelegate dateViewController] withOptions:UIViewAnimationOptionTransitionCrossDissolve];
}

// # HELPER METHODS START #

@end
