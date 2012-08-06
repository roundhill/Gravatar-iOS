//
//  RCXMLRPCParsingContext.h
//  Gravatar
//
//  Created by Beau Collins on 8/6/12.
//  Copyright (c) 2012 Beau Collins. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCXMLRPCParsingContext : NSObject

@property (nonatomic, strong) NSString *elementName;
@property (nonatomic, strong) NSString *currentKey;
@property (nonatomic, strong) id object;

-(void)addObject:(id)object;
-(BOOL)isArray;
-(BOOL)isDictionary;
@end
