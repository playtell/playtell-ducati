//
//  PTNewUser.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 9/12/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PTNewUser : NSObject

@property (nonatomic) BOOL isCreateViaFacebook;
@property (nonatomic) BOOL isAccountForChild;
@property (nonatomic) BOOL isNotificationsApproved;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) UIImage *photo;
@property (nonatomic, strong) NSDate *birthday;

- (id)init;

@end