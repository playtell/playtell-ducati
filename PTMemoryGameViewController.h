//
//  PTMemoryGameViewController.h
//  playtell-ducati
//
//  Created by Giancarlo Daniele on 8/16/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PTMemoryGameViewController : UIViewController
{

}

@property (nonatomic, retain) IBOutlet UIButton *card1, *card2, *card3, *card4, *card5, *card6, *card7, *card8;

- (IBAction)turnCard:(id)sender;


@end
