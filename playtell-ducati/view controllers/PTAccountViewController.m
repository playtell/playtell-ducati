//
//  PTAccountViewController.m
//  playtell-ducati
//
//  Created by Adam Horne on 2/4/13.
//  Copyright (c) 2013 PlayTell. All rights reserved.
//

#import "PTAccountViewController.h"
#import "PTSettingsTitleView.h"

#import "UIColor+ColorFromHex.h"

@interface PTAccountViewController ()

@end

@implementation PTAccountViewController

- (id)init {
    self = [super init];
    if (self) {
        self.view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 500.0f, 500.0f)];
        self.view.autoresizesSubviews = YES;
        self.view.backgroundColor = [UIColor colorFromHex:@"#E4ECEF"];
        
        PTSettingsTitleView *topTitle = [[PTSettingsTitleView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 30.0f)];
        topTitle.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        topTitle.textLabel.text = @"Contact Info";
        [self.view addSubview:topTitle];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
