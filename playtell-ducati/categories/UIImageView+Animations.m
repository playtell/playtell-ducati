//
//  UIImageView+Animations.m
//  playtell-ducati
//
//  Created by Giancarlo D on 9/28/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "UIImageView+Animations.h"

@implementation UIImageView (Animations)

- (void)earthquake {
    CGFloat t = 2.0;
    
    CGAffineTransform leftQuake  = CGAffineTransformTranslate(CGAffineTransformIdentity, t, 0);
    CGAffineTransform rightQuake = CGAffineTransformTranslate(CGAffineTransformIdentity, -t, 0);
    
    self.transform = leftQuake;  // starting point
    
    [UIView beginAnimations:@"earthquake" context:(__bridge void *)(self)];
    [UIView setAnimationRepeatAutoreverses:YES]; // important
    [UIView setAnimationRepeatCount:5];
    [UIView setAnimationDuration:0.07];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(earthquakeEnded:finished:context:)];
    
    self.transform = rightQuake; // end here & auto-reverse
    
    [UIView commitAnimations];
}

- (void)earthquakeEnded:(NSString *)animationID
               finished:(NSNumber *)finished
                context:(void *)context {
    if ([finished boolValue])
    {
        UIView* item = (__bridge UIView *)context;
        item.transform = CGAffineTransformIdentity;
    }
}

- (void)flipOverWithIsBackUp:(BOOL)backUp
                  frontImage:(UIImage *)front
                   backImage:(UIImage *)back
{
    UIImage *otherSideImage;
    otherSideImage = (backUp) ? front : back;
    
    [UIView transitionWithView:self
                      duration:0.5f
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        self.image = otherSideImage;
                    }
                    completion:^(BOOL finished){
                        self.image = otherSideImage;
                    }];
}

- (void) flip
{
}

- (void) enlarge
{
    
}

- (void) floatToMiddle
{
    
} //preceeds stashInDeck

- (void) stashInDeck:(int)player_id
{
    
}

- (void) shake
{
    
}

- (void) glow
{
    
}

@end
