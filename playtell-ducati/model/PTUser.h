//
//  PTUser.h
//  playtell-ducati
//
//  Created by Ricky Hussmann on 6/1/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTPlaymate.h"

@interface PTUser : PTPlaymate

+ (PTUser*)currentUser;

- (BOOL)isLoggedIn;
- (void)resetUser;

@property (nonatomic, readwrite) NSString* authToken;

@end
