//
//  AddAccountViewController.h
//  Gravatar
//
//  Created by Beau Collins on 8/6/12.
//  Copyright (c) 2012 Beau Collins. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GravatarAccount.h"

@protocol AddAccountViewControllerDelegate;

@interface AddAccountViewController : UIViewController

@property (nonatomic, weak) id<AddAccountViewControllerDelegate> delegate;
@property (nonatomic, strong) GravatarAccount *account;

@end

@protocol AddAccountViewControllerDelegate <NSObject>

- (void)addAccountViewControllerDidLogIn:(AddAccountViewController *)viewController;

@end
