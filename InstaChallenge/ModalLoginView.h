//
//  ModalLoginView.h
//  InstaChallenge
//
//  Created by sensor108 on 01.10.14.
//  Copyright (c) 2014 René Nicklas. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ModalLoginViewDelegate;

@interface ModalLoginView : UIView

@property (nonatomic, weak) id<ModalLoginViewDelegate>delegate;

- (void)showAnimated;

@end


@protocol ModalLoginViewDelegate <NSObject>

- (void)loginSuccess;
- (void)loginFailed;


@end
