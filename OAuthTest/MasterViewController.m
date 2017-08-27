//
//  MasterViewController.m
//  OAuthTest
//
//  Created by sergey on 8/8/17.
//  Copyright © 2017 sergey. All rights reserved.
//

#import "MasterViewController.h"
#import "SSTwitt.h"
#import "SSTwitterAPIClient.h"

@interface MasterViewController ()

// store tweets
@property(nonatomic, strong) NSMutableArray *tweets;

//store for last tweet's id
@property(nonatomic, strong) NSNumber *lastTweetID;

@property (nonatomic, assign) BOOL isMoreDataLoading;

@end

@implementation MasterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [SSTwitterAPIClient sharedInstance].delegate = self;
    self.tweets = [NSMutableArray new];
    self.lastTweetID = nil;
}


- (void)viewWillAppear:(BOOL)animated
{
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.topItem.title = @"SoftServeTest";
}

- (void)viewDidAppear:(BOOL)animated
{
    if ([[SSTwitterAPIClient sharedInstance] isAuthorized])
    {
        [self loadTweetsWithoutRefresh:NO];
    }
    else
    {
        [[SSTwitterAPIClient sharedInstance] loginToTwitter];
    }
}

#pragma mark SSTwitterAPIClient
- (void)loadTweetsWithoutRefresh:(BOOL)refresh
{
    [[SSTwitterAPIClient sharedInstance] twittsFromTimeLineWithMaxTwittsID:[self.lastTweetID stringValue] andCompletionBlock:^(NSArray *tweets, NSError *error)
    {
       // [self.tweets addObjectsFromArray:tweets];
        
        if (nil != error)
        {
            NSLog(@"Error: %@", error.localizedDescription);
        }
        else
        {
            if (refresh)
            {
                // if need to append data
                NSMutableArray *cleaned = [NSMutableArray arrayWithArray:tweets];
                if (tweets.count > 0)
                {
                    [cleaned removeObjectAtIndex:0];
                }
                
                if (cleaned.count > 0)
                {
                    [self.tweets addObjectsFromArray:cleaned];
                    self.isMoreDataLoading = NO;
                }
            }
            else
            {
                // if need to refresh table with new data
                [self.tweets removeAllObjects];
                [self.tweets addObjectsFromArray:tweets];
            }
            SSTwitt *lastTweet = self.tweets.lastObject;
            self.lastTweetID = [lastTweet twittID];
            
            [self.tableView reloadData];
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tweets.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    SSTwitt *object = self.tweets[indexPath.row];
    cell.textLabel.text = [object tweetText];
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


#pragma mark UIScrollViewDelegate
// download 10 more tweets if we scroll down
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!self.isMoreDataLoading && self.tweets.count > 0)
    {
        CGFloat scrollViewCH = self.tableView.contentSize.height;
        CGFloat scrollOffset = scrollViewCH - self.tableView.bounds.size.height;
        
        if (scrollView.contentOffset.y > scrollOffset && self.tableView.isDragging)
        {
            self.isMoreDataLoading = YES;
            [self loadTweetsWithoutRefresh:YES];
        }
    }
}

#pragma mark SSTwitterLoginProtocol
//delegate method - tweeter login sucess
- (void)didLoggeIn
{
    if ([[SSTwitterAPIClient sharedInstance] isAuthorized])
    {
        [self loadTweetsWithoutRefresh:NO];
    }
    else
    {
        [[SSTwitterAPIClient sharedInstance] loginToTwitter];
    }
}
@end
