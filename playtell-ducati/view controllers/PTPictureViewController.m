//
//  PTPictureViewController.m
//  playtell-ducati
//
//  Created by Adam Horne on 2/18/13.
//  Copyright (c) 2013 PlayTell. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "PTPictureViewController.h"
#import "PTSettingsTitleView.h"
#import "PTUser.h"

#import "UIColor+ColorFromHex.h"

@interface PTPictureViewController ()

@end

@implementation PTPictureViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 500.0f, 500.0f)];
        self.view.autoresizesSubviews = YES;
        self.view.backgroundColor = [UIColor colorFromHex:@"#E4ECEF"];
        
        PTSettingsTitleView *topTitle = [[PTSettingsTitleView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 30.0f)];
        topTitle.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        topTitle.textLabel.text = @"Your Buddy Pic";
        [self.view addSubview:topTitle];
        
        // Error table view
        errorTable = [[PTErrorTableView alloc] initWithFrame:CGRectMake(0.0f, topTitle.frame.size.height + 1, self.view.frame.size.width, 1.0f)];
        errorTable.hidden = YES;
        errorTable.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        [self.view addSubview:errorTable];
        
        // Picture view
        pictureContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0f, topTitle.frame.size.height + 20, self.view.frame.size.width, 400.0f)];
        pictureContainer.autoresizesSubviews = YES;
        pictureContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        pictureContainer.backgroundColor = [UIColor clearColor];
        [self.view addSubview:pictureContainer];
        
        float picWidth = 300.0f;
        float picHeight = 225.0f;
        pictureView = [[UIImageView alloc] initWithFrame:CGRectMake((pictureContainer.frame.size.width - picWidth) / 2, 0.0f, picWidth, picHeight)];
        pictureView.clipsToBounds = YES;
        pictureView.layer.cornerRadius = 15.0f;
        pictureView.layer.borderColor = [UIColor colorWithWhite:0.0f alpha:0.5f].CGColor;
        pictureView.layer.borderWidth = 2.0f;
        [pictureContainer addSubview:pictureView];
        
        // Set the user picture
        PTUser *currentUser = [PTUser currentUser];
        if (currentUser) {
            pictureView.image = currentUser.userPhoto;
        }
        
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

- (void)showErrors:(NSMutableArray *)errorsToShow {
    if ([errorsToShow count] == 0) {
        // Hide the error table
        [UIView animateWithDuration:0.2f animations:^{
            errorTable.frame = CGRectMake(errorTable.frame.origin.x, errorTable.frame.origin.y, errorTable.frame.size.width, 1.0f);
            pictureContainer.frame = CGRectMake(pictureContainer.frame.origin.x, errorTable.frame.origin.y + errorTable.frame.size.height + 20, pictureContainer.frame.size.width, pictureContainer.frame.size.height);
        } completion:^(BOOL finished) {
            errorTable.hidden = YES;
        }];
    } else {
        // Show the error table and change it to its new size
        [errorTable reloadWithErrors:errorsToShow];
        errorTable.hidden = NO;
        [UIView animateWithDuration:0.2f animations:^{
            errorTable.frame = CGRectMake(errorTable.frame.origin.x, errorTable.frame.origin.y, errorTable.frame.size.width, [errorsToShow count] * 24 + errorsToShow.count);
            pictureContainer.frame = CGRectMake(pictureContainer.frame.origin.x, errorTable.frame.origin.y + errorTable.frame.size.height + 20, pictureContainer.frame.size.width, pictureContainer.frame.size.height);
        }];
    }
}

@end
