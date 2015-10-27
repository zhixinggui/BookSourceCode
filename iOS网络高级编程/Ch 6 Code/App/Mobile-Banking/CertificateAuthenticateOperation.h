//
//  CertificateAuthenticateOperation.h
//  Mobile-Banking
//
//  Created by Nathan Jones on 5/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BaseOperation.h"

@interface CertificateAuthenticateOperation : BaseOperation

@property(nonatomic,strong) NSString *pin;

@end