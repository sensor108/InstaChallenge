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
#import "NSData+AES.h"
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

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.userImageView.layer.shadowRadius = 2.0f;
    self.userImageView.layer.shadowOpacity = 0.4f;
    self.userImageView.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    self.userImageView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.userImageView.bounds].CGPath;

}


#pragma mark - Setup


- (void)initialSetup
{
    self.userInfoContainerView.hidden = YES;
    self.activityIndicator.hidden = YES;
    
    NSString *accessToken = [self getStoredToken];
    
    if (accessToken) {
        
        [[InstagramEngine sharedEngine] setAccessToken:accessToken];
        
        [self showUserInfo];

    } else {

        [self showLoginView];

    }
}


#pragma mark - Store token

- (NSString*)getStoragePath
{
    NSString *docDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *storagePath = [[docDir stringByAppendingPathComponent:@"secret"] stringByAppendingPathExtension:@"dat"];
    
    return storagePath;
}

- (NSString *)getStoredToken
{
    NSString *storagePath = [self getStoragePath];
    
    NSData *storedData = [[NSData dataWithContentsOfFile:storagePath] decryptAES:ENCRYPTION_KEY];
    if (storedData) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:storedData];
    }
    
    return nil;
}

- (void)deleteStoredToken
{
    NSError *error = nil;
    NSString *storagePath = [self getStoragePath];
    [[NSFileManager defaultManager] removeItemAtPath:storagePath error:&error];
    if (error) {
         NSLog(@"Error: %@", [error localizedDescription]);
    }
    
}

- (void)saveToken:(NSString*)token
{
    NSString *storagePath = [self getStoragePath];
    
    NSData *dataToStore = [[NSKeyedArchiver archivedDataWithRootObject:token] encryptAES:ENCRYPTION_KEY];
    if (![dataToStore writeToFile:storagePath atomically:YES]) {
        NSLog(@"OhOh!!!!");
    }
    
    NSError *error = nil;
    [[NSFileManager defaultManager] setAttributes:@{NSFileProtectionKey: NSFileProtectionComplete}
                                     ofItemAtPath:storagePath error:&error];
    if(error) {
        NSLog(@"Error: %@", [error localizedDescription]);
    }
}

#pragma mark - Show user info

- (void)showUserInfo
{
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    
    [[InstagramEngine sharedEngine] getSelfUserDetailsWithSuccess:^(InstagramUser *userDetail) {
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:userDetail.Id forKey:USERDEFAULT_KEY_USER_ID];
        [userDefaults synchronize];
        
        [self.activityIndicator stopAnimating];
        
        self.userInfoContainerView.hidden = NO;
        
        [self.userImageView setImageWithURL:userDetail.profilePictureURL];
        [self.userNameLabel setText:userDetail.username];
        
    } failure:^(NSError *error) {
        // somenthing went wrong. remove all data and show the login screen again
        NSLog(@"Error: %@" , [error localizedDescription]);
        [self logoutButtonTapped:nil];
    }];
}


#pragma mark - Show login

- (void)showLoginView
{
    if (self.loginView == nil) {
        
        self.loginView = [[ModalLoginView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.loginView.delegate = self;
        [self.view addSubview:self.loginView];
        [self.loginView showAnimated];
    }
    
}

#pragma mark - Actions

- (IBAction)logoutButtonTapped:(id)sender
{
    // remove coookie
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    
    // delete stored userID
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:nil forKey:USERDEFAULT_KEY_USER_ID];
    [userDefaults synchronize];
    
    // delete stored token
    [self deleteStoredToken];
    
    [[InstagramEngine sharedEngine] setAccessToken:nil];
    
    self.userInfoContainerView.hidden = YES;
    
    [self showLoginView];
}


#pragma mark - ModalLoginViewDelegate

- (void)loginSuccess
{
    [self.loginView removeFromSuperview];
    self.loginView = nil;
    
    [self saveToken:[InstagramEngine sharedEngine].accessToken];
    
    [self showUserInfo];
}

@end
