//
//  MediaTableViewController.m
//  InstaChallenge
//
//  Created by sensor108 on 01.10.14.
//  Copyright (c) 2014 René Nicklas. All rights reserved.
//

#import <MessageUI/MessageUI.h>

#import "MediaViewController.h"
#import "AppDelegate.h"
#import "InstagramKit.h"
#import "ImageInfoCell.h"
#import "FullscreenImageView.h"

@interface MediaViewController () <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) InstagramPaginationInfo *currentPaginationInfo;
@property (nonatomic, strong) NSMutableArray *mediaArray;
@property (nonatomic, strong) FullscreenImageView *fullscreenImageView;
@property (nonatomic, strong) NSIndexPath *accessoryIndex;

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
    [self loadMedia];
}


- (BOOL)prefersStatusBarHidden {
    return NO;
}

#pragma mark - Load media

- (void)loadMedia
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
    
    //[self.navigationController setNavigationBarHidden:YES animated:YES];
    
    InstagramMedia *media = [self.mediaArray objectAtIndex:indexPath.row];
    CGRect rectInSuperview = [tableView rectForRowAtIndexPath:indexPath];
    rectInSuperview = [tableView convertRect:rectInSuperview toView:self.view];
    
    ImageInfoCell *cell = (ImageInfoCell*)[tableView cellForRowAtIndexPath:indexPath];
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

        [self.navigationController setNavigationBarHidden:NO animated:YES];
        
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

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    
    NSMutableArray *buttonTitles = [NSMutableArray arrayWithObjects:@"Send Email", @"Open in Safari", nil];

    InstagramMedia *media = [self.mediaArray objectAtIndex:indexPath.row];
    NSURL *instagramURL = [NSURL URLWithString:[NSString stringWithFormat:@"instagram://media?id=%@", media.Id]];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        [buttonTitles addObject:@"Open in Instagram"];
    }
    
    self.accessoryIndex = indexPath;

    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:nil
                                         destructiveButtonTitle:@"Cancel"
                                              otherButtonTitles:nil];
    
    for (NSString *title in buttonTitles) {
        [sheet addButtonWithTitle:title];
    }
    
    [sheet showInView:self.view];
}

#pragma mark - Show fullscreen


-(void)displayFullScreenImageViewWithFrame:(CGRect)frame andInstagramMedia:(InstagramMedia *)media andDismissCompletionBlock:(FullScreenImageViewDismissCompletionBlock)dismissCompletion
{

    self.fullscreenImageView = [[FullscreenImageView alloc] initWithFrame:frame];
    
    UIWindow* currentWindow = [UIApplication sharedApplication].keyWindow;
    [currentWindow addSubview:self.fullscreenImageView];
    
    [self.fullscreenImageView setupWithInstagramMedia:media dismissComplitionBlock:dismissCompletion];
    [self.fullscreenImageView startFullScreenAnimation];
}

#pragma mark - UIActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex == actionSheet.destructiveButtonIndex || buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    InstagramMedia *media = [self.mediaArray objectAtIndex:self.accessoryIndex.row];
    
    
    switch (buttonIndex) {
        case 1: {
            [self generateMail:media.standardResolutionImageURL];
            break;
        }
        case 2: {
            
            [[UIApplication sharedApplication] openURL:media.standardResolutionImageURL];
            
            break;
        }
        case 3: {
            NSURL *instagramURL = [NSURL URLWithString:[NSString stringWithFormat:@"instagram://media?id=%@", media.Id]];
            if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
                [[UIApplication sharedApplication] openURL:instagramURL];
            }
        }
    }
}

#pragma mark - Mail

- (void)generateMail:(NSURL*)url
{
    if ([MFMailComposeViewController canSendMail]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            MFMailComposeViewController *vc = [[MFMailComposeViewController alloc] init];
            vc.mailComposeDelegate = self;
            [vc setSubject:@"Instagram Image"];
            
            [vc addAttachmentData:[NSData dataWithContentsOfURL:url] mimeType:@"image/png" fileName:@"instaImage.png"];
            
            // Fill out the email body text
            NSString *emailBody = @"Please have a look!";
            [vc setMessageBody:emailBody isHTML:NO];
            
            
            [self presentViewController:vc animated:YES completion:NULL];
            
        });
        
    } else {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Email error"
                                                            message:@"There seems to be no email account installed"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        
        [alertView show];
        
    }
    
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
