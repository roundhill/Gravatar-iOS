//
//  GravatarImageView.h
//  Gravatar
//
//  Created by Beau Collins on 8/6/12.
//  Copyright (c) 2012 Beau Collins. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GravatarImageView : UIView
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) NSURL *imageURL;

- (void)reload;
- (void)setEmail:(NSString *)email;

@end
