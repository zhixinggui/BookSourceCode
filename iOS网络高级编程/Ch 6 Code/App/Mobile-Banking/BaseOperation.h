//
//  BaseOperation.h
//  Mobile Banking
//
//  Created by Nathan Jones on 2/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonHMAC.h>
#import "Constants.h"
#import "Model.h"
#import "Utils.h"
#import "NSData+Encryption.h"
#import "NSString+Encryption.h"
#import "NSString+Hashing.h"
#import "NSData+Base64.h"

// FIXME: Point Base URL to your web server
#define kResourceBaseURL @"http://yourbankingdomain.com/book/mobilebanking"

@interface BaseOperation : NSOperation <NSCopying>

@property(nonatomic,assign) NSInteger       statusCode;
@property(nonatomic,strong) NSMutableData   *responseData;

- (void)enqueueOperation;
- (void)postNotification:(NSString*)notificationName 
          withStatusCode:(NSString*)statusCode 
            andResultSet:(id)resultSet;
- (BOOL)requestWasSuccessful:(NSHTTPURLResponse*)response 
                       error:(NSError*)error;
- (NSMutableURLRequest*)buildRequestWithURL:(NSString*)url 
                                 httpMethod:(NSString*)method 
                                    payload:(NSMutableDictionary*)payload 
                                    timeout:(NSTimeInterval)timeout 
                              signingOption:(NJRequestSigningOption)signingOption;

+ (BOOL)operationInProcess; // override in each subclass!
+ (NSURLProtectionSpace*)certificateAuthenticationProtectionSpace;

@end
