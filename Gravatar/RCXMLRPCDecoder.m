//
//  RCXMLRPCDecoder.m
//  Gravatar
//
//  Created by Beau Collins on 8/3/12.
//  Copyright (c) 2012 Beau Collins. All rights reserved.
//

#import "RCXMLRPCDecoder.h"
#import "NSData+Base64.h"
#import "RCXMLRPCParsingContext.h"

NSString *const RCXMLRPCDecoderMethodResponseElement = @"methodResponse";
NSString *const RCXMLRPCDecoderParamsElement         = @"params";
NSString *const RCXMLRPCDecoderParamElement          = @"param";
NSString *const RCXMLRPCDecoderStringElement         = @"string";
NSString *const RCXMLRPCDecoderI4Element             = @"i4";
NSString *const RCXMLRPCDecoderDoubleElement         = @"double";
NSString *const RCXMLRPCDecoderDateElement           = @"dateTime.iso8601";
NSString *const RCXMLRPCDecoderIntElement            = @"int";
NSString *const RCXMLRPCDecoderStructElement         = @"struct";
NSString *const RCXMLRPCDecoderMemberElement         = @"member";
NSString *const RCXMLRPCDecoderNameElement           = @"name";
NSString *const RCXMLRPCDecoderValueElement          = @"value";
NSString *const RCXMLRPCDecoderArrayElement          = @"array";
NSString *const RCXMLRPCDecoderDataElement           = @"data";
NSString *const RCXMLRPCDecoderBase64Element         = @"base64";
NSString *const RCXMLRPCDecoderFaultElement          = @"fault";

NSString *const RCXMLRPCDecoderDateFormat            = @"yyyyMMdd'T'HH:mm:ss";

@interface RCXMLRPCDecoder () <NSXMLParserDelegate>

@property (nonatomic, strong) NSMutableArray *responseParams;
@property (nonatomic, strong, readwrite) NSArray *params;
@property (nonatomic, strong, readwrite) id object;
@property (nonatomic, strong) NSMutableArray *elementContext;
@property (nonatomic, strong) NSMutableArray *parsingContext;
@property (nonatomic, strong) id currentValue;
@property (nonatomic, readwrite) BOOL fault;

-(RCXMLRPCParsingContext *)parsingContextForElement:(NSString *)element;
-(RCXMLRPCParsingContext *)currentParsingContext;
-(NSString *)currentElementContext;
-(BOOL)inContentElement;
-(BOOL)elementIsContextElement:(NSString *)element;
- (id)parseCharactersInContext:(NSString *)string;
@end

@implementation RCXMLRPCDecoder

+(NSArray *)contentElements {
    return @[
    RCXMLRPCDecoderStringElement,
    RCXMLRPCDecoderI4Element,
    RCXMLRPCDecoderIntElement,
    RCXMLRPCDecoderDoubleElement,
    RCXMLRPCDecoderDateElement,
    RCXMLRPCDecoderBase64Element,
    ];
}

+(NSArray *)contextElements {
    return @[
    RCXMLRPCDecoderParamsElement,
    RCXMLRPCDecoderArrayElement,
    RCXMLRPCDecoderStructElement
    ];
}

-(BOOL)decodeData:(NSData *)data {
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    parser.delegate = self;
    return [parser parse];
}

-(BOOL)decodeStream:(NSInputStream *)stream {
    NSXMLParser *parser = [NSMutableArray arrayWithCapacity:1];
    parser.delegate = self;
    return [parser parse];
}

-(NSString *)currentElementContext {
    return (NSString*)[self.elementContext lastObject];
}

-(RCXMLRPCParsingContext *)currentParsingContext {
    return (RCXMLRPCParsingContext *)[self.parsingContext lastObject];
}

-(BOOL)inContentElement {
    NSString *currentContext = [self currentElementContext];
    NSArray *contentElements = [[self class] contentElements];
    return [contentElements indexOfObject:currentContext] != NSNotFound;
}

-(BOOL)elementIsContextElement:(NSString *)element {
    return [[RCXMLRPCDecoder contextElements] indexOfObject:element] != NSNotFound;
}


- (id)parseCharactersInContext:(NSString *)string {
    id val;
    NSString *currentContext = [self currentElementContext];
    if ([currentContext isEqualToString:RCXMLRPCDecoderStringElement]) {
        val = string;
    } else if([currentContext isEqualToString:RCXMLRPCDecoderDoubleElement]){
        NSNumberFormatter *formatter  = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        val = [formatter numberFromString:string];
    } else if([currentContext isEqualToString:RCXMLRPCDecoderIntElement] || [currentContext isEqualToString:RCXMLRPCDecoderI4Element]){
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        val = [formatter numberFromString:string];
    } else if([currentContext isEqualToString:RCXMLRPCDecoderDateElement]){
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        formatter.dateFormat = RCXMLRPCDecoderDateFormat;
        val = [formatter dateFromString:string];
    } else if([currentContext isEqualToString:RCXMLRPCDecoderBase64Element]){
        val = [NSData dataFromBase64String:string];
    }
    return val;
}

-(RCXMLRPCParsingContext *)parsingContextForElement:(NSString *)element {
    RCXMLRPCParsingContext *context = [[RCXMLRPCParsingContext alloc] init];
    context.elementName = element;
    if ([element isEqualToString:RCXMLRPCDecoderParamsElement] || [element isEqualToString:RCXMLRPCDecoderArrayElement]) {
        context.object = [NSMutableArray arrayWithCapacity:1];
    } else if([element isEqualToString:RCXMLRPCDecoderStructElement]) {
        context.object = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    return context;
}


#pragma mark - NSXMLParserDelegate Methods

- (void)parserDidStartDocument:(NSXMLParser *)parser {
    self.fault = NO;
    self.elementContext = [NSMutableArray arrayWithCapacity:10];
    self.parsingContext = [NSMutableArray arrayWithCapacity:10];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    self.object = self.currentValue;
    if (self.fault) {
        self.params = nil;
    } else {
        self.params = self.currentValue;
    }
    self.parsingContext = nil;
    self.elementContext = nil;
    self.currentValue = nil;
}


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    [self.elementContext addObject:elementName];
    if ([self elementIsContextElement:elementName]) {
        [self.parsingContext addObject:[self parsingContextForElement:elementName]];
    } else if([elementName isEqualToString:RCXMLRPCDecoderFaultElement]){
        self.fault = YES;
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    RCXMLRPCParsingContext *context = self.currentParsingContext;
    if ([elementName isEqualToString:context.elementName]) {
        RCXMLRPCParsingContext *context = self.currentParsingContext;
        [self.parsingContext removeLastObject];
        self.currentValue = context.object;
    } else if([context isArray] && [elementName isEqualToString:RCXMLRPCDecoderValueElement]){
        [context addObject:self.currentValue];
    } else if([context isDictionary] && [elementName isEqualToString:RCXMLRPCDecoderMemberElement]){
        [context addObject:self.currentValue];
    }
    [self.elementContext removeLastObject];
    
}
// sent when an end tag is encountered. The various parameters are supplied as above.


- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    NSString *currentElement = self.currentElementContext;
    RCXMLRPCParsingContext *context = self.currentParsingContext;
    if ([self inContentElement]) {
        self.currentValue = [self parseCharactersInContext:string];
    } else if([currentElement isEqualToString:RCXMLRPCDecoderNameElement]){
        context.currentKey = string;
    }
}
// This returns the string of the characters encountered thus far. You may not necessarily get the longest character run. The parser reserves the right to hand these to the delegate as potentially many calls in a row to -parser:foundCharacters:

- (void)parser:(NSXMLParser *)parser foundIgnorableWhitespace:(NSString *)whitespaceString {
    
}
// The parser reports ignorable whitespace in the same way as characters it's found.

- (void)parser:(NSXMLParser *)parser foundComment:(NSString *)comment {
    
}
// A comment (Text in a <!-- --> block) is reported to the delegate as a single string

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock {
    
}
// this reports a CDATA block to the delegate as an NSData.


- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSLog(@"Parse error: %@", parseError);
}
// ...and this reports a fatal error to the delegate. The parser will stop parsing.

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError {
    
}
// If validation is on, this will report a fatal validation error to the delegate. The parser will stop parsing.

@end
