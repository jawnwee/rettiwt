//
//  JYLFeedCollectionViewController.m
//  rettiwt
//
//  Created by John Lee on 8/12/14.
//  Copyright (c) 2014 johnjlee. All rights reserved.
//

#import <Accounts/Accounts.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <Social/Social.h>
#import "JYLFeedCollectionViewController.h"
#import "JYLFeedLayout.h"
#import "JYLFeedCollectionViewCell.h"
#import "JYLRettiwtManagedStore.h"
#import "JYLRettiwtPost.h"
#import "JYLConstants.h"

@interface JYLFeedCollectionViewController ()

@property (nonatomic, strong) ACAccount *rettAcc;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSString *tweetCount;

@end

@implementation JYLFeedCollectionViewController

- (instancetype)initWithAccount:(ACAccount *)account {
    self = [super init];
    if (self) {
        _rettAcc = account;
        // This must be set to the max_tweets we store in core data so we know to attempt to
        // store MAX_TWEETS number of objects (unless this number is greater than current number
        // of existing timeline tweets. 10 added to this initial set number (still have yet to
        // figure out why this set number of tweets is not received in the request
        // (usually under the count I set it to thus triggering array out of bounds)
        _tweetCount = [NSString stringWithFormat:@"%d", MAX_TWEETS + 10];
        [self refreshTweets];
        self.view.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupCollectionView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // Setup polling if connection is available
    // However if user disconnects after called
    // we still check if user is connected if a refresh is ever called anyways
    // this is just in case a user was initially connected, but suddenly disconnects and reconnects
    // again later.
    if ([self connected]) {
        [NSTimer scheduledTimerWithTimeInterval:20.0
                                         target:self
                                       selector:@selector(pollingTweets)
                                       userInfo:nil
                                        repeats:YES];
    }
}

/* Setup our collection viey layoud with cards like Facebook's paper */
- (void)setupCollectionView {
    JYLFeedLayout *layout = [[JYLFeedLayout alloc] init];
    CGRect collectionViewFrame = self.view.frame;
    collectionViewFrame.size.height *= 0.4;
    [self.view setFrame:collectionViewFrame];
    CGSize feedSize = CGSizeMake(130, collectionViewFrame.size.height);
    [layout setFeedSize:feedSize];
    [layout setItemSize:feedSize];
    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame
                                                          collectionViewLayout:layout];
    [_collectionView registerClass:[JYLFeedCollectionViewCell class]
       forCellWithReuseIdentifier:@"cell"];
    _collectionView.backgroundColor = [UIColor lightGrayColor];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.showsHorizontalScrollIndicator = YES;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.bounces = NO;
    [self.view addSubview:_collectionView];
}

#pragma mark - Twitter Live Feed
/* Used as a basic connecticity test
 if an even minimal site is found change
 url */
- (BOOL)connected {
    NSURL *scriptUrl = [NSURL URLWithString:@"http://google.com/m"];
    NSData *data = [NSData dataWithContentsOfURL:scriptUrl];
    if (data) {
        return YES;
    } else {
        return NO;
    }
}

/* Retrieve number of tweets that we set in variable self.tweetCount */
- (void)refreshTweets {
    if ([self connected]) {
        NSURL *requestURL =
        [NSURL URLWithString:@"https://api.twitter.com/1/statuses/home_timeline.json"];
        NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
        [parameters setObject:self.tweetCount forKey:@"count"];
        [parameters setObject:@"1" forKey:@"include_entities"];

        SLRequest *postRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                    requestMethod:SLRequestMethodGET
                                                              URL:requestURL
                                                       parameters:parameters];
        postRequest.account = self.rettAcc;
        [postRequest performRequestWithHandler:^(NSData *responseData,
                                                 NSHTTPURLResponse *urlResponse,
                                                 NSError *error) {
            self.dataSource = [NSJSONSerialization JSONObjectWithData:responseData
                                                              options:NSJSONReadingMutableLeaves
                                                                error:&error];
            if (self.dataSource.count != 0) {
                NSDateFormatter *df = [[NSDateFormatter alloc] init];
                [df setDateFormat:@"EEE MMM d HH:mm:ss ZZZZ yyyy"];

                // Series of sync'd dispatches to ensure order and completed execution
                for (int i = 0; i < MAX_TWEETS; i++) {
                    NSDictionary *tweet = self.dataSource[i];
                    NSDictionary *user = tweet[@"user"];
                    NSString *text = tweet[@"text"];
                    NSString *username = user[@"screen_name"];
                    NSTimeInterval timeIntveral =
                               [[df dateFromString:tweet[@"created_at"]] timeIntervalSince1970];
                    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:timeIntveral];
                    [[JYLRettiwtManagedStore sharedStore] addTweet:username
                                                             tweet:text
                                                           forDate:date];
                }

                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self.collectionView reloadData];
                });
            }
        }];
    } else {
        [self retrieveFromLocal];
    }
}

/* Fire this poll every 20 seconds to retrieve first new tweet
   compare the two. If they aren't the same; refresh all tweets and update core data to
   keep first 100 tweets
 */
- (void)pollingTweets {
    NSURL *requestURL =
    [NSURL URLWithString:@"https://api.twitter.com/1/statuses/home_timeline.json"];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:@"1" forKey:@"count"];
    [parameters setObject:@"1" forKey:@"include_entities"];

    SLRequest *postRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                requestMethod:SLRequestMethodGET
                                                          URL:requestURL
                                                   parameters:parameters];
    postRequest.account = self.rettAcc;
    [postRequest performRequestWithHandler:^(NSData *responseData,
                                             NSHTTPURLResponse *urlResponse,
                                             NSError *error) {
        NSArray *retreiveData = [NSJSONSerialization JSONObjectWithData:responseData
                                                          options:NSJSONReadingMutableLeaves
                                                            error:&error];
        if (retreiveData.count != 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *update = retreiveData[0];
                NSDictionary *current = self.dataSource[0];
                NSString *currentTweet = [current objectForKey:@"text"];
                NSString *updatedTweet = [update objectForKey:@"text"];
                if (![currentTweet isEqualToString:updatedTweet]) {
                    [self refreshTweets];
                }
            });
        }
    }];
}

#pragma mark - No Connection Handle

- (void)retrieveFromLocal {
    NSArray *entries = [[JYLRettiwtManagedStore sharedStore] storedTweets];
    NSMutableArray *data = [[NSMutableArray alloc] init];

    // Ommitted to use fast enumeration to recreate dataSource dictionaries
    for (int i = 0; i < [entries count]; i++) {
        JYLRettiwtPost *storedTweet = [entries objectAtIndex:i];
        NSDictionary *user = [[NSDictionary alloc] initWithObjects:@[[storedTweet postAuthor]] 
                                                           forKeys: @[@"screen_name"]];
        NSString *post = [storedTweet post];
        NSMutableDictionary *tweet = [[NSMutableDictionary alloc] init];
        [tweet setObject:post forKey:@"text"];
        [tweet setObject:user forKey:@"user"];
        [data addObject:tweet];
    }

    // Set new datasource
    self.dataSource = data;
}


#pragma mark - UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return [self.dataSource count];
}

/* Set the twitter user and tweet in each of the cards */
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView 
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == ([self.dataSource count] - 1)) {
        NSInteger currentTweetCount = [self.tweetCount integerValue];
        currentTweetCount += 50;
        self.tweetCount = [NSString stringWithFormat:@"%ld", (long)currentTweetCount];
        [self refreshTweets];
    }
    JYLFeedCollectionViewCell *cell =
                                [collectionView dequeueReusableCellWithReuseIdentifier:@"cell"
                                                                          forIndexPath:indexPath];
    NSDictionary *tweet = self.dataSource[[indexPath row]];
    NSDictionary *user = tweet[@"user"];
    NSString *text = tweet[@"text"];
    NSString *handle = @"@";
    NSString *username = user[@"screen_name"];
    NSString *twitterHandle = [handle stringByAppendingString:username];
    [cell setTweetText:text];
    [cell setTweetTitleText:twitterHandle];

    return cell;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
