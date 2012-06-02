//
//  PTUser.h
//  playtell-ducati
//
//  Created by Ricky Hussmann on 6/1/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTPlaymate.h"

@interface PTUser : PTPlaymate

+ (PTUser*)currentUser;

@property (nonatomic, readwrite) NSString* authToken;

@end
