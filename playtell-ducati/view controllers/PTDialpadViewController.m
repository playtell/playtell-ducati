//
//  PTDialpadViewController.m
//  PlayTell
//
//  Created by Ricky Hussmann on 5/25/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "Logging.h"
#import "PTAppDelegate.h"
#import "PTBooksListRequest.h"
#import "PTConcretePlaymateFactory.h"
#import "PTDateViewController.h"
#import "PTDialpadViewController.h"
#import "PTPlayTellPusher.h"
#import "PTPlaydateCreateRequest.h"
#import "PTPlaydateDisconnectRequest.h"
#import "PTPlaymate.h"
#import "PTPlaymateButton.h"
#import "PTUser.h"
#import "TransitionController.h"

#import "UIView+PlayTell.h"

#import <QuartzCore/QuartzCore.h>

#define kAnimationRotateDeg 1.0

static BOOL viewHasAppearedAtLeastOnce = NO;

@interface PTDialpadViewController ()
@property (nonatomic, retain) PTPlaymateButton* selectedButton;
@property (nonatomic, retain) NSDictionary* userButtonHash;
@property (nonatomic, retain) PTPlaydate* requestedPlaydate;
@property (nonatomic, retain) UITapGestureRecognizer* cancelPlaydateRecognizer;
@property (nonatomic, retain) NSArray* books;
@property (nonatomic, retain) PTDateViewController* dateController;
@end

@implementation PTDialpadViewController
@synthesize scrollView;
@synthesize playmates;
@synthesize selectedButton;
@synthesize userButtonHash;
@synthesize requestedPlaydate;
@synthesize cancelPlaydateRecognizer;
@synthesize books;
@synthesize dateController;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[PTPlayTellPusher sharedPusher] subscribeToRendezvousChannel];
    
    UIView* background = [self.view viewWithTag:666];
    CGRect backgroundFrame = self.view.frame;
    backgroundFrame.origin = CGPointZero;
    background.frame = backgroundFrame;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pusherDidReceivePlaydateRequestNotification:)
                                                 name:PTPlayTellPusherDidReceivePlaydateRequestedEvent
                                               object:nil];
    if (self.selectedButton) {
        [self deactivatePlaymateButton];
    }

    // TODO this is a hack to get around the buttons animating in due to a detected
    // rotation. Ultimately, I shouldn't be adding and removing buttons from the view every
    // time it appears and disappears. It should be done at load only, since we don't have to
    // worry about new playmates being added, for the time being.
    if (viewHasAppearedAtLeastOnce) {
        [self drawPlaymates];
    } else {
        viewHasAppearedAtLeastOnce = YES;
    }
}

- (void)drawPlaymates {
    // TODO : revist the naming of these variables...
    NSUInteger numPlaymates = self.playmates.count + 1;
    
    CGFloat margin = 70;
    const CGFloat leftMargin = margin;
    const CGFloat rightMargin = margin;
    const CGFloat topMargin = 30;
    CGFloat rowSpacing = 10;
    const NSUInteger itemsPerRow = 4;
    const CGSize buttonSize = CGSizeMake(201, 151);
    
    CGFloat W = 1024;
    CGFloat interCellPadding = (W - leftMargin - rightMargin - ((CGFloat)itemsPerRow)*buttonSize.width)/(CGFloat)(itemsPerRow - 1);
    
    // Testing...
    rowSpacing = interCellPadding;
    NSUInteger numRows = numPlaymates/itemsPerRow + MIN(numPlaymates%itemsPerRow, 1);

    NSMutableDictionary* playmatesAndButtons = [NSMutableDictionary dictionary];
    for (int rowIndex = 0; rowIndex < numRows; rowIndex++) {
        for (int cellIndex = 0; cellIndex < itemsPerRow; cellIndex++) {
            NSUInteger playmateIndex = (rowIndex*itemsPerRow) + cellIndex;
            if (playmateIndex >= numPlaymates) {
                continue;
            }
            
            CGFloat cellX = leftMargin + ((CGFloat)cellIndex)*(buttonSize.width + interCellPadding);
            CGFloat cellY = topMargin + ((CGFloat)rowIndex)*(buttonSize.height + rowSpacing);
            
            UIButton* button;
            if (playmateIndex == numPlaymates - 1) {
                button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.frame = CGRectMake(0, 0, buttonSize.width, buttonSize.height);
                [button setImage:[UIImage imageNamed:@"add-family.png"] forState:UIControlStateNormal];
                [playmatesAndButtons setObject:button
                                        forKey:@"AddUserButton"];
            } else {
                PTPlaymate* currentPlaymate = [self.playmates objectAtIndex:playmateIndex];
                button = [PTPlaymateButton playmateButtonWithPlaymate:currentPlaymate];
                [button addTarget:self action:@selector(playmateClicked:) forControlEvents:UIControlEventTouchUpInside];
                [playmatesAndButtons setObject:button
                                        forKey:[self stringFromUInt:currentPlaymate.userID]];
            }
            
            CGRect buttonFrame = button.frame;
            buttonFrame.origin = CGPointMake(cellX, cellY);
            button.frame = buttonFrame;
            [self.scrollView addSubview:button];
        }
    }
    self.userButtonHash = [NSDictionary dictionaryWithDictionary:playmatesAndButtons];

    self.scrollView.contentSize = CGSizeMake(W, topMargin + ((CGFloat)(numRows+1))*(rowSpacing + buttonSize.height));
    NSLog(@"Number of rows: %u", numRows);
}

- (void)playmateClicked:(PTPlaymateButton*)sender {
    // Initiate playdate request
    [self joinPlaydate];

    PTPlaydateCreateRequest *playdateCreateRequest = [[PTPlaydateCreateRequest alloc] init];
    [playdateCreateRequest playdateCreateWithFriend:[NSNumber numberWithUnsignedInt:sender.playmate.userID]
                                          authToken:[[PTUser currentUser] authToken]
                                          onSuccess:^(NSDictionary *result)
     {
         LogInfo(@"playdateCreateWithFriend response: %@", result);
         PTPlaydate* aPlaydate = [[PTPlaydate alloc] initWithDictionary:result
                                                        playmateFactory:[PTConcretePlaymateFactory sharedFactory]];
         [self.dateController setPlaydate:aPlaydate];
         self.dateController = nil;
     } onFailure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
         LogError(@"playdateCreateWithFriend failed: %@", error);
     }
     ];
    LogInfo(@"Requesting playdate...");
}

- (void)joinPlaydate {
    LogTrace(@"Joining playdate: %@", self.requestedPlaydate);
    // Unsubscribe from rendezvous channel
    [[PTPlayTellPusher sharedPusher] unsubscribeFromRendezvousChannel];

    NSAssert(self.books, @"Book list cannot be nil before transitioning to dateController");
    self.dateController = [[PTDateViewController alloc] initWithNibName:@"PTDateViewController"
                                                                 bundle:nil
                                                            andBookList:self.books];
    PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.transitionController transitionToViewController:self.dateController withOptions:UIViewAnimationOptionTransitionCrossDissolve];

    if (self.requestedPlaydate) {
        [self.dateController setPlaydate:self.requestedPlaydate];
        self.requestedPlaydate = nil;
        self.dateController = nil;
    }
}

- (NSString*)stringFromUInt:(NSUInteger)number {
    return [NSString stringWithFormat:@"%u", number];
}

- (void)pusherDidReceivePlaydateRequestNotification:(NSNotification*)note {
    PTPlaydate* playdate = [[note userInfo] valueForKey:PTPlaydateKey];
    LogDebug(@"%@ received playdate: %@", NSStringFromSelector(_cmd), playdate);
    
    if (playdate.playmate.userID == [[PTUser currentUser] userID]) {
        self.requestedPlaydate = playdate;
        [self notifyUserOfPlaydate:playdate];
    }
}

- (void)notifyUserOfPlaydate:(PTPlaydate*)playdate {
    PTPlaymateButton* button = [self.userButtonHash valueForKey:[self stringFromUInt:playdate.initiator.userID]];
    [self activatePlaymateButton:button];
}

- (void)activatePlaymateButton:(PTPlaymateButton*)button {
    [self.scrollView bringSubviewToFront:button];
    self.selectedButton = button;
    button.isActivated = YES;

    [button removeTarget:self action:@selector(playmateClicked:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(joinPlaydate) forControlEvents:UIControlEventTouchUpInside];
    
    [UIView animateWithDuration:0.5 animations:^{
        [button setRequestingPlaydate];
    }];
    [self shakeButton:button];

    self.cancelPlaydateRecognizer.enabled = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    NSArray* buttons = [NSArray arrayWithArray:[self.userButtonHash allValues]];
    for (UIButton* button in buttons) {
        [button removeFromSuperview];
    }

    self.userButtonHash = nil;
}

- (void)deactivatePlaymateButton {
    self.selectedButton.transform = CGAffineTransformIdentity;
    [self.selectedButton.layer removeAllAnimations];
    self.selectedButton.isActivated = NO;
    [self.selectedButton resetButton];
    self.selectedButton = nil;

    self.cancelPlaydateRecognizer.enabled = NO;
}

- (void)loadView {
    [super loadView];
    self.view.frame = CGRectMake(0, 0, 1024, 748);

    UIImage* backgroundImage = [UIImage imageNamed:@"date_bg.png"];
    UIImageView* background = [[UIImageView alloc] initWithImage:backgroundImage];
    background.tag = 666;
    [self.view addSubview:background];

    NSString* welcomeText = @"WHO WILL YOU PLAY WITH TODAY?";
    CGSize labelSize = [welcomeText sizeWithFont:[self welcomeTextFont]
                               constrainedToSize:CGSizeMake(1024, CGFLOAT_MAX)];
    CGRect welcomeLabelRect;
    welcomeLabelRect = CGRectMake(1024.0/2.0 - labelSize.width/2.0, 0,
                                  labelSize.width, labelSize.height);
    UILabel* welcomeLabel = [[UILabel alloc] initWithFrame:welcomeLabelRect];
    welcomeLabel.text = welcomeText;
    welcomeLabel.font = [self welcomeTextFont];
    welcomeLabel.textColor = [UIColor redColor];
    welcomeLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:welcomeLabel];

    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 115, 1024, 633)];
    [self.view addSubview:self.scrollView];

    self.cancelPlaydateRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    [self.view addGestureRecognizer:self.cancelPlaydateRecognizer];
    self.cancelPlaydateRecognizer.enabled = NO;
    self.cancelPlaydateRecognizer.delegate = self;

    [self drawPlaymates];

    self.books = nil;
    PTBooksListRequest* booksRequest = [[PTBooksListRequest alloc] init];
    [booksRequest booksListWithAuthToken:[[PTUser currentUser] authToken]
                               onSuccess:^(NSDictionary *result)
    {
        // TODO : I don't like diving into the results object here, this needs refactored
        self.books = [result valueForKey:@"books"];
    } onFailure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        LogError(@"Failed to fetch books list: %@", error);
    }];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (UIFont*)welcomeTextFont {
    return [UIFont fontWithName:@"TeluguSangamMN" size:26.0];
}

- (void)viewTapped:(UIGestureRecognizer*)recognizers {
    LOGMETHOD;
    [self deactivatePlaymateButton];
    PTPlaydateDisconnectRequest *playdateDisconnectRequest = [[PTPlaydateDisconnectRequest alloc] init];
    [playdateDisconnectRequest playdateDisconnectWithPlaydateId:[NSNumber numberWithInt:self.requestedPlaydate.playdateID]
                                                      authToken:[[PTUser currentUser] authToken]
                                                      onSuccess:nil
                                                      onFailure:nil
     ];
    self.requestedPlaydate = nil;
}

- (void)shakeButton:(PTPlaymateButton *)sender {
    // Begin snip
    NSInteger randomInt = arc4random()%500;
    float r = (randomInt/500.0)+0.5;

    CGAffineTransform leftWobble = CGAffineTransformMakeRotation(degreesToRadians( (kAnimationRotateDeg * -1.0) - r ));
    CGAffineTransform rightWobble = CGAffineTransformMakeRotation(degreesToRadians( kAnimationRotateDeg + r ));

    sender.transform = leftWobble;  // starting point

    [[sender layer] setAnchorPoint:CGPointMake(0.5, 0.5)];

    [UIView animateWithDuration:0.1
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse
                     animations:^{
                         [UIView setAnimationRepeatCount:NSNotFound];
                         sender.transform = rightWobble; }
                     completion:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - UIGestureRecognizerDelegate methods
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint touchLocation = [touch locationInView:self.scrollView];

    return !CGRectContainsPoint(self.selectedButton.frame, touchLocation);
}

@end
