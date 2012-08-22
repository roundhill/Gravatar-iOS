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
extern NSString * const GravatarAccountStateChangeNotification;
extern NSString * const GravatarAccountUploadProgressNotification;

typedef enum GravatarAccountState : NSInteger  {
    GravatarAccountStateInitialized  = -1,
    GravatarAccountStateLoggedOut    = 0, // not signed in
    GravatarAccountStateLoading      = 1, // updating emails grav.addresses
    GravatarAccountStateIdle         = 2, // signed in not doing anything
    GravatarAccountStateUploading    = 3  // uploading gravatar
} GravatarAccountState;


@interface GravatarAccount : NSObject

@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong, readonly) NSArray *emails;
@property (nonatomic, strong, readonly) GravatarClient *client;
@property (nonatomic) GravatarAccountState accountState;
@property (nonatomic, readonly) float uploadProgressPercent;

+ (GravatarAccount *)defaultAccount;
- (id)initWithEmail:(NSString *)email;
- (void)setPassword:(NSString *)password;
- (BOOL)isConfigured;
- (void)logOut;
- (void)loadEmails;
- (void)saveImage:(UIImage *)image forEmails:(NSArray *)emails;
- (void)saveImage:(UIImage *)image forEmailsAtIndexes:(NSIndexSet *)emailIndexes;
@end
