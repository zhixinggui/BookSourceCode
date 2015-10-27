//
//  AuthenticateOperation.h
//  Mobile Banking
//
//  Created by Nathan Jones on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BaseOperation.h"

@interface AuthenticateOperation : BaseOperation

@property(nonatomic,strong) NSString    *username;
@property(nonatomic,strong) NSString    *password;
@property(nonatomic,strong) NSString    *passphrase;
@property(nonatomic,assign) BOOL        registerDevice;

@end