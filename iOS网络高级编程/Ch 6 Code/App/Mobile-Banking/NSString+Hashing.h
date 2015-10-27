//
//  NSString+Hashing.h
//  Mobile-Banking
//
//  Created by Nathan Jones on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

enum {
    NJHashTypeMD5 = 0,
    NJHashTypeSHA1,
    NJHashTypeSHA256,
}; typedef NSUInteger NJHashType;

@interface NSString (Hashing)

- (NSString*)md5;
- (NSString*)sha1;
- (NSString*)sha256;
- (NSString*)hashWithType:(NJHashType)type;
- (NSString*)hmacWithKey:(NSString*)key;

@end