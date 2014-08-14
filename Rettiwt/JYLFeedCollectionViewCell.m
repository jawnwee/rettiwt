//
//  JYLFeedViewCellCollectionViewCell.m
//  rettiwt
//
//  Created by John Lee on 8/12/14.
//  Copyright (c) 2014 johnjlee. All rights reserved.
//

#import "JYLFeedCollectionViewCell.h"

@interface JYLFeedCollectionViewCell ()

@property (nonatomic, strong) UITextView *title;
@property (nonatomic, strong) UITextView *tweet;

@end

@implementation JYLFeedCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupCellViews];
    }
    return self;
}

- (void)setupCellViews {
    CGRect tweetFrame = CGRectMake(5, 50, 125, self.frame.size.height * 0.6);
    _tweet = [[UITextView alloc] initWithFrame:tweetFrame];
    _tweet.font = [UIFont fontWithName:@"GillSans" size:14];
    _tweet.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.tweet];

    CGRect titleFrame = CGRectMake(5, 0, 125, self.frame.size.height * 0.2);
    _title = [[UITextView alloc] initWithFrame:titleFrame];
    _title.font = [UIFont fontWithName:@"GillSans-Bold" size:14];
    _title.textAlignment = NSTextAlignmentCenter;

    [self.contentView addSubview:self.title];
}

- (void)setTweetTitleText:(NSString *)title {
    self.title.text = title;
}

- (void)setTweetText:(NSString *)tweet {
    self.tweet.text = tweet;
}

@end
