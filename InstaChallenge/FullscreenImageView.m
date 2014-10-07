//
//  FullscreenImageView.m
//  InstaChallenge
//
//  Created by sensor108 on 02.10.14.
//  Copyright (c) 2014 René Nicklas. All rights reserved.
//

#import "FullscreenImageView.h"
#import "UIImageView+AFNetworking.h"

@interface FullscreenImageView ()

@property (nonatomic, strong) FullScreenImageViewDismissCompletionBlock dismissComplitionBlock;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *doneButton;
@property (nonatomic) CGRect startingFrame;

@end

@implementation FullscreenImageView

#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(0.0f,
                                           0.0f,
                                           CGRectGetWidth([UIScreen mainScreen].bounds),
                                           CGRectGetHeight([UIScreen mainScreen].bounds))];
    if (self) {
        
        _startingFrame = frame;
        [self initialSetup];
        
    }
    return self;
}

#pragma mark - Setup

- (void)initialSetup
{
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = NO;
    
    self.imageView = [[UIImageView alloc] initWithFrame:self.startingFrame];
    self.imageView.clipsToBounds = YES;
    self.imageView.backgroundColor = [UIColor clearColor];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.imageView];
    
    self.doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.doneButton.alpha = 0.0f;
    self.doneButton.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.2f];
    self.doneButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.doneButton.layer.borderWidth = 1.0f;
    self.doneButton.layer.cornerRadius = 4.0f;
    [self.doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [self.doneButton addTarget:self action:@selector(doneButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.doneButton];
    
    [self.doneButton sizeToFit];
    CGRect frame = self.doneButton.frame;
    frame.size.width += 10.0f;
    self.doneButton.frame = frame;
    
}

- (void)setupWithInstagramMedia:(InstagramMedia*)media dismissComplitionBlock:(FullScreenImageViewDismissCompletionBlock)block
{
    self.dismissComplitionBlock = block;
    [self.imageView setImageWithURL:media.thumbnailURL];
    [self.imageView setImageWithURL:media.standardResolutionImageURL];
    
    [self setNeedsLayout];
}



#pragma mark - Animations

- (void)startFullScreenAnimation
{
    [UIView animateWithDuration:0.4f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         
                         self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1.0f];

                         self.imageView.frame = self.bounds;
                         
                         CGRect frame = self.doneButton.frame;
                         CGFloat padding = 16.0f;
                         frame.origin = CGPointMake(CGRectGetWidth(self.imageView.frame) - CGRectGetWidth(frame) - padding,
                                                    CGRectGetMinY(self.imageView.frame) + padding);
                         self.doneButton.frame = frame;
                         
                     }
                     completion:^(BOOL finished) {
                         
                         [UIView animateWithDuration:0.18f
                                               delay:0.0
                                             options:UIViewAnimationOptionCurveEaseOut
                                          animations:^{
                                              
                                              self.doneButton.alpha = 1.0f;
                                              
                                          }
                                          completion:NULL
                          ];
                     }
     ];
}


#pragma mark - Actions

- (void)doneButtonTapped:(id)sender
{
    
    [UIView animateWithDuration:0.1f
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         
                         self.doneButton.alpha = 0.0f;
                         
                     }
                     completion:^(BOOL finished) {
                         
                         [UIView animateWithDuration:0.4f
                                               delay:0.0f
                                             options:UIViewAnimationOptionCurveEaseOut
                                          animations:^{
                                              
                                              self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0f];

                                              self.imageView.frame = self.startingFrame;
                                              
                                          }
                                          completion:^(BOOL finished) {
                                              
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  self.dismissComplitionBlock();
                                              });
                                              
                                              
                                              
                                          }
                          ];

                         
                     }
     ];
}

@end
