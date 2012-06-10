//
//  PTConcretePlaymateFactory.h
//  playtell-ducati
//
//  Created by Ricky Hussmann on 6/10/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTPlaymateFactory.h"

#import <Foundation/Foundation.h>

@interface PTConcretePlaymateFactory : NSObject <PTPlaymateFactory>

+ (PTConcretePlaymateFactory*)sharedFactory;

- (void)refreshPlaymatesForUserID:(NSUInteger)ID
                            token:(NSString*)token
                          success:(void(^)(void))success
                          failure:(void(^)(NSError* error))failure;

@end
