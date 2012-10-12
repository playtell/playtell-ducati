//
//  PTSoloUser.m
//  playtell-ducati
//
//  Created by Ricky Hussmann on 9/6/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "Logging.h"
#import "PTAnalytics.h"
#import "PTCloseActivityTooltip.h"
#import "PTEndCallToolTip.h"
#import "PTFriendTouchTooltip.h"
#import "PTSoloUser.h"
#import "PTTouchHereTooltip.h"
#import "PTTurnPageTooltip.h"

#import <MediaPlayer/MediaPlayer.h>

@interface PTSoloUser ()
@property (nonatomic, strong) MPMoviePlayerController* moviePlayer;
@property (nonatomic, strong) PTTouchHereTooltip *touchTooltip;
@property (nonatomic, strong) PTFriendTouchTooltip *friendTooltip;
@property (nonatomic, strong) PTCloseActivityTooltip *closeTooltip;
@property (nonatomic, strong) PTEndCallTooltip* endCallTooltip;
@property (nonatomic, assign) BOOL isIntroPlayed;
@property (nonatomic, assign) BOOL isFirstBookOpened;
@property (nonatomic, assign) BOOL isTouchTipsVisibile;
@end

@implementation PTSoloUser
@synthesize dateController;
@synthesize moviePlayer;
@synthesize touchTooltip;
@synthesize friendTooltip;
@synthesize closeTooltip;
@synthesize endCallTooltip;
@synthesize isIntroPlayed;
@synthesize isFirstBookOpened;
@synthesize isTouchTipsVisibile;

- (id)init {
    if (self = [super init]) {
        MPMoviePlayerController *movieController = [[MPMoviePlayerController alloc] initWithContentURL:nil];
        movieController.controlStyle = MPMovieControlStyleNone;
        movieController.fullscreen = NO;
        movieController.scalingMode = MPMovieScalingModeAspectFill;
        movieController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.moviePlayer = movieController;
        self.moviePlayer.view.frame = CGRectZero;
        
        self.touchTooltip = [[PTTouchHereTooltip alloc] initWithWidth:201.0f];
        self.friendTooltip = [[PTFriendTouchTooltip alloc] initWithWidth:300.0f];
        self.closeTooltip = [[PTCloseActivityTooltip alloc] initWithWidth:225.0f];
        self.endCallTooltip = [[PTEndCallTooltip alloc] initWithWidth:206.0f];
        [self resetScriptState];
    }
    return self;
}

- (NSString*)friendshipStatus {
    return @"confirmed";
}

- (NSString*)userStatus {
    return @"available";
}


- (BOOL)isARobot {
    return YES;
}

- (NSURL*)photoURL {
    return [[NSBundle mainBundle] URLForResource:@"Solo-profile-pic"
                                   withExtension:@"png"];
}

- (UIImage*)userPhoto {
    return [UIImage imageNamed:@"Solo-profile-pic"];
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


- (void)resetScriptState {
    self.isIntroPlayed = NO;
    self.isFirstBookOpened = NO;
    self.isTouchTipsVisibile = NO;
}

- (void)setDateController:(PTDateViewController *)aDateController {
    dateController = aDateController;
    aDateController.delegate = self;
}

#pragma mark - Notification Handlers

- (void)dateControllerOpenedBook:(PTDateViewController *)sender {
    if (self.isFirstBookOpened) {
        return;
    }
    
    [self playOpenedBookVideoWithChatController:sender.chatController];
    self.isFirstBookOpened = YES;
}

#pragma mark - PTDateViewControllerDelegate methods

- (void)dateViewController:(PTDateViewController *)controller didTurnBookToPage:(NSUInteger)pageNumber {
    
    // TODO : this if statement is a hack. The DateViewController, when moving to the
    // second page calls the page turn method first with the number 2, then the number 1, and
    // then again with the number 2 in quick succession.
    if (pageNumber < 3 && !self.isTouchTipsVisibile) {
        
        self.friendTooltip.alpha = 0.0f;
        [self.friendTooltip addToView:controller.view
                     withCaretAtPoint:CGPointMake(855.0f - 143.0, 525.0f - 152.0)];
        
        [UIView animateWithDuration:0.5 animations:^{
            self.friendTooltip.alpha = 1.0;
        }];
        [self playSecondVideoWithChatController:controller.chatController];
        self.isTouchTipsVisibile = YES;
        
        [self performSelector:@selector(addMeTouchTooltipAndStartVideoWithController:)
                   withObject:controller
                   afterDelay:3.0f];
    }
    
    if (pageNumber == 3) {
        [self.friendTooltip removeFromSuperview];
        [self.touchTooltip removeFromSuperview];
    }
}

- (void)addMeTouchTooltipAndStartVideoWithController:(PTDateViewController*)controller {
    self.touchTooltip.alpha = 0.0f;
    [self.touchTooltip addToView:controller.view
                withCaretAtPoint:CGPointMake(253.0f, 352.0f)];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.touchTooltip.alpha = 1.0;
    }];
}

- (void)dateViewController:(PTDateViewController *)controller didOpenBookWithID:(NSUInteger)bookID {
    if (self.closeTooltip.superview != controller.view) {
        [self.closeTooltip addToView:controller.view
                    withCaretAtPoint:CGPointMake(934.0f, 35.0f)];
    }
    self.closeTooltip.alpha = 0.0f;
    [UIView animateWithDuration:0.5f animations:^{
        self.closeTooltip.alpha = 1.0f;
    }];
     
    if (self.isFirstBookOpened) {
        return;
    }
    
    [self playOpenedBookVideoWithChatController:controller.chatController];
    self.isFirstBookOpened = YES;
}

- (void)dateViewcontrollerWillCloseBook:(PTDateViewController *)controller {

    // Don't re-add the end call tooltip if it's already
    // added
    if (self.endCallTooltip.superview != controller.view) {
        self.endCallTooltip.alpha = 0.0f;
        [self.endCallTooltip addToView:controller.view
                      withCaretAtPoint:CGPointMake(78.0f, 36.0f)];
    }
    
    [UIView animateWithDuration:0.5f animations:^{
        self.closeTooltip.alpha = 0.0f;
        self.endCallTooltip.alpha = 1.0f;
    } completion:^(BOOL finished) {
        //[self.closeTooltip removeFromSuperview];
    }];
    
    [self.touchTooltip removeFromSuperview];
    [self.friendTooltip removeFromSuperview];
}

- (void)dateViewControllerWillAppear:(PTDateViewController *)controller {
    // Analytics
    [PTAnalytics sendEventNamed:EventNUXStarted];
    tutorialStart = [NSDate date];
    
    if (!self.isIntroPlayed) {
        [self playIntroVideoWithChatController:controller.chatController];
    }
}

- (void)dateViewControllerDidEndPlaydate:(PTDateViewController *)controller {
    [controller.chatController stopPlayingMovies];
    
    // Analytics
    if (tutorialStart) {
        NSTimeInterval interval = fabs([tutorialStart timeIntervalSinceNow]);
        tutorialStart = nil;
        
        [PTAnalytics sendEventNamed:EventNUXEnded withProperties:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:interval], PropDuration, nil]];
    }
}

- (void)dateViewController:(PTDateViewController*)controller detectedGrandmaFingerAtPoint:(CGPoint)point isInitiatedBySelf:(BOOL)initiatedBySelf {
    // Hit rect should be centered at 253.0f, 352.0f
    // The rect width and height is 104.0f
    //
    // TODO In the future, the hit area should be calculated programmtically
    CGRect touchHereHitArea = CGRectMake(253.0f - 52.0f,
                                         352.0f - 52.0f,
                                         104.0f,
                                         104.0f);
    
    if (self.touchTooltip.superview && initiatedBySelf && CGRectContainsPoint(touchHereHitArea, point)) {
        [self playYouTouchVideoWithChatController:controller.chatController];
        
        // Remove the touch tooltips
        [UIView animateWithDuration:0.5f animations:^{
            self.touchTooltip.alpha = 0.0f;
            self.friendTooltip.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [self.touchTooltip removeFromSuperview];
            [self.friendTooltip removeFromSuperview];
        }];
    }
}

- (BOOL)dateViewControllerShouldPlayGame:(PTDateViewController*)controller {
    [self performSelector:@selector(playNoGamesVideoWithChatController:)
               withObject:controller.chatController
               afterDelay:3.0f];
    //[self playNoGamesVideoWithChatController:controller.chatController];
    return YES;
}

#pragma mark - Video loading convenience methods

- (void)playIntroVideoWithChatController:(PTChatViewController*)chatController {
    NSURL *introURL = [[NSBundle mainBundle] URLForResource:@"Solo_Hi"
                                              withExtension:@"mp4"];
    [chatController playMovieURLInLeftPane:introURL];
    self.isIntroPlayed = YES;
}

- (void)playOpenedBookVideoWithChatController:(PTChatViewController*)chatController {
    NSURL *bookOpenedURL = [[NSBundle mainBundle] URLForResource:@"Solo_Book"
                                                   withExtension:@"mp4"];
    [chatController playMovieURLInLeftPane:bookOpenedURL];
}

- (void)playSecondVideoWithChatController:(PTChatViewController*)chatController {
    NSURL *secondURL = [[NSBundle mainBundle] URLForResource:@"Solo_MePoint"
                                               withExtension:@"mp4"];
    [chatController playMovieURLInLeftPane:secondURL];
}

- (void)playYouTouchVideoWithChatController:(PTChatViewController*)chatController {
    NSURL *youTouchURL = [[NSBundle mainBundle] URLForResource:@"Solo_YouPoint"
                                                 withExtension:@"mp4"];
    [chatController playMovieURLInLeftPane:youTouchURL];
}

- (void)playNoGamesVideoWithChatController:(PTChatViewController*)chatController {
    NSURL *noGameURL = [[NSBundle mainBundle] URLForResource:@"Solo_Games"
                                               withExtension:@"mp4"];
    [chatController playMovieURLInLeftPane:noGameURL];
}

@end
