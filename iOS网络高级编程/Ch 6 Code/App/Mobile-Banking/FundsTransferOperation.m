//
//  FundsTransferOperation.m
//  Mobile Banking
//
//  Created by Nathan Jones on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FundsTransferOperation.h"

#define kEndpoint @"/account/transferfunds/"
#define kHTTPMethod @"POST"
#define kOperationTimeout 30.0

@interface FundsTransferOperation() {
@private
    BOOL isExecuting;
    BOOL isFinished;
    NSURLConnection *connection;
}
@end

@implementation FundsTransferOperation

@synthesize fromAccount = _fromAccount;
@synthesize toAccount = _toAccount;
@synthesize amount = _amount;
@synthesize transferDate = _transferDate;
@synthesize transferNotes = _transferNotes;

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
    
    // alert observers of the failed attempt
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kFundsTransferStartNotification object:nil];
    });
    
    // clean up any nil values
    _toAccount = _toAccount ? _toAccount : @"";
    _fromAccount = _fromAccount ? _fromAccount : @"";
    NSString *amount = _amount ? [NSString stringWithFormat:@"%.02f",_amount] : @"0.00";
    NSString *date = _transferDate ? [NSString stringWithFormat:@"%@", _transferDate] :[NSString stringWithFormat:@"%@", [NSDate date]]; 
    _transferDate = _transferDate ? _transferDate : [NSDate date];
    _transferNotes = _transferNotes ? _transferNotes : @"";
    
    // build our transfer data
    NSDictionary *transfer = [NSDictionary dictionaryWithObjectsAndKeys:
                              _toAccount, @"toAccount",
                              _fromAccount, @"fromAccount",  
                              date, @"transferDate",
                              _transferNotes, @"transferNotes",
                              amount, @"amount", nil];
    
    // create the json representation of our transfer data using ios5 API
    NSError *error = nil;
    NSData *transferData = [NSJSONSerialization dataWithJSONObject:transfer
                                                           options:0 error:&error];
    NSString *transferString = [[NSString alloc] initWithData:transferData
                                                     encoding:NSUTF8StringEncoding];
    
    // generate our initialization vector
    NSData *iv = [Utils blockInitializationVectorOfLength:kCCBlockSizeAES128];

    // because we generate random bytes, it may not be proper UTF8 encoding.
    // because of this, we can't just init a string with data. instead,
    // we encode it for transmission. the IV is then decoded on the service
    // and used in the decryption process
    NSString *ivString = [iv base64Encoding];
    
    // encrypt our transfer data using AES and a randomly generated IV (this IV needs to be what we send to the service)
    NSString *encryptedString = [transferString encryptedWithAESUsingKey:kAESEncryptionKey 
                                                                   andIV:iv];
    
    // calculate our message authentication code
    NSString *macCandidate = [NSString stringWithFormat:@"%@%@%@%@",
                              _toAccount,       // to account
                              _fromAccount,     // from account
                              amount,           // amount
                              _transferDate];   // transfer date
    
    
    NSString *mac = [macCandidate hmacWithKey:kMACKey];
    
    // construct our payload
    NSMutableDictionary *payload = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    ivString, @"iv", 
                                    mac, @"mac", 
                                    encryptedString, @"payload", nil];
    
    // build our funds transfer request and issue it
    NSString *url;
    url = [kResourceBaseURL stringByAppendingString:kEndpoint];
    
    // build our funds transfer request and issue it
    NSMutableURLRequest *request = [self buildRequestWithURL:url
                                                  httpMethod:kHTTPMethod
                                                     payload:payload
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
    /*
        This method is purposfully not implemented, re-issuing operations like this
        could have dramatically bad consequences in the case of a false-negative.
     */
    return nil;
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
    
    // funds transferred successfully
    if (self.statusCode == 200) {
        // alert observers of the failed attempt
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kFundsTransferSuccessNotification object:nil];
        });
        
    // some sort of error occurred
    } else {
        // alert observers of the failed attempt
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kFundsTransferFailedNotification object:nil];
        });
    }
    
    
    [self finish];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // alert observers of the failed attempt
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kFundsTransferFailedNotification object:nil];
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
    
}

@end