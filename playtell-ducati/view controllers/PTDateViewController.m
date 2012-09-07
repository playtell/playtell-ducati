//
//  PTDateViewController.m
//  playtell-ducati
//
//  Created by DisetPlaymatePhotomitry Bentsionov on 6/4/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "Logging.h"
#import "PTAppDelegate.h"
#import "TransitionController.h"

//VIEW CONTROLLERS
#import "PTDateViewController.h"
#import "PTDialpadViewController.h"
#import "PTChatViewController.h"
#import "PTBookView.h"
#import "PTPageView.h"

//MODELS
#import "PTUser.h"
#import "PTCheckForPlaydateRequest.h"
#import "PTConcretePlaymateFactory.h"

//HTTP POST
#import "AFNetworking.h"
#import "NSMutableURLRequest+POSTParameters.h"
#import "TargetConditionals.h"

//RAILS REQUESTS 
#import "PTPageTurnRequest.h"
#import "PTTictactoeNewGameRequest.h"
#import "PTBookChangeRequest.h"
#import "PTBookCloseRequest.h"
#import "PTPlaydateDisconnectRequest.h"
#import "PTPlaydateJoinedRequest.h"
#import "PTPlaydateFingerTapRequest.h"
#import "PTBooksListRequest.h"
#import "PTPlaydateFingerEndRequest.h"
#import "PTPlayTellPusher.h"
#import "PTPlaydate+InitatorChecking.h"
#import "PTMemoryNewGameRequest.h"

//GAME VIEW CONTROLLERS
#import "PTTictactoeViewController.h"
#import "PTMemoryGameViewController.h"

@interface PTDateViewController ()
@property (nonatomic, strong) PTChatHUDView* chatView;
@property (nonatomic, weak) OTSubscriber* playmateSubscriber;
@property (nonatomic, weak) OTPublisher* myPublisher;
@property (nonatomic, strong) PTChatViewController* chatController;
@end

@implementation PTDateViewController
@synthesize chatView;
@synthesize playdate;
@synthesize playmateSubscriber;
@synthesize myPublisher;
@synthesize endPlaydate, endPlaydateForreal, closeBook, endPlaydatePopup, button2;
@synthesize chatController;

- (void)setPlaydate:(PTPlaydate *)aPlaydate {
    LogDebug(@"Setting playdate");
    NSAssert(playdate == nil, @"Playdate already set");

    playdate = aPlaydate;
    [self wireUpwireUpPlaydateConnections];
#if !(TARGET_IPHONE_SIMULATOR)
    self.chatController = [[PTChatViewController alloc] initWithplaydate:self.playdate];
    [self.view addSubview:self.chatController.view];
#endif
}

- (void)wireUpwireUpPlaydateConnections {

    // The dialpad may already be subscribed to the playdate channel. When a playdate request
    // comes in on the dialpad, it subscribes to the playdate channel to catch end_playdate
    // messages. That way, it can deactivate the playmate button if the playmate ends the
    // playdate before the user accepts. In the instance where the user is not the initiator,
    // the playdate channel will already be subscribed by the time the PTDateViewController is
    // loaded. The check below is used to ensure the playdate channel is not yet subscribed to.
    if (![[PTPlayTellPusher sharedPusher] isSubscribedToPlaydateChannel]) {
        NSLog(@"Subscribing to channel: %@", self.playdate.pusherChannelName);
        [[PTPlayTellPusher sharedPusher] subscribeToPlaydateChannel:self.playdate.pusherChannelName];
    }

    // Notify server (and thus, the initiator) that we joined the playdate
    PTPlaydateJoinedRequest *playdateJoinedRequest = [[PTPlaydateJoinedRequest alloc] init];
    [playdateJoinedRequest playdateJoinedWithPlaydate:[NSNumber numberWithInteger:self.playdate.playdateID]
                                            authToken:[[PTUser currentUser] authToken]
                                            onSuccess:nil
                                            onFailure:nil
     ];
    
//    [self setPlaymatePhoto];
//
//    [[PTVideoPhone sharedPhone] setSessionConnectedBlock:^(OTStream *subscriberStream, OTSession *session, BOOL isSelf) {
//        NSLog(@"Session connected!");
//    }];
    
    NSString* myToken;
    if ([self.playdate isUserIDInitiator:[[PTUser currentUser] userID]]) {
        LogInfo(@"Current user is initator");
        myToken = playdate.initiatorTokboxToken;
    } else {
        LogInfo(@"Current user is NOT initiator");
        myToken = playdate.playmateTokboxToken;
    }

#if !(TARGET_IPHONE_SIMULATOR)
#elif TARGET_OS_IPHONE
//    [[PTVideoPhone sharedPhone] connectToSession:self.playdate.tokboxSessionID
//                                       withToken:myToken
//                                         success:^(OTPublisher *publisher)
//     {
//         if (publisher.publishVideo) {
//             self.myPublisher = publisher;
//             [self.chatView setRightView:publisher.view];
//         }
//     } failure:^(NSError *error) {
//         LogError(@"Error connecting to video phone session: %@", error);
//     }];
//    
//    [[PTVideoPhone sharedPhone] setSubscriberConnectedBlock:^(OTSubscriber *subscriber) {
//        if (subscriber.stream.hasVideo) {
//            self.playmateSubscriber = subscriber;
//            [self.chatView setLeftView:subscriber.view];
//        } else {
//            [self.chatView transitionLeftImage];
//        }
//    }];
//
//    [[PTVideoPhone sharedPhone] setSessionDropBlock:^(OTSession *session, OTStream *stream) {
//        [self setPlaymatePhoto];
//    }];
#endif
}

- (void)setPlaymatePhoto {
    // Pick out the other user
#if !(TARGET_IPHONE_SIMULATOR)
    if (self.playdate) {
        PTPlaymate* otherUser;
        if ([self.playdate isUserIDInitiator:[[PTUser currentUser] userID]]) {
            otherUser = self.playdate.playmate;
        } else {
            otherUser = self.playdate.initiator;
        }
        
        UIImage* otherUserPhoto = (otherUser.userPhoto) ? otherUser.userPhoto : [self placeholderImage];
        [self.chatView setLoadingImageForLeftView:otherUserPhoto
                                      loadingText:otherUser.username];
    } else {
        [self.chatView setLoadingImageForLeftView:[self placeholderImage]
                                      loadingText:@""];
    }
#endif
}

- (UIImage*)placeholderImage {
    return [UIImage imageNamed:@"profile_default_2.png"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //set the app delegate's dateViewController
    PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.dateViewController = self;

    // Init books scroll view
    booksParentView = [[PTBooksParentView alloc] initWithFrame:CGRectMake(0.0f, 126.0f, 1024.0f, 600.0f)];
    booksScrollView = [[PTBooksScrollView alloc] initWithFrame:CGRectMake((1024.0f - 350.0f) / 2.0f, 0.0f, 350.0f, 600.0f)];
    [booksParentView addSubview:booksScrollView];
    [self.view addSubview:booksParentView];
    
    // Init books list
    [self loadBooks];
    
    // Init page scroll view and its pages
    pagesScrollView = [[PTPagesScrollView alloc] initWithFrame:CGRectMake(112.0f, 126.0f, 800.0f, 600.0f)];
    [pagesScrollView setHidden:YES];
    [pagesScrollView setPagesScrollDelegate:self];
    [self.view addSubview:pagesScrollView];
    
//    // Cleate web view that will load our pages (hidden)
//    webView = [[UIWebView alloc] init];
//    [webView setDelegate:self];
//    webView.frame = CGRectMake(112.0f, 800.0f, 800.0f, 600.0f); // Needs to be on main view to render pages right! Position off-screen (TODO: Better solution?)
//    [self.view addSubview:webView];
    
    // Create dictionary that will hold finger views
    fingerViews = [[NSMutableDictionary alloc] init];
    
    // Add the ChatHUD view to the top of the screen
//    self.chatView = [[PTChatHUDView alloc] initWithFrame:CGRectZero];
//    [self.view addSubview:self.chatView];
//    [self setCurrentUserPhoto];
//    [self setPlaymatePhoto];

    // Start listening to pusher notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pusherPlayDateTurnPage:) name:@"PlayDateTurnPage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pusherPlayDateEndPlaydate:) name:@"PlayDateEndPlaydate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pusherPlayDateChangeBook:) name:@"PlayDateChangeBook" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pusherPlayDateCloseBook:) name:@"PlayDateCloseBook" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pusherPlayDateFingerStart:) name:@"PlayDateFingerStart" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pusherPlayDateFingerEnd:) name:@"PlayDateFingerEnd" object:nil];
    //listen for tictactoe game
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pusherPlayDateTictactoeNewGame:) name:@"PlayDateTictactoeNewGame" object:nil];

    
    // Setup end playdate & close book buttons
    [endPlaydate setImage:[UIImage imageNamed:@"EndCallCrankPressed"] forState:UIControlStateHighlighted];
    [endPlaydate setImage:[UIImage imageNamed:@"EndCallCrankPressed"] forState:UIControlStateSelected];
    [closeBook setImage:[UIImage imageNamed:@"CloseBookPressed"] forState:UIControlStateHighlighted];
    [closeBook setImage:[UIImage imageNamed:@"CloseBookPressed"] forState:UIControlStateSelected];
    closeBook.alpha = 0.0f;
    
    // Setup end playdate popup
    endPlaydatePopup.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"EndPlaydatePopupBg"]];
    endPlaydatePopup.hidden = YES;
}

- (void)loadBooks {
    // Load books from plist file
    boolListLoadedFromPlist = NO;
    NSString *documentsDirectory = [self getDocumentsPath];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"books.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath: path]) {
        // File does not exist! Load from API
        [self loadBooksFromAPIWithWritePath:path];
        return;
    }
    
    // Populate books dictionary
    boolListLoadedFromPlist = YES;
    books = [[NSMutableDictionary alloc] init];
    NSArray *fileData = [[NSArray alloc] initWithContentsOfFile:path];
    for (NSDictionary *book in fileData) {
        NSNumber *bookId = [book objectForKey:@"id"];
        [books setObject:[[NSMutableDictionary alloc] initWithDictionary:book] forKey:bookId];
    }
    
    // Load the actual views
    [self loadBookViewsFromDictionary];
    
    // Get the updated list from API
    [self loadBooksFromAPIWithWritePath:path];
}

- (void)loadBooksFromAPIWithWritePath:(NSString *)path {
    PTBooksListRequest* booksRequest = [[PTBooksListRequest alloc] init];
    [booksRequest booksListWithAuthToken:[[PTUser currentUser] authToken]
                               onSuccess:^(NSDictionary *result)
    {
        NSDictionary *allBooks = [result valueForKey:@"books"];  //TODOGIANCARLO valueforkey@"games"
        if (boolListLoadedFromPlist == NO) {
            // Parse all books into format we need
            books = [[NSMutableDictionary alloc] init];
            for (NSDictionary *book in allBooks) {
                NSNumber *bookId = [book objectForKey:@"id"];
                [books setObject:[[NSMutableDictionary alloc] initWithDictionary:book] forKey:bookId];
            }
            
            // Write book list to plist file
            NSMutableArray *writeData = [[NSMutableArray alloc] init];
            for (NSNumber *bookId in books) {
                [writeData addObject:[books objectForKey:bookId]];
            }
            [writeData writeToFile:path atomically:YES];
            
            // Load the actual views
            dispatch_async(dispatch_get_main_queue(), ^() {
                 [self loadBookViewsFromDictionary];
            });
        } else {
            // Figure out which books are new
            NSMutableArray *newBooks = [[NSMutableArray alloc] init];
            NSInteger oldTotalForBooks = [[books allKeys] count];
            for (NSDictionary *book in allBooks) {
                NSNumber *bookId = [book objectForKey:@"id"];
                if ([books objectForKey:bookId] == nil) {
                    [newBooks addObject:bookId];
                    [books setObject:[[NSMutableDictionary alloc] initWithDictionary:book] forKey:bookId];
                }
            }
            
            // If there are new books, create views for them and load their covers
            if ([newBooks count] > 0) {
                // Create new book views
                BOOL restartCoversLoad = (coversToLoadIndex == [coversToLoad count]); // This means original covers load has finished
                CGFloat xPos = (booksScrollView.frame.size.width * oldTotalForBooks) + (800.0f - booksScrollView.frame.size.width) / -2.0f; // full width (800) - scrollview width (350) divided by 2 (centered)
                PTBookView *bookView;
                for (int i=0; i<[newBooks count]; i++) {
                    NSNumber *bookId = [newBooks objectAtIndex:i];
                    NSMutableDictionary *book = [books objectForKey:bookId];
                    bookView = [[PTBookView alloc] initWithFrame:CGRectMake(xPos, 0.0f, 800.0f, 600.0f) andBook:book]; // 800x600
                    [bookView setBookPosition:(oldTotalForBooks + i)];
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
                [booksScrollView setContentSize:CGSizeMake(scroll_width, 600.0f)];
                
                // Start loading book covers
                if (restartCoversLoad) {
                    [self loadBookCoverFromFileOrURL];
                }
                
                // Write book list to plist file
                NSMutableArray *writeData = [[NSMutableArray alloc] init];
                for (NSNumber *bookId in books) {
                    [writeData addObject:[books objectForKey:bookId]];
                }
                [writeData writeToFile:path atomically:YES];
            }
        }
    } onFailure:nil];
}

- (void)loadBookViewsFromDictionary {
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
    
    //TODO we need to incorporate an API call here to load games from the API
    xPos += (booksScrollView.frame.size.width * .75);
    UIImageView *tttBookView = [[UIImageView alloc] initWithFrame:CGRectMake(xPos, 150.0f, 300.0f, 225)]; // 800x600
    tttBookView.image = [UIImage imageNamed:@"TTT-logo.png"];
    UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(ticTacToeTapped:)];
    [tttBookView addGestureRecognizer:tapRecognizer];
    tttBookView.userInteractionEnabled = YES;
    [booksScrollView addSubview:tttBookView];
    xPos += booksScrollView.frame.size.width;
    
    UIImageView *memoryBookView = [[UIImageView alloc] initWithFrame:CGRectMake(xPos, 150.0f, 300.0f, 225)]; // 800x600
    memoryBookView.image = [UIImage imageNamed:@"Memory-logo.png"];
    UITapGestureRecognizer* tapRecognizerMemory = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(memoryTapped:)];
    [memoryBookView addGestureRecognizer:tapRecognizerMemory];
    memoryBookView.userInteractionEnabled = YES;
    [booksScrollView addSubview:memoryBookView];
    xPos += booksScrollView.frame.size.width;
    
    // Update scroll view width (based on # of books)
    CGFloat scroll_width = booksScrollView.frame.size.width * ([books count] + 2);
    [booksScrollView setDelegate:self];
    [booksScrollView setContentSize:CGSizeMake(scroll_width, 600.0f)];
    isBookOpen = NO;

    // Start loading book covers
    [self loadBookCovers];
    isPageViewLoading = NO;
}

- (void)ticTacToeTapped:(UIGestureRecognizer*)tapRecognizer {
    [self playTictactoe:nil];
}

- (void)memoryTapped:(UIGestureRecognizer*)tapRecognizer {
    [self playMemoryGame:nil];
}

- (void)setCurrentUserPhoto {
    UIImage* myPhoto = [[PTUser currentUser] userPhoto];
    
    // If user photo is nil user the placeholder
    myPhoto = (myPhoto) ? [[PTUser currentUser] userPhoto] : [self placeholderImage];
    [self.chatView setLoadingImageForRightView:myPhoto];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // If the chat controller has been created, go ahead an add it
#if !(TARGET_IPHONE_SIMULATOR)
    if (self.chatController) {
        [self.view addSubview:self.chatController.view];
    }
#endif
    
    // Subscribe to backgrounding notifications, so we can subscribe to foregrounding
    // notifications at the time of backgrounding.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dateControllerDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    }

- (void)dateControllerDidEnterBackground:(NSNotification*)note {
    
    // Subscribe to foregrounding changes. The date controller will need to check the validity
    // of the current playdate any time it re-enters the foreground (as the playmate may have
    // terminated the playdate in the interim).
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dateControllerWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
#if !(TARGET_IPHONE_SIMULATOR)
    [self removePlaymateFromChatHUD];
#endif
}

- (void)removePlaymateFromChatHUD {
    if (self.playmateSubscriber) {
        [self.playmateSubscriber.view removeFromSuperview];
        self.playmateSubscriber = nil;
    }

    if (self.myPublisher) {
        [self.myPublisher.view removeFromSuperview];
        self.myPublisher = nil;
    }
}

- (void)dateControllerWillEnterForeground:(NSNotification*)note {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];

    // When the view controller enters the foreground, the playdate is checked
    // for existence. It's possible the other end hung up while the application
    // was in the background. This call is to ensure the playdate is still valid.
    PTCheckForPlaydateRequest *request = [[PTCheckForPlaydateRequest alloc] init];
    [request checkForExistingPlaydateForUser:[[PTUser currentUser] userID]
                                   authToken:[[PTUser currentUser] authToken]
                             playmateFactory:[PTConcretePlaymateFactory sharedFactory]
                                     success:nil
                                     failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        // TODO : This is a temporary solution. The server is currently only returning
        // a status code of 0 when there isn't an active playdate. Commenting this out
        // until the issue is fixed.
//        if (response.statusCode == 100 || response.statusCode == 101) {
//            LogInfo(@"Playdate terminated by user, going back to dialpad");
//            [self disconnectPuhserAndChat];
//            
//            PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
//            [appDelegate.transitionController transitionToViewController:appDelegate.dialpadController
//                                                             withOptions:UIViewAnimationOptionTransitionCrossDissolve];
//        } else {
//            LogDebug(@"Received status code %i from server", response.statusCode);
//        }
        [self disconnectAndTransitionToDialpad];
    }];
#if !(TARGET_IPHONE_SIMULATOR)
    [self setCurrentUserPhoto];
    [self setPlaymatePhoto];
#endif
}

- (void)disconnectAndTransitionToDialpad {
    [self disconnectPusherAndChat];
    [self transitionToDialpad];
}

- (void)disconnectPusherAndChat {
    // Unsubscribe from playdate channel
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.playdate) {
        LogInfo(@"Unsubscribing from channel: %@", self.playdate.pusherChannelName);
        [[PTPlayTellPusher sharedPusher] unsubscribeFromPlaydateChannel:self.playdate.pusherChannelName];
    }
#if !(TARGET_IPHONE_SIMULATOR)
    [[PTVideoPhone sharedPhone] disconnect];
#endif
}

- (void)transitionToDialpad {
    PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
    if (appDelegate.dialpadController.loadingView != nil) {
        [appDelegate.dialpadController.loadingView removeFromSuperview];
    }
    [appDelegate.transitionController transitionToViewController:appDelegate.dialpadController
                                                     withOptions:UIViewAnimationOptionTransitionCrossDissolve];
}

- (IBAction)playTictactoe:(id)sender {
    PTPlaymate *playmate;
    PTTictactoeNewGameRequest *newGameRequest = [[PTTictactoeNewGameRequest alloc] init];
    if ([self.playdate isUserIDInitiator:[[PTUser currentUser] userID]]) {
        LogInfo(@"Current user is initator. Playmate is playmate.");
        playmate = self.playdate.playmate;
        
    } else {
        LogInfo(@"Current user is NOT initiator. Playmate is initiator");
        playmate = self.playdate.initiator;
    }
    
    [newGameRequest newBoardWithPlaydateId:[NSNumber numberWithInt:playdate.playdateID]
                                authToken:[[PTUser currentUser] authToken]
                                playmate_id:[NSString stringWithFormat:@"%d", playmate.userID]
                                initiatorId:[NSString stringWithFormat:@"%d", [[PTUser currentUser] userID]]
                                 onSuccess:^(NSDictionary *result)
     {
         NSLog(@"%@", result);  //TODOGIANCARLO valueforkey@"games"
         
         NSString *board_id = [result valueForKey:@"board_id"];
         
         PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
                  
         PTTictactoeViewController *tictactoeVc = [[PTTictactoeViewController alloc] init];
#if !(TARGET_IPHONE_SIMULATOR)
         [tictactoeVc setChatController:self.chatController];
#endif
         [tictactoeVc setPlaydate:self.playdate];
         [tictactoeVc initGameWithMyTurn:YES];
         tictactoeVc.board_id = [board_id intValue];
         tictactoeVc.playmate_id = playmate.userID;
         tictactoeVc.initiator_id = [[PTUser currentUser] userID];
                  
         CGRect imageframe = CGRectMake(0,0,1024,768);

         UIImageView *splash =  [[UIImageView alloc] initWithFrame:imageframe];
         splash.image = [UIImage imageNamed:@"TTT-cover.png"];
         
         //bring up the view controller of the new game!
         [appDelegate.transitionController loadGame:tictactoeVc
                                                          withOptions:UIViewAnimationOptionTransitionCurlUp withSplash:splash gameType:TICTACTOE];
     } onFailure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
         NSLog(@"%@", error);
         NSLog(@"%@", request);
         NSLog(@"%@", JSON);
     }];
}

- (IBAction)playMemoryGame:(id)sender {
    
    // ##start MEMORY API CALL ##
    PTPlaymate *playmate;
    PTMemoryNewGameRequest *newGameRequest = [[PTMemoryNewGameRequest alloc] init];
    
    if ([self.playdate isUserIDInitiator:[[PTUser currentUser] userID]]) {
        LogInfo(@"Current user is initator. Playmate is playmate.");
        playmate = self.playdate.playmate;
        
    } else {
        LogInfo(@"Current user is NOT initiator. Playmate is initiator");
        playmate = self.playdate.initiator;
    }
    [newGameRequest newBoardWithPlaydate_id:[NSString stringWithFormat:@"%d", self.playdate.playdateID]
                                 auth_token:[[PTUser currentUser] authToken]
                               playmate_id:[NSString stringWithFormat:@"%d", playmate.userID]
                               initiatorId:[NSString stringWithFormat:@"%d", [[PTUser currentUser] userID]]
                                  theme_ID:@"19"
                           num_total_cards:@"4"
                                 onSuccess:^(NSDictionary *result) {
                                     
                                     NSLog(@"%@", result);
                                     
                                     //get response parameters
                                     NSString *board_id = [result valueForKey:@"board_id"];
//                                     NSDictionary *filenameArray = [result valueForKey:@"filename_dump"];
                                                                         
                                    PTMemoryGameViewController *memoryVc = [[PTMemoryGameViewController alloc] initWithPlaydate:self.playdate myTurn:YES boardID:[board_id intValue] playmateID:playmate.userID initiatorID:[[PTUser currentUser] userID]];
                                     
                            #if !(TARGET_IPHONE_SIMULATOR)
                                    [memoryVc setChatController:self.chatController];
                            #endif
                                     //    [appDelegate.transitionController loadGame:memoryGameVc withOptions:UIViewAnimationOptionTransitionCurlUp withSplash:splash gameType:MEMORY];3
                                                                         
                                    CGRect imageframe = CGRectMake(0,0,1024,768);
                                    
                                    UIImageView *splash =  [[UIImageView alloc] initWithFrame:imageframe];
                                    splash.image = [UIImage imageNamed:@"Memory-cover.png"];
                                    
                                    //bring up the view controller of the new game!
                                     PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
                                    [appDelegate.transitionController loadGame:memoryVc
                                                                   withOptions:UIViewAnimationOptionTransitionCurlUp withSplash:splash];
    } onFailure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"%@", error);
        NSLog(@"%@", request);
        NSLog(@"%@", JSON);}];
    
    // ##end MEMORY API CALL ##
}
     

- (IBAction)playdateDisconnect:(id)sender {
    // Notify server of disconnect
    [self disconnectPusherAndChat];
    if (self.playdate) {
        PTPlaydateDisconnectRequest *playdateDisconnectRequest = [[PTPlaydateDisconnectRequest alloc] init];
        [playdateDisconnectRequest playdateDisconnectWithPlaydateId:[NSNumber numberWithInt:playdate.playdateID]
                                                          authToken:[[PTUser currentUser] authToken]
                                                          onSuccess:^(NSDictionary* result)
        {
            // We delay moving to the dialpad because it will be checking for
            // playdates when it appears
            [self transitionToDialpad];
        }
                                                          onFailure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
        {
            [self transitionToDialpad];
        }];
    }
}

- (IBAction)endPlaydatePopupToggle:(id)sender {
    if (endPlaydatePopup.hidden) {
        endPlaydatePopup.hidden = NO;
    } else {
        endPlaydatePopup.hidden = YES;
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
#if !(TARGET_IPHONE_SIMULATOR)
    [self.chatView removeFromSuperview];
    self.chatView = nil;
#endif
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
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
    
    // Save current page in book config
    NSMutableDictionary *book = [books objectForKey:currentBookId];
    [book setObject:[NSNumber numberWithInt:pageNum] forKey:@"current_page"];
    
    // Start loading pages
    [self beginBookPageLoading];
}

- (void)pusherPlayDateEndPlaydate:(NSNotification *)notification {
    NSDictionary *eventData = notification.userInfo;
    NSLog (@"PlayDateEndPlaydate -> %@", eventData);
    [self disconnectAndTransitionToDialpad];
}

- (void)pusherPlayDateCloseBook:(NSNotification *)notification {
    NSDictionary *eventData = notification.userInfo;
    NSInteger playerId = [[eventData objectForKey:@"player"] integerValue];
    
    // Check if this user initiated the book close
    if ([[PTUser currentUser] userID] == playerId) {
        return;
    }
    
    // Find appropriate book view
    PTBookView *bookView = nil;
    for (int i=0, l=[books count]; i<l; i++) {
        if ([[(PTBookView *)[bookList objectAtIndex:i] getId] isEqualToNumber:currentBookId]) {
            bookView = (PTBookView *)[bookList objectAtIndex:i];
            break;
        }
    }

    // Perform book close
    [self closeBookUsingBookView:bookView];
}

- (void)closeBookUsingBookView:(PTBookView*)bookView {
    // Reset page loading
    [pagesToLoad removeAllObjects];
    isPageViewLoading = NO;
    
    // Hide close book button
    [UIView animateWithDuration:BOOK_OPEN_CLOSE_ANIMATION_SPEED animations:^{
        closeBook.alpha = 0.0f;
    }];

    // Close book, hide pages, show all other books
    if (bookView != nil) {
        // Set current page view to book view
        if ([pagesScrollView.subviews count] > 0 && (pagesScrollView.currentPage - 1) < [pagesScrollView.subviews count]) {
            PTPageView *pageView = [pagesScrollView.subviews objectAtIndex:(pagesScrollView.currentPage - 1)];
            [bookView setPageContentsWithLeftContent:[pageView getLeftContent]
                                     andRightContent:[pageView getRightContent]];
        }
        [bookView setHidden:NO];
        [pagesScrollView setHidden:YES];
        [bookView close];
        [booksScrollView showAllBooksExcept:currentBookId];
    }
}

- (void)pusherPlayDateChangeBook:(NSNotification *)notification {
    NSDictionary *eventData = notification.userInfo;
    NSInteger playerId = [[eventData objectForKey:@"player"] integerValue];
    NSNumber *bookId = [eventData objectForKey:@"book"];
    
    // Check if this user initiated the change book event
    if ([[PTUser currentUser] userID] == playerId) {
        return;
    }
    
    // Check if a book is already open
    if (isBookOpen && ![currentBookId isEqualToNumber:bookId]) {
        // Close current book immediately & show all others immediately immediately (aka. no animations)
        for (PTBookView *bookView in bookList) {
            if ([[bookView getId] isEqualToNumber:currentBookId]) {
                [bookView setHidden:NO];
                [bookView closeImmediately];
                [booksScrollView showAllBooksImmediatelyExcept:currentBookId];
                break;
            }
        }

        // Hide pages view
        [pagesScrollView setHidden:YES];
        
        // Hide closeBook button (immediately)
        [closeBook.layer removeAllAnimations];
        closeBook.alpha = 0.0f;
    }
    
    // Update status values
    isBookOpen = YES;
    [booksParentView setIsBookOpen:YES];
    
    // Perform book change
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
    // Show close book button
    [UIView animateWithDuration:(BOOK_OPEN_CLOSE_ANIMATION_SPEED + 0.25f) animations:^{
        closeBook.alpha = 1.0f;
    }];
}

- (void)pusherPlayDateFingerStart:(NSNotification *)notification {
    NSDictionary *eventData = notification.userInfo;
    NSInteger playerId = [[eventData objectForKey:@"player"] integerValue];
    
    // Check if this user initiated the finger action
    if ([[PTUser currentUser] userID] == playerId) {
        return;
    }
    
    // Add finger
    NSInteger x = [[eventData objectForKey:@"x"] integerValue];
    NSInteger y = [[eventData objectForKey:@"y"] integerValue];
    CGPoint point = CGPointMake(x, y);
    [self addFingerAtPoint:point initiatedBySelf:NO];
}

- (void)pusherPlayDateTictactoeNewGame:(NSNotification *)notification {
    //check here to make sure it's coming from the other player
    
    NSDictionary *eventData = notification.userInfo;
    NSInteger initiator_id = [[eventData objectForKey:@"initiator_id"] integerValue];
    NSInteger board_id = [[eventData objectForKey:@"board_id"] integerValue];
    
    //if we did not init new game but there is a pusher for new game on our playdate....
    if (initiator_id != [[PTUser currentUser] userID]) {
    
        PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
        
        PTTictactoeViewController *tictactoeVc = [[PTTictactoeViewController alloc] init];
#if !(TARGET_IPHONE_SIMULATOR)
        [tictactoeVc setChatController:self.chatController];
#endif
        [tictactoeVc setPlaydate:self.playdate];
        [tictactoeVc initGameWithMyTurn:NO];
        tictactoeVc.board_id = board_id;
        tictactoeVc.playmate_id = [[PTUser currentUser] userID];
        tictactoeVc.initiator_id = initiator_id;
        
        CGRect imageframe = CGRectMake(0,0,1024,768);

        UIImageView *splash =  [[UIImageView alloc] initWithFrame:imageframe];
        splash.image = [UIImage imageNamed:@"TTT-cover.png"];
        
        //bring up the view controller of the new game!
        [appDelegate.transitionController loadGame:tictactoeVc
                                                         withOptions:UIViewAnimationOptionTransitionCrossDissolve withSplash:splash gameType:TICTACTOE];
    }
}

- (void)pusherPlayDateFingerEnd:(NSNotification *)notification {
    NSDictionary *eventData = notification.userInfo;
    NSInteger playerId = [[eventData objectForKey:@"player"] integerValue];
    
    // Check if this user initiated the finger action
    if ([[PTUser currentUser] userID] == playerId) {
        return;
    }
    // Remove finger
    NSInteger x = [[eventData objectForKey:@"x"] integerValue];
    NSInteger y = [[eventData objectForKey:@"y"] integerValue];
    CGPoint point = CGPointMake(x, y);
    [self removeFingerAtPoint:point];
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
    [self loadBookCoverFromFileOrURL];
}

- (void)loadBookCoverFromFileOrURL {
    NSString *imagePath = [self coverImagePathForBook:[coversToLoad objectAtIndex:coversToLoadIndex]];
    UIImage *coverImage = [UIImage imageWithContentsOfFile:imagePath];
    if (coverImage) {
        // Send the image to book
        PTBookView *bookView = [bookList objectAtIndex:coversToLoadIndex];
        [bookView setCoverContentsWithImage:coverImage];
        
        // Before loading next cover, load first page of this book
        [self loadFirstPageFromFileOrURL];
    } else {
        NSDictionary *book = [books objectForKey:[coversToLoad objectAtIndex:coversToLoadIndex]];
        NSDictionary *cover = [book objectForKey:@"cover"];
        NSString *cover_bitmap_url = [[cover objectForKey:@"front"] objectForKey:@"bitmap"];
        
        // Load from URL (using the background thread)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^() {
            NSURL *url = [NSURL URLWithString:cover_bitmap_url];
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
            if (image == nil) {
                // TODO: Cover not loaded properly
            }
            
            // Cache image locally
            NSData *imageData = UIImageJPEGRepresentation(image, 1.0f);
            [imageData writeToFile:imagePath atomically:YES];
            
            // Apply to the book (in main thread)
            dispatch_async(dispatch_get_main_queue(), ^() {
                // Send the image to book
                PTBookView *bookView = [bookList objectAtIndex:coversToLoadIndex];
                [bookView setCoverContentsWithImage:image];

                // Before loading next cover, load first page of this book
                [self loadFirstPageFromFileOrURL];
            });
        });
    }
}

- (void)loadFirstPageFromFileOrURL {
    // Find proper book ID from covers-to-load array
    NSNumber *bookId = [coversToLoad objectAtIndex:coversToLoadIndex];

    // Search for local image first
    NSString *imagePath = [self pageImagePathForBook:bookId AndPageNumber:1];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    if (image) {
        // Send it to book view
        PTBookView *bookView = [bookList objectAtIndex:coversToLoadIndex];
        [bookView setPageContentsWithImage:image];
        
        // Load next cover
        coversToLoadIndex++;
        if (coversToLoadIndex < [coversToLoad count]) {
            [self loadBookCoverFromFileOrURL];
        }
    } else {
        NSMutableDictionary *book = [books objectForKey:bookId];
        NSMutableArray *pages = [book objectForKey:@"pages"];
        NSDictionary *page = [pages objectAtIndex:0];
        NSString *page_bitmap_url = [page objectForKey:@"bitmap"];
        
        // Load from URL (using the background thread)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^() {
            NSURL *url = [NSURL URLWithString:page_bitmap_url];
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
            if (image == nil) {
                // TODO: Page not loaded properly
            }            

            // Cache image locally
            NSData *imageData = UIImageJPEGRepresentation(image, 1.0f);
            [imageData writeToFile:imagePath atomically:YES];
            
            // Apply to the book (in main thread)
            dispatch_async(dispatch_get_main_queue(), ^() {
                // Send the image to book
                PTBookView *bookView = [bookList objectAtIndex:coversToLoadIndex];
                [bookView setPageContentsWithImage:image];
                
                // Load next cover
                coversToLoadIndex++;
                if (coversToLoadIndex < [coversToLoad count]) {
                    [self loadBookCoverFromFileOrURL];
                }
            });
        });
    }
}

#pragma mark -
#pragma mark Web view helpers/delegates

//- (BOOL)webView:(UIWebView *)thisWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
//    NSString *requestString = [[request URL] absoluteString];
//    NSArray *components = [requestString componentsSeparatedByString:@":"];
//    
//    // Check if JavaScript said web page has been loaded and render it to bitmap
//    if ([components count] > 1 && [(NSString *)[components objectAtIndex:0] isEqualToString:@"playtell"] && [(NSString *)[components objectAtIndex:1] isEqualToString:@"pageLoadFinished"]) {
//        NSInteger bookId = [(NSString *)[components objectAtIndex:2] intValue];
//        NSInteger pageNum = [(NSString *)[components objectAtIndex:3] intValue];
//        // Render page view to bitmap
//        [self convertWebViewPageToBitmapWithBookId:bookId andPageNumber:pageNum];
//        return NO;
//    } else if ([components count] > 1 && [(NSString *)[components objectAtIndex:0] isEqualToString:@"playtell"] && [(NSString *)[components objectAtIndex:1] isEqualToString:@"coverLoadFinished"]) {
//        NSInteger bookId = [(NSString *)[components objectAtIndex:2] intValue];
//        // Render cover view to bitmap
//        [self convertWebViewCoverToBitmapWithBookId:bookId];
//        return NO;
//    }
//    
//    return YES;
//}

//- (void)convertWebViewPageToBitmapWithBookId:(NSInteger)bookId andPageNumber:(NSInteger)pageNumber {
//    // Generate bitmaps
//    UIGraphicsBeginImageContext(webView.bounds.size);
//    [webView.layer renderInContext:UIGraphicsGetCurrentContext()];
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//
//    // Send the image to book
//    PTBookView *bookView = [bookList objectAtIndex:coversToLoadIndex];
//    [bookView setPageContentsWithImage:image];
//    
//    // Cache image locally
//    NSString *imagePath = [self pageImagePathForBook:[NSNumber numberWithInteger:bookId] AndPageNumber:pageNumber];
//    NSData *imageData = UIImageJPEGRepresentation(image, 1.0f);
//    [imageData writeToFile:imagePath atomically:YES];
//    
//    // Load next cover
//    coversToLoadIndex++;
//    if (coversToLoadIndex < [coversToLoad count]) {
//        [self loadBookCoverFromFileOrURL];
//    }
//}
//
//- (void)convertWebViewCoverToBitmapWithBookId:(NSInteger)bookId {
//    // Generate bitmaps
//    UIGraphicsBeginImageContext(CGSizeMake(webView.bounds.size.width / 2.0f, webView.bounds.size.height));
//    [webView.layer renderInContext:UIGraphicsGetCurrentContext()];
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//
//    // Send the image to book
//    PTBookView *bookView = [bookList objectAtIndex:coversToLoadIndex];
//    [bookView setCoverContentsWithImage:image];
//    
//    // Cache image locally
//    NSString *imagePath = [self coverImagePathForBook:[NSNumber numberWithInteger:bookId]];
//    NSData *imageData = UIImageJPEGRepresentation(image, 1.0f);
//    [imageData writeToFile:imagePath atomically:YES];
//    
//    // Before loading next cover, load first page of this book
//    [self loadFirstPageFromFileOrURL];
//}

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
        // Update status values
        isBookOpen = YES;
        [booksParentView setIsBookOpen:YES];

        // Prepare the pages
        [pagesScrollView setCurrentBook:[books objectForKey:bookId]];
        
        // Open the book
        [bookView open];
        [booksScrollView hideAllBooksExcept:(currentBookId)];
        
        // Start loading pages
        [self beginBookPageLoading];
        
        // Notify server of book open
        if (self.playdate) {
            PTBookChangeRequest *bookChangeRequest = [[PTBookChangeRequest alloc] init];
            [bookChangeRequest changeBookWithPlaydateId:[NSNumber numberWithInt:playdate.playdateID]
                                                 bookId:currentBookId
                                             pageNumber:[NSNumber numberWithInt:1]
                                              authToken:[[PTUser currentUser] authToken]
                                              onSuccess:nil
                                              onFailure:nil
             ];
        }
        
        // Show close book button
        [UIView animateWithDuration:(BOOK_OPEN_CLOSE_ANIMATION_SPEED + 0.25f) animations:^{
            closeBook.alpha = 1.0f;
        }];
    }
}

- (void)bookOpenedWithId:(NSNumber *)bookId AndView:(PTBookView *)bookView {
    currentBookId = [bookId copy];
    [pagesScrollView setHidden:NO];
    [bookView setHidden:YES];
}

- (void)bookClosedWithId:(NSNumber *)bookId AndView:(PTBookView *)bookView {
    isBookOpen = NO;
    [booksParentView setIsBookOpen:NO];
}

- (void)beginBookPageLoading {
    // Setup loading of pages for book
    NSMutableDictionary *book = [books objectForKey:currentBookId];
    currentPage = [[book objectForKey:@"current_page"] intValue];
    NSInteger totalPages = [[book objectForKey:@"total_pages"] intValue];
    
    // Build array of pages to load
    pagesToLoad = nil;
    pagesToLoad = [[NSMutableArray alloc] initWithCapacity:7];
    // Check if the page already has content
    PTPageView *pageView = [pagesScrollView getPageViewAtPageNumber:currentPage];
    if (!pageView.hasContent) {
        [pagesToLoad addObject:[NSNumber numberWithInt:currentPage]];
    }
    for (int i=1; i<=3; i++) {
        // Go X pages forward
        if ((currentPage+i) <= totalPages) {
            // Check if the page already has content
            pageView = [pagesScrollView getPageViewAtPageNumber:(currentPage+i)];
            if (!pageView.hasContent) {
                [pagesToLoad addObject:[NSNumber numberWithInt:(currentPage+i)]];
            }
        }
        // Go X pages backward
        if ((currentPage-i) > 0) {
            // Check if the page already has content
            pageView = [pagesScrollView getPageViewAtPageNumber:(currentPage-i)];
            if (!pageView.hasContent) {
                [pagesToLoad addObject:[NSNumber numberWithInt:(currentPage-i)]];
            }
        }
    }
    
    // Start page loading
    if ([pagesToLoad count] > 0 && isPageViewLoading == NO) {
        isPageViewLoading = YES;
        NSInteger pageNumber = [[pagesToLoad objectAtIndex:0] intValue];
        [pagesToLoad removeObjectAtIndex:0];
        pageView = [pagesScrollView getPageViewAtPageNumber:pageNumber];
        [pageView loadPage];
    }
}

#pragma mark -
#pragma mark Pages scroll delegates

- (void)pageTurnedTo:(NSInteger)number {
    // Reset page loading from new page number
    [self beginBookPageLoading];
    
    // Notify server of new page turn
    if (self.playdate) {
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
}

- (void)pageLoaded:(NSInteger)number {
    isPageViewLoading = NO;
    if ([pagesToLoad count] > 0) {
        isPageViewLoading = YES;
        NSInteger pageNumber = [[pagesToLoad objectAtIndex:0] intValue];
        [pagesToLoad removeObjectAtIndex:0];
        PTPageView *pageView = [pagesScrollView getPageViewAtPageNumber:pageNumber];
        [pageView loadPage];
    }
}

- (IBAction)closeBookButtonPressed:(id)sender {
    if (closeBook.alpha == 1.0f) {
        [self bookPinchClose];
    }
}

- (void)bookPinchClose {
    // Check if any books are even open
    if (isBookOpen == NO) {
        return;
    }
    isBookOpen = NO;
    
    // Find opened book view
    PTBookView *bookView = nil;
    for (int i=0, l=[books count]; i<l; i++) {
        if ([[(PTBookView *)[bookList objectAtIndex:i] getId] isEqualToNumber:currentBookId]) {
            bookView = (PTBookView *)[bookList objectAtIndex:i];
            break;
        }
    }
    
    // Notify server of book close
    if (self.playdate) {
        PTBookCloseRequest *bookCloseRequest = [[PTBookCloseRequest alloc] init];
        [bookCloseRequest closeBookWithPlaydateId:[NSNumber numberWithInt:playdate.playdateID]
                                           bookId:[bookView getId]
                                        authToken:[[PTUser currentUser] authToken]
                                        onSuccess:nil
                                        onFailure:nil
        ];
    }
    
    // Reset the views
    [self closeBookUsingBookView:bookView];
}

- (void)fingerTouchStartedAtPoint:(CGPoint)point {
    // Notify server
    PTPlaydateFingerTapRequest *playdateFingerTapRequest = [[PTPlaydateFingerTapRequest alloc] init];
    [playdateFingerTapRequest playdateFingerTapWithPlaydateId:[NSNumber numberWithInteger:self.playdate.playdateID]
                                                        point:point
                                                    authToken:[[PTUser currentUser] authToken]
                                                    onSuccess:nil
                                                    onFailure:nil
    ];
    
    // Add finger
    [self addFingerAtPoint:point initiatedBySelf:YES];
}

- (void)fingerTouchEndedAtPoint:(CGPoint)point {
    // Notify server
    PTPlaydateFingerEndRequest *playdateFingerEndRequest = [[PTPlaydateFingerEndRequest alloc] init];
    [playdateFingerEndRequest playdateFingerEndWithPlaydateId:[NSNumber numberWithInteger:self.playdate.playdateID]
                                                        point:point
                                                    authToken:[[PTUser currentUser] authToken]
                                                    onSuccess:nil
                                                    onFailure:nil
    ];
    
    // Remove finger
    [self removeFingerAtPoint:point];
}

- (void)pageShouldGoUp {
    // Is there a next page to go to?
    if (pagesScrollView.currentPage == pagesScrollView.totalPages) {
        return;
    }
    
    // Go to next page
    NSInteger newPageNumber = pagesScrollView.currentPage+1;
    [pagesScrollView navigateToPage:newPageNumber];
    
    // Update current page in the book obj
    NSMutableDictionary *book = [books objectForKey:currentBookId];
    [book setObject:[NSNumber numberWithInt:newPageNumber] forKey:@"current_page"];
    
    // Notify delegate to start loading new page content
    [self pageTurnedTo:newPageNumber];
}

- (void)pageShouldGoDown {
    // Is there a previous page to go to?
    if (pagesScrollView.currentPage == 1) {
        return;
    }
    
    // Go to previous page
    NSInteger newPageNumber = pagesScrollView.currentPage-1;
    [pagesScrollView navigateToPage:newPageNumber];
    
    // Update current page in the book obj
    NSMutableDictionary *book = [books objectForKey:currentBookId];
    [book setObject:[NSNumber numberWithInt:newPageNumber] forKey:@"current_page"];
    
    // Notify delegate to start loading new page content
    [self pageTurnedTo:newPageNumber];
}

#pragma mark -
#pragma mark Grandma Finger

- (void)addFingerAtPoint:(CGPoint)point initiatedBySelf:(BOOL)isInitiatedBySelf {
    // Create finger view
    UIImage *fingerImage;
    if (isInitiatedBySelf == YES) {
        fingerImage = [UIImage imageNamed:@"yourfinger"];
    } else {
        fingerImage = [UIImage imageNamed:@"friendfinger"];
    }
    CGSize fingerSize = fingerImage.size;
    UIImageView *fingerView = [[UIImageView alloc] initWithImage:fingerImage];
    fingerView.frame = CGRectMake(point.x-(fingerSize.width/2.0f)+pagesScrollView.frame.origin.x, point.y-(fingerSize.height/2.0f)+pagesScrollView.frame.origin.y, fingerSize.width, fingerSize.height);
    [fingerViews setObject:fingerView forKey:[NSValue valueWithCGPoint:point]];
    
    [self.view addSubview:fingerView];
}

- (void)removeFingerAtPoint:(CGPoint)point {
    // Remove finger view
    UIView *fingerView = [fingerViews objectForKey:[NSValue valueWithCGPoint:point]];
    [fingerView removeFromSuperview];
    
    // Clear from memory
    fingerView = nil;
}

@end