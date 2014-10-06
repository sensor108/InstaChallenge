//
//  ImageInfoCell.h
//  InstaChallenge
//
//  Created by sensor108 on 01.10.14.
//  Copyright (c) 2014 René Nicklas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InstagramKit.h"


@interface ImageInfoCell : UITableViewCell

@property (nonatomic, strong) UIImageView *mediaImageView;

- (void)setupWithInstagramMedia:(InstagramMedia *)media;


@end
