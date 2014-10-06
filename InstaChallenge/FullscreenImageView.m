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


- (id)initWithFrame:(CGRect)frame andOffset:(CGFloat)offset
{
    self = [super initWithFrame:CGRectMake(0.0f,
                                           offset,
                                           CGRectGetWidth([UIScreen mainScreen].bounds),
                                           CGRectGetHeight([UIScreen mainScreen].bounds) - offset)];
    if (self) {
        
        _startingFrame = frame;
        [self initialSetup];
        
    }
    return self;
}

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
    [self.doneButton sizeToFit];
    
    CGRect frame = self.doneButton.frame;
    frame.size.width += 10.0f;
    self.doneButton.frame = frame;
    
    [self addSubview:self.doneButton];
    
}

- (void)setupWithInstagramMedia:(InstagramMedia*)media andDismissComplitionBlock:(FullScreenImageViewDismissCompletionBlock)block;
{
    self.dismissComplitionBlock = block;
    [self.imageView setImageWithURL:media.thumbnailURL];
    [self.imageView setImageWithURL:media.standardResolutionImageURL];
    
    [self setNeedsLayout];
}


- (void)startFullScreenAnimation
{
    [UIView animateWithDuration:0.4f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         
                         self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8f];

                         self.imageView.frame = self.bounds;
                         
                         CGRect frame = self.doneButton.frame;
                         frame.origin = CGPointMake(CGRectGetWidth(self.imageView.frame) - CGRectGetWidth(frame) - 16.0f,
                                                    CGRectGetMinY(self.imageView.frame) + 16.0f);
                         self.doneButton.frame = frame;
                         
                         
                         
                     }
                     completion:^(BOOL finished) {
                         
                         [UIView animateWithDuration:0.18f
                                               delay:0.0
                                             options:UIViewAnimationOptionCurveEaseOut
                                          animations:^{
                                              
                                              self.doneButton.alpha = 1.0f;
                                              
                                          }
                                          completion:^(BOOL finished) {
                                              
                                          }
                          ];
                         
                     }
     ];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
}

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
                                              
                                              self.dismissComplitionBlock();
                                              
                                          }
                          ];

                         
                     }
     ];
}



@end
