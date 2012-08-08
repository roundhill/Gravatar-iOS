//
//  GravatarClient.m
//  Gravatar
//
//  Created by Beau Collins on 8/6/12.
//  Copyright (c) 2012 Beau Collins. All rights reserved.
//

#import "GravatarClient.h"
#import "RCXMLRPCDecoder.h"

NSString *const GravatarClientAuthenticationErrorNotification = @"Gravatar Authentication Error";
NSString *const GravatarClientFaultInfoKey = @"Fault";
NSString *const GravatarClientRequestInfoKey = @"Request";

@protocol GravatarClientRequestDelegate;

@interface GravatarClientRequest : NSObject <GravatarRequestDelegate>
@property (nonatomic, copy) void(^successBlock)(GravatarRequest *request, NSArray *params);
@property (nonatomic, copy) void(^failBlock)(GravatarRequest *request, NSDictionary *fault);
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

-(void)callMethod:(NSString *)method withArguments:(NSDictionary *)arguments onSucces:(void(^)(GravatarRequest* request, NSArray *params))successBlock onFailure:(void(^)(GravatarRequest* request, NSDictionary *fault))failureBlock {
    
    // create a delegate with the given blocks
    GravatarClientRequest *clientRequest = [GravatarClientRequest requestWithClient:self];
    clientRequest.failBlock = failureBlock;
    clientRequest.successBlock = successBlock;
    clientRequest.delegate = self;
    
    GravatarRequest *request = [self requestForMethod:method withArguments:arguments];
    
    [self.requests addObject:clientRequest];
    [request sendWithDelegate:clientRequest];
}

- (void)addressesOnSuccess:(void (^)(GravatarRequest *, NSArray *))successBlock onFailure:(void (^)(GravatarRequest *, NSDictionary *))failureBlock {
    
    [self callMethod:@"addresses" withArguments:nil onSucces:successBlock onFailure:failureBlock];
    
}

- (void)existsForHashes:(NSArray *)hashes onSuccess:(void (^)(GravatarRequest *, NSArray *))successBlock onFailure:(void (^)(GravatarRequest *, NSDictionary *))failureBlock {
    
    [self callMethod:@"exists" withArguments:@{ @"hashes": hashes } onSucces:successBlock onFailure:failureBlock];
    
}

- (void)userimagesOnSuccess:(void (^)(GravatarRequest *, NSArray *))successBlock onFailure:(void (^)(GravatarRequest *, NSDictionary *))failureBlock {
    [self callMethod:@"userimages" withArguments:nil onSucces:successBlock onFailure:failureBlock];
}

- (void)saveData:(NSData *)data withRating:(GravatarClientImageRating)rating onSucces:(void (^)(GravatarRequest *, NSArray *))successBlock onFailure:(void (^)(GravatarRequest *, NSDictionary *))failureBlock {
    
    NSNumber *gravatarRating = [NSNumber numberWithInt:rating];
    NSDictionary *args = @{ @"data" : data, @"rating": gravatarRating };
    [self callMethod:@"saveData" withArguments:args onSucces:successBlock onFailure:failureBlock];
    
}

- (void)testOnSucces:(void (^)(GravatarRequest *, NSArray *))successBlock onFailure:(void (^)(GravatarRequest *, NSDictionary *))failureBlock {
    [self callMethod:@"test" withArguments:nil onSucces:successBlock onFailure:failureBlock];
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

