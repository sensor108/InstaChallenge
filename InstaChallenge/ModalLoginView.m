//
//  ModalLoginView.m
//  InstaChallenge
//
//  Created by sensor108 on 01.10.14.
//  Copyright (c) 2014 René Nicklas. All rights reserved.
//

#import "ModalLoginView.h"
#import "InstagramKit.h"
#import "AppDelegate.h"


@interface ModalLoginView() <UIWebViewDelegate>

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;


@end

@implementation ModalLoginView

- (instancetype) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialSetup];
    }
    
    return self;
    
}

- (void)initialSetup
{
    
    self.backgroundColor = [UIColor clearColor];
    self.backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    self.backgroundView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.8f];
    self.backgroundView.alpha = 0.0f;
    [self addSubview:self.backgroundView];
    
    CGSize size = CGSizeMake(CGRectGetWidth(self.bounds) - 60.0f, CGRectGetHeight(self.bounds) - 200.0f);
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.bounds) - size.width) / 2.0f,
                                                            (CGRectGetHeight(self.bounds) - size.height) / 2.0f,
                                                            size.width,
                                                            size.height)];
    
    self.webView.scrollView.bounces = NO;
    self.webView.contentMode = UIViewContentModeScaleAspectFit;
    self.webView.delegate = self;
    self.webView.layer.cornerRadius = 4.0f;
    self.webView.backgroundColor = [UIColor redColor];
    self.webView.clipsToBounds = YES;
    self.webView.alpha = 0.0f;
    self.webView.transform = CGAffineTransformMakeScale(0.8f, 0.8f);
    
    [self.backgroundView addSubview:self.webView];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.activityIndicator hidesWhenStopped];
    CGRect frame = self.activityIndicator.frame;
    frame.origin = CGPointMake((CGRectGetWidth(self.backgroundView.frame) - CGRectGetWidth(frame)) / 2.0f,
                               (CGRectGetHeight(self.backgroundView.frame) - CGRectGetHeight(frame)) / 2.0f);
    self.activityIndicator.frame = frame;
    [self.backgroundView addSubview:self.activityIndicator];
    [self.activityIndicator startAnimating];
}

#pragma mark - Show login

- (void)showAnimated
{
    
    NSDictionary *configuration = [InstagramEngine sharedEngineConfiguration];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?client_id=%@&redirect_uri=%@&response_type=token",
                                       configuration[kInstagramKitAuthorizationUrlConfigurationKey],
                                       configuration[kInstagramKitAppClientIdConfigurationKey],
                                       configuration[kInstagramKitAppRedirectUrlConfigurationKey]]];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];

    [UIView animateWithDuration:0.18f
                          delay:0.5f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         
                         self.backgroundView.alpha = 1.0f;
                         
                     } completion:^(BOOL finished) {
                         
                         [UIView animateWithDuration:0.18f
                                               delay:0.2f
                                             options:UIViewAnimationOptionCurveEaseOut
                                          animations:^{
                                              
                                              self.webView.alpha = 1.0f;
                                              self.webView.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
                                              
                                          }
                                          completion:^(BOOL finished) {
                                              
                                              [UIView animateWithDuration:0.18f
                                                                    delay:0.0f
                                                                  options:UIViewAnimationOptionCurveEaseOut
                                                               animations:^{
                                                                   self.webView.transform = CGAffineTransformIdentity;
                                                               }
                                                               completion:(NULL)
                                               ];

                                          }
                          ];

                     }
     ];
}

#pragma mark - UIWebViewDelegate

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.activityIndicator stopAnimating];
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *URLString = [request.URL absoluteString];
    if ([URLString hasPrefix:[[InstagramEngine sharedEngine] appRedirectURL]]) {
        NSString *delimiter = @"access_token=";
        NSArray *components = [URLString componentsSeparatedByString:delimiter];
        if (components.count > 1) {
            NSString *accessToken = [components lastObject];
            [[InstagramEngine sharedEngine] setAccessToken:accessToken];
            
            [webView stopLoading];
            webView.delegate = nil;
            
            if ([self.delegate respondsToSelector:@selector(loginSuccess)]) {
                [self.delegate performSelector:@selector(loginSuccess) withObject:nil];
            }
            
        }
        return NO;
    } else {
        [webView.window makeKeyAndVisible];
    }
    
    
    return YES;
}



@end
