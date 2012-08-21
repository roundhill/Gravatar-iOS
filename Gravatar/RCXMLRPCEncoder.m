//
//  RCXMLRPCEncoder.m
//  Gravatar
//
//  Created by Beau Collins on 8/3/12.
//  Copyright (c) 2012 Beau Collins. All rights reserved.
//

#import "RCXMLRPCEncoder.h"
#import "NSData+Base64.h"

NSString * const RCXMLRPCEncoderOpening = @"<?xml version=\"1.0\"?>\n<methodCall><methodName>%@</methodName>";
NSString * const RCXMLRPCEncoderClosing = @"</methodCall>";

#define kRCXMLRPCEncoderStringFormat  @"<string>%@</string>"
#define kRCXMLRPCEncoderFloatFormat   @"<double>%@</double>"
#define kRCXMLRPCEncoderIntFormat     @"<i4>%@</i4>"
#define kRCXMLRPCEncoderBoolFormat    @"<boolean>%@</boolean>"
#define kRCXMLRPCEncoderDateFormat    @"<dateTime.iso8601>%@</dateTime.iso8601>"
#define kRCXMLRPCEncoderBase64Format  @"<base64>%@</base64>"
#define kRCXMLRPCEncoderParamsFormat  @"<params>%@</params>"
#define kRCXMLRPCEncoderParamFormat   @"<param>%@</param>"
#define kRCXMLRPCEncoderArrayFormat   @"<array><data>%@</data></array>"
#define kRCXMLRPCEncoderArrayMemberFormat  @"<value>%@</value>"
#define kRCXLMRPCRequsetEncoderISO8601Format @"yyyyMMdd'T'HH:mm:ss"

#define kRCXMLRPCEncoderStructFormat  @"<struct>%@</struct>"
#define kRCXMLRPCEncoderStructMemberFormat  @"<member><name>%@</name><value>%@</value></member>"

@interface RCXMLRPCEncoder()

+(BOOL)object:(id)object isKindOf:(Class)class;

@end

@implementation RCXMLRPCEncoder

#pragma mark - Serialization Methods

+(NSData *)dataForRequestMethod:(NSString *)methodName andParams:(NSArray *)params {
    return [[self stringForRequestMethod:methodName andParams:params] dataUsingEncoding:NSUTF8StringEncoding];

}

+(NSString *)stringForRequestMethod:(NSString *)methodName andParams:(NSArray *)params {
    NSString *container = [RCXMLRPCEncoder requestContainer];
    NSString *request = [NSString stringWithFormat:container, methodName, [RCXMLRPCEncoder fragmentForParams:params]];
    return request;
}

+(NSString *)requestContainer {
    return [NSString stringWithFormat:@"%@%%@%@", RCXMLRPCEncoderOpening, RCXMLRPCEncoderClosing];
}

+(NSString *)fragmentForParams:(NSArray *)params {
    NSMutableString *paramsString = [NSMutableString stringWithString:@""];
    for (id param in params) {
        [paramsString appendFormat:kRCXMLRPCEncoderParamFormat, [self fragmentForObject:param]];
        
    }
    return [NSString stringWithFormat:kRCXMLRPCEncoderParamsFormat, paramsString];
}

+(NSString *)fragmentForArray:(NSArray *)array {
    NSMutableString *memberString = [NSMutableString stringWithString:@""];
    for (id member in array) {
        [memberString appendFormat:kRCXMLRPCEncoderArrayMemberFormat, [self fragmentForObject:member]];
    }
    return [NSString stringWithFormat:kRCXMLRPCEncoderArrayFormat, memberString];
}

+ (BOOL)object:(id)object isKindOf:(Class)class {
    
    return [object class] == class || [object isKindOfClass:class];
}

+ (NSString *)fragmentForObject:(id)object {
    if([object respondsToSelector:@selector(objectForXMLRPCSerialization)]){
       return [self fragmentForObject:[object performSelector:@selector(objectForXMLRPCSerialization)]];
    } 

    if ([self object:object isKindOf:[NSString class]]) {
        return [self fragmentForString:object];
    } else if ([self object:object isKindOf:[NSNumber class]]){
        return [self fragmentForNumber:object];
    } else if ([self object:object isKindOf:[NSData class]]){
        return [self fragmentForData:object];
    } else if ([self object:object isKindOf:[NSDictionary class]]){
        return [self fragmentForDictionary:object];
    } else if ([self object:object isKindOf:[NSArray class]]){
        return [self fragmentForArray:object];
    }
    return nil;
}

+ (NSString *)fragmentForDictionary:(NSDictionary *)dictionary {
    NSMutableString *dictString = [NSMutableString stringWithFormat:@""];
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [dictString appendFormat:kRCXMLRPCEncoderStructMemberFormat, key, [self  fragmentForObject:obj]];
    }];
    return [NSString stringWithFormat:kRCXMLRPCEncoderStructFormat, dictString];
}

+(NSString *)fragmentForString:(NSString *)string {
    return [NSString stringWithFormat:kRCXMLRPCEncoderStringFormat, string];
}

+(NSString *)fragmentForFloat:(float)num {
    NSNumber *number = [NSNumber numberWithFloat:num];
    return [NSString stringWithFormat:kRCXMLRPCEncoderFloatFormat, number];
}

+(NSString *)fragmentForInt:(int)num {
    NSNumber *number = [NSNumber numberWithInt:num];
    return [NSString stringWithFormat:kRCXMLRPCEncoderIntFormat, number];
}

+(NSString *)fragmentForBool:(BOOL)value {
    NSNumber *number = [NSNumber numberWithBool:value];
    return [NSString stringWithFormat:kRCXMLRPCEncoderBoolFormat, number];
}

+(NSString *)fragmentForDate:(NSDate *)date {
    NSString *dateString = [self iso8601StringForDate:date];
    return [NSString stringWithFormat:kRCXMLRPCEncoderDateFormat, dateString];
}

+(NSString*)iso8601StringForDate:(NSDate *)date {
    static NSDateFormatter *formatter;
    if (nil == formatter) {
        formatter = [[NSDateFormatter alloc] init];
        formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        formatter.dateFormat = kRCXLMRPCRequsetEncoderISO8601Format;
    }
    return [formatter stringFromDate:date];
}

+(NSString*)fragmentForNumber:(NSNumber *)number {
    NSString *fragment;
    if(strcmp(@encode(bool), [number objCType]) == 0){
        fragment = [self fragmentForBool:[number boolValue]];
    } else if( strcmp(@encode(int), [number objCType]) == 0) {
        fragment = [self fragmentForInt:[number integerValue]];
    } else if( strcmp(@encode(float), [number objCType]) == 0) {
        fragment = [self fragmentForFloat: [number floatValue]];
    } else if( strcmp(@encode(double), [number objCType]) == 0) {
        fragment = [self fragmentForFloat: [number floatValue]];
    }
    
    return fragment;
}

+ (NSString *)fragmentForData:(NSData *)data {
    return [NSString stringWithFormat:kRCXMLRPCEncoderBase64Format, [data base64EncodedString]];
}


@end
