//
//  Post.h
//  topstories
//
//  Created by Nathan Jones on 5/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Post : NSObject

@property(nonatomic,strong) NSString        *title;             //rss
@property(nonatomic,strong) NSString        *postDescription;   //rss
@property(nonatomic,strong) NSString        *content;           //html
@property(nonatomic,strong) NSString        *author;            //html
@property(nonatomic,strong) NSString        *section;           //html
@property(nonatomic,strong) NSString        *contentURL;        //rss
@property(nonatomic,strong) NSDate          *pubDate;           //rss
@property(nonatomic,strong) NSMutableArray  *keywords;          //html

@property(nonatomic,strong) NSMutableArray  *tweets;
@property(nonatomic,assign) BOOL            contentFetched;
@property(nonatomic,assign) BOOL            tweetsLoading;

- (NSDictionary*)dictionaryRepresentation;

@end