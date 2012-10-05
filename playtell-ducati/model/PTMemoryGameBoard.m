//
//  PTMemoryGameBoard.m
//  playtell-ducati
//
//  Created by Giancarlo Daniele on 8/24/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//


#import "PTMemoryGameBoard.h"
#import "PTMemoryGameCard.h"
#import "PTMemoryViewController.h"
#import "PTMemoryPlayTurnRequest.h"
#import "PTAppDelegate.h"
#import "PTUser.h"

@implementation PTMemoryGameBoard

NSString *backFilename = @"card-back.png";

@synthesize initiator_id, playmate_id, playdate_id, totalNumCards, cardsLeftOnBoard, cardsOnBoard, isMyTurn, isOneCardAlreadyFlipped, board_id;

- (id)initMemoryGameBoardWithNumCards:(int)numCards
                               isMyTurn:(BOOL)myTurn
                               playdate:(int)playdateId
                              initiator:(int)initiatorId
                               playmate:(int)playmateId
                              boardId:(int)boardId
                               filenameDict:(NSArray *)allFilenames
{
    //set instance vars
    [self setTotalNumCards:numCards];
    [self setPlaydate_id:playdateId];
    [self setInitiator_id:initiatorId];
    [self setPlaydate_id:playdateId];
    [self setIsMyTurn:myTurn];
    [self setIsOneCardAlreadyFlipped:NO];
    [self setCardsLeftOnBoard:numCards];
    [self setBoard_id:boardId];

    [self setCardsOnBoard:[self initializeCardsOnBoard:allFilenames]];

    return self;
}

- (NSMutableArray *)initializeCardsOnBoard:(NSArray *)filenames
{
    NSMutableArray *allCards = [[NSMutableArray alloc] init];
    int count = [filenames count];
    for (int i = 0; i < count; i++) {
        PTMemoryGameCard *card = [[PTMemoryGameCard alloc] initWithFrontFilename:[filenames objectAtIndex:i] backFilename:backFilename indexOnBoard:i numberOfCards:[self totalNumCards]];
        [allCards addObject:card];
    }
    return allCards;
}
     
- (void)cardMatch:(int)card1Index
            card2:(int)card2Index

{
}

- (void) playTurn:(PTMemoryGameCard *)card
{
    PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
    PTMemoryViewController *memoryVC = appDelegate.memoryViewController;
    NSString *userId = [NSString stringWithFormat:@"%d", [[PTUser currentUser] userID]];;
    
    //check if already one card selected
    if ([self isOneCardAlreadyFlipped]) {
        
    }
    else {
        NSString *boardID = [NSString stringWithFormat:@"%d", self.board_id];
        
        PTMemoryPlayTurnRequest *playturnRequest = [[PTMemoryPlayTurnRequest alloc] init];
        NSLog(@"Auth token is :%@", [[PTUser currentUser] authToken]);
        NSLog(@"user_id is :%@", userId);
        NSLog(@"board_id is :%@",boardID);
        NSLog(@"playdate_id is :%@",[NSString stringWithFormat:@"%d", memoryVC.playdate.playdateID]);
        [playturnRequest placePieceWithCoordinates:@"nil" authToken:[[PTUser currentUser] authToken] user_id:userId board_id:boardID playdate_id:[NSString stringWithFormat:@"%d", memoryVC.playdate.playdateID] card1_index:[NSString stringWithFormat:@"%d",card.boardIndex] card2_index:@"-1"
         
                                         onSuccess:^(NSDictionary *result) {
            ///okay
            
            
            [self setIsOneCardAlreadyFlipped:YES];
//            [self setFlippedCardIndex:card.boardIndex]
        } onFailure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
            //okay
        }];
    }
}


//         placePieceWithCoordinates:coordinate.coordinateString
//                                           authToken:[[PTUser currentUser] authToken]
//                                             user_id:userID
//                                            board_id:boardID
//                                         playdate_id:[NSString stringWithFormat:@"%d", self.playdate.playdateID]
//                                           with_json:@"false"
//                                           onSuccess:^(NSDictionary *result) {
//                                               NSNumber *pStatus = [result valueForKey:@"placement_code"];
//                                               int placement_status = [pStatus intValue];
//                                               
//                                               int win_code = YOU_DID_NOT_WIN_YET;
//                                               
//                                               if (placement_status == PLACED_WON) {
//                                                   NSNumber *winCode = [result valueForKey:@"win_code"];
//                                                   win_code = [winCode intValue];
//                                               }
//                                               NSLog(@"%@", result);
//                                               
//                                               
//                                               [memoryVC upda:placement_status coordinates:coordinate winStatus:win_code isCurrentUser:YES];
//                                           }
//                                           onFailure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
//                                               NSLog(@"Can't place piece. API returned error");
//                                               [self beginSound:(id)[NSNumber numberWithInt:MISS_SOUND]];
//                                               
//                                               NSLog(@"%@", error);
//                                               NSLog(@"%@", request);
//                                               NSLog(@"%@", JSON);                                           
//                                           }];

@end