//
//  PTNewUserNavigationController.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 9/11/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTNewUserNavigationController.h"
#import "PTNewUserInfoViewController.h"
#import "UIColor+HexColor.h"

@interface PTNewUserNavigationController ()

@end

@implementation PTNewUserNavigationController

@synthesize currentUser;

- (id)initWithDefaultViewController {
    PTNewUserInfoViewController *newUserInfoViewController = [[PTNewUserInfoViewController alloc] initWithNibName:@"PTNewUserInfoViewController" bundle:nil];
    self = [super initWithRootViewController:newUserInfoViewController];
    if (self) {
        self.currentUser = [[PTNewUser alloc] init];
    }
    return self;
}

- (void)loadView {
    [super loadView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Style setup
    self.navigationBar.tintColor = [UIColor colorFromHex:@"#2e4857"];
    self.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorFromHex:@"#E3F1FF"], UITextAttributeTextColor, nil];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

@end