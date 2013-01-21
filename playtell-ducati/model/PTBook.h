//
//  PTBook.h
//  playtell-ducati
//
//  Created by Adam Horne on 1/18/13.
//  Copyright (c) 2013 PlayTell. All rights reserved.
//

#import "PTActivity.h"

@interface PTBook : PTActivity

@property (nonatomic, strong) NSNumber *bookId;
@property (nonatomic) int currentPage;
@property (nonatomic, readonly) int totalPages;
@property (nonatomic, strong, readonly) NSString *cover;
@property (nonatomic, readonly) NSURL *coverUrl;
@property (nonatomic, strong, readonly) NSArray *pages;
@property (nonatomic, readonly) NSArray *pageUrls;

- (id)initWithDictionary:(NSDictionary *)book;
- (NSDictionary *)originalDictionary;

@end
