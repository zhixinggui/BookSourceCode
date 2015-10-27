//
//  Model.m
//  topstories
//
//  Created by Nathan Jones on 2/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Model.h"

#import "FetchTopStoriesOperation.h"
#import "FetchPostContentOperation.h"
#import "FetchPostTweetsOperation.h"
#import "ShareArticlesOperationJSON.h"
#import "ShareArticlesOperationXML.h"

@interface Model() {
@private
    NSOperationQueue    *queue;
}
@end

@implementation Model

@synthesize posts = _posts;

static Model *_instance = nil;

- (id)init {
    self = [super init];
    return self;
}

+ (Model *)sharedModel {
    if (_instance == nil) {
        _instance = [[self alloc] init];
    }
    
    return _instance;
}

#pragma mark - Queue Management
- (void)enqueueOperation:(NSOperation*)op {
    if (queue == nil) {
        queue = [[NSOperationQueue alloc] init];
        [queue setMaxConcurrentOperationCount:5];
    }
    
    [queue addOperation:op];
}

#pragma mark - Post Management
- (void)fetchTopStories {
    FetchTopStoriesOperation *op = [[FetchTopStoriesOperation alloc] init];
    op.queuePriority = NSOperationQueuePriorityVeryHigh;
    [op enqueueOperation];
}

- (void)fetchContentForPost:(Post*)post {
    FetchPostContentOperation *op = [[FetchPostContentOperation alloc] init];
    op.post = post;
    op.queuePriority = NSOperationQueuePriorityVeryHigh;
    [op enqueueOperation];
}

- (void)fetchTweetsForPost:(Post*)post {
    FetchPostTweetsOperation *op = [[FetchPostTweetsOperation alloc] init];
    op.post = post;
    [op enqueueOperation];
}

- (void)sharePostsWithType:(PayloadShareType)type {
    
    if (type == PayloadShareTypeJSON) {
        ShareArticlesOperationJSON *op = [[ShareArticlesOperationJSON alloc] init];
        op.posts = _posts;
        op.shareType = type;
        [op enqueueOperation]; 
    } else {
        ShareArticlesOperationXML *op = [[ShareArticlesOperationXML alloc] init];
        op.posts = _posts;
        op.shareType = type;
        [op enqueueOperation];
    }
    
}

@end