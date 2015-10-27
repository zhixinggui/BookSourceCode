//
//  Tweet.m
//  topstories
//
//  Created by Nathan Jones on 5/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Tweet.h"
#import "FetchTweetProfileImageOperation.h"

@implementation Tweet

@synthesize identifier, fromUser, fromUserDisplay, profileImageURL, text, createdDate, profileImage;

- (id)initWithDictionary:(NSDictionary*)tweetData {
    self = [super init];
    
    if (self != nil) {
        self.identifier = [tweetData objectForKey:@"id_str"];
        self.fromUser = [tweetData objectForKey:@"from_user"];
        self.fromUserDisplay = [tweetData objectForKey:@"from_user_name"];
        self.profileImageURL = [tweetData objectForKey:@"profile_image_url"];
        self.text = [tweetData objectForKey:@"text"];
        self.createdDate = [Utils tweetDateFromString:[tweetData objectForKey:@"created_at"]];
    }
    
    // fire operation to get profile image
    FetchTweetProfileImageOperation *op = [[FetchTweetProfileImageOperation alloc] init];
    op.tweet = self;
    op.queuePriority = NSOperationQueuePriorityVeryHigh;
    [op enqueueOperation];
    
    return self;
}

@end