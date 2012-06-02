//
//  PTDialpadViewController.m
//  PlayTell
//
//  Created by Ricky Hussmann on 5/25/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTDialpadViewController.h"
#import "PTPlaymate.h"
#import "PTPlaymateButton.h"

#import "UIView+PlayTell.h"

#import <QuartzCore/QuartzCore.h>

@implementation PTDialpadViewController
@synthesize scrollView;

- (void)loadView {
    [super loadView];

    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    [self.view addSubview:self.scrollView];
}

- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor redColor];

    NSUInteger numPlaymates = 12;
    NSMutableArray* playmates = [NSMutableArray arrayWithCapacity:100];
    for (int playmateIndex = 0; playmateIndex < numPlaymates; playmateIndex++) {
        [playmates addObject:[[PTPlaymate alloc] init]];
    }

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
            PTPlaymate* currentPlaymate = [playmates objectAtIndex:playmateIndex];
            PTPlaymateButton* button = [PTPlaymateButton playmateButtonWithPlaymate:currentPlaymate];

            CGRect buttonFrame = button.frame;
            buttonFrame.origin = CGPointMake(cellX, cellY);
            button.frame = buttonFrame;
            [self.scrollView addSubview:button];
        }
    }

    self.scrollView.contentSize = CGSizeMake(W, topMargin + ((CGFloat)(numRows+1))*(rowSpacing + buttonSize.height));
    NSLog(@"Number of rows: %u", numRows);
}

- (void)playmateClicked:(id)sender {
    PTPlaymateButton* button = (PTPlaymateButton*)sender;
    NSLog(@"Clicked playmate: %@", button.playmate.username);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

@end
