//
//  MediaTableViewController.m
//  InstaChallenge
//
//  Created by sensor108 on 01.10.14.
//  Copyright (c) 2014 René Nicklas. All rights reserved.
//

#import "MediaViewController.h"
#import "AppDelegate.h"
#import "InstagramKit.h"
#import "ImageInfoCell.h"
#import "FullscreenImageView.h"

@interface MediaViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) InstagramPaginationInfo *currentPaginationInfo;
@property (nonatomic, strong) NSMutableArray *mediaArray;
@property (nonatomic, strong) FullscreenImageView *fullscreenImageView;

@end


@implementation MediaViewController

#pragma mark - Lifecycle

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _mediaArray = [NSMutableArray array];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSelfFeed];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (void)loadSelfFeed
{
    NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULT_KEY_USER_ID];
    
    [[InstagramEngine sharedEngine] getMediaForUser:userID withSuccess:^(NSArray *media, InstagramPaginationInfo *paginationInfo) {
        self.currentPaginationInfo = paginationInfo;
        
        [self.activityIndicator stopAnimating];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isVideo = NO"];
        [self.mediaArray addObjectsFromArray:[media filteredArrayUsingPredicate:predicate]];
        
        NSSortDescriptor *dateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"createdDate"
                                                                            ascending:NO];
        
        [self.mediaArray sortUsingDescriptors:@[dateSortDescriptor]];
        
        [self.tableView reloadData];

    } failure:^(NSError *error) {
        NSLog(@"Error: %s Reason: %@", __func__, [error localizedDescription]);
    }];
}


#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    InstagramMedia *media = [self.mediaArray objectAtIndex:indexPath.row];
    CGRect rectInSuperview = [tableView rectForRowAtIndexPath:indexPath];
    rectInSuperview = [tableView convertRect:rectInSuperview toView:self.view];
    
    __block ImageInfoCell *cell = (ImageInfoCell*)[tableView cellForRowAtIndexPath:indexPath];
    cell.mediaImageView.hidden = YES;
    
    CGRect imageFrameRect = cell.mediaImageView.frame;
    CGRect frame = CGRectMake(imageFrameRect.origin.x,
                              rectInSuperview.origin.y + imageFrameRect.origin.y,
                              CGRectGetWidth(imageFrameRect),
                              CGRectGetHeight(imageFrameRect));
    
    [self displayFullScreenImageViewWithFrame:frame andInstagramMedia:media andDismissCompletionBlock:^{
        cell.mediaImageView.hidden = NO;
        [self.fullscreenImageView removeFromSuperview];
        self.fullscreenImageView = nil;
    }];
}


#pragma mark - TableView DataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.mediaArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    ImageInfoCell *imageInfoCell = (ImageInfoCell*)[tableView dequeueReusableCellWithIdentifier:@"ImageInfoCell"
                                                                                   forIndexPath:indexPath];
    
    InstagramMedia *media = [self.mediaArray objectAtIndex:indexPath.row];
    
    [imageInfoCell setupWithInstagramMedia:media];
    
    return imageInfoCell;
}


-(void)displayFullScreenImageViewWithFrame:(CGRect)frame andInstagramMedia:(InstagramMedia *)media andDismissCompletionBlock:(FullScreenImageViewDismissCompletionBlock)dismissCompletion
{

    CGFloat offset = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
    offset += CGRectGetHeight(self.navigationController.navigationBar.frame);
    
    frame.origin.y -= offset;

    self.fullscreenImageView = [[FullscreenImageView alloc] initWithFrame:frame andOffset:offset];
    [self.view addSubview:self.fullscreenImageView];
    
    [self.fullscreenImageView setupWithInstagramMedia:media andDismissComplitionBlock:dismissCompletion];
    
    [self.fullscreenImageView startFullScreenAnimation];
}

@end
