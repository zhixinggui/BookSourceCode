//
//  Model.h
//  topstories
//
//  Created by Nathan Jones on 2/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Post.h"
#import "Tweet.h"

typedef enum {
	PayloadShareTypeJSON = 0,
	PayloadShareTypeXML,
} PayloadShareType;

#define kTopStoriesStartNotification            @"TopStoresOperationStart"
#define kTopStoriesSuccessNotification          @"TopStoresOperationSuccess"
#define kTopStoriesErrorNotification            @"TopStoresOperationError"

#define kPostContentStartNotification           @"PostContentOperationStart"
#define kPostContentSuccessNotification         @"PostContentsOperationSuccess"
#define kPostContentErrorNotification           @"PostContentOperationError"

#define kTweetsStartNotification                @"TweetsOperationStart"
#define kTweetsSuccessNotification              @"TweetsOperationSuccess"
#define kTweetsErrorNotification                @"TweetsOperationError"

#define kShareArticleStartNotification          @"ShareArticleOperationStart"
#define kShareArticleSuccessNotification        @"ShareArticleOperationSuccess"
#define kShareArticleErrorNotification          @"ShareArticleOperationError"

#define kTweetProfileImageSuccessNotification   @"TweetProfileImageOperationSuccess"

@interface Model : NSObject

@property(nonatomic,strong) NSMutableArray  *posts;

+ (Model *)sharedModel;

- (void)enqueueOperation:(NSOperation*)op;

- (void)fetchTopStories;

- (void)fetchContentForPost:(Post*)post;

- (void)fetchTweetsForPost:(Post*)post;

- (void)sharePostsWithType:(PayloadShareType)type;

@end
