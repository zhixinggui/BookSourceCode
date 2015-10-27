//
//  TopStoriesParser.h
//  topstories
//
//  Created by Nathan Jones on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Post.h"

@protocol TopStoriesDelegate <NSObject>
@required
-(void)topStoriesParsedWithResult:(NSMutableArray*)posts;
@end

@interface TopStoriesParser : NSObject <NSXMLParserDelegate>

@property(nonatomic,strong) NSData                  *feedData;
@property(nonatomic,strong) NSMutableArray          *posts;

@property(assign)           id<TopStoriesDelegate>  delegate;

- (id)initWithFeedData:(NSData*)data;
- (void)parseTopStoriesFeed;

@end