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
#import "PTChatHUDView.h"
#import "PTPageView.h"
#import "PTUser.h"
#import "PTPageTurnRequest.h"
#import "PTBookChangeRequest.h"
#import "PTBookCloseRequest.h"
#import "PTPlaydateDisconnectRequest.h"
#import "PTVideoPhone.h"

@interface PTDateViewController ()

@end

@implementation PTDateViewController

@synthesize closeBookButton, playdate;

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
    isWebViewLoading = NO;
    
    // Start loading book covers
    [self loadBookCovers];
    
    // Start listening to pusher notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pusherPlayDateTurnPage:) name:@"PlayDateTurnPage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pusherPlayDateEndPlaydate:) name:@"PlayDateEndPlaydate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pusherPlayDateChangeBook:) name:@"PlayDateChangeBook" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    PTChatHUDView* chatView = [[PTChatHUDView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:chatView];
    [chatView setLoadingImageForLeftView:[UIImage imageNamed:@"144.png"]
                             loadingText:self.playdate.initiator.username];

    [[PTVideoPhone sharedPhone] setSessionConnectedBlock:^(OTStream *subscriberStream, OTSession *session, BOOL isSelf) {
        NSLog(@"Session connected!");
    }];
    [[PTVideoPhone sharedPhone] connectToSession:self.playdate.tokboxSessionID
                                       withToken:self.playdate.playmateTokboxToken
                                         success:^(OTPublisher *publisher)
    {
        NSLog(@"Inside session connection block");
        if (publisher.publishVideo) {
            [chatView setRightView:publisher.view];
        }
    } failure:^(NSError *error) {
        NSLog(@"Inside session failure block");
    }];
}

- (IBAction)closeBook:(id)sender {
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
    
    // Notify server of book close
    PTBookCloseRequest *bookCloseRequest = [[PTBookCloseRequest alloc] init];
    [bookCloseRequest closeBookWithPlaydateId:[NSNumber numberWithInt:playdate.playdateID]
                                       bookId:[bookView getId]
                                    authToken:[[PTUser currentUser] authToken]
                                    onSuccess:nil
                                    onFailure:nil
    ];
}

- (IBAction)playdateDisconnect:(id)sender {
    // Notify server of disconnect
    PTPlaydateDisconnectRequest *playdateDisconnectRequest = [[PTPlaydateDisconnectRequest alloc] init];
    [playdateDisconnectRequest playdateDisconnectWithPlaydateId:[NSNumber numberWithInt:playdate.playdateID]
                                                      authToken:[[PTUser currentUser] authToken]
                                                      onSuccess:nil
                                                      onFailure:nil
    ];
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
    NSInteger playerId = [[eventData objectForKey:@"player"] integerValue];
    
    // Check if this user initiated the page turn event
    if ([[PTUser currentUser] userID] == playerId) {
        return;
    }
    
    // Perform page turn
    NSInteger pageNum = [[eventData objectForKey:@"page"] integerValue];
    [pagesScrollView navigateToPage:pageNum];
    
    // Start loading pages
    [self beginBookPageLoading];
}

- (void)pusherPlayDateEndPlaydate:(NSNotification *)notification {
    NSDictionary *eventData = notification.userInfo;
    NSLog (@"PlayDateEndPlaydate -> %@", eventData);
}

- (void)pusherPlayDateChangeBook:(NSNotification *)notification {
    NSDictionary *eventData = notification.userInfo;
    NSInteger playerId = [[eventData objectForKey:@"player"] integerValue];
    
    // Check if this user initiated the page turn event
    if ([[PTUser currentUser] userID] == playerId) {
        return;
    }
    
    // Perform book change
    NSNumber *bookId = [eventData objectForKey:@"book"];
    currentBookId = [bookId copy];
    [booksScrollView navigateToBook:bookId];
    [self performSelector:@selector(openBookAfterNavigation) withObject:nil afterDelay:0.35];
}

- (void)openBookAfterNavigation {
    // Prepare the pages
    [pagesScrollView setCurrentBook:[books objectForKey:currentBookId]];
    
    // Find the book
    for (PTBookView *bookView in bookList) {
        if ([[bookView getId] isEqualToNumber:currentBookId]) {
            // Open the book
            [bookView open];
            [booksScrollView hideAllBooksExcept:(currentBookId)];
            
            // Start loading pages
            [self beginBookPageLoading];

            break;
        }
    }
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
        NSInteger bookId = [(NSString *)[components objectAtIndex:2] intValue];
        NSInteger pageNum = [(NSString *)[components objectAtIndex:3] intValue];
        // Render page view to bitmap
        [self convertWebViewPageToBitmapWithBookId:bookId andPageNumber:pageNum];
        return NO;
    } else if ([components count] > 1 && [(NSString *)[components objectAtIndex:0] isEqualToString:@"playtell"] && [(NSString *)[components objectAtIndex:1] isEqualToString:@"coverLoadFinished"]) {
        NSInteger bookId = [(NSString *)[components objectAtIndex:2] intValue];
        // Render cover view to bitmap
        [self convertWebViewCoverToBitmapWithBookId:bookId];
    }
    
    return YES;
}

- (void)convertWebViewPageToBitmapWithBookId:(NSInteger)bookId andPageNumber:(NSInteger)pageNumber {
    // Delay conversion until iOS deems it convenient (throws UI lag otherwise)
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^() {
        
        // Generate bitmaps
        UIGraphicsBeginImageContext(webView.bounds.size);
        [webView.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        dispatch_async(dispatch_get_main_queue(), ^() {
            
            // Send the image to page
            //NSInteger pageNumber = [[pagesToLoad objectAtIndex:pagesToLoadIndex] intValue];
            if ([pagesScrollView.subviews count] > 0) {
                PTPageView *pageView = [pagesScrollView.subviews objectAtIndex:(pageNumber - 1)];
                [pageView setPageContentsWithImage:image];
            }
            
            // If first page, also send it to book view
            if (pageNumber == 1 && coversToLoadIndex < [bookList count]) {
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
            if ([pagesToLoad count] > 0) {
                NSInteger pageNumber = [[pagesToLoad objectAtIndex:0] intValue];
                [pagesToLoad removeObjectAtIndex:0];
                NSMutableDictionary *book = [books objectForKey:currentBookId];
                NSArray *pages = [book objectForKey:@"pages"];
                isWebViewLoading = YES;
                [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[pages objectAtIndex:(pageNumber-1)]]]];
            } else {
                isWebViewLoading = NO;

                // Check for covers
                coversToLoadIndex += 1;
                if (coversToLoadIndex < [coversToLoad count]) {
                    [self loadCurrentBookCoverFromFileOrURL];
                }
            }
            
        });
    });
}

- (void)convertWebViewCoverToBitmapWithBookId:(NSInteger)bookId {
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
        
        // Notify server of book
        PTBookChangeRequest *bookChangeRequest = [[PTBookChangeRequest alloc] init];
        [bookChangeRequest changeBookWithPlaydateId:[NSNumber numberWithInt:playdate.playdateID]
                                             bookId:currentBookId
                                         pageNumber:[NSNumber numberWithInt:1]
                                          authToken:[[PTUser currentUser] authToken]
                                          onSuccess:nil
                                          onFailure:nil
         ];
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
    //pagesToLoadIndex = 0;
    
    // Start page loading
    if ([pagesToLoad count] > 0 && isWebViewLoading == NO) {
        NSInteger pageNumber = [[pagesToLoad objectAtIndex:0] intValue];
        [pagesToLoad removeObjectAtIndex:0];
        NSArray *pages = [book objectForKey:@"pages"];
        isWebViewLoading = YES;
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[pages objectAtIndex:(pageNumber-1)]]]];
    }
}

#pragma mark -
#pragma mark Pages scroll delegates

- (void)pageTurnedTo:(NSInteger)number {
    // Reset page loading from new page number
    [self beginBookPageLoading];
    
    // Notify server of new page turn
    NSMutableDictionary *book = [books objectForKey:currentBookId];
    NSNumber *pageNum = [book objectForKey:@"current_page"];
    PTPageTurnRequest *pageTurnRequest = [[PTPageTurnRequest alloc] init];
    [pageTurnRequest pageTurnWithPlaydateId:[NSNumber numberWithInt:playdate.playdateID]
                                 pageNumber:pageNum
                                  authToken:[[PTUser currentUser] authToken]
                                  onSuccess:nil
                                  onFailure:nil
    ];
}

@end