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


@interface GravatarClient : NSObject

@property (nonatomic, strong, readonly) NSMutableSet *requests;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *password;

-(id)initWithEmail:(NSString *)email andPassword:(NSString *)password;
-(GravatarRequest *)requestForMethod:(NSString *)method withArguments:(NSDictionary *)arguments;

#pragma mark - Gravatar API Methods
// Base API methods for making Gravatar XML-RPC calls
-(void)callMethod:(NSString *)method withArguments:(NSDictionary *)arguments onSucces:(void(^)(GravatarRequest* request, NSArray *params))successBlock onFailure:(void(^)(GravatarRequest* request, NSDictionary *fault))failureBlock;

// grav.exists check whether a hash has a gravatar
-(void)existsForHashes:(NSArray *)hashes onSuccess:(void(^)(GravatarRequest *request, NSArray *params))successBlock onFailure:(void(^)(GravatarRequest *request, NSDictionary *fault))failureBlock;

// grav.addresses get a list of addresses for this account
-(void)addressesOnSuccess:(void(^)(GravatarRequest *request, NSArray *params))successBlock onFailure:(void(^)(GravatarRequest *request, NSDictionary *fault))failureBlock;

// grav.userimages - return an array of userimages for this account
-(void)userimagesOnSuccess:(void(^)(GravatarRequest *request, NSArray *params))successBlock onFailure:(void(^)(GravatarRequest *request, NSDictionary *fault))failureBlock;

// grav.saveData - Save binary image data as a userimage for this account
-(void)saveData:(NSData *)data withRating:(GravatarClientImageRating)rating onSucces:(void(^)(GravatarRequest* request, NSArray *params))successBlock onFailure:(void(^)(GravatarRequest* request, NSDictionary *fault))failureBlock;

// grav.saveURL - Read an image via its URL and save that as a userimage for this account
-(void)saveUrl:(NSString *)url withRating:(GravatarClientImageRating)rating onSucces:(void(^)(GravatarRequest* request, NSArray *params))successBlock onFailure:(void(^)(GravatarRequest* request, NSDictionary *fault))failureBlock;

// grav.saveUserimage - use a userimage as a gravatar for one of more addresses on this account
-(void)saveUserimage:(NSString *)userimage forAddress:(NSArray *)addresses onSucces:(void(^)(GravatarRequest* request, NSArray *params))successBlock onFailure:(void(^)(GravatarRequest* request, NSDictionary *fault))failureBlock;

// grav.removeImage - remove the userimage associated with one or more email addresses
-(void)removeImageForAddresses:(NSArray *)addresses onSucces:(void(^)(GravatarRequest* request, NSArray *params))successBlock onFailure:(void(^)(GravatarRequest* request, NSDictionary *fault))failureBlock;

// grav.deleteUserimage - remove a userimage from the account and any email addresses with which it is associated
-(void)deleteUserimage:(NSString *)userimage onSucces:(void(^)(GravatarRequest* request, NSArray *params))successBlock onFailure:(void(^)(GravatarRequest* request, NSDictionary *fault))failureBlock;

// grav.test - a test function
-(void)testOnSucces:(void(^)(GravatarRequest* request, NSArray *params))successBlock onFailure:(void(^)(GravatarRequest* request, NSDictionary *fault))failureBlock;

@end
