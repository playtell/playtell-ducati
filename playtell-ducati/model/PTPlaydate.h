//
//  PTPlaydate.h
//  playtell-ducati
//
//  Created by Ricky Hussmann on 6/2/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTPlaymate.h"
#import "PTPlaymateFactory.h"

#import <Foundation/Foundation.h>

@interface PTPlaydate : NSObject

- (id)initWithDictionary:(NSDictionary*)playdateData playmateFactory:(id<PTPlaymateFactory>)playmateFactory;

@property (nonatomic, readwrite) PTPlaymate* initiator;
@property (nonatomic, readwrite) PTPlaymate* playmate;
@property (nonatomic, assign) NSUInteger playdateID;
@property (nonatomic, copy) NSString* pusherChannelName;
@property (nonatomic, copy) NSString* initiatorTokboxToken;
@property (nonatomic, copy) NSString* playmateTokboxToken;
@property (nonatomic, copy) NSString* tokboxSessionID;

@end
