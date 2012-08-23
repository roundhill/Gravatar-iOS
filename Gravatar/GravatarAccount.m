//
//  GravatarAccount.m
//  Gravatar
//
//  Created by Beau Collins on 8/7/12.
//  Copyright (c) 2012 Beau Collins. All rights reserved.
//

#import "GravatarAccount.h"
#import "SFHFKeychainUtils.h"
#import "MD5Hasher.h"

NSString * const GravatarAccountSettingKey = @"GravatarUsername";
NSString * const GravatarAccountKeychainServiceName = @"GravatarService";

@interface GravatarAccount()

@property (nonatomic, weak) NSString *password;
@property (nonatomic, strong, readwrite) GravatarClient *client;
@property (nonatomic, strong, readwrite) NSArray *emails;

- (NSString*)emailHash;
@end

@implementation GravatarAccount

+ (GravatarAccount *)defaultAccount {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *email = [defaults stringForKey:GravatarAccountSettingKey];
    GravatarAccount *account = [[GravatarAccount alloc] initWithEmail:email];
    return account;
}

- (void)logOut {
    NSError *error;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:GravatarAccountSettingKey];
    [SFHFKeychainUtils deleteItemForUsername:self.emailHash
                              andServiceName:GravatarAccountKeychainServiceName
                                       error:&error];

}

- (BOOL)isConfigured {
    return self.email != nil && self.password != nil;
}

- (id)initWithEmail:(NSString *)email {
    if (self = [super init]) {
        
        self.client = [[GravatarClient alloc] initWithEmail:email andPassword:nil];
        
        
        // load password from keychain
        NSError *error;
        self.client.password = [SFHFKeychainUtils getPasswordForUsername:self.emailHash andServiceName:GravatarAccountKeychainServiceName error:&error];
        
        
    }
    return self;
}

- (NSString *)emailHash {
    if (self.email != nil) {
        return [MD5Hasher hashForEmail:self.email];
    } else {
        return nil;
    }
}

- (NSString *)email {
    return self.client.email;
}

- (void)setEmail:(NSString *)email {
    [[NSUserDefaults standardUserDefaults] setValue:email forKey:GravatarAccountSettingKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"Saved email; %@", email);
    self.client.email = email;
}

- (NSString *)password {
    return self.client.password;
}

- (void)setPassword:(NSString *)password {
    NSError *error;
    self.client.password = password;
    if (password == nil) {
        return;
    }
    [SFHFKeychainUtils storeUsername:self.emailHash andPassword:password forServiceName:GravatarAccountKeychainServiceName updateExisting:YES error:&error];
    // store password in keychain
    NSLog(@"Saved password: %@", error);

}


@end
