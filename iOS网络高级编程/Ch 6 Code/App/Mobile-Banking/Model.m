//
//  Model.m
//  Mobile Banking
//
//  Created by Nathan Jones on 2/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Model.h"
#import "AuthenticateOperation.h"
#import "CertificateAuthenticateOperation.h"
#import "FundsTransferOperation.h"
#import "GetAccountsOperation.h"
#import "Account.h"

@interface Model() {
@private
    NSOperationQueue    *queue;
    NSMutableArray      *pendingOperations;
}
@end

@implementation Model

@synthesize accounts = _accounts;
@synthesize token = _token;

static Model *_instance = nil;

- (id)init {
    self = [super init];
    return self;
}

+ (Model *)sharedModel {
    if (_instance == nil) {
        _instance = [[self alloc] init];
    }
    
    return _instance;
}

- (void)enqueueOperation:(NSOperation*)op {
    if (queue == nil) {
        queue = [[NSOperationQueue alloc] init];
        [queue setMaxConcurrentOperationCount:5];
    }
    
    [queue addOperation:op];
}

// add operation to array of pending operations which will
// be retriggered once the user has successfully authenticated
- (void)enqueuePendingOperation:(NSOperation*)op {
    if (pendingOperations == nil) {
        pendingOperations = [[NSMutableArray alloc] init];
    }
    
    [pendingOperations addObject:op];
}

- (void)authenticateWithUsername:(NSString*)username
                     andPassword:(NSString*)password
                  registerDevice:(BOOL)registerDevice
                    withPasscode:(NSString*)passcode {
    // fire up an authentication request
    AuthenticateOperation *operation = [[AuthenticateOperation alloc] init];
    operation.username = username;
    operation.password = password;
    operation.registerDevice = registerDevice;
    operation.passphrase = passcode;
    [operation enqueueOperation];
}

- (void)authenticateWithCertificateAndPin:(NSString*)pin {
    CertificateAuthenticateOperation *operation = [[CertificateAuthenticateOperation alloc] init];
    operation.pin = pin;
    [operation enqueueOperation];
}

- (void)signOut {
    // here is where we would typically remove token values
    // from the keychain. Chapter 11 covers keychain interaction
    // in more detail, for now we'll just clear our model 
    // variable that holds the token
    _token = nil;
}

- (void)fetchAccounts {
    // request new accounts
    GetAccountsOperation *operation = [[GetAccountsOperation alloc] init];
    [operation enqueueOperation];
}

- (void)registerDevice {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"registeredDevice"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)isDeviceRegistered {
    BOOL registered = [[NSUserDefaults standardUserDefaults] boolForKey:@"registeredDevice"];
    if (registered == YES) {
        return YES;
    }
    return NO;
}

- (void)transferFundsFromAccount:(NSString*)fromAccount
                       toAccount:(NSString*)toAccount
                   effectiveDate:(NSDate*)transferDate
                      withAmount:(double)amount
                        andNotes:(NSString*)notes {

    FundsTransferOperation *operation = [[FundsTransferOperation alloc] init];
    operation.fromAccount = fromAccount;
    operation.toAccount = toAccount;
    operation.transferDate = transferDate;
    operation.amount = amount;
    operation.transferNotes = notes;
    [operation enqueueOperation];
    
}

- (NSArray *)validProtectionSpaces {

    // valid supported protection spaces
    NSURLProtectionSpace *defaultSpace = [[NSURLProtectionSpace alloc] initWithHost:@"yourbankingdomain.com"
                                                                               port:443
                                                                           protocol:NSURLProtectionSpaceHTTPS
                                                                              realm:@"mobile"
                                                               authenticationMethod:NSURLAuthenticationMethodDefault];
    
    NSURLProtectionSpace *trustSpace = [[NSURLProtectionSpace alloc] initWithHost:@"yourbankingdomain.com"
                                                                             port:443
                                                                         protocol:NSURLProtectionSpaceHTTPS
                                                                            realm:@"mobile"
                                                             authenticationMethod:NSURLAuthenticationMethodServerTrust];
    
    NSURLProtectionSpace *certSpace = [[NSURLProtectionSpace alloc] initWithHost:@"yourbankingdomain.com"
                                                                            port:443
                                                                        protocol:NSURLProtectionSpaceHTTPS
                                                                           realm:nil
                                                            authenticationMethod:NSURLAuthenticationMethodClientCertificate];
    
    return [NSArray arrayWithObjects:defaultSpace, trustSpace, certSpace, nil];
    
}

- (NSURLProtectionSpace*)clientCertificateProtectionSpace {
    NSURLProtectionSpace *certSpace = [[NSURLProtectionSpace alloc] initWithHost:@"yourbankingdomain.com"
                                                                            port:443
                                                                        protocol:NSURLProtectionSpaceHTTPS
                                                                           realm:@""
                                                            authenticationMethod:NSURLAuthenticationMethodClientCertificate];
    return certSpace;
}

@end