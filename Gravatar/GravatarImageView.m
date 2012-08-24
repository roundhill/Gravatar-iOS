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
- (void)requestImage;
- (NSURL *)gravatarURLForEmail:(NSString *)email;
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

- (void)reload {
    NSLog(@"Reloading image");
    [self requestImage];
}

- (void)drawRect:(CGRect)rect {
    self.layer.cornerRadius = 2.f;
    self.layer.masksToBounds = YES;
}

- (NSURL *)gravatarURLForEmail:(NSString *)email {
    if (email == nil) {
        return nil;
    }
    NSString *url = [NSString stringWithFormat:kGravatarURLFormat, [MD5Hasher hashForEmail:email]];
    return [NSURL URLWithString:url];
    
}

- (void)requestImage {
    NSURL *url = self.imageURL;
    if (url == nil) {
        return;
    }
    NSURLRequest *request = [NSURLRequest
                             requestWithURL:url
                             cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                             timeoutInterval:0.f];
        
    NSURLConnection *connection = [[NSURLConnection alloc]
                                   initWithRequest:request
                                   delegate:self
                                   startImmediately:NO];
    
    [connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    
    [UIView animateWithDuration:0.2f animations:^{
        self.imageView.alpha = 0.f;
    }];
    [connection start];
}

- (void)setEmail:(NSString *)email {
    self.imageURL = [self gravatarURLForEmail:email];
}

- (void)setImageURL:(NSURL *)imageURL {
    if (![[imageURL absoluteString] isEqualToString:[self.imageURL absoluteString]]) {
        _imageURL = imageURL;
        [self requestImage];
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
