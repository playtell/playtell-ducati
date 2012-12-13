//
//  PTLoadingViewController.m
//  playtell-ducati
//
//  Created by Ricky Hussmann on 6/11/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTLoadingViewController.h"
#import "PTSpinnerView.h"

@interface PTLoadingViewController ()

@end

@implementation PTLoadingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        float width = self.view.frame.size.width;
        float height = self.view.frame.size.height;
        float size = 75.0f;
        
        PTSpinnerView *spinner = [[PTSpinnerView alloc] init];
        spinner.frame = CGRectMake(0.0f, 0.0f, size, size);
        spinner.center = CGPointMake(width / 2, height - 50.0);
        [spinner startSpinning];
        [self.view addSubview:spinner];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

@end
