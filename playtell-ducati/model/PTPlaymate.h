//
//  PTPlaymate.h
//  playtell-ducati
//
//  Created by Ricky Hussmann on 6/1/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PTPlaymate : NSObject

- (id)initWithEmail:(NSString*)email username:(NSString*)name userID:(NSUInteger)userID;
- (id)initWithDictionary:(NSDictionary*)playmateDictionary;

@property (nonatomic, readwrite) NSString* email;
@property (nonatomic, readwrite) NSString* username;
@property (nonatomic, readwrite) NSURL* photoURL;
@property (nonatomic, assign) NSUInteger userID;

@end
