//
//  GravatarRequest.h
//  Gravatar
//
//  Created by Beau Collins on 8/6/12.
//  Copyright (c) 2012 Beau Collins. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GravatarRequestDelegate;

@interface GravatarRequest : NSObject
@property (nonatomic, strong) NSString *methodName;
@property (nonatomic, strong) NSArray *params;
@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong, readonly) NSString *emailHash;

+(NSURL*)URLWithHash:(NSString *)emailHash;
+(NSString *)hashForEmail:(NSString *)email;
-(id)initWithEmail:(NSString *)email;
-(void)sendWithDelegate:(id<GravatarRequestDelegate>)delegate;

@end

@protocol GravatarRequestDelegate <NSObject>

@optional

-(void)request:(GravatarRequest *)request didFinishWithFault:(NSDictionary *)fault;
-(void)request:(GravatarRequest *)request didFinishWithParams:(NSArray *)params;

@end
