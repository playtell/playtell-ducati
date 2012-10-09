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


#import "PTNewUserInfoViewController.h"
#import "PTNewUserPhotoViewController.h"
#import "PTNewUserBirthdateViewController.h"
#import "PTNewUserPushNotificationsViewController.h"

@interface PTNewUserNavigationController ()

@end

@implementation PTNewUserNavigationController

@synthesize currentUser;

- (id)initWithDefaultViewController {
    PTNewUserInfoViewController *newUserInfoViewController = [[PTNewUserInfoViewController alloc] initWithNibName:@"PTNewUserInfoViewController" bundle:nil];
    self = [super initWithRootViewController:newUserInfoViewController];
    if (self) {
        self.currentUser = [[PTNewUser alloc] init];
//        self.currentUser.name = @"Dimitry B";
//        self.currentUser.email = @"dimitry@fsdfds.com";
//        self.currentUser.password = @"vsdfds";
//        self.currentUser.photo = [UIImage imageNamed:@"login_bg"];
//        self.currentUser.birthday = [NSDate dateWithTimeIntervalSinceNow:(-1*60*60*24*30*12*16)];
        self.delegate = self;
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
    
    // Page control
    pageControl = [[PTPageIndicatorView alloc] initWithFrame:CGRectMake(462.0f, 666.0f, 100.0f, 21.0f) andPage:1];
    [self.view addSubview:pageControl];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - Navigation delegates

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    NSInteger page = 1;
    if ([viewController isKindOfClass:[PTNewUserPhotoViewController class]]) {
        page = 2;
    } else if ([viewController isKindOfClass:[PTNewUserBirthdateViewController class]]) {
        page = 3;
    } else if ([viewController isKindOfClass:[PTNewUserPushNotificationsViewController class]]) {
        page = 4;
    }
    [pageControl moveToNewCurrentPage:page];
}

#pragma mark - Page control hide

- (void)hidePageControl {
    [UIView animateWithDuration:0.5f animations:^{
        pageControl.alpha = 0.0f;
        pageControl.frame = CGRectOffset(pageControl.frame, 0.0f, 100.0f);
    }];
}

@end