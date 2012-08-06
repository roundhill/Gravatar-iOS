//
//  GravatarClient.h
//  Gravatar
//
//  Created by Beau Collins on 8/6/12.
//  Copyright (c) 2012 Beau Collins. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GravatarRequest.h"

@interface GravatarClient : NSObject

@property (nonatomic, strong, readonly) NSMutableSet *requests;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *password;

-(id)initWithEmail:(NSString *)email andPassword:(NSString *)password;
-(GravatarRequest *)requestForMethod:(NSString *)method withArguments:(NSDictionary *)arguments;
-(void)callMethod:(NSString *)method withArguments:(NSDictionary *)arguments onSucces:(void(^)(GravatarRequest* request, NSArray *params))successBlock onFailure:(void(^)(GravatarRequest* request, NSDictionary *fault))failureBlock;


@end
