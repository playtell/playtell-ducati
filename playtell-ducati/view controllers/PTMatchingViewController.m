//
//  PTMatchingViewController.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 10/23/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTMatchingViewController.h"
#import "PTMatchingEndGameRequest.h"
#import "PTMatchingPlayTurnRequest.h"
#import "PTMatchingRefreshGameRequest.h"

@interface PTMatchingViewController ()

@end

@implementation PTMatchingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

@end