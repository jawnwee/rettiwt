//
//  JYLRettiwtUser.h
//  Rettiwt
//
//  Created by John Lee on 8/14/14.
//  Copyright (c) 2014 johnjlee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class JYLRettiwtPost;

@interface JYLRettiwtUser : NSManagedObject

@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSSet *tweets;
@end

@interface JYLRettiwtUser (CoreDataGeneratedAccessors)

- (void)addTweetsObject:(JYLRettiwtPost *)value;
- (void)removeTweetsObject:(JYLRettiwtPost *)value;
- (void)addTweets:(NSSet *)values;
- (void)removeTweets:(NSSet *)values;

@end
