//
//  PTPlaydateEndViewController.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 8/14/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTPlaydateDelegate.h"

@interface PTPlaydateEndViewController : UIViewController {
    id<PTPlaydateDelegate> delegate;
}

@property (nonatomic, retain) id<PTPlaydateDelegate> delegate;
- (IBAction)endPlaydatePressed:(id)sender;

@end