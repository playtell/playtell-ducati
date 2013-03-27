//
//  PTConnectionLossViewController.m
//  playtell-ducati
//
//  Created by Adam Horne on 3/15/13.
//  Copyright (c) 2013 PlayTell. All rights reserved.
//

#import "PTConnectionLossViewController.h"

#import "UIColor+ColorFromHex.h"

@interface PTConnectionLossViewController ()

@end

@implementation PTConnectionLossViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationFullScreen;
        
        // Create the image views
        imgConnectionLost = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nowifi.png"]];
        imgConnectionLost.backgroundColor = [UIColor clearColor];
        imgConnectionLost.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        imgConnectionFound = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wifi.png"]];
        imgConnectionFound.backgroundColor = [UIColor clearColor];
        imgConnectionFound.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        imgConnectionFound.hidden = YES;
        
        // Create the main view
        self.view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, imgConnectionLost.frame.size.width, imgConnectionLost.frame.size.height + 100)];
        self.view.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.7f];
        self.view.autoresizesSubviews = YES;
        
        // Add the image views to the main view
        CGRect viewBounds = self.view.bounds;
        CGPoint centerPoint = CGPointMake(viewBounds.size.width / 2, viewBounds.size.height / 2);
        imgConnectionLost.center = centerPoint;
        imgConnectionFound.center = centerPoint;
        [self.view addSubview:imgConnectionLost];
        [self.view addSubview:imgConnectionFound];
        
        // Add the text labels
        UILabel *topLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, imgConnectionFound.frame.size.height + 40, self.view.frame.size.width, 30.0f)];
        topLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        topLabel.textAlignment = UITextAlignmentCenter;
        topLabel.backgroundColor = [UIColor clearColor];
        topLabel.text = @"Connection Dropped";
        topLabel.textColor = [UIColor whiteColor];
        topLabel.font = [UIFont boldSystemFontOfSize:28.0f];
        [self.view addSubview:topLabel];
        UILabel *bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, topLabel.frame.origin.y + topLabel.frame.size.height, self.view.frame.size.width, 25.0f)];
        bottomLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        bottomLabel.textAlignment = UITextAlignmentCenter;
        bottomLabel.backgroundColor = [UIColor clearColor];
        bottomLabel.text = @"find a parent to help";
        bottomLabel.textColor = [UIColor colorFromHex:@"91CDE2"];
        bottomLabel.font = [UIFont boldSystemFontOfSize:20.0f];
        [self.view addSubview:bottomLabel];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showConnectionLost {
    imgConnectionLost.hidden = NO;
    imgConnectionFound.hidden = YES;
}

- (void)showConnectionFound {
    imgConnectionLost.hidden = YES;
    imgConnectionFound.hidden = NO;
}

- (void)startBlinking {
    if (blinkerTimer) {
        [blinkerTimer invalidate];
        blinkerTimer = nil;
    }
    
    blinkerTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(blink) userInfo:nil repeats:YES];
    blinkerShowingConnected = NO;
    [self showConnectionLost];
}

- (void)stopBlinking {
    [blinkerTimer invalidate];
    blinkerTimer = nil;
    [self showConnectionLost];
}

- (void)blink {
    if (blinkerShowingConnected) {
        [self showConnectionLost];
    } else {
        [self showConnectionFound];
    }
    blinkerShowingConnected = !blinkerShowingConnected;
}

@end
