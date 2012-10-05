//
//  PTPlaydateGetAllBooksAndActivities.m
//  playtell-ducati
//
//  Created by Giancarlo Daniele on 8/16/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTPlaydateGetAllBooksAndActivities.h"
#import "AFNetworking.h"
#import "NSMutableURLRequest+POSTParameters.h"

@implementation PTPlaydateGetAllBooksAndActivities


- (void)loadToybox
{
    NSDictionary* postParameters = nil;
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/list", ROOT_URL]];
    NSMutableURLRequest* request = [NSMutableURLRequest postRequestWithURL:url];
    [request setPostParameters:postParameters];
    
    AFJSONRequestOperation* toyBox;
    toyBox = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
              success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                  //code here
                  if (response != nil) {
                  }
              } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                  //code here
                  if (response != nil) {
                  }
              }];
    [toyBox start];
}

@end