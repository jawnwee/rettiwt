//
//  JYLRettiwtManagedStore.h
//  rettiwt
//
//  Created by John Lee on 8/13/14.
//  Copyright (c) 2014 johnjlee. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ACAccount;

@interface JYLRettiwtManagedStore : NSObject

+ (instancetype)sharedStore;

- (NSArray *)storedTweets;
- (void)addTweet:(NSString *)handle tweet:(NSString *)text forDate:(NSDate *)date;
- (void)setAccount:(ACAccount *)account;
- (void)saveContextWithTweets;


@end
