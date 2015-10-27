//
//  ShareArticlesOperationXML.m
//  topstories
//
//  Created by Nathan Jones on 6/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ShareArticlesOperationXML.h"

@implementation ShareArticlesOperationXML

@synthesize posts, shareType;

- (void)main {
    
    [self startNetworkActivityIndicator];
    
    // create the and issue request
    NSString *urlString = 
    [NSString 
     stringWithFormat:@"<server>/parse.php?parseMethod=%d",shareType];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *req = 
    [[NSMutableURLRequest alloc] initWithURL:url                           
                                 cachePolicy:NSURLCacheStorageAllowed                   
                             timeoutInterval:30.0];
    
    [req setHTTPMethod:@"POST"];
    [req setValue:@"application/xml" forHTTPHeaderField:@"Accept"];
    
    // convert array of POST objects to array of dictionary
    // objects so the XML writer can handle it
    NSMutableArray *articles = [[NSMutableArray alloc] init];
    for (Post *post in posts) {
        [articles addObject:post.dictionaryRepresentation];
    }
    NSDictionary *articleData = 
    [NSDictionary dictionaryWithObject:articles forKey:@"articles"];
    
    // convert dictionary to XML data and set body
    NSData *payload = [Utils postXMLDataFromDictionary:articleData];
    [req setHTTPBody:payload];
    
    // issue network request
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:req
                                         returningResponse:&response
                                                     error:&error];
    
    // check response got data and process data accordingly
    // you would also typically check the status code here too
    if (data != nil) {
        NSError *jsonParseError = nil;
        NSDictionary *responseDict = 
        [NSJSONSerialization JSONObjectWithData:data                                   
                                        options:0 
                                          error:&jsonParseError];
        
        // successfully transmitted articles
        if ([responseDict objectForKey:@"articleCount"] != nil) {
            [self postNotification:kShareArticleStartNotification];
            
            // tell the user how many articles were sent
            NSInteger articleCount = 
                [[responseDict objectForKey:@"articleCount"] intValue];
            NSString *msg = 
                [NSString stringWithFormat:@"%d articles shared via XML.",
                 articleCount];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"Great Success" 
                                            message:msg 
                                           delegate:nil 
                                  cancelButtonTitle:@"OK" 
                                  otherButtonTitles:nil] show];
            });
            
        // server was not able to properly interpret the content
        } else {
            [self postNotification:kShareArticleErrorNotification];
        }
        
    }
    
    [self stopNetworkActivityIndicator];
}

@end