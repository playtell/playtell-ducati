//
//  PTCreatePostcardViewController.m
//  playtell-ducati
//
//  Created by Adam Horne on 11/1/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTCreatePostcardViewController.h"
#import "PTPostcardCreateRequest.h"
#import "PTUser.h"

@interface PTCreatePostcardViewController ()

@property (nonatomic, strong) PTCreatePostcardView *postcardView;

@end

@implementation PTCreatePostcardViewController
@synthesize playmateId;
@synthesize delegate;

@synthesize postcardView;

- (id)init {
    return [self initWithNibName:nil bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.postcardView = [[PTCreatePostcardView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 1024.0f, 768.0f)];
        self.postcardView.delegate = self;
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

- (void)startPhotoCountdown {
    [self.postcardView startPhotoCountdown];
}

#pragma mark - Postcard Delegate
- (void)postcardTaken:(UIImage *)postcard withScreenshot:(UIImage *)screenshot {
    dispatch_async(dispatch_get_current_queue(), ^{
        PTPostcardCreateRequest *postcardCreateRequest = [[PTPostcardCreateRequest alloc] init];
        [postcardCreateRequest postcardCreateWithUserId:[PTUser currentUser].userID
                                             playmateId:self.playmateId
                                                  photo:postcard
                                                success:^(NSDictionary *result) {
                                                    //NSLog(@"Postcard successfully uploaded.");
                                                } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                    NSLog(@"Postcard creation failure!! %@ - %@", error, JSON);
                                                }];
    });
    //UIImageWriteToSavedPhotosAlbum(postcard, nil, nil, nil);
    //UIImageWriteToSavedPhotosAlbum(screenshot, nil, nil, nil);
    
    if ([delegate respondsToSelector:@selector(postcardDidSend)]) {
        [delegate postcardDidSend];
    }
}

@end
