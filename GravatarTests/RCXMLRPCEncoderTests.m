//
//  RCXMLRPCEncoderTests.m
//  Gravatar
//
//  Created by Beau Collins on 8/3/12.
//  Copyright (c) 2012 Beau Collins. All rights reserved.
//

#import "RCXMLRPCEncoderTests.h"
#import "RCXMLRPCEncoder.h"

@implementation RCXMLRPCEncoderTests

- (NSString *)xml:(NSString *)name {
    NSBundle *testBundle = [NSBundle bundleForClass:[self class]];
    return [NSString stringWithContentsOfFile:[testBundle pathForResource:name ofType:@"xml"] encoding:NSUTF8StringEncoding error:nil];
    
}

- (void)testStringFragment {
    NSString *str = @"Hello World";
    NSString *fragment = [RCXMLRPCEncoder fragmentForString:str];
    STAssertEqualObjects(fragment, @"<string>Hello World</string>", nil);
    
}

- (void)testFloatFragment {
    float flt = 10.5f;
    NSString *fragment = [RCXMLRPCEncoder fragmentForFloat:flt];
    STAssertEqualObjects(fragment, @"<double>10.5</double>", nil);
}

- (void)testIntFragment {
    int num = 1024;
    NSString *fragment = [RCXMLRPCEncoder fragmentForInt:num];
    STAssertEqualObjects(fragment, @"<i4>1024</i4>", nil);
}

- (void)testBooleanFragment {
    NSString *trueFragment = [RCXMLRPCEncoder fragmentForBool:YES];
    STAssertEqualObjects(trueFragment, @"<boolean>1</boolean>", nil);

    NSString *falseFragment = [RCXMLRPCEncoder fragmentForBool:NO];
    STAssertEqualObjects(falseFragment, @"<boolean>0</boolean>", nil);

}

- (void)testDateFragment {
    // 2001-01-01 00:39:05 +0000
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:2345];
    NSString *fragment = [RCXMLRPCEncoder fragmentForDate:date];
    STAssertEqualObjects(fragment, @"<dateTime.iso8601>20010101T00:39:05</dateTime.iso8601>", nil);
}

- (void)testNumberFragment {
    NSNumber *num = [NSNumber numberWithInt:5];
    STAssertEqualObjects([RCXMLRPCEncoder fragmentForNumber:num], @"<i4>5</i4>", @"Testing int NSNumber");
    
    num = [NSNumber numberWithFloat:10.f];
    STAssertEqualObjects([RCXMLRPCEncoder fragmentForNumber:num], @"<double>10</double>", @"Testing float NSNumber");
}

- (void)testParamFragment {
    NSArray *param = @[@"Hello World"];
    NSString *expected = [self xml:@"params"];
    
    STAssertEqualObjects([RCXMLRPCEncoder fragmentForParams:param], expected, nil);
    
}

- (void)testArrayFragment {
    NSArray *array = @[@"hello world", @10, @100.25];
    NSString *expected = [self xml:@"array"];

    STAssertEqualObjects([RCXMLRPCEncoder fragmentForArray:array], expected, nil);
}

- (void)testStructFragment {
    NSDictionary *dict = @{ @"name" : @"Finn", @"age": @5 };
    NSString *expected = [self xml:@"dict"];
    
    STAssertEqualObjects([RCXMLRPCEncoder fragmentForDictionary:dict], expected, nil);
}

- (void)testDataFragment {
    NSBundle *fixtureBundle = [NSBundle bundleForClass:[self class]];
    NSData *data = [NSData dataWithContentsOfFile:[fixtureBundle pathForResource:@"data" ofType:@"txt"  ]];
    
    NSString *fragment = [RCXMLRPCEncoder fragmentForData:data];
    
    STAssertEqualObjects(fragment, @"<base64>SGVsbG8gV29ybGQh</base64>", nil);
    
}

- (void)testDataInStruct {
    NSString *expected = [self xml:@"datadict"];
    NSBundle *fixtureBundle = [NSBundle bundleForClass:[self class]];
    NSData *data = [NSData dataWithContentsOfFile:[fixtureBundle pathForResource:@"data" ofType:@"txt"  ]];
    NSDictionary *dict = @{ @"data" : data };
    NSString *fragment = [RCXMLRPCEncoder fragmentForDictionary:dict];
    
    STAssertEqualObjects(fragment, expected, nil);

}

- (void)testMethodCall {
    NSString *request = [RCXMLRPCEncoder stringForRequestMethod:@"add" andParams:@[@2,@2, @{@"hello":@"world"}, @[@1,@2.5]]];
    
    NSString *expected = [self xml:@"request"];
    
    STAssertEqualObjects(request, expected, nil);
}


@end
