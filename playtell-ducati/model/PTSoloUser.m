//
//  PTSoloUser.m
//  playtell-ducati
//
//  Created by Ricky Hussmann on 9/6/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "Logging.h"
#import "PTFriendTouchTooltip.h"
#import "PTTouchHereTooltip.h"
#import "PTSoloUser.h"

#import <MediaPlayer/MediaPlayer.h>

@interface PTSoloUser ()
@property (nonatomic, retain) MPMoviePlayerController* moviePlayer;
@property (nonatomic, retain) PTTouchHereTooltip *touchTooltip;
@property (nonatomic, retain) PTFriendTouchTooltip *friendTooltip;
@property (nonatomic, assign) BOOL isFirstBookOpened;
@end

@implementation PTSoloUser
@synthesize dateController;
@synthesize moviePlayer;
@synthesize touchTooltip;
@synthesize friendTooltip;
@synthesize isFirstBookOpened;

- (BOOL)isARobot {
    return YES;
}

- (void)resetScriptState {
    self.isFirstBookOpened = NO;
}

- (id)init {
    if (self = [super init]) {
        MPMoviePlayerController *movieController = [[MPMoviePlayerController alloc] initWithContentURL:nil];
        movieController.controlStyle = MPMovieControlStyleNone;
        movieController.fullscreen = NO;
        movieController.scalingMode = MPMovieScalingModeAspectFill;
        movieController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.moviePlayer = movieController;
        self.moviePlayer.view.frame = CGRectZero;
        
        self.touchTooltip = [[PTTouchHereTooltip alloc] initWithWidth:300.0f];
        self.friendTooltip = [[PTFriendTouchTooltip alloc] initWithWidth:300.0f];
    }
    return self;
}

- (void)setDateController:(PTDateViewController *)aDateController {
    dateController = aDateController;
    
    // Remove from previous notifications, and subscribe to notifications
    // for this instance of the DateController (ensures we're only subscribed once)
    [self removeAllPreviousNotificationsForDateController:aDateController];
    [self registerForNotificationsForDateController:aDateController];
}

- (void)removeAllPreviousNotificationsForDateController:(PTDateViewController*)aDateController {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"PTDialpadLoadedNotification"
                                                  object:aDateController];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"PTBookOpened"
                                                  object:aDateController];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"PTPlaydateEnded"
                                                  object:aDateController];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"PTPageTurned"
                                                  object:aDateController];
}

- (void)registerForNotificationsForDateController:(PTDateViewController*)aDateController {
    [[NSNotificationCenter defaultCenter] addObserverForName:@"PTDialpadLoadedNotification"
                                                      object:aDateController
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      PTDateViewController* sender = note.object;
                                                      [self playIntroVideoWithChatController:sender.chatController];
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"PTBookOpened"
                                                      object:aDateController
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      if (self.isFirstBookOpened) {
                                                          return;
                                                      }
                                                      
                                                      PTDateViewController* sender = note.object;
                                                      [self playSecondVideoWithChatController:sender.chatController];

                                                      self.touchTooltip.alpha = 0.0f;
                                                      [self.touchTooltip addToView:sender.view
                                                                  withCaretAtPoint:CGPointMake(641.0f, 365.0f)];
                                                      
                                                      self.friendTooltip.alpha = 0.0f;
                                                      [self.friendTooltip addToView:sender.view
                                                                   withCaretAtPoint:CGPointMake(855.0f, 525.0f)];
                                                      
                                                      [UIView animateWithDuration:0.5 animations:^{
                                                          self.touchTooltip.alpha = 1.0;
                                                          self.friendTooltip.alpha = 1.0;
                                                      }];
                                                      
                                                      self.isFirstBookOpened = YES;
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"PTPageTurned"
                                                      object:aDateController
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      if (self.isFirstBookOpened) {
                                                          [self.touchTooltip removeFromSuperview];
                                                          [self.friendTooltip removeFromSuperview];
                                                      }
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"PTPlaydateEnded"
                                                      object:aDateController
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      LogDebug(@"Playdate Ended.");
                                                      [self.moviePlayer stop];
                                                  }];
}

- (void)playIntroVideoWithChatController:(PTChatViewController*)chatController {
    PTChatHUDView *chatView = (PTChatHUDView*)chatController.view;
    
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectZero];
    containerView.backgroundColor = [UIColor clearColor];
    containerView.layer.cornerRadius = 6.0;
    containerView.clipsToBounds = YES;
    NSURL *introURL = [[NSBundle mainBundle] URLForResource:@"koda-hi"
                                              withExtension:@"mp4"];
    self.moviePlayer.contentURL = introURL;
    [containerView addSubview:self.moviePlayer.view];
    [chatView setLeftView:containerView];
    [self.moviePlayer play];
}

- (void)playSecondVideoWithChatController:(PTChatViewController*)chatController {
    PTChatHUDView *chatView = (PTChatHUDView*)chatController.view;
    
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectZero];
    containerView.backgroundColor = [UIColor clearColor];
    containerView.layer.cornerRadius = 6.0;
    containerView.clipsToBounds = YES;
    NSURL *secondURL = [[NSBundle mainBundle] URLForResource:@"koda-hi-2"
                                               withExtension:@"mp4"];
    self.moviePlayer.contentURL = secondURL;
    self.moviePlayer.view.frame = CGRectZero;
    [containerView addSubview:self.moviePlayer.view];
    [chatView setLeftView:containerView];
    [self.moviePlayer play];
}

- (NSURL*)photoURL {
    return [[NSBundle mainBundle] URLForResource:@"dialpad-live"
                                   withExtension:@"png"];
}

- (UIImage*)userPhoto {
    return [UIImage imageNamed:@"dialad-live"];
}

- (NSString*)email {
    return @"solo@playtell.com";
}

- (NSUInteger)userID {
    return -1;
}

- (NSString*)username {
    return @"Test Call with Solo";
}

@end
