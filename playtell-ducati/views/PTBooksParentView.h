//
//  PTBooksParentView.h
//  PlayTell
//
//  Created by Dimitry Bentsionov on 5/21/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTBooksScrollView.h"

@interface PTBooksParentView : UIView {
    PTBooksScrollView *scrollView;
    BOOL isBookOpen;
}

@property (nonatomic) BOOL isBookOpen;

@end
