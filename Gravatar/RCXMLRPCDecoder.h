//
//  RCXMLRPCDecoder.h
//  Gravatar
//
//  Created by Beau Collins on 8/3/12.
//  Copyright (c) 2012 Beau Collins. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const RCXMLRPCDecoderArrayElement;
extern NSString * const RCXMLRPCDecoderParamsElement;
extern NSString * const RCXMLRPCDecoderStructElement;

@interface RCXMLRPCDecoder : NSObject

@property (nonatomic, strong, readonly) NSArray *params;
@property (nonatomic, strong, readonly) id object;
@property (nonatomic, readonly, getter = isFault) BOOL fault;

-(BOOL)decodeData:(NSData *)data;
-(BOOL)decodeStream:(NSInputStream *)stream;
+(NSArray *)contentElements;
+(NSArray *)contextElements;
@end