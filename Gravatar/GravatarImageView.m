//
//  GravatarImageView.m
//  Gravatar
//
//  Created by Beau Collins on 8/6/12.
//  Copyright (c) 2012 Beau Collins. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "GravatarImageView.h"
#import "MD5Hasher.h"

#define kGravatarURLFormat @"https://secure.gravatar.com/avatar/%@"

@interface GravatarImageView () <NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSMutableData *imageData;
- (void)requestGravatar;

@end

@implementation GravatarImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.imageView.alpha = 0.f;
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.imageView];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    self.layer.cornerRadius = 2.f;
    self.layer.masksToBounds = YES;
}

- (NSURL *)gravatarURL {
    if (self.email == nil) {
        return nil;
    }
    NSString *url = [NSString stringWithFormat:kGravatarURLFormat, [MD5Hasher hashForEmail:self.email]];
    return [NSURL URLWithString:url];
    
}

- (void)requestGravatar {
    NSURLRequest *request = [NSURLRequest requestWithURL:self.gravatarURL];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [UIView animateWithDuration:0.2f animations:^{
        self.imageView.alpha = 0.f;
    }];
    [connection start];
}

- (void)setEmail:(NSString *)email {
    if (_email != email) {
        _email = email;
        [self requestGravatar];
    }
}

- (void)layoutSubviews {
    self.imageView.frame = self.bounds;
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.imageView.alpha = 0.f;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.imageData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.imageData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    self.imageView.image = [UIImage imageWithData:self.imageData];
    [UIView animateWithDuration:0.2f animations:^{
        self.imageView.alpha = 1.f;
    }];
}

@end
