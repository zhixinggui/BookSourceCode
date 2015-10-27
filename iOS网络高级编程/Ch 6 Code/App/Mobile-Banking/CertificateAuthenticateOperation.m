//
//  CertificateAuthenticateOperation.m
//  Mobile-Banking
//
//  Created by Nathan Jones on 5/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CertificateAuthenticateOperation.h"

#define kEndpoint @"/user/authenticate/certificate"
#define kHTTPMethod @"POST"
#define kOperationTimeout 30.0

@interface CertificateAuthenticateOperation() {
@private
    BOOL isExecuting;
    BOOL isFinished;
    NSURLConnection *connection;
}

@end

@implementation CertificateAuthenticateOperation

@synthesize pin = _pin;

static BOOL _operationInProcess = NO;

#pragma Operation Lifecycle

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
    
    // alert observers
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kRegisteredLoginStartNotification object:nil];
    });
    
    // build and issue our authentication request
    NSString *url;
    url = [kResourceBaseURL stringByAppendingFormat:@"%@?pin=%@", kEndpoint, _pin];
    
    NSMutableURLRequest *request = [self buildRequestWithURL:url
                                                  httpMethod:kHTTPMethod
                                                     payload:nil
                                                     timeout:kOperationTimeout
                                               signingOption:NJRequestSigningOptionNone];
    
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
    CertificateAuthenticateOperation*copy = [super copyWithZone:zone];
    copy.pin = _pin;
    return copy;
}

#pragma mark - NSURLConnection Delegates
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.responseData = [[NSMutableData alloc] init];
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    self.statusCode = httpResponse.statusCode;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    // successful authentication
    if (self.statusCode == 200) {
        
        // unpack service response
        NSError *error = nil;
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:self.responseData 
                                                                 options:0 
                                                                   error:&error];
        
        NSString *token = [response objectForKey:@"token"];
        // normally we would write the token to the keychain, Chapter XX covers keychain
        // in more detail, so for now we'll store in our model object
        [Model sharedModel].token = token;
        
        // issue command to retrieve users accounts
        [[Model sharedModel] fetchAccounts];
        
        // alert observers
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kRegisteredLoginSuccessNotification object:nil];
        });
        
    // authentication failed
    } else {
        // alert observers
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kRegisteredLoginFailedNotification object:nil];
        });
    }
    
    [self finish];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // post notification
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kRegisteredLoginFailedNotification object:nil];
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

        // cancel authentication
     [challenge.sender cancelAuthenticationChallenge:challenge];
    }
    
    // user the clients certificate
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