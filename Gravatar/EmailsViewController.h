//
//  EmailsViewController.h
//  Gravatar
//
//  Created by Beau Collins on 8/7/12.
//  Copyright (c) 2012 Beau Collins. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GravatarAccount.h"

@protocol EmailsViewControllerDelegate;

@interface EmailsViewController : UITableViewController

@property (nonatomic, assign) id<EmailsViewControllerDelegate> delegate;
@property (nonatomic, strong) GravatarAccount *account;
@property (nonatomic, strong) NSArray *emails;

- (void)reloadAccount;

@end

@protocol EmailsViewControllerDelegate <NSObject>

- (void)emailViewController:(EmailsViewController*)controller didSelectEmail:(id)email;

@end
