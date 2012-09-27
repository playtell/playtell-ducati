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
#import "UIView+Animation.h"
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
    //card should be a card object!!!
//    PTMemoryGameCard *card = (PTMemoryGameCard *)sender;
    UIButton *card = (UIButton *)sender;

    NSString *filename = @"theme19artwork1.png"; //card.filename;
    [card enlarge];
}

- (void) drawNewGame
{
#if !(TARGET_IPHONE_SIMULATOR)
    [self setChatController:self.chatController];
    [self.view addSubview:self.chatController.view];
#endif
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
