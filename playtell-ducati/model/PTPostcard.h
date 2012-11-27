//
//  PTPostcard.h
//  playtell-ducati
//
//  Created by Adam Horne on 11/27/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PTPostcard : NSObject

@property (nonatomic, strong) NSURL *photoURL;
@property (nonatomic, strong) NSString *sender;
@property (nonatomic, strong) NSDate *timestamp;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
