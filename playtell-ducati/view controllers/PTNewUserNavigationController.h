//
//  PTNewUserNavigationController.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 9/11/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTNewUser.h"

@interface PTNewUserNavigationController : UINavigationController {
    PTNewUser *currentUser;
}

@property (nonatomic, strong) PTNewUser *currentUser;

- (id)initWithDefaultViewController;

@end