//
//  JYLFeedCollectionViewController.h
//  rettiwt
//
//  Created by John Lee on 8/12/14.
//  Copyright (c) 2014 johnjlee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JYLFeedCollectionViewController : UIViewController <UICollectionViewDataSource,
                                                               UICollectionViewDelegate,
                                                               UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;

- (instancetype)initWithAccount:(ACAccount *)account;


@end
