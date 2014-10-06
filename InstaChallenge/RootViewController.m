//
//  RootViewController.m
//  InstaChallenge
//
//  Created by sensor108 on 01.10.14.
//  Copyright (c) 2014 René Nicklas. All rights reserved.
//

#import "RootViewController.h"
#import "ModalLoginView.h"
#import "InstagramKit.h"
#import "UIImageView+AFNetworking.h"
#import "AppDelegate.h"


@interface RootViewController () <ModalLoginViewDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIView *userInfoContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

@property (strong, nonatomic) ModalLoginView *loginView;

@end

@implementation RootViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initialSetup];

}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}


#pragma mark - Setup

- (void)initialSetup
{
    self.userInfoContainerView.hidden = YES;
    self.activityIndicator.hidden = YES;
    self.userImageView.layer.shadowRadius = 2.0f;
    self.userImageView.layer.shadowOpacity = 0.4f;
    self.userImageView.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    self.userImageView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.userImageView.bounds].CGPath;
    
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULT_KEY_ACCESS_TOKEN];
    
    if (accessToken) {
        
        [[InstagramEngine sharedEngine] setAccessToken:accessToken];
        
        [self showUserInfo];

    } else {

        [self showLoginView];

    }
}


#pragma mark - Show user info

- (void)showUserInfo
{
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    
    [[InstagramEngine sharedEngine] getSelfUserDetailsWithSuccess:^(InstagramUser *userDetail) {
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:[InstagramEngine sharedEngine].accessToken forKey:USERDEFAULT_KEY_ACCESS_TOKEN];
        [userDefaults setObject:userDetail.Id forKey:USERDEFAULT_KEY_USER_ID];
        [userDefaults synchronize];
        
        [self.activityIndicator stopAnimating];
        
        self.userInfoContainerView.hidden = NO;
        
        [self.userImageView setImageWithURL:userDetail.profilePictureURL];
        [self.userNameLabel setText:userDetail.username];
        
    } failure:^(NSError *error) {
        NSLog(@"Error: %@" , [error localizedDescription]);
    }];
}


#pragma mark - Show login

- (void)showLoginView
{
    if (self.loginView == nil) {
        
        CGRect screenBounds = [UIScreen mainScreen].bounds;
        
        self.loginView = [[ModalLoginView alloc] initWithFrame:screenBounds];
        self.loginView.delegate = self;
        [self.view addSubview:self.loginView];
        [self.loginView showAnimated];
    }
    
}

#pragma mark - Actions

- (IBAction)logoutButtonTapped:(id)sender
{
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:nil forKey:USERDEFAULT_KEY_ACCESS_TOKEN];
    [userDefaults setObject:nil forKey:USERDEFAULT_KEY_USER_ID];
    [userDefaults synchronize];
    
    [[InstagramEngine sharedEngine] setAccessToken:nil];
    
    self.userInfoContainerView.hidden = YES;
    
    [self showLoginView];
}


#pragma mark - ModalLoginViewDelegate


- (void)loginSuccess
{
    [self.loginView removeFromSuperview];
    self.loginView = nil;
    
    [self showUserInfo];
    
}

@end
