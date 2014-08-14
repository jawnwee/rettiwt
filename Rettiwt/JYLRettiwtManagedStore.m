//
//  JYLRettiwtManagedStore.m
//  rettiwt
//
//  Created by John Lee on 8/13/14.
//  Copyright (c) 2014 johnjlee. All rights reserved.
//
//
//  Creates a store to retrieve tweets when there is no internet connection
//  otherwise, this store manages the core data logic
//  we check if the number of tweets in our db exceeds the set number of tweets to keep
//  then remove the one in the last tweet from core data/mutable array
//  then add the new tweet
//

#import "JYLRettiwtManagedStore.h"
#import "JYLRettiwtPost.h"
#import "JYLConstants.h"


@import CoreData;
@interface JYLRettiwtManagedStore ()

@property (nonatomic, strong) NSMutableArray *privateTweets;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSManagedObjectModel *model;

@end

@implementation JYLRettiwtManagedStore

+ (instancetype)sharedStore {
    static JYLRettiwtManagedStore *sharedStore = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStore = [[self alloc] initPrivate];
    });

    return sharedStore;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"Singleon" 
                                   reason:@"use shared instance" 
                                 userInfo:nil];
    return nil;
}

- (instancetype)initPrivate {
    self = [super init];
    if (self) {
        _model = [NSManagedObjectModel mergedModelFromBundles:nil];
        NSPersistentStoreCoordinator *coordinator =
                           [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_model];
        NSString *path = [self archivePath];
        NSURL *storeURL = [NSURL fileURLWithPath:path];
        NSError *error = nil;
        if (![coordinator addPersistentStoreWithType:NSSQLiteStoreType 
                                       configuration:nil 
                                                 URL:storeURL 
                                             options:nil 
                                               error:&error]) {
            @throw [NSException exceptionWithName:@"failed" reason:[error description] userInfo:nil];
        }
        _context = [[NSManagedObjectContext alloc] init];
        _context.persistentStoreCoordinator = coordinator;

        [self loadData];
    }
    return self;
}

- (NSString *)archivePath {
    NSArray *documents =
                    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [documents firstObject];

    return [directory stringByAppendingPathComponent:@"store.data"];
}

/* Fetch in core data for an existing tweet. if it does not exist. Add it, check if we reached
 max capacity. If so, remove the last existing object in our private entries and delete from
 core data as well
 */
- (void)addTweet:(NSString *)handle tweet:(NSString *)text forDate:(NSDate *)date {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity =
    [NSEntityDescription entityForName:@"JYLRettiwtPost"
                inManagedObjectContext:self.context];
    [request setEntity:entity];

    NSPredicate *predicate =
    [NSPredicate predicateWithFormat:@"post == %@", text];
    [request setPredicate:predicate];

    NSError *error;
    NSArray *array = [self.context executeFetchRequest:request error:&error];
    NSUInteger count = 0;
    if (array != nil) {
        count = [array count];
    }
    // This could be 0 if the object was previously deleted so we only add if this count is 0
    if (array == nil || count == 0) {
        if ([self.privateTweets count] == MAX_TWEETS) {
            [self removeTweet];
        }
        JYLRettiwtPost *rett = [NSEntityDescription insertNewObjectForEntityForName:@"JYLRettiwtPost"
                                                             inManagedObjectContext:self.context];
        rett.date = date;;
        rett.postAuthor = handle;
        rett.post = text;

        [self.privateTweets insertObject:rett atIndex:0];
        NSError *error = nil;
        [self.context save:&error];
    }
}

- (void)removeTweet {
    JYLRettiwtPost *lastObject = [self.privateTweets objectAtIndex:([self.privateTweets count] - 1)];
    [self.context deleteObject:lastObject];
    [self.privateTweets removeObject:lastObject];
}

- (void)loadData {
    if (!self.privateTweets) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"JYLRettiwtPost"
                                             inManagedObjectContext:self.context];
        request.entity = entity;
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"date" 
                                                               ascending:NO];
        request.sortDescriptors = @[sort];

        NSError *error;
        NSArray *results = [self.context executeFetchRequest:request error:&error];

        if (!results) {
            [NSException raise:@"fetch fail" format:@"somethings wrong"];
        }

        self.privateTweets = [[NSMutableArray alloc] initWithArray:results];
    }
}

- (NSArray *)storedTweets {
    return self.privateTweets;
}

@end
