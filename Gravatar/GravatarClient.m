//
//  GravatarClient.m
//  Gravatar
//
//  Created by Beau Collins on 8/6/12.
//  Copyright (c) 2012 Beau Collins. All rights reserved.
//

#import "GravatarClient.h"


@protocol GravatarClientRequestDelegate;

@interface GravatarClientRequest : NSObject <GravatarRequestDelegate>
@property (nonatomic, copy) void(^successBlock)(GravatarRequest *request, NSArray *params);
@property (nonatomic, copy) void(^failBlock)(GravatarRequest *request, NSDictionary *fault);
@property (nonatomic, assign) id<GravatarClientRequestDelegate> delegate;
@end

@protocol GravatarClientRequestDelegate <NSObject>

-(void)clientRequestDidFinish:(GravatarClientRequest *)request;

@end


@interface GravatarClient () <GravatarClientRequestDelegate>
@property (nonatomic, strong, readwrite) NSMutableSet *requests;
@end

@implementation GravatarClient

-(id)initWithEmail:(NSString *)email andPassword:(NSString *)password {
    
    if (self = [super init]) {
        self.email = email;
        self.password = password;
        self.requests = [NSMutableSet set];
    }
    
    return self;
    
}

-(GravatarRequest *)requestForMethod:(NSString *)method withArguments:(NSDictionary *)arguments {
    
    GravatarRequest *request = [[GravatarRequest alloc] initWithEmail:self.email];
    request.methodName = [NSString stringWithFormat:@"grav.%@", method];
    // new dictionary with a password
    NSMutableDictionary *args = [NSMutableDictionary dictionaryWithDictionary:arguments];
    [args setObject:self.password forKey:@"password"];
    [args enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
       
    }];
    request.params = @[ args ];
    
    return request;
    
}

-(void)callMethod:(NSString *)method withArguments:(NSDictionary *)arguments onSucces:(void(^)(GravatarRequest* request, NSArray *params))successBlock onFailure:(void(^)(GravatarRequest* request, NSDictionary *fault))failureBlock {
    
    // create a delegate with the given blocks
    GravatarClientRequest *clientRequest = [[GravatarClientRequest alloc] init];
    clientRequest.failBlock = failureBlock;
    clientRequest.successBlock = successBlock;
    clientRequest.delegate = self;
    
    GravatarRequest *request = [self requestForMethod:method withArguments:arguments];
    
    [self.requests addObject:clientRequest];
    [request sendWithDelegate:clientRequest];
}

- (void)clientRequestDidFinish:(GravatarClientRequest *)clientRequest {
    [self.requests removeObject:clientRequest];
}

@end


@implementation GravatarClientRequest

- (void)request:(GravatarRequest *)request didFinishWithFault:(NSDictionary *)fault {
    if (self.failBlock) {
        self.failBlock(request, fault);
    }
    [self.delegate clientRequestDidFinish:self];
}

- (void)request:(GravatarRequest *)request didFinishWithParams:(NSArray *)params {
    if (self.successBlock) {
        self.successBlock(request, params);
    }
    [self.delegate clientRequestDidFinish:self];
}

@end

