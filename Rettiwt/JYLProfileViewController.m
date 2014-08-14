//
//  JYLProfileViewController.m
//  rettiwt
//
//  Created by John Lee on 8/13/14.
//  Copyright (c) 2014 johnjlee. All rights reserved.
//

#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "JYLProfileViewController.h"

@interface JYLProfileViewController ()

@property (nonatomic, strong) ACAccount *mainAcc;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) UIImageView *bannerImageView;
@property (nonatomic, strong) UIImageView *profileImageView;
@property (nonatomic, strong) UILabel *usernameLabel;

@end

@implementation JYLProfileViewController

- (instancetype)initWithAccount:(ACAccount *)acc {
    self = [super init];
    if (self) {
        self.view.backgroundColor = [UIColor whiteColor];
        _mainAcc = acc;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubviews];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([self connected]) {
        NSURL *requestURL =
        [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/user_timeline.json"];
        NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
        [parameters setObject:@"1" forKey:@"count"];
        [parameters setObject:@"1" forKey:@"include_entities"];

        SLRequest *postRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                    requestMethod:SLRequestMethodGET
                                                              URL:requestURL
                                                       parameters:parameters];
        postRequest.account = self.mainAcc;

        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeAnnularDeterminate;
        hud.labelText = @"Logging In";
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            [postRequest performRequestWithHandler:^(NSData *responseData,
                                                     NSHTTPURLResponse *urlResponse,
                                                     NSError *error) {
                self.dataSource = [NSJSONSerialization JSONObjectWithData:responseData
                                                                  options:NSJSONReadingMutableLeaves
                                                                    error:&error];
                if (self.dataSource.count != 0) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        [self setupProfile];
                    });
                }
            }];
        });
    }
}

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

- (void)setupSubviews {
    CGRect adjustFrame = self.view.frame;
    adjustFrame.size.height *= 0.5;
    self.view.frame = adjustFrame;
    _profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    _profileImageView.center = self.view.center;
    _bannerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,
                                                                     self.view.frame.size.width,
                                                                     self.view.frame.size.height)];
    [_profileImageView.layer setBorderWidth:4.0f];
    [_profileImageView.layer setBorderColor:[[UIColor whiteColor] CGColor]];

    [_profileImageView.layer setShadowRadius:3.0];
    [_profileImageView.layer setShadowOpacity:0.5];
    [_profileImageView.layer setShadowOffset:CGSizeMake(1.0, 0.0)];
    [_profileImageView.layer setShadowColor:[[UIColor blackColor] CGColor]];

    CGRect buttonFrame = CGRectMake(0, 0, 80, 30);
    buttonFrame.origin.x = self.view.frame.size.width - buttonFrame.size.width - 20;
    buttonFrame.origin.y = self.view.frame.size.height - buttonFrame.size.height - 20;
    UIButton *tweet = [UIButton buttonWithType:UIButtonTypeSystem];
    tweet.frame = buttonFrame;
    tweet.backgroundColor = [UIColor whiteColor];
    [tweet addTarget:self action:@selector(tweet) forControlEvents:UIControlEventTouchUpInside];
    [tweet setTitle:@"Tweet" forState:UIControlStateNormal];

    [self.view addSubview:_bannerImageView];
    [self.view addSubview:_profileImageView];
    [self.view addSubview:tweet];
}

- (void)setupProfile {
    NSDictionary *tweet = self.dataSource[0];
    NSDictionary *user = [tweet objectForKey:@"user"];
    NSString *imageURL = [user objectForKey:@"profile_image_url_https"];
    NSURL *url = [NSURL URLWithString:imageURL];
    NSData *data = [NSData dataWithContentsOfURL:url];
    _profileImageView.image = [UIImage imageWithData:data];

    NSString *imageBannerURL = [user objectForKey:@"profile_banner_url"];
    NSURL *urlBanner = [NSURL URLWithString:imageBannerURL];
    NSData *dataBanner = [NSData dataWithContentsOfURL:urlBanner];
    _bannerImageView.image = [UIImage imageWithData:dataBanner];
}

- (void)tweet {
    if ([self connected]) {
        SLComposeViewController *tweet =
                 [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [self.view.window.rootViewController presentViewController:tweet 
                                                          animated:YES 
                                                        completion:nil];
    } else {
        // no internet
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
