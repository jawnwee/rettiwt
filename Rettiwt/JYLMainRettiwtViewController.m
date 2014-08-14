//
//  JYLMainRettiwtViewController.m
//  rettiwt
//
//  Created by John Lee on 8/12/14.
//  Copyright (c) 2014 johnjlee. All rights reserved.
//

#import <Accounts/Accounts.h>
#import "JYLMainRettiwtViewController.h"
#import "JYLFeedCollectionViewController.h"
#import "JYLProfileViewController.h"

@interface JYLMainRettiwtViewController ()

@property (nonatomic, strong) ACAccount *rettAccount;
@property (nonatomic, strong) JYLFeedCollectionViewController *feed;
@property (nonatomic, strong) JYLProfileViewController *profile;

@end

@implementation JYLMainRettiwtViewController

#pragma mark - Initialization
- (instancetype)initWithAccount:(ACAccount *)account 
                      profileVC:(JYLProfileViewController *)profile 
                         feedVC:(JYLFeedCollectionViewController *)feed {
    self = [super init];
    if (self) {
        _rettAccount = account;
        _feed = feed;
        _profile = profile;
        self.view.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

#pragma mark - View Setup
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setupProfile];
    [self setupFeed];
    [self setupFooter];
}

- (void)setupProfile {
    CGRect headerFrame = self.view.frame;
    headerFrame.size.height *= 0.5;
    self.profile.view.frame = headerFrame;
    [self.view addSubview:self.profile.view];
}

- (void)setupFeed {
    CGRect adjustOrigin = self.feed.view.frame;
    adjustOrigin.origin.y = self.view.frame.size.height * 0.5;
    self.feed.view.frame = adjustOrigin;
    [self.view addSubview:self.feed.view];
}

- (void)setupFooter {
    CGRect headerFrame = self.view.frame;
    headerFrame.origin.y = headerFrame.size.height * 0.9;
    headerFrame.size.height *= 0.1;
    UIView *header = [[UIView alloc] initWithFrame:headerFrame];
    NSString *username = self.rettAccount.username;
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,
                                                                   self.view.frame.size.width,
                                                                   headerFrame.size.height)];
    nameLabel.text = username;
    nameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    header.backgroundColor = [UIColor lightGrayColor];

    [header addSubview:nameLabel];
    [self.view addSubview:header];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
