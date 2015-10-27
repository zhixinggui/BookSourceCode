//
//  FetchTopStoriesOperation.m
//  topstories
//
//  Created by Nathan Jones on 5/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FetchTopStoriesOperation.h"
#import "FetchPostContentOperation.h"
#import "TopStoriesParser.h"

#define kURL @"http://rss.cnn.com/rss/cnn_topstories.rss"
//#define kURL @"file:/<path to folder>/cnn_topstories.rss"

@implementation FetchTopStoriesOperation

- (void)main {
    
    [self postNotification:kTopStoriesStartNotification];
    [self startNetworkActivityIndicator];
    
    // create the and issue request
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] 
                                initWithURL:[NSURL URLWithString:kURL]
                                cachePolicy:NSURLCacheStorageAllowed
                                timeoutInterval:30.0];
    
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:req
                                         returningResponse:&response
                                                     error:&error];
    
    // check response got data and process data accordingly
    if (data != nil) {
        TopStoriesParser *parser = [[TopStoriesParser alloc] 
                                    initWithFeedData:data];
        parser.delegate = self;
        [parser parseTopStoriesFeed];
        
    // there was an error getting the feed, alert the presses
    } else {
        [self postNotification:kTopStoriesErrorNotification];
    }
    
    [self stopNetworkActivityIndicator];
}

#pragma mark - TopStoriesDelegate
- (void)topStoriesParsedWithResult:(NSMutableArray *)posts {
    // add the parsed results to the model
    [Model sharedModel].posts = posts;
    
    // trigger the content fetch (low priority)
    // handled here vs Model.m to adjust priority
    for (Post *post in posts){
        FetchPostContentOperation *op = [[FetchPostContentOperation alloc] 
                                         init];
        op.post = post;
        op.queuePriority = NSOperationQueuePriorityLow;
        [op enqueueOperation];
    }
    
    [self postNotification:kTopStoriesSuccessNotification];
}

@end