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
@synthesize joinButton;
@synthesize subscribeButton;

@synthesize playdate;
@synthesize isSubscribedToRendezvous;
@synthesize books;

- (IBAction)joinPressed:(id)sender {
    LOGMETHOD;
    PTPlaydate* aPlaydate = self.playdate;
    PTPlayTellPusher* pusher = [PTPlayTellPusher sharedPusher];
    NSLog(@"Playdate -> %@", self.playdate);
    
    // Unsubscribe from rendezvous channel
    [self unsunscribeFromRendezvousAndUpdateUI];
    
    // Subscribe to playdate channel
    NSLog(@"Subscribing to channel: %@", aPlaydate.pusherChannelName);
    [pusher subscribeToPlaydateChannel:aPlaydate.pusherChannelName];
    
    // Load playdate
    PTDateViewController *dateController = [[PTDateViewController alloc] initWithNibName:@"PTDateViewController" bundle:nil andBookList:books];
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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.channelStatus.backgroundColor = [UIColor redColor];
    self.initiatorLabel.text = @"";
    self.playmateLabel.text = @"";
    self.joinButton.enabled = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pusherDidReceivePlaydRequestNotification:)
                                                 name:PTPlayTellPusherDidReceivePlaydateRequestedEvent
                                               object:nil];

    [self unsunscribeFromRendezvousAndUpdateUI];

    [self getBooksList];
}

- (void)getBooksList {
    PTBooksListRequest* booksListRequest = [[PTBooksListRequest alloc] init];
    [booksListRequest booksListWithAuthToken:[[PTUser currentUser] authToken]
                                   onSuccess:^(NSDictionary *result)
     {
         LogInfo(@"getBooks result: %@", result);
         books = [result objectForKey:@"books"];
     } 
                                   onFailure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
     {
         LogError(@"Error retrieving book list: %@", error);
     }];
}

- (void)pusherDidReceivePlaydRequestNotification:(NSNotification*)note {
    PTPlaydate* aPlaydate = [[note userInfo] valueForKey:PTPlaydateKey];
    self.initiatorLabel.text = aPlaydate.initiator.username;
    self.playmateLabel.text = aPlaydate.playmate.username;

    self.playdate = aPlaydate;
    self.joinButton.enabled = YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

@end
