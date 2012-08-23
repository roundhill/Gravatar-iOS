//
//  GravatarRequest.m
//  Gravatar
//
//  Created by Beau Collins on 8/6/12.
//  Copyright (c) 2012 Beau Collins. All rights reserved.
//

#import "GravatarRequest.h"
#import "RCXMLRPCEncoder.h"
#import "RCXMLRPCDecoder.h"
#import "MD5Hasher.h"

NSString * const GravatarURL = @"https://secure.gravatar.com/xmlrpc";

@interface GravatarRequest () <NSURLConnectionDataDelegate>

@property (nonatomic, strong, readwrite) NSString *emailHash;
@property (nonatomic, strong) NSMutableData *responseData;
@end

@implementation GravatarRequest

+(NSURL *)URLWithHash:(NSString *)emailHash {
    NSString *url = [NSString stringWithFormat:@"%@?user=%@", GravatarURL, emailHash];
    return [NSURL URLWithString:url];
}

+(NSString *)hashForEmail:(NSString *)email {
    return [MD5Hasher hashForString:email];
}

-(id)initWithEmail:(NSString *)email {
    if (self = [super init]) {
        self.email = email;
    }
    return self;
}

-(void)setEmail:(NSString *)email {
    if (self.email != email) {
        _email = email;
        // generate the email hash
        self.emailHash = [GravatarRequest hashForEmail:self.email];
    }
}

-(void)sendWithDelegate:(id)delegate {
    self.delegate = delegate;
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[GravatarRequest URLWithHash:self.emailHash]];
    
    [request setValue:@"text/xml" forHTTPHeaderField:@"Content Type"];
    [request setValue:@"gravinator" forHTTPHeaderField:@"User-Agent"];
    [request setHTTPMethod:@"POST"];
    
    [request setHTTPBody:[RCXMLRPCEncoder dataForRequestMethod:self.methodName andParams:self.params]];
    NSURLConnection *connection = [[NSURLConnection alloc]
                                   initWithRequest:request
                                   delegate:self
                                   startImmediately:NO];
    
    [connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    NSLog(@"Calling remote method: %@ (%@)", self.methodName, request.URL);
    [connection start];
}

#pragma mark - NSURLConnectionDelegate Methods

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    
    if ([self.delegate respondsToSelector:@selector(request:didSendBodyData:ofExpected:)]) {
        [self.delegate request:self didSendBodyData:totalBytesWritten ofExpected:totalBytesExpectedToWrite];
    }
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSLog(@"Received response from server: %d (%@)", httpResponse.statusCode, self.methodName);
    self.expectedResponseLength = [NSNumber numberWithLongLong:response.expectedContentLength];
    self.responseData = [[NSMutableData alloc] initWithCapacity:1024];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.delegate request:self didFailWithError:error];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    // parse the data and notify the delegate
    RCXMLRPCDecoder *decoder = [[RCXMLRPCDecoder alloc] init];
    [decoder decodeData:self.responseData];
    if (decoder.isFault) {
        if ([self.delegate respondsToSelector:@selector(request:didFinishWithFault:)]) {
            [self.delegate request:self didFinishWithFault:decoder.object];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(request:didFinishWithParams:)]) {
            [self.delegate request:self didFinishWithParams:decoder.params];
        }
    }
    
}

@end
