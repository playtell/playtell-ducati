//
//  PTMemoryViewController.m
//  playtell-ducati
//
//  Created by Giancarlo D on 9/16/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTMemoryViewController.h"
#import "PTAppDelegate.h"
#import "TransitionController.h"
#import "PTPlaydate.h"
#import "UIImageView+Animation.h"
#import "PTMemoryGameCard.h"
#import "PTMemoryGameBoard.h"

@interface PTMemoryViewController ()

@end

@implementation PTMemoryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) initializeWithPlaydate:(PTPlaydate *)playdate_id
                 myTurn:(BOOL)myTurn
                boardID:(int)boardID
             playmateID:(int)playmateID
            initiatorID:(int)initiatorID
{
    NSMutableArray *allVisualsCurrentlyOnBoard = [[NSMutableArray alloc] init];
    //initialize the memoryBoard object
    
    //place all cards on the screen
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

// ## GAMEPLAY METHODS START ##
- (IBAction)cardTouched:(id)sender
{
    //find out which card has been touched and grab it from the array of cards
    
    PTMemoryGameCard *card = (PTMemoryGameCard *)sender;
//    UIButton *card = (UIButton *)sender;

    NSString *filename = @"theme19artwork1.png";
    
//    [card.imageView flipOverWithIsBackUp:[card isBackUp] frontImage:[card front] backImage:[card back]];
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
