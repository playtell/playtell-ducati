//
//  PTBook.m
//  playtell-ducati
//
//  Created by Adam Horne on 1/18/13.
//  Copyright (c) 2013 PlayTell. All rights reserved.
//

#import "PTBook.h"

@implementation PTBook

@synthesize bookId;
@synthesize currentPage;
@synthesize totalPages;
@synthesize cover;
@synthesize pages;

NSDictionary *original;

- (id)init {
    self = [super init];
    if (self) {
        self.type = ActivityBook;
        self.bookId = [NSNumber numberWithInt:-1];
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)book {
    self = [self init];
    if (self) {
        original = book;
        
        // Assign the id which could be different depending on where it's read from
        if ([[book allKeys] containsObject:@"id"]) {
            bookId = [NSNumber numberWithInt:[[book objectForKey:@"id"] intValue]];
        }
        if ([[book allKeys] containsObject:@"book_id"]) {
            bookId = [NSNumber numberWithInt:[[book objectForKey:@"book_id"] intValue]];
        }
        // Assign the cover
        NSDictionary *coverDict = [book objectForKey:@"cover"];
        cover = [[coverDict objectForKey:@"front"] objectForKey:@"bitmap"];
        
        // Assign the pages
        totalPages = [[book objectForKey:@"total_pages"] intValue];
        currentPage = [[book objectForKey:@"current_page"] intValue];
        NSMutableArray *pagesArray = [NSMutableArray array];
        NSMutableArray *pagesInDict = [book objectForKey:@"pages"];
        for (NSDictionary *page in pagesInDict) {
            NSString *pageBitmapUrl = [page objectForKey:@"bitmap"];
            [pagesArray addObject:pageBitmapUrl];
        }
        pages = pagesArray;
    }
    return self;
}

- (NSURL *)coverUrl {
    @try {
        return [NSURL URLWithString:cover];
    }
    @catch (NSException *exception) {
        return nil;
    }
}

- (NSArray *)pageUrls {
    NSMutableArray *urls = [NSMutableArray array];
    
    for (NSString *page in pages) {
        NSURL *pageUrl = [NSURL URLWithString:page];
        [urls addObject:pageUrl];
    }
    
    return urls;
}

- (NSDictionary *)originalDictionary {
    return original;
}

- (NSString *)loggingString {
    NSString *pagesString = @"";
    for (int i = 0; i < [pages count]; i++) {
        if (i > 0) {
            pagesString = [pagesString stringByAppendingString:@", "];
        }
        pagesString = [pagesString stringByAppendingString:[pages objectAtIndex:i]];
    }
    return [NSString stringWithFormat:@"PTBook data values: bookId => %d, currentPage => %d, totalPages => %d, cover => %@, pages => { %@ } with superclass %@", [bookId intValue], currentPage, totalPages, cover, pagesString, [super loggingString]];
}

@end
