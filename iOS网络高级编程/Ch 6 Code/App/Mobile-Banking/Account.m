//
//  Account.m
//  Mobile-Banking
//
//  Created by Nathan Jones on 2/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Account.h"

@implementation Account

@synthesize accountNumber = _accountNumber;
@synthesize accountName = _accountName;
@synthesize accountBalance = _accountBalance;
@synthesize pendingTransfer = _pendingTransfer;

- (id)initWithData:(NSDictionary*)data {
    self = [super init];
    
    if (self != nil) {
        _accountNumber = [data objectForKey:@"number"];
        _accountName = [data objectForKey:@"name"];
        _accountBalance = [[data objectForKey:@"balance"] doubleValue];
        _pendingTransfer = [[data objectForKey:@"pending"] boolValue];
    }
    
    return self;
}

@end