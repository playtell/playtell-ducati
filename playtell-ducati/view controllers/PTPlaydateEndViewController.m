//
//  PTPlaydateEndViewController.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 8/14/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTPlaydateEndViewController.h"

@interface PTPlaydateEndViewController ()

@end

@implementation PTPlaydateEndViewController

@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)endPlaydatePressed:(id)sender {
    if ([delegate respondsToSelector:@selector(playdateShouldEnd)]) {
        [delegate playdateShouldEnd];
    }
}

@end