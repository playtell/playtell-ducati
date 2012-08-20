//
//  PTMemoryGameViewController.m
//  playtell-ducati
//
//  Created by Giancarlo Daniele on 8/16/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTMemoryGameViewController.h"

@implementation PTMemoryGameViewController

@synthesize card1, card2, card3, card4, card5, card6, card7, card8;

- (IBAction)turnCard:(id)sender
{
    UIButton *button = (UIButton *)sender;
//    NSString *buttonTag = [NSString stringWithFormat:@"%d", [button tag]]; //buttons are tagged with their coordinates in interface builder
        
    [UIView transitionWithView:button.imageView
                      duration:0.5f
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        button.imageView.image = [UIImage imageNamed:@"login_bg.png"];
                    }
                    completion:^(BOOL finished){
                    }];
}


@end
