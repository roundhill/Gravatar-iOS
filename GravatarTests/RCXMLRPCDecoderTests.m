//
//  RCXMLRPCDecoder.m
//  Gravatar
//
//  Created by Beau Collins on 8/3/12.
//  Copyright (c) 2012 Beau Collins. All rights reserved.
//

#import "RCXMLRPCDecoderTests.h"
#import "RCXMLRPCDecoder.h"
#import "NSData+Base64.h"

@interface RCXMLRPCDecoderTests ()
@property (nonatomic, strong) RCXMLRPCDecoder *decoder;

@end

@implementation RCXMLRPCDecoderTests

- (NSData *)xml:(NSString *)name {
    NSBundle *testBundle = [NSBundle bundleForClass:[self class]];
    return [NSData dataWithContentsOfFile:[testBundle pathForResource:name ofType:@"xml"]];
    
}


-(void)setUp {
    self.decoder = [[RCXMLRPCDecoder alloc] init];
}

-(void)testDecodeSimpleResponse {
    [self.decoder decodeData:[self xml:@"response"]];
    STAssertEqualObjects([self.decoder params], @[@"South Dakota"], nil);
    
}

-(void)testDecodeAdvancedResponse {
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:2345];
    NSData *data = [@"you can't read this!" dataUsingEncoding:NSUTF8StringEncoding];
    [self.decoder decodeData:[self xml:@"response-complex"]];
    NSArray *expected = @[@5, date, data, @[@"Hello", @{@"Test":@3.4}], @{ @"Name":@"Finn", @"Age": @5, @"OK":@YES }];
    __block NSArray *params = self.decoder.params;
    [expected enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        STAssertEqualObjects([params objectAtIndex:idx], obj, nil);
    }];
}

-(void)testNegativeNumbers {
    id expected = @[@-9, @-10.25];
    [self.decoder decodeData:[self xml:@"response-numbers"]];
    STAssertEqualObjects(self.decoder.params, expected, nil);
}

-(void)testFaultResponse {
    [self.decoder decodeData:[self xml:@"response-fault"]];
    id expected = @{ @"faultCode" : @4, @"faultString": @"Too many parameters." };
    STAssertTrue([self.decoder isFault], nil);
    STAssertEqualObjects(self.decoder.object, expected, nil);
}

@end
