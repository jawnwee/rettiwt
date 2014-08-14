//
//  JYLMainRettiwtViewController.h
//  rettiwt
//
//  Created by John Lee on 8/12/14.
//  Copyright (c) 2014 johnjlee. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ACAccount;
@class JYLFeedCollectionViewController;
@class JYLProfileViewController;

@interface JYLMainRettiwtViewController : UIViewController

- (instancetype)initWithAccount:(ACAccount *)account 
                      profileVC:(JYLProfileViewController *)profile 
                         feedVC:(JYLFeedCollectionViewController *)feed;

@end
