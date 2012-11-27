//
//  PTPostcard.m
//  playtell-ducati
//
//  Created by Adam Horne on 11/27/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTPostcard.h"

@implementation PTPostcard

@synthesize photoURL;
@synthesize sender;
@synthesize timestamp;

- (id)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        self.sender = [dictionary valueForKey:@"sender_name"];
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
        NSString *dateString = [dictionary valueForKey:@"created_at"];
        self.timestamp = [df dateFromString:dateString];
        
        NSDictionary *urlDictionary = [dictionary valueForKey:@"photo"];
        NSString *photoURLString = [urlDictionary valueForKey:@"url"];
        NSURL* url = [NSURL URLWithString:photoURLString];
        self.photoURL = url;
    }
    return  self;
}

@end
