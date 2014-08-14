//
//  JYLFeedLayout.m
//  rettiwt
//
//  Created by John Lee on 8/12/14.
//  Copyright (c) 2014 johnjlee. All rights reserved.
//

#import "JYLFeedLayout.h"

@interface JYLFeedLayout ()

@property (nonatomic) CGSize feedSize;

@end

@implementation JYLFeedLayout

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupFeedLayout];
    }
    return self;
}

- (void)setupFeedLayout {
    self.minimumLineSpacing = 1.0;
    [self setScrollDirection:UICollectionViewScrollDirectionHorizontal];
}

- (CGSize)collectionViewContentSize {
    NSInteger itemCount = [self.collectionView numberOfItemsInSection:0];

    NSInteger pages = ceil(itemCount * (self.feedSize.width + self.minimumLineSpacing));
    return CGSizeMake(pages, self.feedSize.height);
}

- (void)setFeedSize:(CGSize)size {
    _feedSize = size;
}

@end
