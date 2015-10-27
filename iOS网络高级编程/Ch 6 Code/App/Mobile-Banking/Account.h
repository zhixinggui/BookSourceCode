//
//  Account.h
//  Mobile-Banking
//
//  Created by Nathan Jones on 2/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Account : NSObject

@property(nonatomic,strong) NSString *accountNumber;
@property(nonatomic,strong) NSString *accountName;
@property(nonatomic,assign) double   accountBalance;
@property(nonatomic,assign) BOOL     pendingTransfer;

- (id)initWithData:(NSDictionary*)data;

@end