//
//  UIImageView+PlayTell.m
//  PlayTell
//
//  Created by Ricky Hussmann on 5/4/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "UIImageView+PlayTell.h"

@implementation UIImageView (PlayTell)

- (void)setImageWithURLString:(NSString*)aString {
    NSURL* url = [NSURL URLWithString:aString];
    [self setImageWithAURL:url];
}

- (void)setImageWithAURL:(NSURL*)aURL origin:(CGPoint)aPoint maxSize:(CGSize)aSize completeion:(PTImageLoadedBlock)completionHandler {
    NSURLRequest* request = [NSURLRequest requestWithURL:aURL];
    
    __block __typeof__(self) blockSelf = self;
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse* response, NSData* data, NSError* error) {
                               if (!data) {
                                   NSLog(@"Unable to load image %@, error: %@", aURL, error);
                                   return;
                               };

                               UIImage* anImage = [[UIImage alloc] initWithData:data];

                               CGRect newFrame = CGRectZero;
                               CGFloat aspectRatio = anImage.size.width / anImage.size.height;
                               if (aSize.width / aspectRatio <= aSize.height) {
                                   newFrame.size.width = aSize.width;
                                   newFrame.size.height = aSize.width / aspectRatio;
                               } else {
                                   newFrame.size.height = aSize.height;
                                   newFrame.size.width = aSize.height * aspectRatio;
                               }

                               blockSelf.contentMode = UIViewContentModeScaleAspectFit;
                               blockSelf.image = anImage;

                               newFrame.origin.x = aPoint.x;
                               newFrame.origin.y = aPoint.y;
                               blockSelf.frame = newFrame;

                               if (completionHandler) {
                                   completionHandler(blockSelf);
                               }
                           }];
}

- (void)setImageWithAURL:(NSURL*)aURL {
    NSURLRequest* request = [NSURLRequest requestWithURL:aURL];

    __block __typeof__(self) blockSelf = self;
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse* response, NSData* data, NSError* error) {
                               if (!data) {
                                   NSLog(@"Unable to load image %@, error: %@", aURL, error);
                                   return;
                               };

                               UIImage* anImage = [[UIImage alloc] initWithData:data];
                               blockSelf.image = anImage;
                               NSLog(@"%@", NSStringFromSelector(_cmd));
                           }];
}

@end
