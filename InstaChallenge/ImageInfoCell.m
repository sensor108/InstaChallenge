//
//  ImageInfoCell.m
//  InstaChallenge
//
//  Created by sensor108 on 01.10.14.
//  Copyright (c) 2014 René Nicklas. All rights reserved.
//

#import "ImageInfoCell.h"
#import "UIImageView+AFNetworking.h"

@interface ImageInfoCell ()

@property (nonatomic, strong) UILabel *captionLabel;
@property (nonatomic, strong) UILabel *numberOfLikesLabel;
@property (nonatomic, strong) UILabel *locationLabel;

@end

@implementation ImageInfoCell


-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialSetup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialSetup];
    }
    return self;
}



- (void) initialSetup
{
    self.backgroundColor = [UIColor clearColor];
    self.contentView.clipsToBounds = YES;
    
    self.mediaImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 80.0f, 80.0f)];
    self.mediaImageView.backgroundColor = [UIColor clearColor];
    self.mediaImageView.clipsToBounds = NO;
    self.mediaImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.mediaImageView.layer.shadowRadius = 2.0f;
    self.mediaImageView.layer.shadowOpacity = 0.4f;
    self.mediaImageView.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    self.mediaImageView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.mediaImageView.bounds].CGPath;
    [self.contentView addSubview:self.mediaImageView];
    
    self.captionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.captionLabel.numberOfLines = 1;
    [self.contentView addSubview:self.captionLabel];
    
    self.numberOfLikesLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.numberOfLikesLabel.numberOfLines = 1;
    [self.contentView addSubview:self.numberOfLikesLabel];
    
    self.locationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.locationLabel.numberOfLines = 1;
    [self.contentView addSubview:self.locationLabel];

}

- (void)setupWithInstagramMedia:(InstagramMedia *)media
{
    [self.mediaImageView setImageWithURL:media.thumbnailURL];
    
    [self.captionLabel setText:media.caption.text];
    
    [self.numberOfLikesLabel setText:[NSString stringWithFormat:@"Likes: %i", media.likesCount]];
    
    if (CLLocationCoordinate2DIsValid(media.location) && media.location.latitude > 0.0f && media.location.longitude > 0.0f) {
        
        [self.locationLabel setText:[NSString stringWithFormat:@"Lat: %.2f Long: %.2f", media.location.latitude, media.location.longitude]];
        
    }
    
    [self setNeedsLayout];
}


-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat padding = 16.0f;
    
    // image
    CGRect frame = self.mediaImageView.frame;
    frame.origin = CGPointMake(padding,
                               (CGRectGetHeight(self.contentView.bounds) - CGRectGetHeight(frame)) / 2.0f);
    self.mediaImageView.frame = frame;

    // caption
    [self.captionLabel sizeToFit];
    frame = self.captionLabel.frame;
    frame.origin = CGPointMake(CGRectGetMaxX(self.mediaImageView.frame) + padding,
                               CGRectGetMinY(self.mediaImageView.frame));
    self.captionLabel.frame = frame;
    
    // likes
    [self.numberOfLikesLabel sizeToFit];
    frame = self.numberOfLikesLabel.frame;
    frame.origin = CGPointMake(CGRectGetMaxX(self.mediaImageView.frame) + padding,
                               CGRectGetMinY(self.mediaImageView.frame) + (CGRectGetHeight(self.mediaImageView.bounds) - CGRectGetHeight(frame)) / 2.0f);
    self.numberOfLikesLabel.frame = frame;
    
    // location
    [self.locationLabel sizeToFit];
    frame = self.locationLabel.frame;
    frame.origin = CGPointMake(CGRectGetMaxX(self.mediaImageView.frame) + padding,
                               CGRectGetMaxY(self.mediaImageView.frame) - CGRectGetHeight(frame));
    self.locationLabel.frame = frame;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
