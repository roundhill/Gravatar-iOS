//
//  RCXMLRPCEncoder.h
//  Gravatar
//
//  Created by Beau Collins on 8/3/12.
//  Copyright (c) 2012 Beau Collins. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const RCXMLRPCEncoderOpening;

@interface RCXMLRPCEncoder : NSObject

+ (NSData *)dataForRequestMethod:(NSString *)methodName andParams:(NSArray *)params;
+ (NSString *)stringForRequestMethod:(NSString *)methodName andParams:(NSArray *)params;
+ (NSString *)fragmentForObject:(id)object;
+ (NSString *)fragmentForString:(NSString *)string;
+ (NSString *)fragmentForDictionary:(NSDictionary *)dictionary;
+ (NSString *)fragmentForArray:(NSArray *)array;
+ (NSString *)fragmentForDate:(NSDate *)date;
+ (NSString *)fragmentForFloat:(float)number;
+ (NSString *)fragmentForInt:(int)number;
+ (NSString *)fragmentForNumber:(NSNumber *)number;
+ (NSString *)fragmentForBool:(BOOL)value;
+ (NSString *)fragmentForData:(NSData*)data;
+ (NSString *)requestContainer;
+ (NSString *)fragmentForParams:(NSArray *)params;
+ (NSString *)iso8601StringForDate:(NSDate *)date;

@end
