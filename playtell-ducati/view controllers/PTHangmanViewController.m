//
//  PTHangmanViewController.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 12/12/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import "PTHangmanViewController.h"

@interface PTHangmanViewController ()

@end

@implementation PTHangmanViewController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
             playdate:(PTPlaydate *)_playdate
              boardId:(NSInteger)_boardId
            initiator:(PTPlaymate *)_initiator
             playmate:(PTPlaymate *)_playmate {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        playdate = _playdate;
        boardId = _boardId;
        initiator = _initiator;
        playmate = _playmate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)dealloc {
    // Notifications cleanup
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

@end