//
//  NSData+Encryption.h
//  Mobile Banking
//
//  Created by Nathan Jones on 2/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Encryption)

- (NSData *)encryptedWithAESUsingKey:(NSString*)key andIV:(NSData*)iv;
- (NSData *)decryptedWithAESUsingKey:(NSString*)key andIV:(NSData*)iv;

- (NSData *)encryptedWith3DESUsingKey:(NSString*)key andIV:(NSData*)iv;
- (NSData *)decryptedWith3DESUsingKey:(NSString*)key andIV:(NSData*)iv;

@end