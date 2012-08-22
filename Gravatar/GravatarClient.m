//
//  GravatarClient.m
//  Gravatar
//
//  Created by Beau Collins on 8/6/12.
//  Copyright (c) 2012 Beau Collins. All rights reserved.
//

#import "GravatarClient.h"
#import "RCXMLRPCDecoder.h"
#import "NSData+Base64.h"

NSString *const GravatarClientAuthenticationErrorNotification = @"Gravatar Authentication Error";
NSString *const GravatarClientFaultInfoKey = @"Fault";
NSString *const GravatarClientRequestInfoKey = @"Request";

@protocol GravatarClientRequestDelegate;

@interface GravatarClientRequest : NSObject <GravatarRequestDelegate>
@property (nonatomic, copy) GravatarSuccessBlock successBlock;
@property (nonatomic, copy) GravatarFailureBlock failBlock;
@property (nonatomic, copy) GravatarProgressBlock progressBlock;
@property (nonatomic, assign) id<GravatarClientRequestDelegate> delegate;
@property (nonatomic, strong) GravatarClient *client;

+ (GravatarClientRequest *)requestWithClient:(GravatarClient *)client;

@end

@protocol GravatarClientRequestDelegate <NSObject>

-(void)clientRequestDidFinish:(GravatarClientRequest *)request;

@end


@interface GravatarClient () <GravatarClientRequestDelegate>
@property (nonatomic, strong, readwrite) NSMutableSet *requests;

@end

#pragma mark - GravatarClient

@implementation GravatarClient

-(id)initWithEmail:(NSString *)email andPassword:(NSString *)password {
    
    if (self = [super init]) {
        self.email = email;
        self.password = password;
        self.requests = [NSMutableSet set];
    }
    
    return self;
    
}

#pragma mark - GravatarRequest builder

-(GravatarRequest *)requestForMethod:(NSString *)method withArguments:(NSDictionary *)arguments {
    
    GravatarRequest *request = [[GravatarRequest alloc] initWithEmail:self.email];
    request.methodName = [NSString stringWithFormat:@"grav.%@", method];
    // new dictionary with a password
    NSMutableDictionary *args = [NSMutableDictionary dictionaryWithDictionary:arguments];
    if (self.password != nil) {
        [args setObject:self.password forKey:@"password"];
    }
    [args enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
       
    }];
    request.params = @[ args ];
    
    return request;
    
}

#pragma mark - Gravatar API Methods

-(GravatarRequest *)callMethod:(NSString *)method withArguments:(NSDictionary *)arguments onSuccess:(GravatarSuccessBlock)successBlock onFailure:(GravatarFailureBlock)failureBlock {
    
    return [self callMethod:method withArguments:arguments onSuccess:successBlock onProgress:nil onFailure:failureBlock];
}

-(GravatarRequest *)callMethod:(NSString *)method withArguments:(NSDictionary *)arguments onSuccess:(GravatarSuccessBlock)successBlock onProgress:(GravatarProgressBlock)progressBlock onFailure:(GravatarFailureBlock)failureBlock {
    
    // create a delegate with the given blocks
    GravatarClientRequest *clientRequest = [GravatarClientRequest requestWithClient:self];
    clientRequest.failBlock = failureBlock;
    clientRequest.progressBlock = progressBlock;
    clientRequest.successBlock = successBlock;
    clientRequest.delegate = self;
    
    GravatarRequest *request = [self requestForMethod:method withArguments:arguments];
    
    [self.requests addObject:clientRequest];
    [request sendWithDelegate:clientRequest];
    return request;
}

- (GravatarRequest *)existsForHashes:(NSArray *)hashes onSuccess:(GravatarSuccessBlock)successBlock onFailure:(GravatarFailureBlock)failureBlock {
    return [self callMethod:@"exists" withArguments:@{ @"hashes": hashes } onSuccess:successBlock onFailure:failureBlock];
    
}

- (GravatarRequest *)addressesOnSuccess:(GravatarSuccessBlock)successBlock onFailure:(GravatarFailureBlock)failureBlock {
    
    return [self callMethod:@"addresses" withArguments:nil onSuccess:successBlock onFailure:failureBlock];
    
}

- (GravatarRequest *)userimagesOnSuccess:(GravatarSuccessBlock)successBlock onFailure:(GravatarFailureBlock)failureBlock {
    return [self callMethod:@"userimages" withArguments:nil onSuccess:successBlock onFailure:failureBlock];
}

- (GravatarRequest *)saveData:(NSData *)data withRating:(GravatarClientImageRating)rating onProgress:(GravatarProgressBlock)progressBlock onSuccess:(GravatarSuccessBlock)successBlock onFailure:(GravatarFailureBlock)failureBlock {
    NSNumber *gravatarRating = [NSNumber numberWithInt:rating];
    NSString *dataString = [data base64EncodedString];
    NSDictionary *args = @{ @"data" : dataString, @"rating": gravatarRating };
    return [self callMethod:@"saveData" withArguments:args onSuccess:successBlock onProgress:progressBlock onFailure:failureBlock];
}

- (GravatarRequest *)saveUrl:(NSString *)url withRating:(GravatarClientImageRating)rating onSuccess:(GravatarSuccessBlock)successBlock onFailure:(GravatarFailureBlock)failureBlock {
    NSNumber *gravatarRating = [NSNumber numberWithInt:rating];
    return [self callMethod:@"saveUrl" withArguments:@{@"url":url, @"rating":gravatarRating} onSuccess:successBlock onFailure:failureBlock];
}

- (GravatarRequest *)useUserimage:(NSString *)userimage forAddresses:(NSArray *)addresses onSuccess:(GravatarSuccessBlock)successBlock onFailure:(GravatarFailureBlock)failureBlock {
    return [self callMethod:@"useUserimage" withArguments:@{@"userimage":userimage, @"addresses":addresses} onSuccess:successBlock onFailure:failureBlock];
}

- (GravatarRequest *)removeImageForAddresses:(NSArray *)addresses onSuccess:(GravatarSuccessBlock)successBlock onFailure:(GravatarFailureBlock)failureBlock {
    return [self callMethod:@"removeUserimage" withArguments:@{@"addresses":addresses} onSuccess:successBlock onFailure:failureBlock];
}

- (GravatarRequest *)deleteUserimage:(NSString *)userimage onSuccess:(GravatarSuccessBlock)successBlock onFailure:(GravatarFailureBlock)failureBlock {
    return [self callMethod:@"deleteUserimage" withArguments:@{@"userimage":userimage} onSuccess:successBlock onFailure:failureBlock];
}

- (GravatarRequest *)testOnSuccess:(GravatarSuccessBlock)successBlock onFailure:(GravatarFailureBlock)failureBlock {
    return [self callMethod:@"test" withArguments:nil onSuccess:successBlock onFailure:failureBlock];
}

# pragma mark - Client Request management

- (void)clientRequestDidFinish:(GravatarClientRequest *)clientRequest {
    [self.requests removeObject:clientRequest];
}

@end


@implementation GravatarClientRequest

+ (GravatarClientRequest *)requestWithClient:(GravatarClient *)client {
    GravatarClientRequest *request = [[GravatarClientRequest alloc] init];
    request.client = client;
    return request;
}

- (void)request:(GravatarRequest *)request didSendBodyData:(NSInteger)totalBytesWritten ofExpected:(NSInteger)expectedTotalBytes {
    if (self.progressBlock != nil) {
        self.progressBlock(request, (float)totalBytesWritten/(float)expectedTotalBytes);
    }
}

- (void)request:(GravatarRequest *)request didFailWithError:(NSError *)error {
    self.client = nil;
    [self.delegate clientRequestDidFinish:self];
}

- (void)request:(GravatarRequest *)request didFinishWithFault:(NSDictionary *)fault {
    NSNumber *errorCode = [fault objectForKey:RCXMLRPCFaultErrorCodeKey];
    if ([errorCode integerValue] == GravatarErrorCodeAuthentication) {
        NSDictionary *userInfo = @{
        GravatarClientFaultInfoKey: fault,
        GravatarClientRequestInfoKey: request
        };
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:GravatarClientAuthenticationErrorNotification
                          object:self.client
                        userInfo:userInfo];
    }
    if (self.failBlock) {
        self.failBlock(request, fault);
    }
    [self.delegate clientRequestDidFinish:self];
    self.client = nil;
}

- (void)request:(GravatarRequest *)request didFinishWithParams:(NSArray *)params {
    if (self.successBlock) {
        self.successBlock(request, params);
    }
    [self.delegate clientRequestDidFinish:self];
    self.client = nil;
}

@end

