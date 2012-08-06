//
//  MD5Hasher.m
//  Gravatar
//
//  Created by Beau Collins on 8/6/12.
//  Copyright (c) 2012 Beau Collins. All rights reserved.
//

#import "MD5Hasher.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation MD5Hasher

+(NSString *)hashForString:(NSString *)string {
    // pointer to UTF8 chars
    const char *ptr = [string UTF8String];
    // char array with md5 str length
    unsigned char md5buffer[CC_MD5_DIGEST_LENGTH];
    // generate the md5 char array from the ptr
    // store in the buffer
    CC_MD5(ptr, strlen(ptr), md5buffer);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i=0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", md5buffer[i]];
    }
    
    return output;
    
}

@end
