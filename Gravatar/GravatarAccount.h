//
//  GravatarAccount.h
//  Gravatar
//
//  Created by Beau Collins on 8/7/12.
//  Copyright (c) 2012 Beau Collins. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GravatarClient.h"

extern NSString * const GravatarAccountSettingKey;
extern NSString * const GravatarAccountKeychainServiceName;

@interface GravatarAccount : NSObject

@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong, readonly) GravatarClient *client;
@property (nonatomic, strong, readonly) NSArray *emails;

+ (GravatarAccount *)defaultAccount;
- (id)initWithEmail:(NSString *)email;
- (void)setPassword:(NSString *)password;
- (BOOL)isConfigured;
- (void)logOut;

@end
