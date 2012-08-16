//
//  PTContactSelectDelegate.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 8/1/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PTContactSelectDelegate <NSObject>

@optional
- (void)contactDidInvite:(NSMutableDictionary *)contact cell:(id)sender;
- (void)contactDidCancelInvite:(NSMutableDictionary *)contact cell:(id)sender;
- (void)contactDidAddFriend:(NSMutableDictionary *)contact cell:(id)sender;

@end