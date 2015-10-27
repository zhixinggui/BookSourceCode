//
//  BaseOperation.m
//  Mobile Banking
//
//  Created by Nathan Jones on 2/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BaseOperation.h"
#import "Model.h"

@implementation BaseOperation

@synthesize statusCode = _statusCode;
@synthesize responseData = _responseData;

- (id)init {
    self = [super init];
    return self;
}

- (void)enqueueOperation {
    [[Model sharedModel] enqueueOperation:self];
}
- (void)postNotification:(NSString*)notificationName 
          withStatusCode:(NSString*)statusCode 
            andResultSet:(id)resultSet {
    
    // handle nil's...nsdict sure won't play nice
    statusCode = (statusCode != nil) ? statusCode : @"";
    resultSet = (resultSet != nil) ? resultSet : @"";
    
    // build response
    NSDictionary *response = [NSDictionary dictionaryWithObjectsAndKeys:
                              statusCode, kNJStatusCode,
                              resultSet, kNJResultSet, nil];
    
    // post the notification to the main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName
                                                            object:nil
                                                          userInfo:response];
    });
}

- (BOOL)requestWasSuccessful:(NSHTTPURLResponse*)response 
                       error:(NSError*)error {
    
    NSInteger statusCode = response.statusCode;
    
    // handle the one off case for http code 401
    if (error != nil && error.code == NSURLErrorUserCancelledAuthentication) {
        statusCode = 401;
        // if we receive a 401 then our token is no longer valid.  we 
        // would use this opportunity to remove them from the keychain.
        // we'll just kill the token in our model for now
        [[Model sharedModel] signOut];
    }
    
    switch (statusCode) {
        case 200:
        case 201: 
        case 202: 
        case 204:
            // successful response
            return YES;
            break;
        
        case 500:
        case 501:
        case 502:
        case 503:
        case 504:
        case 505:
            // inform user via simple alert view
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"Service Down"
                                            message:@"Acme Bank's mobile service is down for maintenance."
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil] show];
            });
            return NO;
            
        default:
            // check if the connect timed out and alert accordingly
            if (error != nil && error.code == NSURLErrorTimedOut) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[[UIAlertView alloc] initWithTitle:@"Service Down"
                                                message:@"Your request timed out. Please try again later."
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil] show];
                });
            }
            return NO;
            break;
    }
    
    
    // inform user via simple alert view that an unexpected case occurred
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[UIAlertView alloc] initWithTitle:@"Unexpected Error"
                                    message:@"Acme Bank's services are down."
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    });
    return NO;

}

- (NSMutableURLRequest*)buildRequestWithURL:(NSString*)url 
                                 httpMethod:(NSString*)method 
                                    payload:(NSMutableDictionary*)payload 
                                    timeout:(NSTimeInterval)timeout 
                              signingOption:(NJRequestSigningOption)signingOption {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:timeout];
    
    switch (signingOption) {
        case NJRequestSigningOptionQuerystring:
            // here we would check for a ? and add one if needed prior to adding our token
            break;
        
        case NJRequestSigningOptionPayload:
            [payload setObject:[Model sharedModel].token forKey:@"auth-token"];
            break;
        
        case NJRequestSigningOptionHeader:
            // add token to the request header here
            [request setValue:[Model sharedModel].token forHTTPHeaderField:@"auth-token"];
            break;
            
        // pass through
        case NJRequestSigningOptionNone:    
        default:
            break;
    }
    
    // handle the various request configuration settings
    [request setHTTPMethod:method];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    // add the request payload if present
    if (payload != nil) {
        NSError *error = nil;
        // create the json representation using ios5 API
        NSData *requestBody = [NSJSONSerialization dataWithJSONObject:payload
                                                              options:0 error:&error];
        [request setHTTPBody:requestBody];
    }
    
    return request;
    
}

+ (BOOL)operationInProcess {return NO;}

+ (NSURLProtectionSpace*)certificateAuthenticationProtectionSpace {
    NSURLProtectionSpace *space = [[NSURLProtectionSpace alloc] initWithHost:@"67.205.6.121"
                                                                        port:443
                                                                    protocol:NSURLProtectionSpaceHTTPS
                                                                       realm:@"mobilebanking"
                                                        authenticationMethod:NSURLAuthenticationMethodClientCertificate];
    return space;
}

#pragma mark - Copying
- (id)copyWithZone:(NSZone*)zone {
    BaseOperation *copy = [[[self class] allocWithZone:zone] init];
    return copy;
}

@end