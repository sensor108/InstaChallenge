//
//  FullscreenImageView.h
//  InstaChallenge
//
//  Created by sensor108 on 02.10.14.
//  Copyright (c) 2014 René Nicklas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InstagramKit.h"

typedef void (^FullScreenImageViewDismissCompletionBlock)();

@protocol FullscreenImageViewDelegate <NSObject>

- (void)dismissFullscreenImageView;

@end

@interface FullscreenImageView : UIView

@property (nonatomic, weak) id<FullscreenImageViewDelegate>delegate;

- (void)setupWithInstagramMedia:(InstagramMedia*)media dismissComplitionBlock:(FullScreenImageViewDismissCompletionBlock)block;
- (void)startFullScreenAnimation;
@end

