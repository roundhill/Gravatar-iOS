//
//  GravatarRequest.h
//  Gravatar
//
//  Created by Beau Collins on 8/6/12.
//  Copyright (c) 2012 Beau Collins. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const GravatarURL;
/*
-7	Use secure.gravatar.com
-8	Internal error
-9	Authentication error
-10	Method parameter missing
-11	Method parameter incorrect
-100	Misc error (see text)
*/

typedef enum GravatarErrorCode : NSInteger  {
    GravatarErrorCodeUseSecure          = -7,
    GravatarErrorCodeInternal           = -8,
    GravatarErrorCodeAuthentication     = -9,
    GravatarErrorCodeParameterMissing   = -10,
    GravatarErrorCodeParameterIncorrect = -11,
    GravatarErrorCodeMisc               = -100
} GravatarErrorCode;

@protocol GravatarRequestDelegate;

@interface GravatarRequest : NSObject
@property (nonatomic, strong) NSString *methodName;
@property (nonatomic, strong) NSArray *params;
@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong, readonly) NSString *emailHash;
@property (nonatomic, strong) NSNumber *expectedResponseLength;

+(NSURL*)URLWithHash:(NSString *)emailHash;
+(NSString *)hashForEmail:(NSString *)email;
-(id)initWithEmail:(NSString *)email;
-(void)sendWithDelegate:(id<GravatarRequestDelegate>)delegate;

@end

@protocol GravatarRequestDelegate <NSObject>

@optional

-(void)request:(GravatarRequest *)request didFailWithError:(NSError *)error;
-(void)request:(GravatarRequest *)request didFinishWithFault:(NSDictionary *)fault;
-(void)request:(GravatarRequest *)request didFinishWithParams:(NSArray *)params;

@end
