//
//  Utils.h
//  topstories
//
//  Created by Nathan Jones on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject

+ (NSString*)urlEncode:(NSString*)rawString;

+ (NSString*)prettyStringFromDate:(NSDate*)date;

+ (NSDate*)publicationDateFromString:(NSString*)pubDate;

+ (NSDate*)tweetDateFromString:(NSString*)tweetDate;

+ (NSData*)postXMLDataFromDictionary:(NSDictionary*)dictionary;
@end