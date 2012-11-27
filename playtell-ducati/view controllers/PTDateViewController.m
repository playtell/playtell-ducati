//
//  PTDateViewController.m
//  playtell-ducati
//
//  Created by DisetPlaymatePhotomitry Bentsionov on 6/4/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <Opentok/Opentok.h>

#import "Logging.h"
#import "PTAnalytics.h"
#import "PTAppDelegate.h"
#import "TransitionController.h"
#import "UIColor+ColorFromHex.h"

//VIEW CONTROLLERS
#import "PTCreatePostcardViewController.h"
#import "PTDateViewController.h"
#import "PTDialpadViewController.h"
#import "PTBookView.h"
#import "PTChatHUDView.h"
#import "PTPageView.h"
#import "PTGameView.h"

//MODELS
#import "PTUser.h"
#import "PTCheckForPlaydateRequest.h"
#import "PTConcretePlaymateFactory.h"
#import "PTSoloUser.h"

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
#import "PTMatchingNewGameRequest.h"

//GAME VIEW CONTROLLERS
#import "PTTictactoeViewController.h"
#import "PTMemoryViewController.h"
#import "PTMatchingViewController.h"

@interface PTDateViewController ()
@property (nonatomic, weak) OTSubscriber* playmateSubscriber;
@property (nonatomic, weak) OTPublisher* myPublisher;
@property (nonatomic, strong) PTPlaymate* playmate;
@property (nonatomic, retain) AVAudioPlayer* audioPlayer;
@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTask;
@end

@implementation PTDateViewController
@synthesize playdate;
@synthesize playmateSubscriber;
@synthesize myPublisher;
@synthesize endPlaydate, endPlaydateForreal, closeBook, endPlaydatePopup, button2;
@synthesize chatController;
@synthesize playmate;
@synthesize delegate;
@synthesize audioPlayer;
@synthesize backgroundTask;

NSTimer *postcardTimer;

- (id)initWithPlaymate:(PTPlaymate*)aPlaymate
    chatViewController:(PTChatViewController*)aChatController {
    self = [super initWithNibName:@"PTDateViewController"
                           bundle:nil];
    if (self) {
        self.chatController = aChatController;
        [[self view] addSubview:aChatController.view];
        self.playmate = aPlaymate;
    }
    return self;
}

- (void)setPlaydate:(PTPlaydate *)aPlaydate {
    LogDebug(@"Setting playdate");
    playdate = aPlaydate;
    [self wireUpwireUpPlaydateConnections];

    PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
    self.chatController = appDelegate.chatController;
    [self.chatController setPlaydate:aPlaydate];
    [self.view addSubview:self.chatController.view];
    
    if ([aPlaydate isUserIDInitiator:[[PTUser currentUser] userID]]) {
        [self setupRinger];
        [self beginRinging];
        postcardTimer = [NSTimer scheduledTimerWithTimeInterval:10.0f
                                                         target:self
                                                       selector:@selector(showPostcardPrompt)
                                                       userInfo:nil
                                                        repeats:NO];
    } else {
        // Start taking automatic screenshots
        [self.chatController startAutomaticPicturesWithInterval:15.0];
    }
    
    // Set the start time for use with analytics
    playdateStart = [NSDate date];
    
    // Let the chat view change size
    [self.chatController restrictToSmallSize:NO];
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

//#if !(TARGET_IPHONE_SIMULATOR)
//#elif TARGET_OS_IPHONE
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
//#endif
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
    //listen for memory game
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pusherPlayDateMemoryNewGame:) name:@"PlayDateMemoryNewGame" object:nil];
    //listen for matching game
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pusherPlayDateMatchingNewGame:) name:@"PlayDateMatchingNewGame" object:nil];
    
    // Setup end playdate & close book buttons
    endPlaydate.layer.shadowColor = [UIColor blackColor].CGColor;
    endPlaydate.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    endPlaydate.layer.shadowOpacity = 0.2f;
    endPlaydate.layer.shadowRadius = 6.0f;
//    [endPlaydate setImage:[UIImage imageNamed:@"EndCallCrankPressed"] forState:UIControlStateHighlighted];
//    [endPlaydate setImage:[UIImage imageNamed:@"EndCallCrankPressed"] forState:UIControlStateSelected];
    [closeBook setImage:[UIImage imageNamed:@"CloseBookPressed"] forState:UIControlStateHighlighted];
    [closeBook setImage:[UIImage imageNamed:@"CloseBookPressed"] forState:UIControlStateSelected];
    closeBook.alpha = 0.0f;
    
    // Setup end playdate popup
    endPlaydatePopup.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"EndPlaydatePopupBg"]];
    endPlaydatePopup.hidden = YES;
}

- (void)showPostcardPrompt {
    UIView *prompt = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 150.0f)];
    prompt.backgroundColor = [UIColor colorFromHex:@"#2E4957"];
    
    UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(10.0f, 10.0f, prompt.frame.size.width - 20.0, 25.0)];
    title.textAlignment = UITextAlignmentCenter;
    title.textColor = [UIColor whiteColor];
    title.backgroundColor = [UIColor clearColor];
    title.font = [UIFont systemFontOfSize:title.frame.size.height - 5.0];
    title.text = @"Leave a Postcard";
    title.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [prompt addSubview:title];
    
    float iconWidth = 89.0f;
    float iconHeight = 67.0f;
    UIButton *icon = [[UIButton alloc] initWithFrame:CGRectMake((prompt.frame.size.width - iconWidth) / 2, (prompt.frame.size.height - iconHeight) / 2, iconWidth, iconHeight)];
    [icon setBackgroundImage:[UIImage imageNamed:@"postcard-icon.png"] forState:UIControlStateNormal];
    [icon addTarget:self action:@selector(showPostcardView) forControlEvents:UIControlEventTouchUpInside];
    icon.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [prompt addSubview:icon];
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(icon.frame.origin.x, icon.frame.origin.y + icon.frame.size.height + 5.0, icon.frame.size.width, 30.0)];
    [button setBackgroundImage:[UIImage imageNamed:@"bluebutton.png"] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"bluebutton-press.png"] forState:UIControlStateHighlighted];
    [button setTitle:@"Postcard" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(showPostcardView) forControlEvents:UIControlEventTouchUpInside];
    button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [prompt addSubview:button];
    
    PTChatHUDView *chatView = (PTChatHUDView *)self.chatController.leftView;
    [chatView setView:prompt];
}

- (void)showPostcardView {
    // Stop any ongoing events
    [self endRinging];
    [self.chatController stopAutomaticPictures];
    
    // Get the view sizes for transitioning the postcard view
    float height = self.view.frame.size.height;
    float width = self.view.frame.size.width;
    
    [self.view bringSubviewToFront:endPlaydate];
    
    PTCreatePostcardViewController *postcardController = [[PTCreatePostcardViewController alloc] init];
    postcardController.delegate = self;
    postcardController.playmateId = self.playdate.playmate.userID;
    postcardController.view.frame = CGRectMake(0.0f, 0.0f, width, height);
    [self.view insertSubview:postcardController.view belowSubview:background];
    
    float margin = 50.0f;
    
    [UIView animateWithDuration:1.0f animations:^{
        background.frame = CGRectMake(margin, height, width - (2 * margin), height);
        booksParentView.frame = CGRectOffset(booksParentView.frame, 0.0f, height);
        pagesScrollView.frame = CGRectOffset(pagesScrollView.frame, 0.0f, height);
        self.chatController.view.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [postcardController startPhotoCountdown];
    }];
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
            
            // Make sure this file isn't backed up by iCloud
            [self addSkipBackupAttributeToItemAtURLstring:path];
            
            // Load the actual views
            dispatch_async(dispatch_get_main_queue(), ^() {
                 [self loadBookViewsFromDictionary];
            });
        } else {
            // Figure out which books are new
            NSMutableArray *apiBooks = [[NSMutableArray alloc] init];
            NSMutableArray *newBooks = [[NSMutableArray alloc] init];
            NSInteger oldTotalForBooks = [[books allKeys] count];
            for (NSDictionary *book in allBooks) {
                NSNumber *bookId = [book objectForKey:@"id"];
                [apiBooks addObject:bookId];
                if ([books objectForKey:bookId] == nil) {
                    [newBooks addObject:bookId];
                    [books setObject:[[NSMutableDictionary alloc] initWithDictionary:book] forKey:bookId];
                }
            }
            
            // Figure out which books are old (aka, no longer returned by API)
            NSMutableArray *oldBooks = [[NSMutableArray alloc] init];
            NSArray *allBookIds = [books allKeys];
            for (NSNumber *bookId in allBookIds) {
                // Check if stored book id no longer exists
                if ([apiBooks indexOfObject:bookId] == NSNotFound) {
                    [oldBooks addObject:bookId];
                    [books removeObjectForKey:bookId];
                }
            }
            oldTotalForBooks = oldTotalForBooks - [oldBooks count];
            
            // If there are books to add to remove, re-draw the books views
            if ([newBooks count] > 0 || [oldBooks count] > 0) {
                // Write book list to plist file
                NSMutableArray *writeData = [[NSMutableArray alloc] init];
                for (NSNumber *bookId in books) {
                    [writeData addObject:[books objectForKey:bookId]];
                }
                [writeData writeToFile:path atomically:YES];
                
                // Make sure this file isn't backed up by iCloud
                [self addSkipBackupAttributeToItemAtURLstring:path];

                // Load the actual views
                dispatch_async(dispatch_get_main_queue(), ^() {
                    [self loadBookViewsFromDictionary];
                });
            }
            
//            // If there are new books, create views for them and load their covers
//            if ([newBooks count] > 0) {
//                // Create new book views
//                BOOL restartCoversLoad = (coversToLoadIndex == [coversToLoad count]); // This means original covers load has finished
//                CGFloat xPos = (booksScrollView.frame.size.width * oldTotalForBooks) + (800.0f - booksScrollView.frame.size.width) / -2.0f; // full width (800) - scrollview width (350) divided by 2 (centered)
//                PTBookView *bookView;
//                for (int i=0; i<[newBooks count]; i++) {
//                    NSNumber *bookId = [newBooks objectAtIndex:i];
//                    NSMutableDictionary *book = [books objectForKey:bookId];
//                    bookView = [[PTBookView alloc] initWithFrame:CGRectMake(xPos, 0.0f, 800.0f, 600.0f) andBook:book]; // 800x600
//                    [bookView setBookPosition:(oldTotalForBooks + i)];
//                    [bookView setDelegate:self];
//                    [booksScrollView addSubview:bookView];
//                    xPos += booksScrollView.frame.size.width;
//                    i++;
//                    [bookList addObject:bookView];
//                    
//                    // Book cover pages load
//                    [coversToLoad addObject:bookId];
//                }
//                
//                // Update scroll view width (based on # of books)
//                CGFloat scroll_width = booksScrollView.frame.size.width * [books count];
//                [booksScrollView setContentSize:CGSizeMake(scroll_width, 600.0f)];
//                
//                // Start loading book covers
//                if (restartCoversLoad) {
//                    [self loadBookCoverFromFileOrURL];
//                }
//                
//                // Write book list to plist file
//                NSMutableArray *writeData = [[NSMutableArray alloc] init];
//                for (NSNumber *bookId in books) {
//                    [writeData addObject:[books objectForKey:bookId]];
//                }
//                [writeData writeToFile:path atomically:YES];
//            }
        }
    } onFailure:nil];
}

- (void)loadBookViewsFromDictionary {
    // Empty book views container
    [[booksScrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];

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
    
    // Load the game views (hardcoded for now)
    gameList = [[NSMutableArray alloc] initWithCapacity:2];

    PTGameView *gameView1 = [[PTGameView alloc] initWithFrame:CGRectMake(xPos, 0.0f, 800.0f, 600.0f)
                                                       gameId:1
                                                     gameLogo:[UIImage imageNamed:@"Memory-logo"]];
    [gameView1 setPosition:i];
    [gameView1 setDelegate:self];
    [booksScrollView addSubview:gameView1];
    [gameList addObject:gameView1];
    
    xPos += booksScrollView.frame.size.width;
    i++;
    
    PTGameView *gameView2 = [[PTGameView alloc] initWithFrame:CGRectMake(xPos, 0.0f, 800.0f, 600.0f)
                                                       gameId:2
                                                     gameLogo:[UIImage imageNamed:@"TTT-logo"]];
    [gameView2 setPosition:i];
    [gameView2 setDelegate:self];
    [booksScrollView addSubview:gameView2];
    [gameList addObject:gameView2];
    
    xPos += booksScrollView.frame.size.width;
    i++;
    
    PTGameView *gameView3 = [[PTGameView alloc] initWithFrame:CGRectMake(xPos, 0.0f, 800.0f, 600.0f)
                                                       gameId:3
                                                     gameLogo:[UIImage imageNamed:@"matching-logo"]];
    [gameView3 setPosition:i];
    [gameView3 setDelegate:self];
    //[booksScrollView addSubview:gameView3];
    //[gameList addObject:gameView3];
    
    // Update scroll view width (based on # of books)
    CGFloat scroll_width = booksScrollView.frame.size.width * ([books count] + 2); // 3 hardcoded games
    [booksScrollView setDelegate:self];
    [booksScrollView setContentSize:CGSizeMake(scroll_width, 600.0f)];
    isBookOpen = NO;

    // Start loading book covers
    [self loadBookCovers];
    isPageViewLoading = NO;
}

- (void)ticTacToeTapped:(UIGestureRecognizer*)tapRecognizer {
    // Only allow a game to be played if the delegate allows it
    if (![self delegateAllowsPlayingGames]) {
        return;
    }
    
    [self playTictactoe:nil];
}

- (void)memoryTapped:(UIGestureRecognizer*)tapRecognizer {
    // Only allow a game to be played if the delegate allows it
    if (![self delegateAllowsPlayingGames]) {
        return;
    }
    [self playMemoryGame:nil];
}

- (BOOL)delegateAllowsPlayingGames {
    if (self.delegate && [self.delegate respondsToSelector:@selector(dateViewControllerShouldPlayGame:)]) {
        return [self.delegate dateViewControllerShouldPlayGame:self];
    }
    
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // If the chat controller has been created, go ahead an add it
    if (self.chatController) {
        [self.view addSubview:self.chatController.view];
    }
    
    // Subscribe to playmate joined events so we can use analytics
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pusherDidReceivePlaydateJoinedNotification:)
                                                 name:PTPlayTellPusherDidReceivePlaydateJoinedEvent
                                               object:nil];
    
    // Subscribe to backgrounding notifications, so we can subscribe to foregrounding
    // notifications at the time of backgrounding.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dateControllerDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    // Remove borders from chat hud
    [self.chatController hideAllBorders];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // Alert the delegate the DateViewController will appear
    if (self.delegate && [self.delegate respondsToSelector:@selector(dateViewControllerWillAppear:)]) {
        [self.delegate dateViewControllerWillAppear:self];
    }
}

- (void)dateControllerDidEnterBackground:(NSNotification*)note {
    // We don't want to record an interrupted session in analytics, so clear the start time
    bookStart = nil;
    playdateStart = nil;
    
    // Subscribe to foregrounding changes. The date controller will need to check the validity
    // of the current playdate any time it re-enters the foreground (as the playmate may have
    // terminated the playdate in the interim).
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dateControllerWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dateControllerDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
#if !(TARGET_IPHONE_SIMULATOR)
    backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler: ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (backgroundTask != UIBackgroundTaskInvalid)
            {
                [[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
                backgroundTask = UIBackgroundTaskInvalid;
            }
        });
    }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Here goes your operation
        [self removePlaymateFromChatHUD];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (backgroundTask != UIBackgroundTaskInvalid)
            {
                // if you don't call endBackgroundTask, the OS will exit your app.
                [[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
                backgroundTask = UIBackgroundTaskInvalid;
            }
        });
    });
#endif
}

- (void)removePlaymateFromChatHUD {
    // Remove the chat hud from view
    [self.chatController disconnectOpenTokSession];
    [self.chatController.view removeFromSuperview];
    [self.chatController setPlaymate:nil];
    [self.chatController configureForDialpad];
    
    // We don't setup these, so not sure why these calls are in here
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
}

- (void)dateControllerDidBecomeActive:(NSNotification*)note {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
    
#if !(TARGET_IPHONE_SIMULATOR)
    PTPlaymate *partner;
    if ([self.playdate isUserIDInitiator:[[PTUser currentUser] userID]]) {
        partner = self.playdate.playmate;
    } else {
        partner = self.playdate.initiator;
    }
    
    PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
    self.chatController = appDelegate.chatController;
    [self.view addSubview:self.chatController.view];
    [self.chatController setPlaymate:partner];
    [self.chatController setLoadingViewForPlaymate:partner];
    [self.chatController connectToOpenTokSession];
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
    [postcardTimer invalidate];
    
    // Send analytics an event for playdate ending
    if (playdateStart) {
        NSTimeInterval interval = fabs([playdateStart timeIntervalSinceNow]);
        playdateStart = nil;
        
        PTPlaymate *partner;
        if ([self.playdate isUserIDInitiator:[[PTUser currentUser] userID]]) {
            partner = self.playdate.playmate;
        } else {
            partner = self.playdate.initiator;
        }
        
        [PTAnalytics sendEventNamed:EventPlaydateEnded withProperties:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:interval], PropDuration,
                                         partner.username, PropPlaymateId, nil]];
    }
    
    // Shutoff the ringer
    [self endRinging];
    
    // Stop taking automatic screenshots
    [self.chatController stopAutomaticPictures];
    
    [self.chatController setLeftViewAsPlaceholder];
    [self.chatController configureForDialpad];
    //[self.chatController connectToPlaceholderOpenTokSession];
    
    PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
    if (appDelegate.dialpadController.loadingView != nil) {
        [appDelegate.dialpadController.loadingView removeFromSuperview];
    }
    [appDelegate.transitionController transitionToViewController:appDelegate.dialpadController
                                                     withOptions:UIViewAnimationOptionTransitionCrossDissolve];
    
    // Restrict the size of the chat view
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.chatController restrictToSmallSize:YES];
        
        // Remove borders from chat hud
        [self.chatController hideAllBorders];
        
        // Make sure the chat hud is visible
        self.chatController.view.alpha = 1.0f;
    });
}

- (IBAction)playdateDisconnect:(id)sender {    
//    // Notify server of disconnect
//    [self disconnectPusherAndChat];
//    if (self.playdate) {
//        PTPlaydateDisconnectRequest *playdateDisconnectRequest = [[PTPlaydateDisconnectRequest alloc] init];
//        [playdateDisconnectRequest playdateDisconnectWithPlaydateId:[NSNumber numberWithInt:playdate.playdateID]
//                                                          authToken:[[PTUser currentUser] authToken]
//                                                          onSuccess:^(NSDictionary* result)
//        {
//            // We delay moving to the dialpad because it will be checking for
//            // playdates when it appears
//            [self transitionToDialpad];
//        }
//                                                          onFailure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
//        {
//            [self transitionToDialpad];
//        }];
//    }
}

- (IBAction)endPlaydatePopupToggle:(id)sender {
//    if (endPlaydatePopup.hidden) {
//        endPlaydatePopup.hidden = NO;
//    } else {
//        endPlaydatePopup.hidden = YES;
//    }
    if (playdateEndViewController == nil || playdateEndPopover == nil) {
        playdateEndViewController = [[PTPlaydateEndViewController alloc] initWithNibName:@"PTPlaydateEndViewController" bundle:nil];
        playdateEndViewController.delegate = self;
        playdateEndPopover = [[UIPopoverController alloc] initWithContentViewController:playdateEndViewController];
        playdateEndPopover.popoverContentSize = CGSizeMake(205.0f, 60.0f);
    }

    [playdateEndPopover presentPopoverFromRect:endPlaydate.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
}

- (IBAction)playTictactoe:(id)sender {
    PTPlaymate *aPlaymate;
    PTTictactoeNewGameRequest *newGameRequest = [[PTTictactoeNewGameRequest alloc] init];
    if ([self.playdate isUserIDInitiator:[[PTUser currentUser] userID]]) {
        LogInfo(@"Current user is initator. Playmate is playmate.");
        aPlaymate = self.playdate.playmate;
        
    } else {
        LogInfo(@"Current user is NOT initiator. Playmate is initiator");
        aPlaymate = self.playdate.initiator;
    }
    
    if (self.playdate == nil || [self.playdate.playmate isARobot]) {
        PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
        
        PTTictactoeViewController *tictactoeVc = [[PTTictactoeViewController alloc] init];
        [tictactoeVc setChatController:self.chatController];
        [tictactoeVc setPlaydate:self.playdate];
        [tictactoeVc initGameWithMyTurn:YES];
        tictactoeVc.board_id = 0;
        tictactoeVc.playmate_id = aPlaymate.userID;
        tictactoeVc.initiator_id = [[PTUser currentUser] userID];
        
        CGRect imageframe = CGRectMake(0,0,1024,768);
        
        UIImageView *splash =  [[UIImageView alloc] initWithFrame:imageframe];
        splash.image = [UIImage imageNamed:@"TTT-cover.png"];
        
        //bring up the view controller of the new game!
        [appDelegate.transitionController loadGame:tictactoeVc
                                       withOptions:UIViewAnimationOptionTransitionCurlUp withSplash:splash];
        return;
    }
    
    [newGameRequest newBoardWithPlaydateId:[NSNumber numberWithInt:playdate.playdateID]
                                authToken:[[PTUser currentUser] authToken]
                                playmate_id:[NSString stringWithFormat:@"%d", aPlaymate.userID]
                                initiatorId:[NSString stringWithFormat:@"%d", [[PTUser currentUser] userID]]
                                 onSuccess:^(NSDictionary *result)
     {
         NSLog(@"%@", result);  //TODOGIANCARLO valueforkey@"games"
         
         // Send analytics an event for starting the game
         [PTAnalytics sendEventNamed:EventGamePlayed withProperties:[NSDictionary dictionaryWithObjectsAndKeys:@"Tictactoe", PropGameName,
                                          aPlaymate.username, PropPlaymateId, nil]];
         
         NSString *board_id = [result valueForKey:@"board_id"];
         
         PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
                  
         PTTictactoeViewController *tictactoeVc = [[PTTictactoeViewController alloc] init];
         [tictactoeVc setChatController:self.chatController];
         [tictactoeVc setPlaydate:self.playdate];
         [tictactoeVc initGameWithMyTurn:YES];
         tictactoeVc.board_id = [board_id intValue];
         tictactoeVc.playmate_id = aPlaymate.userID;
         tictactoeVc.initiator_id = [[PTUser currentUser] userID];
                  
         CGRect imageframe = CGRectMake(0,0,1024,768);

         UIImageView *splash =  [[UIImageView alloc] initWithFrame:imageframe];
         splash.image = [UIImage imageNamed:@"TTT-cover.png"];
         
         //bring up the view controller of the new game!
         [appDelegate.transitionController loadGame:tictactoeVc
                                                          withOptions:UIViewAnimationOptionTransitionCurlUp withSplash:splash];
     } onFailure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
         NSLog(@"%@", error);
         NSLog(@"%@", request);
         NSLog(@"%@", JSON);
     }];
}

- (IBAction)playMemoryGame:(id)sender {
//    int numCards = NUM_MEMORY_CARDS;
    
    // Find playmate user id
    PTPlaymate *aPlaymate;
    if ([self.playdate isUserIDInitiator:[[PTUser currentUser] userID]]) {
        aPlaymate = self.playdate.playmate;
    } else {
        aPlaymate = self.playdate.initiator;
    }
    
    if (self.playdate == nil || [aPlaymate isARobot]) {
        PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
        
        PTMemoryViewController *memoryVC = [[PTMemoryViewController alloc] initWithNibName:@"PTMemoryViewController"
                                                                                    bundle:nil
                                                                                  playdate:self.playdate
                                                                                    myTurn:YES
                                                                                   boardID:0
                                                                                playmateID:aPlaymate.userID
                                                                               initiatorID:[[PTUser currentUser] userID]
                                                                              allFilenames:[NSArray arrayWithObjects:nil]
                                                                                  numCards:4];
        [memoryVC setChatController:self.chatController];
        
        // Init game splash
        UIImageView *splash =  [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 1024.0f, 768.0f)];
        splash.image = [UIImage imageNamed:@"Memory-cover.png"];
        
        // Bring up the view controller of the new game
        [appDelegate.transitionController loadGame:memoryVC
                                       withOptions:UIViewAnimationOptionTransitionCurlUp
                                        withSplash:splash];
        return;
    }
    
    NSInteger randNumCards = 2 * (arc4random_uniform(4) + 2); // Random number from 2 to 6 multiplied by 2 to get an even number from 2 to 12

    PTMemoryNewGameRequest *newGameRequest = [[PTMemoryNewGameRequest alloc] init];
    [newGameRequest newBoardWithPlaydate_id:[NSString stringWithFormat:@"%d", self.playdate.playdateID]
                                 auth_token:[[PTUser currentUser] authToken]
                                playmate_id:[NSString stringWithFormat:@"%d", aPlaymate.userID]
                                initiatorId:[NSString stringWithFormat:@"%d", [[PTUser currentUser] userID]]
                                   theme_ID:@"19"
                            num_total_cards:[NSString stringWithFormat:@"%d", randNumCards]
                                  onSuccess:^(NSDictionary *result) {
                                      // Send analytics an event for starting the game
                                      [PTAnalytics sendEventNamed:EventGamePlayed withProperties:[NSDictionary dictionaryWithObjectsAndKeys:@"Memory", PropGameName, aPlaymate.username, PropPlaymateId, nil]];
                                      
                                      // Get response parameters
                                      NSString *board_id = [result valueForKey:@"board_id"];
                                      NSString *filenames = [result valueForKey:@"filename_dump"];
                                      filenames = [filenames substringWithRange:NSMakeRange(2, [filenames length] - 4)];
                                      NSArray *allFilenames = [filenames componentsSeparatedByString:@"\",\""];
                                      
                                      PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
                                      
                                      PTMemoryViewController *memoryVC = [[PTMemoryViewController alloc] initWithNibName:@"PTMemoryViewController"
                                                                                                                  bundle:nil
                                                                                                                playdate:self.playdate
                                                                                                                  myTurn:YES
                                                                                                                 boardID:[board_id integerValue]
                                                                                                              playmateID:aPlaymate.userID
                                                                                                             initiatorID:[[PTUser currentUser] userID]
                                                                                                            allFilenames:allFilenames
                                                                                                                numCards:randNumCards];
                                      [memoryVC setChatController:self.chatController];
                                     
                                      // Init game splash
                                      UIImageView *splash =  [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 1024.0f, 768.0f)];
                                      splash.image = [UIImage imageNamed:@"Memory-cover.png"];
                                      
                                      // Bring up the view controller of the new game
                                      [appDelegate.transitionController loadGame:memoryVC
                                                                     withOptions:UIViewAnimationOptionTransitionCurlUp
                                                                      withSplash:splash];
    } onFailure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"New game API error: %@", error);
        NSLog(@"%@", request);
        NSLog(@"%@", JSON);
    }];
}

- (void)matchingTapped:(id)sender {
    // Only allow a game to be played if the delegate allows it
    if (![self delegateAllowsPlayingGames]) {
        return;
    }

    // Find playmate user id
    PTPlaymate *aPlaymate;
    if ([self.playdate isUserIDInitiator:[[PTUser currentUser] userID]]) {
        aPlaymate = self.playdate.playmate;
    } else {
        aPlaymate = self.playdate.initiator;
    }
    
    NSInteger randNumCards = 2 * (arc4random_uniform(4) + 2); // Random number from 2 to 6 multiplied by 2 to get an even number from 2 to 12
    
    if (self.playdate == nil || [aPlaymate isARobot]) {
        // Create a fake filename array
        NSArray *filenames = [NSArray arrayWithObjects:@"theme19artwork1_r.png", @"theme19artwork2_r.png", @"theme19artwork3_r.png", @"theme19artwork2_l.png", @"theme19artwork3_l.png", @"theme19artwork1_l.png", nil];
        
        // Create a fake cardsString
        NSString *cardsString = @"1,2,3,2,3,1";
        
        // Init the game controller
        PTMatchingViewController *matchingViewController = [[PTMatchingViewController alloc]
                                                            initWithNibName:@"PTMatchingViewController"
                                                            bundle:nil
                                                            playdate:self.playdate
                                                            boardId:0
                                                            themeId:19 // TODO: Hard coded
                                                            initiator:[PTUser currentUser]
                                                            playmate:aPlaymate
                                                            filenames:filenames
                                                            totalCards:6
                                                            cardsString:cardsString
                                                            myTurn:YES];
        matchingViewController.chatController = self.chatController;
        
        
        // Init game splash
        UIImageView *splash =  [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 1024.0f, 768.0f)];
        splash.image = [UIImage imageNamed:@"matching-splash"];
        
        // Bring up the view controller of the new game
        PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
        [appDelegate.transitionController loadGame:matchingViewController
                                       withOptions:UIViewAnimationOptionTransitionCurlUp
                                        withSplash:splash];
        return;
    }
    
    PTMatchingNewGameRequest *newGameRequest = [[PTMatchingNewGameRequest alloc] init];
    [newGameRequest newBoardWithPlaydateId:self.playdate.playdateID
                                 playmateId:aPlaymate.userID
                                    themeId:19 // TODO: Hard coded
                                   numCards:randNumCards
                                  authToken:[[PTUser currentUser] authToken]
                                  onSuccess:^(NSDictionary *result) {
                                      // Send analytics an event for starting the game
                                      [PTAnalytics sendEventNamed:EventGamePlayed withProperties:[NSDictionary dictionaryWithObjectsAndKeys:@"Matching", PropGameName, aPlaymate.username, PropPlaymateId, nil]];
                                      
                                      // Get response parameters
                                      NSInteger boardId = [[result valueForKey:@"board_id"] integerValue];
                                      NSString *filenamesFlat = [result valueForKey:@"filename_dump"];
                                      filenamesFlat = [filenamesFlat substringWithRange:NSMakeRange(2, [filenamesFlat length] - 4)];
                                      NSArray *filenames = [filenamesFlat componentsSeparatedByString:@"\",\""];
                                      NSString *cardsString = [result valueForKey:@"card_array_string"];
                                      
                                      // Init the game controller
                                      PTMatchingViewController *matchingViewController = [[PTMatchingViewController alloc]
                                                                                          initWithNibName:@"PTMatchingViewController"
                                                                                          bundle:nil
                                                                                          playdate:self.playdate
                                                                                          boardId:boardId
                                                                                          themeId:19 // TODO: Hard coded
                                                                                          initiator:[PTUser currentUser]
                                                                                          playmate:aPlaymate
                                                                                          filenames:filenames
                                                                                          totalCards:randNumCards
                                                                                          cardsString:cardsString
                                                                                          myTurn:YES];
                                      matchingViewController.chatController = self.chatController;
                                      
                                      
                                      // Init game splash
                                      UIImageView *splash =  [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 1024.0f, 768.0f)];
                                      splash.image = [UIImage imageNamed:@"matching-splash"];
                                      
                                      // Bring up the view controller of the new game
                                      PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
                                      [appDelegate.transitionController loadGame:matchingViewController
                                                                     withOptions:UIViewAnimationOptionTransitionCurlUp
                                                                      withSplash:splash];
                                  }
                                  onFailure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                      NSLog(@"New game API error: %@", error);
                                      NSLog(@"%@", request);
                                      NSLog(@"%@", JSON);
                                  }];
}

- (IBAction)endPlaydateHandle:(id)sender {
    [postcardTimer invalidate];

    // Alert the delegate of playdate end
    if (self.delegate && [self.delegate respondsToSelector:@selector(dateViewControllerDidEndPlaydate:)]) {
        [self.delegate dateViewControllerDidEndPlaydate:self];
    }

    if ([self.playmate isARobot]) {
        [self transitionToDialpad];
    }
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - Pusher notification handlers

- (void)pusherDidReceivePlaydateJoinedNotification:(NSNotification*)note {
    PTPlaydate* joinedPlaydate = [[note userInfo] valueForKey:PTPlaydateKey];
    
    // Make sure the information is about this playdate
    if (joinedPlaydate.initiator.userID == [[PTUser currentUser] userID] && joinedPlaydate.playmate.userID == playmate.userID) {
        [postcardTimer invalidate];
        
        // Send analytics event for joining a playdate
        [PTAnalytics sendEventNamed:EventPlaymateJoinedMyPlaydate withProperties:[NSDictionary dictionaryWithObjectsAndKeys:playmate.username, PropPlaymateId, nil]];
        
        [self endRinging];
        
        // Start taking automatic pictures
        [self.chatController startAutomaticPicturesWithInterval:15.0f];
    }
}

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
    // Alert the delegate a book will close
    if (self.delegate && [self.delegate respondsToSelector:@selector(dateViewcontrollerWillCloseBook:)]) {
        [self.delegate dateViewcontrollerWillCloseBook:self];
    }

    // Reset page loading
    [pagesToLoad removeAllObjects];
    isPageViewLoading = NO;
    
    // Hide close book button
    [UIView animateWithDuration:BOOK_OPEN_CLOSE_ANIMATION_SPEED animations:^{
        closeBook.alpha = 0.0f;
    }];

    // Close book, hide pages, show all other books and games
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
        [self showAllGameViews];
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
        [tictactoeVc setChatController:self.chatController];
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
                                                         withOptions:UIViewAnimationOptionTransitionCrossDissolve withSplash:splash];
    }
}

- (void)pusherPlayDateMemoryNewGame:(NSNotification *)notification {
    NSDictionary *eventData = notification.userInfo;
    NSInteger initiator_id = [[eventData objectForKey:@"initiator_id"] integerValue];
    NSInteger board_id = [[eventData objectForKey:@"board_id"] integerValue];
    NSInteger numCards = [[eventData objectForKey:@"num_cards"] integerValue];
    NSString *filenames = [eventData objectForKey:@"filename_dump"];
    filenames = [filenames substringWithRange:NSMakeRange(2, [filenames length] - 4)];
    NSArray *allFilenames = [filenames componentsSeparatedByString:@"\",\""];
    
    PTPlaymate *aPlaymate;
    if ([self.playdate isUserIDInitiator:[[PTUser currentUser] userID]]) {
        aPlaymate = self.playdate.playmate;
    } else {
        aPlaymate = self.playdate.initiator;
    }
    
    // Someone invited us to play
    if (initiator_id != [[PTUser currentUser] userID]) {
        PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
        
        PTMemoryViewController *memoryVC = [[PTMemoryViewController alloc] initWithNibName:@"PTMemoryViewController"
                                                                                    bundle:nil
                                                                                  playdate:self.playdate
                                                                                    myTurn:NO
                                                                                   boardID:board_id
                                                                                playmateID:[[PTUser currentUser] userID]
                                                                               initiatorID:aPlaymate.userID
                                                                              allFilenames:allFilenames
                                                                                  numCards:numCards];
        [memoryVC setChatController:self.chatController];

        // Init game splash
        UIImageView *splash =  [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 1024.0f, 768.0f)];
        splash.image = [UIImage imageNamed:@"Memory-cover.png"];

        // Bring up the view controller of the new game
        [appDelegate.transitionController loadGame:memoryVC
                                       withOptions:UIViewAnimationOptionTransitionCurlUp
                                        withSplash:splash];
    }
}

- (void)pusherPlayDateMatchingNewGame:(NSNotification *)notification {
    NSDictionary *eventData = notification.userInfo;

    // Get response parameters
    NSInteger initiatorId = [[eventData objectForKey:@"initiator_id"] integerValue];
    NSInteger boardId = [[eventData objectForKey:@"board_id"] integerValue];
    NSInteger totalCards = [[eventData objectForKey:@"num_cards"] integerValue];
    NSString *filenamesFlat = [eventData valueForKey:@"filename_dump"];
    filenamesFlat = [filenamesFlat substringWithRange:NSMakeRange(2, [filenamesFlat length] - 4)];
    NSArray *filenames = [filenamesFlat componentsSeparatedByString:@"\",\""];
    NSString *cardsString = [eventData valueForKey:@"card_array_string"];
    
    PTPlaymate *aPlaymate;
    if ([self.playdate isUserIDInitiator:[[PTUser currentUser] userID]]) {
        aPlaymate = self.playdate.playmate;
    } else {
        aPlaymate = self.playdate.initiator;
    }
    
    // Someone invited us to play
    if (initiatorId != [[PTUser currentUser] userID]) {
        // Init the game controller
        PTMatchingViewController *matchingViewController = [[PTMatchingViewController alloc]
                                                            initWithNibName:@"PTMatchingViewController"
                                                            bundle:nil
                                                            playdate:self.playdate
                                                            boardId:boardId
                                                            themeId:19 // TODO: Hard coded
                                                            initiator:[PTUser currentUser]
                                                            playmate:aPlaymate
                                                            filenames:filenames
                                                            totalCards:totalCards
                                                            cardsString:cardsString
                                                            myTurn:NO];
        matchingViewController.chatController = self.chatController;
        
        // Init game splash
        UIImageView *splash =  [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 1024.0f, 768.0f)];
        splash.image = [UIImage imageNamed:@"matching-splash"];
        
        // Bring up the view controller of the new game
        PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
        [appDelegate.transitionController loadGame:matchingViewController
                                       withOptions:UIViewAnimationOptionTransitionCurlUp
                                        withSplash:splash];
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

#pragma mark - Covers/pages loading

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
            
            // Make sure this file isn't backed up by iCloud
            [self addSkipBackupAttributeToItemAtURLstring:imagePath];
            
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
            
            // Make sure this file isn't backed up by iCloud
            [self addSkipBackupAttributeToItemAtURLstring:imagePath];
            
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

#pragma mark - Documents filesys helpers

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

- (BOOL)addSkipBackupAttributeToItemAtURLstring:(NSString *)URLstring {
    NSURL *URL = [[NSURL alloc] initFileURLWithPath:URLstring];
    assert([[NSFileManager defaultManager] fileExistsAtPath:[URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool:YES]
                                  forKey: NSURLIsExcludedFromBackupKey error:&error];
    if (!success) {
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

#pragma mark - Books scroll delegates

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Adjust size/opacity of each book as they scroll
    CGFloat x = scrollView.contentOffset.x;
    CGFloat width = booksScrollView.frame.size.width;
    for (int i=0, l=[books count]; i<l; i++) {
        CGFloat pos = ABS(i * width - x);
        if (pos < (width * 2.0f)) { // Ignore all the views out of view (whole view fits about 3 books)
            CGFloat level = 1.0f - pos / width;
            [(PTBookView *)[bookList objectAtIndex:i] setFocusLevel:level];
        }
    }
    
    // Same for each game
    for (int i=0, l=[gameList count]; i<l; i++) {
        int actual_i = i + [books count];
        CGFloat pos = ABS(actual_i * width - x);
        if (pos < (width * 2.0f)) { // Ignore all the views out of view (whole view fits about 3 books)
            CGFloat level = 1.0f - pos / width;
            [(PTGameView *)[gameList objectAtIndex:i] setFocusLevel:level];
        }
    }
}

#pragma mark - Book delegates

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
        
        // Hide all other books views
        [booksScrollView hideAllBooksExcept:(currentBookId)];
        
        // Hide all games views
        [self hideAllGameViews];
        
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

- (UIView*)openBookView {
    return pagesScrollView;
}

- (void)bookOpenedWithId:(NSNumber *)bookId AndView:(PTBookView *)bookView {
    currentBookId = [bookId copy];
    [pagesScrollView setHidden:NO];
    [bookView setHidden:YES];
    
    // Alert the delegate of the book opening
    if (self.delegate && [self.delegate respondsToSelector:@selector(dateViewController:didOpenBookWithID:)]) {
        [self.delegate dateViewController:self didOpenBookWithID:[bookId integerValue]];
    }
    
    // Record the time of book opening for analytics
    bookStart = [NSDate date];
}

- (void)bookClosedWithId:(NSNumber *)bookId AndView:(PTBookView *)bookView {
    isBookOpen = NO;
    [booksParentView setIsBookOpen:NO];
    
    // Send analytics an event for book closing
    if (bookStart) {
        NSTimeInterval interval = fabs([bookStart timeIntervalSinceNow]);
        bookStart = nil;
        
        PTPlaymate *partner;
        if ([self.playdate isUserIDInitiator:[[PTUser currentUser] userID]]) {
            partner = self.playdate.playmate;
        } else {
            partner = self.playdate.initiator;
        }
        
        [PTAnalytics sendEventNamed:EventBookRead withProperties:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:interval], PropDuration,
                                         partner.username, PropPlaymateId,
                                         bookId, PropBookId, nil]];
    }
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

#pragma mark - Pages scroll delegates

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
    
    // Post notification of page turn
    if (self.delegate && [self.delegate respondsToSelector:@selector(dateViewController:didTurnBookToPage:)]) {
        [self.delegate dateViewController:self didTurnBookToPage:number];
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

#pragma mark - Ringer methods

- (void)setupRinger {
    NSError *playerError;
    NSURL *ringtone = [[NSBundle mainBundle] URLForResource:@"ringtone-connecting" withExtension:@"mp3"];
    AVAudioPlayer *thePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:ringtone error:&playerError];
    thePlayer.volume = 0.25;
    thePlayer.numberOfLoops = 4;
    self.audioPlayer = thePlayer;
}

- (void)beginRinging {
    if (self.audioPlayer) {
        [self.audioPlayer play];
    }
}

- (void)endRinging {
    if (self.audioPlayer) {
        [self.audioPlayer stop];
    }
}

#pragma mark - Grandma Finger

- (void)addFingerAtPoint:(CGPoint)point initiatedBySelf:(BOOL)isInitiatedBySelf {

    LogDebug(@"Date view point: %@", NSStringFromCGPoint(point));
    // Alert the delegate of the touch event
    if (self.delegate && [self.delegate respondsToSelector:@selector(dateViewController:detectedGrandmaFingerAtPoint:isInitiatedBySelf:)]) {
        UIView *currentPageView = [pagesScrollView getPageViewAtPageNumber:pagesScrollView.currentPage];
        [self.delegate dateViewController:self
             detectedGrandmaFingerAtPoint:[self.view convertPoint:point fromView:currentPageView]
                        isInitiatedBySelf:isInitiatedBySelf];
    }
    
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

#pragma mark - Playdate delegates

- (void)playdateShouldEnd {
    // Dismiss popover
    [playdateEndPopover dismissPopoverAnimated:NO];

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

#pragma mark - Games delegates

- (void)gameFocusedWithId:(NSNumber *)gameId {
}

- (void)gameTouchedWithId:(NSNumber *)gameId AndView:(PTGameView *)gameView {
    // Game selected, either focus it or open it
    if ([gameView inFocus] == NO) {
        // Bring game to focus
        NSInteger position = [gameView getPosition];
        CGPoint navigateTo = CGPointMake(booksScrollView.frame.size.width * position, 0.0f);
        [booksScrollView setContentOffset:navigateTo animated:YES];
    } else {
        // Open specific book (ids are hardcoded)
        if ([gameId integerValue] == 1) {
            [self memoryTapped:nil];
        } else if ([gameId integerValue] == 2) {
            [self ticTacToeTapped:nil];
        } else if ([gameId integerValue] == 3) {
            [self matchingTapped:nil];
        }
    }
}

#pragma mark - Games methods

- (void)hideAllGameViews {
    [UIView animateWithDuration:0.5f
                     animations:^{
                         for (PTGameView *gameView in gameList) {
                             gameView.alpha = 0.0f;
                         }
                     }];
}

- (void)showAllGameViews {
    [UIView animateWithDuration:0.5f
                     animations:^{
                         for (PTGameView *gameView in gameList) {
                             gameView.alpha = 0.6f;
                         }
                     }];
}

#pragma mark - Postcard Controller delegate

- (void)postcardDidSend {
    [self playdateShouldEnd];
}

@end