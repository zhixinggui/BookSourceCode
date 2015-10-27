//
//  GetAccountsOperation.m
//  Mobile-Banking
//
//  Created by Nathan Jones on 3/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GetAccountsOperation.h"
#import "Account.h"

#define kEndpoint @"/user/accounts"
#define kHTTPMethod @"GET"
#define kOperationTimeout 30.0

@interface GetAccountsOperation() {
@private
    BOOL isExecuting;
    BOOL isFinished;
    NSURLConnection *connection;
}
@end

@implementation GetAccountsOperation

static BOOL _operationInProcess = NO;

#pragma mark - Operation Lifecycle

- (id)init {
    self = [super init];
    
    isExecuting = NO;
    isFinished = NO;
    
    return self;
}

// used to allow for asynchronous request
- (BOOL)isConcurrent {
    return YES;
}

- (void)start {
    
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(start) 
                               withObject:nil 
                            waitUntilDone:NO];
        return;
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    isExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];
        
    // build our request and issue it
    NSString *url;
    url = [kResourceBaseURL stringByAppendingString:kEndpoint];
    
    NSMutableURLRequest *request = [self buildRequestWithURL:url
                                                  httpMethod:kHTTPMethod
                                                     payload:nil
                                                     timeout:kOperationTimeout
                                               signingOption:NJRequestSigningOptionHeader];
    
    connection = [[NSURLConnection alloc] initWithRequest:request
                                                 delegate:self];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

}

- (void)finish  {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    connection = nil;
    
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    
    isExecuting = NO;
    isFinished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

+ (BOOL)operationInProcess {
    return _operationInProcess;
}

#pragma mark - Copy
- (id)copyWithZone:(NSZone *)zone {
    GetAccountsOperation *copy = [super copyWithZone:zone];
    return copy;
}

#pragma mark - NSURLConnection Delegates
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.responseData = [[NSMutableData alloc] init];
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSLog(@"Accounts Response: %d",httpResponse.statusCode);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    // unpack service response
    NSError *error = nil;
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:self.responseData 
                                                             options:0 
                                                               error:&error];
    
    // decrypt the payload
    NSString *inboundMAC = [response objectForKey:@"mac"];
    NSData *ivData = [[response objectForKey:@"iv"] dataUsingEncoding:NSUTF8StringEncoding];
    NSString *encryptedResponse = [response objectForKey:@"payload"];
    NSString *decryptedResponse = [encryptedResponse decryptedWithAESUsingKey:kAESEncryptionKey
                                                                        andIV:ivData];
    
    if (decryptedResponse != nil) {
        // create our JSON array of account info
        NSError *accountError = nil;
        NSArray *accounts = [NSJSONSerialization JSONObjectWithData:[decryptedResponse dataUsingEncoding:NSUTF8StringEncoding]
                                                            options:0 
                                                              error:&accountError];
        
        // validate the MAC
        NSString *generatedMAC = [decryptedResponse hmacWithKey:kMACKey];
        if ([inboundMAC isEqualToString:generatedMAC]) {
            
            // validation passed, create accounts
            for (NSDictionary *accountData in accounts) {
                Account *account = [[Account alloc] initWithData:accountData];
                [[Model sharedModel].accounts addObject:account];
            }
            
            // post notification
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kAccountOperationSuccessful object:nil];
            });
            
        } else {
            // dispatch alert view message to the main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"Unsecure Connection"
                                            message:@"We're unable to verify account data validity. Please check your network connection and try again."
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
            });
            
            // post notification
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kAccountOperationError object:nil];
            });
            
        }
    } else {
        // dispatch alert view message to the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc] initWithTitle:@"Unsecure Connection"
                                        message:@"We're unable to interpret account data validity. Please check your network connection and try again."
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        });
        
        // post notification
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kAccountOperationError object:nil];
        });
        
    }
    
    [self finish];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // post notification
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kAccountOperationError object:nil];
    });
    [self finish];
}


- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    
    // validate that the authentication challenge came from a whitelisted protection space
    if (![[[Model sharedModel] validProtectionSpaces] containsObject:challenge.protectionSpace]) {
        // dispatch alert view message to the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc] initWithTitle:@"Unsecure Connection"
                                        message:@"We're unable to establish a secure connection. Please check your network connection and try again."
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        });
        
        // post notification
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kAccountOperationError object:nil];
        });
        
        // cancel authentication
        [challenge.sender cancelAuthenticationChallenge:challenge];
    }
    
    // if this is a client certificate authentication request AND
    // the user has already registered this device, attempt to issue
    // the certificate to the service tier
    if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodClientCertificate) {
        
        // proceed with authentication
        if (challenge.previousFailureCount == 0) {
            
            // retrieve the default credential specifically for client certificate challenges
            NSURLCredential *credential = [[NSURLCredentialStorage sharedCredentialStorage] 
                                           defaultCredentialForProtectionSpace:[[Model sharedModel] clientCertificateProtectionSpace]];
            if (credential) {
                [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
            }
            
        // authentication has previously failed. depending on authentication configuration, too
        // many attempts here could lead to a poor user experience via locked accounts
        } else {
            
            // cancel the authentication attempt
            [[challenge sender] cancelAuthenticationChallenge:challenge];
            
            // alert the user that their credentials are invalid
            // this would typically be handled in a cleaner manner such as updating the styled login view
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"Invalid Certificate"
                                            message:@"The certificate used is not valid. Please login using your username and password."
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
            });
            
        }
    
    }
    
    // if nothing catches this challenge, attempt to connect without credentials
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

@end