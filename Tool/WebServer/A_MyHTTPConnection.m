//
//  MyHTTPConnection.m
//  LocalWebServer
//
//  Created by Smallfan on 23/08/2017.
//  Copyright © 2017 Smallfan. All rights reserved.
//

#import "A_MyHTTPConnection.h"

@implementation A_MyHTTPConnection

- (BOOL)isSecureServer {
    return YES;
}

- (NSArray *)sslIdentityAndCertificates {
    
    SecIdentityRef C_identityRef = NULL;
    SecCertificateRef C_certificateRef = NULL;
    SecTrustRef C_trustRef = NULL;
    
    NSString *C_thePath = [[NSBundle bundleWithPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Resource"]] pathForResource:@"localhost" ofType:@"p12"];
    NSData *C_PKCS12Data = [[NSData alloc] initWithContentsOfFile:C_thePath];
    CFDataRef C_inPKCS12Data = (__bridge CFDataRef)C_PKCS12Data;
    CFStringRef C_password = CFSTR("b123456");
    const void *C_keys[] = { kSecImportExportPassphrase };
    const void *C_values[] = { C_password };
    CFDictionaryRef C_optionsDictionary = CFDictionaryCreate(NULL, C_keys, C_values, 1, NULL, NULL);
    CFArrayRef C_items = CFArrayCreate(NULL, 0, 0, NULL);
    
    OSStatus C_securityError = errSecSuccess;
    C_securityError =  SecPKCS12Import(C_inPKCS12Data, C_optionsDictionary, &C_items);
    if (C_securityError == 0) {
        CFDictionaryRef C_myIdentityAndTrust = CFArrayGetValueAtIndex (C_items, 0);
        const void *C_tempIdentity = NULL;
        C_tempIdentity = CFDictionaryGetValue (C_myIdentityAndTrust, kSecImportItemIdentity);
        C_identityRef = (SecIdentityRef)C_tempIdentity;
        const void *C_tempTrust = NULL;
        C_tempTrust = CFDictionaryGetValue (C_myIdentityAndTrust, kSecImportItemTrust);
        C_trustRef = (SecTrustRef)C_tempTrust;
    } else {
        NSLog(@"Failed with error code %d",(int)C_securityError);
        return nil;
    }
    
    SecIdentityCopyCertificate(C_identityRef, &C_certificateRef);
    NSArray *C_result = [[NSArray alloc] initWithObjects:(__bridge id)C_identityRef, (__bridge id)C_certificateRef, nil];
    
    return C_result;
}

@end
