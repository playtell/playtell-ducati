//
//  PTDiagnosticViewController.h
//  playtell-ducati
//
//  Created by Ricky Hussmann on 6/6/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PTDiagnosticViewController : UIViewController
@property (nonatomic, retain) IBOutlet UIView* channelStatus;
@property (nonatomic, retain) IBOutlet UILabel* statusLabel;
@property (nonatomic, retain) IBOutlet UILabel* initiatorLabel;
@property (nonatomic, retain) IBOutlet UILabel* playmateLabel;
@property (nonatomic, retain) IBOutlet UIButton* joinButton;
@property (nonatomic, retain) IBOutlet UIButton* subscribeButton;

- (IBAction)joinPressed:(id)sender;
- (IBAction)subscribeToRendezvous:(id)sender;
@end
