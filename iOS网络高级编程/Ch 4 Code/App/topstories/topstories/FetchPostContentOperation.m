//
//  FetchPostContentOperation.m
//  topstories
//
//  Created by Nathan Jones on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FetchPostContentOperation.h"
#import "HTMLParser.h"

#define kURLPrefix @"file:<Path to un-archived news articles>"

@interface FetchPostContentOperation ()

- (void)processContentData:(NSData*)content;

@end

@implementation FetchPostContentOperation

@synthesize post = _post;

- (void)main {
    
    [self postNotification:kPostContentStartNotification];
    [self startNetworkActivityIndicator];
    
    NSURL *url = [NSURL URLWithString:_post.contentURL];
    //NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kURLPrefix, _post.contentURL]];
    
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] 
                                initWithURL:url
                                cachePolicy:NSURLCacheStorageAllowed
                                timeoutInterval:30.0];
    
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:req
                                         returningResponse:&response
                                                     error:&error];
    
    // check response got data and process data accordingly
    if (data != nil) {
        [self processContentData:data];
        _post.contentFetched = YES;
        
        [self postNotification:kPostContentSuccessNotification];
        
    // there was an error getting the post content, alert the presses
    } else {
        [self postNotification:kPostContentErrorNotification];
        
    }
    
    [self stopNetworkActivityIndicator];
}

#pragma mark - Private Methods
- (void)processContentData:(NSData*)content {
    
    NSError *error = nil;
    HTMLParser *parser = [[HTMLParser alloc] initWithData:content error:&error];
    if (error) {
        return;
    }
    
    // get html doc head and meta tags
    HTMLNode *head = [parser head];
    NSArray *metaTags = [head findChildTags:@"meta"];
    
    // retrieve article meta data and add to the post
    for (HTMLNode *meta in metaTags) {
        NSString *name = [meta getAttributeNamed:@"name"];
        
        // keywords
        if ([name isEqualToString:@"keywords"]) {
            NSString *keywordContent = [meta getAttributeNamed:@"content"];
            NSMutableArray *keywords = (NSMutableArray*)[keywordContent componentsSeparatedByString:@","];
            if ([keywords count]>0) {
                _post.keywords = keywords;
            }
            
        // author name
        } else if ([name isEqualToString:@"author"]) {
            NSString *author = [meta getAttributeNamed:@"content"];
            if (author.length > 0) {
                _post.author = author;
            }
            
        // article section
        } else if ([name isEqualToString:@"section"]) {
            NSString *section = [meta getAttributeNamed:@"content"];
            if (section.length > 0) {
                _post.section = section;
            }
        }
    }
    
    // get html doc body and paragraph tags
    HTMLNode *body = [parser body];
    NSArray *paragraphTags = [body findChildTags:@"p"];
    
    // iterate through all paragraphs saving the appropriate story content
    NSMutableString *storyContent = [[NSMutableString alloc] init];
    for (HTMLNode *para in paragraphTags) {
        
        // only save the 'story paragraphs' - class=cnn_storypgraphtxt
        NSString *class = [para getAttributeNamed:@"class"];
        NSRange storyParaTest = [[class lowercaseString] rangeOfString:@"cnn_storypgraphtxt"];
        if ((storyParaTest.location != NSNotFound) && (class != nil)) {
            [storyContent appendString:[para rawContents]];
        }
    }
    
    _post.content = storyContent;
}

@end