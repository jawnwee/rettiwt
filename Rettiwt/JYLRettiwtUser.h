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
@property (nonatomic, retain) JYLRettiwtPost *tweets;

@end
