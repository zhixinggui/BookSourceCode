//
//  TopStoriesParser.m
//  topstories
//
//  Created by Nathan Jones on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TopStoriesParser.h"
#import "Utils.h"

@interface TopStoriesParser () {
    Post            *post;
    NSMutableString *currentValue;
    BOOL            parsingItem;
}

@end

@implementation TopStoriesParser

@synthesize posts = _posts;
@synthesize feedData = _feedData;
@synthesize delegate = _delegate;

- (id)initWithFeedData:(NSData*)data {
    self = [super init];
    if (self != nil) {
        self.feedData = data;
    }
    return self;
}

- (void)parseTopStoriesFeed {
    // create and start parser
	NSXMLParser *parser = [[NSXMLParser alloc] 
                           initWithData:_feedData];
	parser.delegate = self;
	[parser parse];
}

#pragma mark - NSXMLParserDelegate
- (void)parserDidStartDocument:(NSXMLParser *)parser {
    _posts = [[NSMutableArray alloc] init];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    if ([_delegate respondsToSelector:@selector(topStoriesParsedWithResult:)]) {
        [_delegate topStoriesParsedWithResult:_posts];
    }
}

- (void)parser:(NSXMLParser *)parser 
didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName 
    attributes:(NSDictionary *)attributeDict {
    
    // if you were expecting an attribute, it would be
    // handled here in the attributeDict by using
    // objectForKey: using the attribute name
    
    // started a new post, create a fresh object
	if ([elementName isEqualToString:@"item"]) {
        post = [[Post alloc] init];
        parsingItem = YES;
        
	}
}

- (void)parser:(NSXMLParser *)parser 
foundCharacters:(NSString *)string {
    
    // capture the current element value
    NSString *tmpValue = [string stringByTrimmingCharactersInSet:
                          [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (currentValue == nil) {
		currentValue = [[NSMutableString alloc] initWithString:tmpValue];
	} else {
		[currentValue appendString:tmpValue];
	}
    
}

- (void)parser:(NSXMLParser *)parser 
 didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName {
    
    // reached the end of a post
	if ([elementName isEqualToString:@"item"]) {
        [_posts addObject:post];
        post = nil;
        parsingItem = NO;
    }
    
    // make sure we're parsing a post item and not header data
    if (parsingItem == YES) {
        if ([elementName isEqualToString:@"title"]) {
            post.title = currentValue;
            
        } else if ([elementName isEqualToString:@"description"]) {
            post.postDescription = currentValue;
            
        } else if ([elementName isEqualToString:@"pubDate"]) {
            post.pubDate = [Utils publicationDateFromString:currentValue];
            
        } else if ([elementName isEqualToString:@"feedburner:origLink"]) {
            post.contentURL = currentValue;
        
        }
    }
    
    // reset the current element value
    currentValue = nil;
}

@end