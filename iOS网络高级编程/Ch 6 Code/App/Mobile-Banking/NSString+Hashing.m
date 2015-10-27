//
//  NSString+Hashing.m
//  Mobile-Banking
//
//  Created by Nathan Jones on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSString+Hashing.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonCryptor.h>

@implementation NSString (Hashing)

- (NSString*)md5 {
    return [self hashWithType:NJHashTypeMD5];
}

- (NSString*)sha1 {
    return [self hashWithType:NJHashTypeSHA1];
}

- (NSString*)sha256 {
    return [self hashWithType:NJHashTypeSHA256];
}

- (NSString*)hashWithType:(NJHashType)type {
    
    // Create pointer to the string as UTF8
    const char *ptr = [self UTF8String];
    
    // Create buffer with length for chosen digest
    NSInteger bufferSize;
    switch (type) {
        case NJHashTypeMD5:
            // 16 bytes            
            bufferSize = CC_MD5_DIGEST_LENGTH;
            break;
        
        case NJHashTypeSHA1:
            // 20 bytes            
            bufferSize = CC_SHA1_DIGEST_LENGTH;
            break;
        
        case NJHashTypeSHA256:
            // 32 bytes            
            bufferSize = CC_SHA256_DIGEST_LENGTH;
            break;
            
        default:
            return nil;
            break;
    }
    
    unsigned char buffer[bufferSize];
    
    // Perform hash calculation and store in buffer
    switch (type) {
        case NJHashTypeMD5:
            CC_MD5(ptr, strlen(ptr), buffer);
            break;
            
        case NJHashTypeSHA1:
            CC_SHA1(ptr, strlen(ptr), buffer);
            break;
            
        case NJHashTypeSHA256:
            CC_SHA256(ptr, strlen(ptr), buffer);
            break;
            
        default:
            return nil;
            break;
    }
    
    // Convert buffer value to pretty printed NSString (this will match the servers hash calculation)
    NSMutableString *hashString = [NSMutableString stringWithCapacity:bufferSize * 2];
    for(int i = 0; i < bufferSize; i++) {
        [hashString appendFormat:@"%02x",buffer[i]];
    }
    
    return hashString;
    
}

#pragma mark - Keyed Message Authentication Code
- (NSString*)hmacWithKey:(NSString*)key {
    // Pointer to UTF8 representations of strings
    const char *ptr = [self UTF8String];
    const char *keyPtr = [key UTF8String];
    
    // Implemented with SHA256, create appropriate buffer (32 bytes)
    unsigned char buffer[CC_SHA256_DIGEST_LENGTH];
    
    // Create hash value
    CCHmac(kCCHmacAlgSHA256,            // algorithm 
           keyPtr, kCCKeySizeAES256,    // key and key length
           ptr, strlen( ptr ),          // data to hash and length
           buffer);                     // output buffer
    
    // Convert HMAC buffer value to pretty printed NSString
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x",buffer[i]];
    }
    
    return output;
    
}

@end