//
//  JYLRettiwtPost.h
//  rettiwt
//
//  Created by John Lee on 8/13/14.
//  Copyright (c) 2014 johnjlee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface JYLRettiwtPost : NSManagedObject

@property (nonatomic, retain) NSString *post;
@property (nonatomic, retain) NSString *postAuthor;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSManagedObject *user;

@end
