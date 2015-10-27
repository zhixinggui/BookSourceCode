//
//  FetchPostTweetsOperation.m
//  topstories
//
//  Created by Nathan Jones on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FetchPostTweetsOperation.h"

#define kTimeout 30.0

@implementation FetchPostTweetsOperation

@synthesize post = _post;

- (void)main {
    
    [self postNotification:kTweetsStartNotification];
    [self startNetworkActivityIndicator];
    _post.tweetsLoading = YES;
    
    // create the twitter query
    NSMutableString *query = [[NSMutableString alloc] init];
    for (int i=0; i<[_post.keywords count]; i++) {
        // prepend comma for all but first keyword
        if (i != 0) {
            [query appendString:@","];
        }
        
        [query appendString:[_post.keywords objectAtIndex:i]];
    }
    
    // create the and issue request - separate variables for line size
    NSString *searchEndpoint = @"http://search.twitter.com/search.json";
    NSString *querystring = [NSString 
                             stringWithFormat:@"q=%@&rpp=15",
                             [Utils urlEncode:query]];
    
    NSString *url = [NSString stringWithFormat:@"%@?%@",
                     searchEndpoint,
                     querystring];
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] 
                                initWithURL:[NSURL URLWithString:url]
                                cachePolicy:NSURLCacheStorageAllowed
                                timeoutInterval:kTimeout];
    
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:req
                                         returningResponse:&response
                                                     error:&error];
    
    // check response got data and process data accordingly
    if (data != nil) {
        
        // convert response to JSON
        NSError *error = nil;
        NSDictionary *searchResults = [NSJSONSerialization 
                                       JSONObjectWithData:data 
                                       options:NSJSONReadingAllowFragments 
                                       error:&error];
        
        // create tweets
        NSMutableArray *tweets = [[NSMutableArray alloc] init];
        NSArray *results = [searchResults objectForKey:@"results"];
        for (NSDictionary *tweetData in results) {
            Tweet *tweet = [[Tweet alloc] initWithDictionary:tweetData];
            [tweets addObject:tweet];
        }
        
        _post.tweetsLoading = NO;
        if ([tweets count] > 0) {
            _post.tweets = tweets; 
            [self postNotification:kTweetsSuccessNotification];
        
        // no tweets were retreived
        } else {
            [self postNotification:kTweetsErrorNotification];
        }
        
    // there was an error getting the post content, alert the presses
    } else {
        _post.tweetsLoading = NO;
        [self postNotification:kTweetsErrorNotification];
        
    }
    
    
    [self stopNetworkActivityIndicator];
}

@end