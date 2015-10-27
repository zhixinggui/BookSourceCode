//
//  FetchTweetProfileImageOperation.m
//  topstories
//
//  Created by Nathan Jones on 5/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FetchTweetProfileImageOperation.h"

@implementation FetchTweetProfileImageOperation

@synthesize tweet = _tweet;

- (void)main {
    
    [self startNetworkActivityIndicator];
    
    // create the and issue request
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:_tweet.profileImageURL]
                                                            cachePolicy:NSURLCacheStorageAllowed
                                                        timeoutInterval:30.0];
    
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:req
                                         returningResponse:&response
                                                     error:&error];
    
    // check response got data and process data accordingly
    if (data != nil) {
        UIImage *profileImage = [UIImage imageWithData:data];
        _tweet.profileImage = profileImage;
        
        [self postNotification:kTweetProfileImageSuccessNotification];
    }
    
    [self stopNetworkActivityIndicator];
}

@end