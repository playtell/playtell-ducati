//
//  TransitionController.m
//
//  Created by XJones on 11/25/11.
//

#import "TransitionController.h"
#import "PTAppDelegate.h"

@implementation TransitionController

@synthesize containerView = _containerView,
viewController = _viewController;

- (id)initWithViewController:(UIViewController *)viewController
{
    if (self = [super init]) {
        _viewController = viewController;
    }
    return self;
}

- (void)loadView
{
    self.wantsFullScreenLayout = YES;
    UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.view = view;

    _containerView = [[UIView alloc] initWithFrame:view.bounds];
    _containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_containerView];
    
    [_containerView addSubview:self.viewController.view];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [self.viewController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.viewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.viewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

-(void)loadGameViewController:(id)viewController
{
    UIViewController *aViewController = (UIViewController *)viewController;
    [UIView transitionWithView:self.containerView
                      duration:.25f
                       options:UIViewAnimationOptionTransitionCurlDown
                    animations:^{
                        [self.viewController.view removeFromSuperview];
                        [self.containerView addSubview:aViewController.view];
                    }
                    completion:^(BOOL finished){
                        self.viewController = aViewController;
                    }];
}

-(void)loadGame:(UIViewController *)aViewController withOptions:(UIViewAnimationOptions)options withSplash:(UIImageView *)splash gameType:(int)gameType
{
    [UIView transitionWithView:self.containerView
                      duration:0.25f
                       options:options
                    animations:^{
                        [self.viewController.view removeFromSuperview];
                        [self.containerView addSubview:splash];

                    }
                    completion:^(BOOL finished){
                        self.viewController = aViewController;
                        
                        [UIView transitionWithView:self.containerView
                                          duration:1.5f
                                           options:UIViewAnimationOptionTransitionCrossDissolve
                                        animations:^{
                                        }
                                        completion:^(BOOL finished){
                                            [splash removeFromSuperview];
                                        }];
                        
                    }];
    
    [self performSelector:@selector(loadGameViewController:) withObject:(id)aViewController afterDelay:1.5f];
}

- (void)transitionToViewController:(UIViewController *)aViewController
                       withOptions:(UIViewAnimationOptions)options
{
    [UIView transitionWithView:self.containerView
                      duration:0.25f
                       options:options
                    animations:^{
                        [self.viewController.view removeFromSuperview];
                        [self.containerView addSubview:aViewController.view];
                    }
                    completion:^(BOOL finished){
                        self.viewController = aViewController;
                    }];
}

@end