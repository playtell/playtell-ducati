//
//  PTDateViewController.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 6/4/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PTDateViewController.h"
#import "PTBookView.h"
#import "PTPageView.h"

@interface PTDateViewController ()

@end

@implementation PTDateViewController

@synthesize closeBookButton;

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle andBookList:(NSArray *)allBooks {
    // Parse all books into format we need
    books = [[NSMutableDictionary alloc] init];
    for (NSDictionary *book in allBooks) {
        NSNumber *bookId = [book objectForKey:@"id"];
        [books setObject:[[NSMutableDictionary alloc] initWithDictionary:book] forKey:bookId];
    }
    return [super initWithNibName:nibName bundle:nibBundle];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Init books scroll view
    booksParentView = [[PTBooksParentView alloc] initWithFrame:CGRectMake(0.0f, 62.0f, 1024.0f, 600.0f)];
    booksScrollView = [[PTBooksScrollView alloc] initWithFrame:CGRectMake((1024.0f - 350.0f) / 2.0f, 0.0f, 350.0f, 600.0f)];
    [booksParentView addSubview:booksScrollView];
    [self.view addSubview:booksParentView];
    
    // Init temp book
//    books = [[NSMutableDictionary alloc] init];
//    
//    NSMutableDictionary *book1 = [[NSMutableDictionary alloc] init];
//    [book1 setValue:@"bookNumber1" forKey:@"id"];
//    [book1 setValue:[NSNumber numberWithInteger:1] forKey:@"current_page"];
//    [book1 setValue:@"http://pic.iamdimitry.com/book/cover_front2.html" forKey:@"cover_front"];
//    NSArray *pages = [[NSArray alloc] initWithObjects:
//                      @"http://pic.iamdimitry.com/book/page1.html",
//                      @"http://pic.iamdimitry.com/book/page2.html",
//                      @"http://pic.iamdimitry.com/book/page3.html",
//                      @"http://pic.iamdimitry.com/book/page4.html", nil]; 
//    [book1 setObject:[pages copy] forKey:@"pages"];
//    [book1 setValue:[NSNumber numberWithInteger:[pages count]] forKey:@"total_pages"];
//    [books setObject:book1 forKey:@"bookNumber1"];
//    
//    NSMutableDictionary *book2 = [[NSMutableDictionary alloc] init];
//    [book2 setValue:@"bookNumber2" forKey:@"id"];
//    [book2 setValue:[NSNumber numberWithInteger:1] forKey:@"current_page"];
//    [book2 setValue:@"http://pic.iamdimitry.com/book/cover_front.html" forKey:@"cover_front"];
//    pages = [[NSArray alloc] initWithObjects:
//             @"http://pic.iamdimitry.com/book/page1.html",
//             @"http://pic.iamdimitry.com/book/page2.html",
//             @"http://pic.iamdimitry.com/book/page3.html",
//             @"http://pic.iamdimitry.com/book/page4.html",
//             @"http://pic.iamdimitry.com/book/page5.html",
//             @"http://pic.iamdimitry.com/book/page6.html",
//             @"http://pic.iamdimitry.com/book/page7.html",
//             @"http://pic.iamdimitry.com/book/page8.html",
//             @"http://pic.iamdimitry.com/book/page9.html",
//             @"http://pic.iamdimitry.com/book/page10.html", nil]; 
//    [book2 setObject:[pages copy] forKey:@"pages"];
//    [book2 setValue:[NSNumber numberWithInteger:[pages count]] forKey:@"total_pages"];
//    [books setObject:book2 forKey:@"bookNumber2"];
    
    // Create views for each book
    CGFloat xPos = (800.0f - booksScrollView.frame.size.width) / -2.0f; // full width (800) - scrollview width (350) divided by 2 (centered)
    PTBookView *bookView;
    int i = 0;
    bookList = [[NSMutableArray alloc] initWithCapacity:[books count]];
    coversToLoad = [[NSMutableArray alloc] initWithCapacity:[books count]];
    for (NSNumber *bookId in books) {
        if (i == 0) {
            // Set current book id
            currentBookId = [bookId copy];
        }
        NSMutableDictionary *book = [books objectForKey:bookId];
        bookView = [[PTBookView alloc] initWithFrame:CGRectMake(xPos, 0.0f, 800.0f, 600.0f) andBook:book]; // 800x600
        [bookView setBookPosition:i];
        [bookView setDelegate:self];
        [booksScrollView addSubview:bookView];
        xPos += booksScrollView.frame.size.width;
        i++;
        [bookList addObject:bookView];
        
        // Book cover pages load
        [coversToLoad addObject:bookId];
    }
    
    // Update scroll view width (based on # of books)
    CGFloat scroll_width = booksScrollView.frame.size.width * [books count];
    [booksScrollView setDelegate:self];
    [booksScrollView setContentSize:CGSizeMake(scroll_width, 600.0f)];
    isBookOpen = NO;
    
    // Init page scroll view and its pages
    pagesScrollView = [[PTPagesScrollView alloc] initWithFrame:CGRectMake(112.0f, 62.0f, 800.0f, 600.0f)];
    [pagesScrollView setHidden:YES];
    [pagesScrollView setPagesScrollDelegate:self];
    [self.view addSubview:pagesScrollView];
    
    // Cleate web view that will load our pages (hidden)
    webView = [[UIWebView alloc] init];
    [webView setDelegate:self];
    webView.frame = CGRectMake(112.0f, 800.0f, 800.0f, 600.0f); // Needs to be on main view to render pages right! Position off-screen (TODO: Better solution?)
    [self.view addSubview:webView];
    
    // Start loading book covers
    [self loadBookCovers];
    
    // Start listening to pusher notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pusherPlayDateTurnPage:) name:@"PlayDateTurnPage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pusherPlayDateEndPlaydate:) name:@"PlayDateEndPlaydate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pusherPlayDateChangeBook:) name:@"PlayDateChangeBook" object:nil];
}

- (IBAction)closeBook {
    // Find opened book
    PTBookView *bookView = nil;
    for (int i=0, l=[books count]; i<l; i++) {
        if ([[(PTBookView *)[bookList objectAtIndex:i] getId] isEqualToNumber:currentBookId]) {
            bookView = (PTBookView *)[bookList objectAtIndex:i];
            break;
        }
    }
    // Close book, hide pages, show all other books
    if (bookView != nil) {
        // TODO: Set current page view to book view
        [bookView setHidden:NO];
        [pagesScrollView setHidden:YES];
        [bookView close];
        [booksScrollView showAllBooksExcept:currentBookId];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)dealloc {
    // Clean up notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark Pusher notification handlers

- (void)pusherPlayDateTurnPage:(NSNotification *)notification {
    NSDictionary *eventData = notification.userInfo;
    NSLog (@"PlayDateTurnPage -> %@", eventData);
}

- (void)pusherPlayDateEndPlaydate:(NSNotification *)notification {
    NSDictionary *eventData = notification.userInfo;
    NSLog (@"PlayDateEndPlaydate -> %@", eventData);
}

- (void)pusherPlayDateChangeBook:(NSNotification *)notification {
    NSDictionary *eventData = notification.userInfo;
    NSLog (@"PlayDateChangeBook -> %@", eventData);
}

#pragma mark -
#pragma mark Covers/pages loading

- (void)loadBookCovers {
    // Create a directory for each book, if needed
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    for (NSString *bookId in books) {
        NSString *bookPath = [[self getDocumentsPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"Books/%@", bookId]];
        if (![fileManager fileExistsAtPath:bookPath]) {
            [fileManager createDirectoryAtPath:bookPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    
    // Start loading covers
    coversToLoadIndex = 0;
    [self loadCurrentBookCoverFromFileOrURL];
}

- (void)loadCurrentBookCoverFromFileOrURL {
    NSString *imagePath = [self coverImagePathForBook:[coversToLoad objectAtIndex:coversToLoadIndex]];
    UIImage *coverImage = [UIImage imageWithContentsOfFile:imagePath];
    if (coverImage) {
        // Send the image to book
        PTBookView *bookView = [bookList objectAtIndex:coversToLoadIndex];
        [bookView setCoverContentsWithImage:coverImage];
        
        // Before loading next cover, load first page of this book
        [self loadCurrentFirstPageFromFileOrURL];
    } else {
        NSString *cover_url = [[books objectForKey:[coversToLoad objectAtIndex:coversToLoadIndex]] objectForKey:@"cover_front"];
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:cover_url]]];
    }
}

- (void)loadCurrentFirstPageFromFileOrURL {
    NSString *imagePath = [self pageImagePathForBook:[coversToLoad objectAtIndex:coversToLoadIndex] AndPageNumber:1];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    if (image) {
        // Send the image to book view
        PTBookView *bookView = [bookList objectAtIndex:coversToLoadIndex];
        [bookView setPageContentsWithImage:image];
        
        // Check for more covers to load
        coversToLoadIndex += 1;
        if (coversToLoadIndex < [coversToLoad count]) {
            [self loadCurrentBookCoverFromFileOrURL];
        }
    } else {
        NSMutableDictionary *book = [books objectForKey:[coversToLoad objectAtIndex:coversToLoadIndex]];
        NSMutableArray *pages = [book objectForKey:@"pages"];
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[pages objectAtIndex:0]]]];
    }
}

#pragma mark -
#pragma mark Web view helpers/delegates

- (BOOL)webView:(UIWebView *)thisWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *requestString = [[request URL] absoluteString];
    NSArray *components = [requestString componentsSeparatedByString:@":"];
    
    // Check if JavaScript said web page has been loaded and render it to bitmap
    if ([components count] > 1 && [(NSString *)[components objectAtIndex:0] isEqualToString:@"playtell"] && [(NSString *)[components objectAtIndex:1] isEqualToString:@"pageLoadFinished"]) {
        // Render page view to bitmap
        [self convertWebViewPageToBitmap];
        return NO;
    } else if ([components count] > 1 && [(NSString *)[components objectAtIndex:0] isEqualToString:@"playtell"] && [(NSString *)[components objectAtIndex:1] isEqualToString:@"coverLoadFinished"]) {
        // Render cover view to bitmap
        [self convertWebViewCoverToBitmap];
    }
    
    return YES;
}

- (void)convertWebViewPageToBitmap {
    // Delay conversion until iOS deems it convenient (throws UI lag otherwise)
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^() {
        
        // Generate bitmaps
        UIGraphicsBeginImageContext(webView.bounds.size);
        [webView.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        dispatch_async(dispatch_get_main_queue(), ^() {
            
            // Send the image to page
            NSInteger pageNumber = [[pagesToLoad objectAtIndex:pagesToLoadIndex] intValue];
            if ([pagesScrollView.subviews count] > 0) {
                PTPageView *pageView = [pagesScrollView.subviews objectAtIndex:(pageNumber - 1)];
                [pageView setPageContentsWithImage:image];
            }
            
            // If first page, also send it to book view
            if (pageNumber == 0) {
                PTBookView *bookView = [bookList objectAtIndex:coversToLoadIndex];
                [bookView setPageContentsWithImage:image];
                
                // Cache image locally
                NSMutableDictionary *book = [books objectForKey:[coversToLoad objectAtIndex:coversToLoadIndex]];
                NSNumber *bookId = [book objectForKey:@"id"];
                NSString *imagePath = [self pageImagePathForBook:bookId AndPageNumber:1];
                NSData *imageData = UIImageJPEGRepresentation(image, 1.0f);
                [imageData writeToFile:imagePath atomically:YES];
            }
            
            // More pages to load? (Or more covers to load?)
            pagesToLoadIndex += 1;
            if (pagesToLoadIndex < [pagesToLoad count]) {
                NSMutableDictionary *book = [books objectForKey:currentBookId];
                NSArray *pages = [book objectForKey:@"pages"];
                NSInteger pageNumber = [[pagesToLoad objectAtIndex:pagesToLoadIndex] intValue];
                [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[pages objectAtIndex:(pageNumber-1)]]]];
            } else {
                // Check for covers
                coversToLoadIndex += 1;
                if (coversToLoadIndex < [coversToLoad count]) {
                    [self loadCurrentBookCoverFromFileOrURL];
                }
            }
            
        });
    });
}

- (void)convertWebViewCoverToBitmap {
    // Delay conversion until iOS deems it convenient (throws UI lag otherwise)
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^() {
        
        // Generate bitmaps
        UIGraphicsBeginImageContext(CGSizeMake(webView.bounds.size.width / 2.0f, webView.bounds.size.height));
        [webView.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        dispatch_async(dispatch_get_main_queue(), ^() {
            
            // Send the image to book
            PTBookView *bookView = [bookList objectAtIndex:coversToLoadIndex];
            [bookView setCoverContentsWithImage:image];
            
            // Cache image locally
            NSMutableDictionary *book = [books objectForKey:[coversToLoad objectAtIndex:coversToLoadIndex]];
            NSNumber *bookId = [book objectForKey:@"id"];
            NSString *imagePath = [self coverImagePathForBook:bookId];
            NSData *imageData = UIImageJPEGRepresentation(image, 1.0f);
            [imageData writeToFile:imagePath atomically:YES];
            
            // Before loading next cover, load first page of this book
            [self loadCurrentFirstPageFromFileOrURL];
        });
    });
}

- (NSString *)getDocumentsPath {
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [documentDirectories objectAtIndex:0];
}

- (NSString *)coverImagePathForBook:(NSNumber *)bookId {
    NSString *documentDirectory = [self getDocumentsPath];
    return [[[documentDirectory stringByAppendingPathComponent:@"Books"] stringByAppendingPathComponent:[bookId stringValue]] stringByAppendingPathComponent:@"cover_front.jpg"];
}

- (NSString *)pageImagePathForBook:(NSNumber *)bookId AndPageNumber:(NSInteger)pageNumber {
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    return [[[documentDirectory stringByAppendingPathComponent:@"Books"] stringByAppendingPathComponent:[bookId stringValue]] stringByAppendingPathComponent:[NSString stringWithFormat:@"page%i.jpg", pageNumber]];
}

#pragma mark -
#pragma mark Books scroll delegates

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Adjust size/opacity of each book as they scroll
    CGFloat x = scrollView.contentOffset.x;
    CGFloat width = booksScrollView.frame.size.width;
    for (int i=0, l=[books count]; i<l; i++) {
        CGFloat pos = ABS(i * width - x);
        if (pos <= (width * 3.0f)) { // Ignore all the books out of view (whole view fits about 3 books)
            CGFloat level = 1.0f - pos / width;
            [(PTBookView *)[bookList objectAtIndex:i] setFocusLevel:level];
        }
    }
}

#pragma mark -
#pragma mark Book delegates

- (void)bookFocusedWithId:(NSNumber *)bookId {
    currentBookId = [bookId copy];
}

- (void)bookTouchedWithId:(NSNumber *)bookId AndView:(PTBookView *)bookView {
    // Book selected, either focus it or open it
    if ([bookView inFocus] == NO) {
        // Bring book to focus
        NSInteger position = [bookView getBookPosition];
        CGPoint navigateTo = CGPointMake(booksScrollView.frame.size.width * position, 0.0f);
        [booksScrollView setContentOffset:navigateTo animated:YES];
    } else {
        // Prepare the pages
        [pagesScrollView setCurrentBook:[books objectForKey:bookId]];
        
        // Open the book
        [bookView open];
        [booksScrollView hideAllBooksExcept:(currentBookId)];
        
        // Start loading pages
        [self beginBookPageLoading];
    }
}

- (void)bookOpenedWithId:(NSNumber *)bookId AndView:(PTBookView *)bookView {
    currentBookId = [bookId copy];
    [pagesScrollView setHidden:NO];
    [bookView setHidden:YES];
    //[pageView showPages]; // TODO: Implement page fade-in?
    isBookOpen = YES;
    [booksParentView setIsBookOpen:YES];
}

- (void)bookClosedWithId:(NSNumber *)bookId AndView:(PTBookView *)bookView {
    isBookOpen = NO;
    [booksParentView setIsBookOpen:NO];
    
    // Stop any current page loads
    [webView stopLoading];
}

- (void)beginBookPageLoading {
    // Stop any current page loads
    [webView stopLoading];
    
    // Setup loading of pages for book
    NSMutableDictionary *book = [books objectForKey:currentBookId];
    currentPage = [[book objectForKey:@"current_page"] intValue];
    NSInteger totalPages = [[book objectForKey:@"total_pages"] intValue];
    
    // Build array of pages to load
    pagesToLoad = nil;
    pagesToLoad = [[NSMutableArray alloc] initWithCapacity:7];
    // Check if the page already has content
    PTPageView *pageView = (PTPageView *)[pagesScrollView.subviews objectAtIndex:(currentPage-1)];
    if (!pageView.hasContent) {
        [pagesToLoad addObject:[NSNumber numberWithInt:currentPage]];
    }
    for (int i=1; i<=3; i++) {
        // Go X pages forward
        if ((currentPage+i) <= totalPages) {
            // Check if the page already has content
            pageView = (PTPageView *)[pagesScrollView.subviews objectAtIndex:(currentPage+i-1)];
            if (!pageView.hasContent) {
                [pagesToLoad addObject:[NSNumber numberWithInt:(currentPage+i)]];
            }
        }
        // Go X pages backward
        if ((currentPage-i) > 0) {
            // Check if the page already has content
            pageView = (PTPageView *)[pagesScrollView.subviews objectAtIndex:(currentPage-i-1)];
            if (!pageView.hasContent) {
                [pagesToLoad addObject:[NSNumber numberWithInt:(currentPage-i)]];
            }
        }
    }
    pagesToLoadIndex = 0;
    
    // Start page loading
    if ([pagesToLoad count] > 0) {
        NSArray *pages = [book objectForKey:@"pages"];
        NSInteger pageNumber = [[pagesToLoad objectAtIndex:pagesToLoadIndex] intValue];
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[pages objectAtIndex:(pageNumber-1)]]]];
    }
}

#pragma mark -
#pragma mark Pages scroll delegates

- (void)pageTurnedTo:(NSInteger)number {
    // Reset page loading from new page number
    [self beginBookPageLoading];
}

@end