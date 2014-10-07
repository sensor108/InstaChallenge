//
//  NSData+AES.h
//  InstaChallenge
//
//  Created by sensor108 on 07.10.14.
//  Copyright (c) 2014 René Nicklas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCrypto.h>

@interface NSData (AES)
- (NSData *)encryptAES:(NSString *)key;
- (NSData *)decryptAES:(NSString *)key;
@end
