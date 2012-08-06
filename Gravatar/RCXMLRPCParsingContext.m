//
//  RCXMLRPCParsingContext.m
//  Gravatar
//
//  Created by Beau Collins on 8/6/12.
//  Copyright (c) 2012 Beau Collins. All rights reserved.
//

#import "RCXMLRPCParsingContext.h"
#import "RCXMLRPCDecoder.h"

@implementation RCXMLRPCParsingContext


-(void)addObject:(id)object {
    if ([self.object respondsToSelector:@selector(setObject:forKey:)]) {
        // add with key
        NSMutableDictionary *dict = (NSMutableDictionary *)self.object;
        [dict setObject:object forKey:self.currentKey];
    } else if([self.object respondsToSelector:@selector(addObject:)]){
        // just add
        NSMutableArray *arr = (NSMutableArray *)self.object;
        [arr addObject:object];
    }    
}

-(BOOL)isArray {
    return [self.elementName isEqualToString:RCXMLRPCDecoderArrayElement] || [self.elementName isEqualToString:RCXMLRPCDecoderParamsElement];
}

-(BOOL)isDictionary {
    return [self.elementName isEqualToString:RCXMLRPCDecoderStructElement];
}

@end
