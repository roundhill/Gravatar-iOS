//
//  GravatarClient.h
//  Gravatar
//
//  Created by Beau Collins on 8/6/12.
//  Copyright (c) 2012 Beau Collins. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GravatarRequest.h"

typedef enum GravatarClientImageRating : NSInteger  {
    GravatarClientImageRatingG   = 0,
    GravatarClientImageRatingPG  = 1,
    GravatarClientImageRatingR   = 2,
    GravatarClientImageRatingX   = 3
} GravatarClientImageRating;

extern NSString *const GravatarClientAuthenticationErrorNotification;
extern NSString *const GravatarClientFaultInfoKey;
extern NSString *const GravatarClientRequestInfoKey;

typedef void (^GravatarSuccessBlock)(GravatarRequest *request, NSArray *params);
typedef void (^GravatarFailureBlock)(GravatarRequest *request, NSDictionary *fault);
typedef void (^GravatarProgressBlock)(GravatarRequest *request, float progressPercent);

@interface GravatarClient : NSObject

@property (nonatomic, strong, readonly) NSMutableSet *requests;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *password;

-(id)initWithEmail:(NSString *)email andPassword:(NSString *)password;
-(GravatarRequest *)requestForMethod:(NSString *)method withArguments:(NSDictionary *)arguments;

#pragma mark - Gravatar API Methods
// Base API methods for making Gravatar XML-RPC calls
-(GravatarRequest *)callMethod:(NSString *)method withArguments:(NSDictionary *)arguments onSuccess:(GravatarSuccessBlock)successBlock onFailure:(GravatarFailureBlock)failureBlock;

// grav.exists check whether a hash has a gravatar
-(GravatarRequest *)existsForHashes:(NSArray *)hashes onSuccess:(GravatarSuccessBlock)successBlock onFailure:(GravatarFailureBlock)failureBlock;

// grav.addresses get a list of addresses for this account
-(GravatarRequest *)addressesOnSuccess:(GravatarSuccessBlock)successBlock onFailure:(GravatarFailureBlock)failureBlock;

// grav.userimages - return an array of userimages for this account
-(GravatarRequest *)userimagesOnSuccess:(GravatarSuccessBlock)successBlock onFailure:(GravatarFailureBlock)failureBlock;

// grav.saveData - Save binary image data as a userimage for this account
-(GravatarRequest *)saveData:(NSData *)data withRating:(GravatarClientImageRating)rating onProgress:(GravatarProgressBlock)progressBlock onSuccess:(GravatarSuccessBlock)successBlock onFailure:(GravatarFailureBlock)failureBlock;

// grav.saveURL - Read an image via its URL and save that as a userimage for this account
-(GravatarRequest *)saveUrl:(NSString *)url withRating:(GravatarClientImageRating)rating onSuccess:(GravatarSuccessBlock)successBlock onFailure:(GravatarFailureBlock)failureBlock;

// grav.saveUserimage - use a userimage as a gravatar for one of more addresses on this account
-(GravatarRequest *)saveUserimage:(NSString *)userimage forAddress:(NSArray *)addresses onSuccess:(GravatarSuccessBlock)successBlock onFailure:(GravatarFailureBlock)failureBlock;

// grav.removeImage - remove the userimage associated with one or more email addresses
-(GravatarRequest *)removeImageForAddresses:(NSArray *)addresses onSuccess:(GravatarSuccessBlock)successBlock onFailure:(GravatarFailureBlock)failureBlock;

// grav.deleteUserimage - remove a userimage from the account and any email addresses with which it is associated
-(GravatarRequest *)deleteUserimage:(NSString *)userimage onSuccess:(GravatarSuccessBlock)successBlock onFailure:(GravatarFailureBlock)failureBlock;

// grav.test - a test function
-(GravatarRequest *)testOnSuccess:(GravatarSuccessBlock)successBlock onFailure:(GravatarFailureBlock)failureBlock;

@end
