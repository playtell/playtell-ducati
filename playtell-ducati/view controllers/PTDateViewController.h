//
//  PTDateViewController.h
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 6/4/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTBookView.h"
#import "PTBooksParentView.h"
#import "PTBooksScrollView.h"
#import "PTChatViewController.h"
#import "PTPageView.h"
#import "PTPagesScrollView.h"
#import "PTPlaydate.h"
#import "PTPlaydateDelegate.h"
#import "PTPlaydateEndViewController.h"
#import "PTPlaymate.h"

#import <UIKit/UIKit.h>

@class PTDateViewController;

@protocol PTDateViewControllerDelegate <NSObject>
- (void)dateViewController:(PTDateViewController *)controller didTurnBookToPage:(NSUInteger)pageNumber;
- (void)dateViewController:(PTDateViewController *)controller didOpenBookWithID:(NSUInteger)bookID;
- (void)dateViewcontrollerWillCloseBook:(PTDateViewController *)controller;
- (void)dateViewControllerWillAppear:(PTDateViewController *)controller;
- (void)dateViewControllerDidEndPlaydate:(PTDateViewController *)controller;
- (void)dateViewController:(PTDateViewController*)controller detectedGrandmaFingerAtPoint:(CGPoint)point isInitiatedBySelf:(BOOL)initiatedBySelf;
- (BOOL)dateViewControllerShouldPlayGame:(PTDateViewController*)controller;
@end

@interface PTDateViewController : UIViewController <UIScrollViewDelegate, PTBookViewDelegate, PTPagesScrollViewDelegate, PTPlaydateDelegate> {
    // Playdate
    PTPlaydate *playdate;
    IBOutlet UIButton *endPlaydate;
    IBOutlet UIButton *closeBook;
    IBOutlet UIButton *endPlaydateForreal;
    IBOutlet UIView *endPlaydatePopup;
    UIPopoverController *playdateEndPopover;
    PTPlaydateEndViewController *playdateEndViewController;
    
    // Books
    PTBooksParentView *booksParentView;
    PTBooksScrollView *booksScrollView;
    NSNumber *currentBookId;
    NSMutableDictionary *books;
    NSMutableArray *bookList;
    BOOL isBookOpen;
    NSMutableArray *coversToLoad;
    NSInteger coversToLoadIndex;
    BOOL boolListLoadedFromPlist;
    
    // Pages
    PTPagesScrollView *pagesScrollView;
    NSMutableArray *pagesToLoad;
    NSInteger currentPage;
    
    // Page loader
//    UIWebView *webView;
    //BOOL isWebViewLoading;
    BOOL isPageViewLoading;
    
    // Fingers
    NSMutableDictionary *fingerViews;
}

@property (nonatomic) PTPlaydate *playdate;
@property (nonatomic, retain) IBOutlet UIButton *endPlaydate;
@property (nonatomic, retain) IBOutlet UIButton *endPlaydateForreal;
@property (nonatomic, retain) IBOutlet UIButton *closeBook;
@property (nonatomic, retain) IBOutlet UIButton *button2;

@property (nonatomic, retain) IBOutlet UIView *endPlaydatePopup;
@property (nonatomic, strong) PTChatViewController* chatController;
@property (nonatomic, weak) NSObject<PTDateViewControllerDelegate> *delegate;

- (id)initWithPlaymate:(PTPlaymate*)aPlaymate
    chatViewController:(PTChatViewController*)chatController;

- (IBAction)playdateDisconnect:(id)sender;
- (IBAction)playTictactoe:(id)sender;

- (IBAction)endPlaydateHandle:(id)sender;
- (void)openBookAfterNavigation;

- (UIView*)openBookView;

@end
