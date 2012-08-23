//
//  GravatarTitleView.h
//  Gravatar
//
//  Created by Beau Collins on 8/20/12.
//  Copyright (c) 2012 Beau Collins. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GravatarAccount.h"
@interface GravatarTitleView : UIView

@property (nonatomic, strong) GravatarAccount *account;
@property (nonatomic, strong, readonly) UILabel *descriptionLabel;

@end
