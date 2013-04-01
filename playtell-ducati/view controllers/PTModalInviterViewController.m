//
//  PTModalInviterViewController.m
//  playtell-ducati
//
//  Created by Adam Horne on 3/29/13.
//  Copyright (c) 2013 PlayTell. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "PTModalInviterViewController.h"

#import "UIColor+ColorFromHex.h"

@interface PTModalInviterViewController ()

@end

@implementation PTModalInviterViewController

@synthesize delegate;

- (id)init {
    self = [super init];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    return self;
}

- (void)loadView {
    // Create the main view
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 1024.0f, 768.0f)];
    self.view.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.7f];
    self.view.autoresizesSubviews = YES;
    
    // Common properties
    float screenMargin = 20.0f;
    float cornerRadius = 5.0f;
    float borderMargin = 10.0f;
    float tableShrink = 10.0f; // amount to make the table smaller on each side
    
    // Add the search container
    CGSize containerSize = CGSizeMake(626.0f, 250.0f);
    searchContainer = [[UIView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - containerSize.width) / 2, screenMargin, containerSize.width, containerSize.height)];
    searchContainer.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = searchContainer.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorFromHex:@"#D9D9D9"] CGColor], (id)[[UIColor colorFromHex:@"#CCDBE6"] CGColor], nil];
    gradient.cornerRadius = cornerRadius;
    [searchContainer.layer insertSublayer:gradient atIndex:0];
    [searchContainer.layer setCornerRadius:cornerRadius];
    [searchContainer.layer setShadowColor:[UIColor blackColor].CGColor];
    [searchContainer.layer setShadowOpacity:0.75f];
    [searchContainer.layer setShadowRadius:2.0f];
    [searchContainer.layer setShadowOffset:CGSizeMake(0.0f, 1.0f)];
    [self.view addSubview:searchContainer];
    
    // Title label
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(borderMargin, borderMargin, searchContainer.frame.size.width - (borderMargin * 2), 40.0f)];
    lblTitle.textColor = [UIColor colorFromHex:@"A3B6B7"];
    lblTitle.shadowColor = [UIColor whiteColor];
    lblTitle.shadowOffset = CGSizeMake(0.0f, 1.0f);
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.font = [UIFont boldSystemFontOfSize:30.0f];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.text = @"Invite PlayPal";
    [searchContainer addSubview:lblTitle];
    
    // Close button
    UIImage *closeImage = [UIImage imageNamed:@"close.png"];
    UIImage *closePress = [UIImage imageNamed:@"close-press.png"];
    btnClose = [[UIButton alloc] initWithFrame:CGRectMake(searchContainer.frame.size.width - closeImage.size.width - borderMargin, borderMargin, closeImage.size.width, closeImage.size.height)];
    btnClose.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
    [btnClose setImage:closeImage forState:UIControlStateNormal];
    [btnClose setImage:closePress forState:UIControlStateHighlighted];
    [btnClose addTarget:self action:@selector(closeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [searchContainer addSubview:btnClose];
    
    // Text field
    CGSize searchFieldSize = CGSizeMake(440.0f, 31.0f);
    txtSearch = [[UITextField alloc] initWithFrame:CGRectMake((searchContainer.frame.size.width - searchFieldSize.width) / 2, (searchContainer.frame.size.height - searchFieldSize.height) / 2 - 20.0, searchFieldSize.width, searchFieldSize.height)];
    txtSearch.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    txtSearch.borderStyle = UITextBorderStyleRoundedRect;
    txtSearch.font = [UIFont boldSystemFontOfSize:16.0f];
    txtSearch.placeholder = @"Email or full name";
    txtSearch.autocapitalizationType = UITextAutocapitalizationTypeNone;
    txtSearch.autocorrectionType = UITextAutocorrectionTypeNo;
    txtSearch.keyboardType = UIKeyboardTypeDefault;
    txtSearch.returnKeyType = UIReturnKeyDone;
    txtSearch.clearButtonMode = UITextFieldViewModeWhileEditing;
    txtSearch.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    txtSearch.delegate = self;
    [searchContainer addSubview:txtSearch];
    
    // Magnifying glass image view
    UIImage *magnifyingGlass = [UIImage imageNamed:@"search-icon.png"];
    UIImageView *magnifyingGlassIcon = [[UIImageView alloc] initWithFrame:CGRectMake(txtSearch.frame.origin.x - borderMargin - magnifyingGlass.size.width, txtSearch.frame.origin.y - ((magnifyingGlass.size.height - txtSearch.frame.size.height) / 2), magnifyingGlass.size.width, magnifyingGlass.size.height)];
    magnifyingGlassIcon.image = magnifyingGlass;
    [searchContainer addSubview:magnifyingGlassIcon];
    
    // Search button
    UIImage *buttonImage = [UIImage imageNamed:@"find.png"];
    UIImage *buttonPress = [UIImage imageNamed:@"find-press.png"];
    btnSearch = [[UIButton alloc] initWithFrame:CGRectMake((searchContainer.frame.size.width - buttonImage.size.width) / 2, searchContainer.frame.size.height - buttonImage.size.height - borderMargin - 40.0, buttonImage.size.width, buttonImage.size.height)];
    btnSearch.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [btnSearch setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [btnSearch setBackgroundImage:buttonPress forState:UIControlStateHighlighted];
    [btnSearch setTitle:@"Find PlayPal" forState:UIControlStateNormal];
    [btnSearch setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnSearch setTitleShadowColor:[UIColor grayColor] forState:UIControlStateNormal];
    [btnSearch addTarget:self action:@selector(searchButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [searchContainer addSubview:btnSearch];
    
    // Down arrow to show where table view is
    UIImage *downArrow = [UIImage imageNamed:@"arrow.png"];
    UIImageView *downArrowIcon = [[UIImageView alloc] initWithFrame:CGRectMake((searchContainer.frame.size.width - downArrow.size.width) / 2, searchContainer.frame.size.height - downArrow.size.height - borderMargin, downArrow.size.width, downArrow.size.height)];
    downArrowIcon.image = downArrow;
    [searchContainer addSubview:downArrowIcon];
    
    // Add the table view
    tblResults = [[UITableView alloc] initWithFrame:CGRectMake(searchContainer.frame.origin.x + tableShrink, searchContainer.frame.origin.y + searchContainer.frame.size.height, searchContainer.frame.size.width - (2 * tableShrink), 300.0f)];
    tblResults.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.view insertSubview:tblResults belowSubview:searchContainer];
}

- (void)closeButtonPressed {
    [self.delegate modalShouldClose:self];
}

- (void)searchButtonPressed {
    [txtSearch resignFirstResponder];
}

#pragma mark - TextField delegates

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    //[self searchStringDidChange:self];
    return YES;
}

@end
