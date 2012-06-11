//
//  PTUser.m
//  playtell-ducati
//
//  Created by Ricky Hussmann on 6/1/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTUser.h"

#define PT_USERNAME_KEY @"kPTUsernameKey"
#define PT_TOKEN_KEY    @"kPTTokenKey"
#define PT_USER_ID_KEY  @"kPTUserIdKey"
#define PT_PHOTO_URL_KEY @"kPTUserPhotoURLKey"

@implementation PTUser


static PTUser* instance = nil;

+ (PTUser*)currentUser {
    if (instance == nil) {
        instance = [[PTUser alloc] init];
    }
    return instance;
}

- (BOOL)isLoggedIn {
    return (self.authToken && self.authToken.length &&
            self.username && self.username.length);
}

- (void)setUsername:(NSString*)username {
    [[NSUserDefaults standardUserDefaults] setObject:username forKey:PT_USERNAME_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString*)username {
    return [[NSUserDefaults standardUserDefaults] stringForKey:PT_USERNAME_KEY];
}

- (void)setAuthToken:(NSString*)aToken {
    [[NSUserDefaults standardUserDefaults] setObject:aToken forKey:PT_TOKEN_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString*)authToken {
    return [[NSUserDefaults standardUserDefaults] stringForKey:PT_TOKEN_KEY];
}

- (void)setUserID:(NSUInteger)aUserID {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithUnsignedInt:aUserID]
                                              forKey:PT_USER_ID_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSUInteger)userID {
    return [[NSUserDefaults standardUserDefaults] integerForKey:PT_USER_ID_KEY];
}

- (void)setPhotoURL:(NSURL *)photoURL {
    [[NSUserDefaults standardUserDefaults] setURL:photoURL forKey:PT_PHOTO_URL_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSURL*)photoURL {
    return [[NSUserDefaults standardUserDefaults] URLForKey:PT_PHOTO_URL_KEY];
}


- (NSString*)description {
    NSString* description = [super description];
    return [description stringByAppendingFormat:@", token=%@", self.authToken];
}

@end
