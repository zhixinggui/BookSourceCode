//
//  Model.h
//  Mobile Banking
//
//  Created by Nathan Jones on 2/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface Model : NSObject

@property(nonatomic,strong) NSMutableArray  *accounts;
@property(nonatomic,strong) NSString        *token;

+ (Model *)sharedModel;
- (void)enqueueOperation:(NSOperation*)op;
- (void)enqueuePendingOperation:(NSOperation*)op;

- (void)authenticateWithUsername:(NSString*)username 
                     andPassword:(NSString*)password
                  registerDevice:(BOOL)registerDevice
                    withPasscode:(NSString*)passcode;
- (void)authenticateWithCertificateAndPin:(NSString*)pin;
- (void)signOut;
- (void)fetchAccounts;
- (void)registerDevice;
- (BOOL)isDeviceRegistered;

- (void)transferFundsFromAccount:(NSString*)fromAccount
                       toAccount:(NSString*)toAccount
                   effectiveDate:(NSDate*)transferDate
                      withAmount:(double)amount
                        andNotes:(NSString*)notes;

- (NSArray*)validProtectionSpaces;
- (NSURLProtectionSpace*)clientCertificateProtectionSpace;

@end
