//
//  Utils.h
//  Mobile Banking
//
//  Created by Nathan Jones on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject

+ (NSData*)blockInitializationVectorOfLength:(size_t)ivLength;
+ (void)identity:(SecIdentityRef*)identity 
  andCertificate:(SecCertificateRef*)certificate 
  fromPKCS12Data:(NSData*)certData 
  withPassphrase:(NSString*)passphrase;

@end