//
//  PTDialpadViewController.m
//  PlayTell
//
//  Created by Ricky Hussmann on 5/25/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTDialpadViewController.h"
#import "PTPlaymate.h"
#import "PTPlaymateButton.h"

// TODO : Remove after testing
#import "PTMockPlaymateFactory.h"

#import "UIView+PlayTell.h"

#import <QuartzCore/QuartzCore.h>

@implementation PTDialpadViewController
@synthesize scrollView;

- (void)loadView {
    [super loadView];

    UIImage* backgroundImage = [UIImage imageNamed:@"login_bg.png"];
    UIImageView* background = [[UIImageView alloc] initWithImage:backgroundImage];
    background.tag = 666;
    [self.view addSubview:background];

    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    [self.view addSubview:self.scrollView];
}

- (void)viewDidLoad {

    NSArray* playmates = [[[PTMockPlaymateFactory alloc] init] allPlaymates];
    NSUInteger numPlaymates = playmates.count;
//    for (int playmateIndex = 0; playmateIndex < numPlaymates; playmateIndex++) {
//        [playmates addObject:[[PTPlaymate alloc] init]];
//    }

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

    for (int rowIndex = 0; rowIndex < numRows; rowIndex++) {
        for (int cellIndex = 0; cellIndex < itemsPerRow; cellIndex++) {
            if (rowIndex*itemsPerRow + cellIndex >= numPlaymates) {
                continue;
            }

            CGFloat cellX = leftMargin + ((CGFloat)cellIndex)*(buttonSize.width + interCellPadding);
            CGFloat cellY = topMargin + ((CGFloat)rowIndex)*(buttonSize.height + rowSpacing);

            NSUInteger playmateIndex = (rowIndex*itemsPerRow) + cellIndex;
            if (playmateIndex >= playmates.count) {
                break;
            }

            PTPlaymate* currentPlaymate = [playmates objectAtIndex:playmateIndex];
            PTPlaymateButton* button = [PTPlaymateButton playmateButtonWithPlaymate:currentPlaymate];
            [button addTarget:self action:@selector(playmateClicked:) forControlEvents:UIControlEventTouchUpInside];

            CGRect buttonFrame = button.frame;
            buttonFrame.origin = CGPointMake(cellX, cellY);
            button.frame = buttonFrame;
            [self.scrollView addSubview:button];
        }
    }

    self.scrollView.contentSize = CGSizeMake(W, topMargin + ((CGFloat)(numRows+1))*(rowSpacing + buttonSize.height));
    NSLog(@"Number of rows: %u", numRows);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIView* background = [self.view viewWithTag:666];
    CGRect backgroundFrame = self.view.frame;
    backgroundFrame.origin = CGPointZero;
    background.frame = backgroundFrame;
}

- (void)playmateClicked:(PTPlaymateButton*)sender {
    static BOOL buttonSelected = NO;
    static CGRect normalButtonFrame;

    NSLog(@"Clicked playmate: %@", sender.playmate);

    if (!buttonSelected) {
        UIView* backgroundView = [self.view viewWithTag:666];
        UIView* transparentView = [[UIView alloc] initWithFrame:backgroundView.frame];
        transparentView.backgroundColor = [UIColor blackColor];
        transparentView.alpha = 0.0;
        transparentView.tag = 667;
        [self.scrollView addSubview:transparentView];
        [self.scrollView bringSubviewToFront:sender];
        normalButtonFrame = sender.frame;
        buttonSelected = YES;
        
        [UIView animateWithDuration:0.5 animations:^{
            [sender setRequestingPlaydate];
            transparentView.alpha = 0.7;
        }];
    } else {
        [[self.view viewWithTag:667] removeFromSuperview];
        [sender resetButton];
        buttonSelected = NO;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

@end
