//
//  NSData+AES.m
//  InstaChallenge
//
//  Created by sensor108 on 07.10.14.
//  Copyright (c) 2014 René Nicklas. All rights reserved.
//

#import "NSData+AES.h"

@implementation NSData (AES)

- (NSData *)encryptAES:(NSString *)key
{
    char keyPtr[kCCKeySizeAES256+1];
    bzero( keyPtr, sizeof(keyPtr) );
    
    [key getCString: keyPtr maxLength: sizeof(keyPtr) encoding: NSUTF16StringEncoding];
    size_t numBytesEncrypted = 0;
    
    NSUInteger dataLength = [self length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    CCCryptorStatus result = CCCrypt( kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                     keyPtr, kCCKeySizeAES256,
                                     NULL,
                                     [self bytes], [self length],
                                     buffer, bufferSize,
                                     &numBytesEncrypted );
    
    if( result == kCCSuccess ) {
        
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];;
    }
    
    free(buffer);
    return nil;
}

- (NSData *)decryptAES:(NSString *)key
{
    char  keyPtr[kCCKeySizeAES256+1];
    bzero( keyPtr, sizeof(keyPtr) );
    
    [key getCString: keyPtr maxLength: sizeof(keyPtr) encoding: NSUTF16StringEncoding];
    
    size_t numBytesEncrypted = 0;
    
    NSUInteger dataLength = [self length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer_decrypt = malloc(bufferSize);
    
    CCCryptorStatus result = CCCrypt( kCCDecrypt , kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                     keyPtr, kCCKeySizeAES256,
                                     NULL,
                                     [self bytes], [self length],
                                     buffer_decrypt, bufferSize,
                                     &numBytesEncrypted );
    
    if( result == kCCSuccess ) {
        
        return [NSData dataWithBytesNoCopy:buffer_decrypt length:numBytesEncrypted];
    }
    
    free(buffer_decrypt);
    return nil;
}

@end
