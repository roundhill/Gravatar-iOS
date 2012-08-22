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
NSString * const GravatarAccountStateChangeNotification = @"Gravatar Account State Changed";
NSString * const GravatarAccountUploadProgressNotification = @"Gravatar Account Upload Progress";

@interface GravatarAccount()

@property (nonatomic, weak) NSString *password;
@property (nonatomic, strong, readwrite) GravatarClient *client;
@property (nonatomic, strong, readwrite) NSArray *emails;
@property (nonatomic, readwrite) float uploadProgressPercent;

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
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
               selector:@selector(failedAuth:)
                   name:GravatarClientAuthenticationErrorNotification
                 object:self.client];

        
        // load password from keychain
        NSError *error;
        self.client.password = [SFHFKeychainUtils getPasswordForUsername:self.emailHash andServiceName:GravatarAccountKeychainServiceName error:&error];
        _accountState = GravatarAccountStateInitialized;
                
        if (!self.isConfigured) {
            self.accountState = GravatarAccountStateLoggedOut;
        }
        
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

}

- (void)setAccountState:(GravatarAccountState)accountState {
    if (_accountState != accountState) {
        _accountState = accountState;
        [[NSNotificationCenter defaultCenter] postNotificationName:GravatarAccountStateChangeNotification object:self];
    }
}

- (void)setUploadProgressPercent:(float)uploadProgressPercent {
    if (_uploadProgressPercent != uploadProgressPercent) {
        _uploadProgressPercent = uploadProgressPercent;
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:GravatarAccountUploadProgressNotification
         object:self];
        
    }
}

- (void)loadEmails {
    if (!self.isConfigured) {
        self.accountState = GravatarAccountStateLoggedOut;
        return;
    }
    self.accountState = GravatarAccountStateLoading;
    [self.client addressesOnSuccess:^(GravatarRequest *request, NSArray *params) {
        NSDictionary *addressSettings = [params objectAtIndex:0];
        self.emails = [addressSettings allKeys];
        self.accountState = GravatarAccountStateIdle;
    } onFailure:nil];
    
}

- (void)saveImage:(UIImage *)image forEmails:(NSArray *)emails {
    NSData *data = UIImageJPEGRepresentation(image, 0.9f);
    self.accountState = GravatarAccountStateUploading;
    NSLog(@"Saving for emails: %@", emails);
    self.uploadProgressPercent = 0.f;
    [self.client saveData:data withRating:GravatarClientImageRatingG onProgress:^(GravatarRequest *request, float progress) {
        self.uploadProgressPercent = progress;
    } onSuccess:^(GravatarRequest *request, NSArray *params) {
        NSLog(@"Uploaded data: %@", params);
        self.uploadProgressPercent = 1.f;
        // now set the emails addresses to the given avatar
        NSString *userimage = (NSString *)[params objectAtIndex:0];
        NSLog(@"Set for emails: %@", emails);
        [self.client useUserimage:userimage forAddresses:emails onSuccess:^(GravatarRequest *request, NSArray *params) {
            NSLog(@"Use image: %@", params);
            self.accountState = GravatarAccountStateIdle;
        } onFailure:^(GravatarRequest *request, NSDictionary *fault) {
            NSLog(@"Fault: %@", fault);
            self.accountState = GravatarAccountStateIdle;
        }];
    } onFailure:^(GravatarRequest *request, NSDictionary *fault) {
        NSLog(@"Failed to upload data: %@", fault);
        self.uploadProgressPercent = 0.f;
    }];

}

- (void)saveImage:(UIImage *)image forEmailsAtIndexes:(NSIndexSet *)emailIndexes {
    NSArray *emails = [self.emails objectsAtIndexes:emailIndexes];
    [self saveImage:image forEmails:emails];
}

- (void)failedAuth:(NSNotification *)notification {
    self.accountState = GravatarAccountStateLoggedOut;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %@ state:%d>", [self class], self.email, self.accountState, nil];
}


@end
