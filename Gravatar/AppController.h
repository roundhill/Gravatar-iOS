//
//  AppController.h
//  Gravatar
//
//  Created by Beau Collins on 8/14/12.
//  Copyright (c) 2012 Beau Collins. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoSelectionViewController.h"
#import "GravatarAccount.h"

@interface AppController : UIViewController
@property (nonatomic, strong) PhotoSelectionViewController *photosController;
@property (nonatomic, strong) GravatarAccount *account;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UINavigationBar *navigationBar;
@property (nonatomic, strong) UINavigationItem *accountNavigationItem;
@end
