//
//  ViewController.m
//  QualificationFeedChallenge
//
//  Created by Greg Gunner on 09/12/2014.
//  Copyright (c) 2014 Greg Gunner. All rights reserved.
//

#import "GRGFeedViewController.h"

@interface GRGFeedViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>
@property (nonatomic,strong) UITableView* feedTableView;
@property (nonatomic,strong) UIActivityIndicatorView* activityView;
@property (nonatomic,strong) NSArray* tableFeedItems;
@end

@implementation GRGFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableFeedItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    GRGFeedTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kFeedCellReuseIdentifier forIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    FeedItem* feedItem = self.tableFeedItems[indexPath.row];
    [cell setTitleText:feedItem.title];
    
    [self.imageController getImageFromFeedItem:feedItem forIndexPath:indexPath withCompletion:^(NSError *error, UIImage *image, BOOL fromCache) {
        if (!error) {
            if ([tableView.indexPathsForVisibleRows containsObject:indexPath]) {
                [cell setPhotoImage:image withAnimation:!fromCache];
            }
        }
    }];
    */
    UITableViewCell* cell;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
