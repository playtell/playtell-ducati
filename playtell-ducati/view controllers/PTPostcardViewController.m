//
//  PTPostcardViewController.m
//  playtell-ducati
//
//  Created by Adam Horne on 11/1/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTPostcardViewController.h"

@interface PTPostcardViewController ()

@property (nonatomic, strong) PTPostcardView *postcardView;

@end

@implementation PTPostcardViewController
@synthesize postcardView;
@synthesize chatController;

- (id)init {
    return [self initWithNibName:nil bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.postcardView = [[PTPostcardView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 1024.0f, 768.0f)];
        [self.view addSubview:self.postcardView];
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

@end
