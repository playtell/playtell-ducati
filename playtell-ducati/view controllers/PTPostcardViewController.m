//
//  PTPostcardViewController.m
//  playtell-ducati
//
//  Created by Adam Horne on 11/1/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTPlaydatePhotoCreateRequest.h"
#import "PTPostcardViewController.h"
#import "PTUser.h"

@interface PTPostcardViewController ()

@property (nonatomic, strong) PTPostcardView *postcardView;

@end

@implementation PTPostcardViewController
@synthesize playdateId;
@synthesize delegate;

@synthesize postcardView;

- (id)init {
    return [self initWithNibName:nil bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.postcardView = [[PTPostcardView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 1024.0f, 768.0f)];
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

#pragma mark - Postcard Delegate
- (void)postcardTaken:(UIImage *)postcard withScreenshot:(UIImage *)screenshot {
    dispatch_async(dispatch_get_current_queue(), ^{
        PTPlaydatePhotoCreateRequest *photoCreateRequest = [[PTPlaydatePhotoCreateRequest alloc] init];
        [photoCreateRequest playdatePhotoCreateWithUserId:[PTUser currentUser].userID
                                               playdateId:self.playdateId
                                                    photo:postcard
                                                  success:^(NSDictionary *result) {
                                                      //NSLog(@"Postcard successfully uploaded.");
                                                  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                      NSLog(@"Playdate photo creation failure!! %@ - %@", error, JSON);
                                                  }];
    });
    //UIImageWriteToSavedPhotosAlbum(postcard, nil, nil, nil);
    //UIImageWriteToSavedPhotosAlbum(screenshot, nil, nil, nil);
    
    if ([delegate respondsToSelector:@selector(postcardDidSend)]) {
        [delegate postcardDidSend];
    }
}

@end
