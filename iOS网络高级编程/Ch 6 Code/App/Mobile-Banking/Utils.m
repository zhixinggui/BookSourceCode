//
//  Utils.m
//  Mobile Banking
//
//  Created by Nathan Jones on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Utils.h"
#import <CommonCrypto/CommonCryptor.h>
#import <Security/SecRandom.h>

@implementation Utils

#pragma mark Listing 6-15 - Creating an Initialization Vector
+ (NSData*)blockInitializationVectorOfLength:(size_t)ivLength {
    // default to AES block size
    if (ivLength == 0) {
        ivLength = kCCBlockSizeAES128;
    }
    
    NSMutableData *iv = [NSMutableData dataWithLength:ivLength];
    
    int ivResult = SecRandomCopyBytes(kSecRandomDefault,
                                      ivLength,
                                      iv.mutableBytes);
    
    if (ivResult == noErr) {
        return iv;
    }
    
    return nil;
}

+ (void)identity:(SecIdentityRef*)identity 
  andCertificate:(SecCertificateRef*)certificate 
  fromPKCS12Data:(NSData*)certData 
  withPassphrase:(NSString*)passphrase {
    
    // adapted from https://developer.apple.com/library/IOs/#documentation/Security/Conceptual/CertKeyTrustProgGuide/iPhone_Tasks/iPhone_Tasks.html#//apple_ref/doc/uid/TP40001358-CH208-SW13
    
    // bridge our import data to foundation objects
    CFStringRef importPassphrase = (__bridge CFStringRef)passphrase;
    CFDataRef importData = (__bridge CFDataRef)certData;
    
    // create dictionary of options for the PKCS12 import
    const void *keys[] = { kSecImportExportPassphrase };
    const void *values[] = { importPassphrase };
    CFDictionaryRef importOptions = CFDictionaryCreate(NULL, keys,
                                                       values, 1,
                                                       NULL, NULL);
    
    // create array to store our import results
    CFArrayRef importResults = CFArrayCreate(NULL, 0, 0, NULL);
    OSStatus pkcs12ImportStatus = errSecSuccess;
    
    pkcs12ImportStatus = SecPKCS12Import(importData,
                                         importOptions,
                                         &importResults);
    
    // check if we import successfully
    if (pkcs12ImportStatus == errSecSuccess) {
        CFDictionaryRef identityAndTrust = CFArrayGetValueAtIndex (importResults, 0);
        
        // retrieve the identity from the certificate we imported
        const void *tempIdentity = NULL;
        tempIdentity = CFDictionaryGetValue (identityAndTrust,
                                             kSecImportItemIdentity);
        *identity = (SecIdentityRef)tempIdentity;
        
        // extract the certificate from the identity
        SecCertificateRef tempCertificate = NULL;
        OSStatus certificateStatus = errSecSuccess;
        certificateStatus = SecIdentityCopyCertificate (*identity,
                                                        &tempCertificate);
        *certificate = (SecCertificateRef)tempCertificate;
    }
    
    // clean up
    if (importOptions) {
        CFRelease(importOptions);
    }
}

@end