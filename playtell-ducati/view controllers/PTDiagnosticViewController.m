//
//  PTDiagnosticViewController.m
//  playtell-ducati
//
//  Created by Ricky Hussmann on 6/6/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "Logging.h"
#import "PTBooksListRequest.h"
#import "PTDateViewController.h"
#import "PTDiagnosticViewController.h"
#import "PTPlaydate.h"
#import "PTPlayTellPusher.h"
#import "PTUser.h"
#import "PTPlaydateCreateRequest.h"
#import "PTPlaydateJoinedRequest.h"

// TODO : remove this after testing
#import "PTMockPlaymateFactory.h"

#import <QuartzCore/QuartzCore.h>

@interface PTDiagnosticViewController ()
@property (nonatomic, retain) PTPlaydate* playdate;
@property (nonatomic, assign) BOOL isSubscribedToRendezvous;
@property (nonatomic, retain) NSArray* books;
@end

@implementation PTDiagnosticViewController
@synthesize channelStatus;
@synthesize statusLabel;
@synthesize initiatorLabel;
@synthesize playmateLabel;
@synthesize playdateIDLabel;
@synthesize channelNameLabel;
@synthesize joinButton;
@synthesize subscribeButton;
@synthesize playmateIDField;

@synthesize playdate;
@synthesize isSubscribedToRendezvous;
@synthesize books;

- (IBAction)requestPlaydate:(id)sender {
    id<PTPlaymateFactory> factory = [[PTMockPlaymateFactory alloc] init];
    
    // Get playmate
    PTPlaymate* playmate = [factory playmateWithUsername:self.playmateIDField.text];
    NSLog(@"Playmate: %@", playmate);
    if (playmate == nil) {
        NSLog(@"Playmate NOT FOUND!");
        return;
    }

    // Initiate playdate request
    PTPlaydateCreateRequest *playdateCreateRequest = [[PTPlaydateCreateRequest alloc] init];
    [playdateCreateRequest playdateCreateWithFriend:[NSNumber numberWithInteger:playmate.userID]
                                          authToken:[[PTUser currentUser] authToken]
                                          onSuccess:^(NSDictionary *result)
     {
         LogInfo(@"playdateCreateWithFriend response: %@", result);
         self.playdate = [[PTPlaydate alloc] initWithDictionary:result
                                                playmateFactory:[[PTMockPlaymateFactory alloc] init]];
         [self joinPlaydate];
     } onFailure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
         LogError(@"playdateCreateWithFriend failed: %@", error);
     }
    ];
    LogInfo(@"Requesting playdate...");
}

- (IBAction)joinPressed:(id)sender {
    LOGMETHOD;
    [self joinPlaydate];
}

- (void)joinPlaydate {
    NSLog(@"Playdate -> %@", self.playdate);

    // Unsubscribe from rendezvous channel
    [self unsunscribeFromRendezvousAndUpdateUI];

    // Load playdate
    PTDateViewController *dateController = [[PTDateViewController alloc] initWithNibName:@"PTDateViewController" bundle:nil andBookList:books];
    [dateController setPlaydate:self.playdate];
    [self presentViewController:dateController animated:YES completion:nil];
}

- (IBAction)subscribeToRendezvous:(id)sender {
    [self toggleRendezvousSubscription];
}

- (void)toggleRendezvousSubscription {
    (self.isSubscribedToRendezvous) ? [self unsunscribeFromRendezvousAndUpdateUI] : [self subscribeToRendezvousAndUpdateUI];
}

- (void)subscribeToRendezvousAndUpdateUI {
    [[PTPlayTellPusher sharedPusher] subscribeToRendezvousChannel];
    self.channelStatus.backgroundColor = [UIColor greenColor];
    self.statusLabel.text = @"Subscribed to rendezvous";
    [self.subscribeButton setTitle:@"Unsubscribe" forState:UIControlStateNormal];
    self.isSubscribedToRendezvous = YES;
}

- (void)unsunscribeFromRendezvousAndUpdateUI {
    [[PTPlayTellPusher sharedPusher] unsubscribeFromRendezvousChannel];
    self.channelStatus.backgroundColor = [UIColor redColor];
    self.statusLabel.text = @"NOT subscribed to rendezvous";
    [self.subscribeButton setTitle:@"Subscribe" forState:UIControlStateNormal];
    self.isSubscribedToRendezvous = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.channelStatus.backgroundColor = [UIColor redColor];
    self.initiatorLabel.text = @"";
    self.playmateLabel.text = @"";
    self.playdateIDLabel.text = @"";
    self.channelNameLabel.text = @"";
    self.joinButton.enabled = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pusherDidReceivePlaydateJoinedNotification:)
                                                 name:PTPlayTellPusherDidReceivePlaydateJoinedEvent
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pusherDidReceivePlaydRequestNotification:)
                                                 name:PTPlayTellPusherDidReceivePlaydateRequestedEvent
                                               object:nil];

    [self unsunscribeFromRendezvousAndUpdateUI];
    [self getBooksList];

    // TODO shouldn't have to do this, but the XIB doesn't seem to be respecting the frame...
    self.channelStatus.frame = CGRectMake(20, 10, 50, 50);
    self.channelStatus.layer.cornerRadius = 5.0;
}

- (void)getBooksList {
    PTBooksListRequest* booksListRequest = [[PTBooksListRequest alloc] init];
    [booksListRequest booksListWithAuthToken:[[PTUser currentUser] authToken]
                                   onSuccess:^(NSDictionary *result)
     {
         LogTrace(@"getBooks result: %@", result);
         books = [result objectForKey:@"books"];
     } 
                                   onFailure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
     {
         LogError(@"Error retrieving book list: %@", error);
     }];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)pusherDidReceivePlaydRequestNotification:(NSNotification*)note {
    PTPlaydate* aPlaydate = [[note userInfo] valueForKey:PTPlaydateKey];
    self.initiatorLabel.text = aPlaydate.initiator.username;
    self.playmateLabel.text = aPlaydate.playmate.username;
    self.playdateIDLabel.text = [NSString stringWithFormat:@"%u",aPlaydate.playdateID];
    self.channelNameLabel.text = aPlaydate.pusherChannelName;

    self.playdate = aPlaydate;
    self.joinButton.enabled = YES;
}

- (void)pusherDidReceivePlaydateJoinedNotification:(NSNotification*)note {
    PTPlaydate* aPlaydate = [[note userInfo] valueForKey:PTPlaydateKey];
    self.playdate = aPlaydate;
    NSLog(@"Playdate received: %i", self.playdate.playdateID);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

@end
