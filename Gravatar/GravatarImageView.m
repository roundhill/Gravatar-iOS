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
        self.imageView = [[UIImageView alloc] initWithFrame:frame];
        self.imageView.hidden = YES;
        [self addSubview:self.imageView];
    }
    return self;
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
    [connection start];
}

- (void)setEmail:(NSString *)email {
    if (_email != email) {
        _email = email;
        self.imageView.hidden = YES;
        [self requestGravatar];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    self.layer.cornerRadius = 10.f;
}
*/

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.imageView.hidden = YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.imageView.hidden = YES;
    self.imageData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.imageData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    self.imageView.image = [UIImage imageWithData:self.imageData];
    self.imageView.hidden = NO;
}

@end
