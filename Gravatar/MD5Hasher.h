//
//  MD5Hasher.h
//  Gravatar
//
//  Created by Beau Collins on 8/6/12.
//  Copyright (c) 2012 Beau Collins. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MD5Hasher : NSObject

+ (NSString *)hashForEmail:(NSString *)email;
+ (NSString *)hashForString:(NSString *)string;

@end
