//
//  AppController.m
//  Gravatar
//
//  Created by Beau Collins on 8/14/12.
//  Copyright (c) 2012 Beau Collins. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "AppController.h"
#import "AddAccountViewController.h"
#import "PhotoEditorViewController.h"
#import "GravatarImageView.h"

@interface AppController () <PhotoSelectionViewControllerDelegate, PhotoEditorViewControllerDelegate, AddAccountViewControllerDelegate>
@property (nonatomic, strong) GravatarImageView *gravatarImageView;
@end

@implementation AppController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(failedAuth:)
               name:GravatarClientAuthenticationErrorNotification
             object:nil];

    
    // we're going to have a toolbar at the top
    CGRect toolbarFrame = self.view.bounds;
    toolbarFrame.size.height = 44.f;
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:toolbarFrame];
    
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIImage *gravatarWhite = [UIImage imageNamed:@"gravatar-white"];
    UIBarButtonItem *gravatar = [[UIBarButtonItem alloc] init];
    gravatar.image = gravatarWhite;
    
    gravatar.enabled = NO;
    
    toolbar.items = @[flex, gravatar, flex];
    
    [self.view addSubview:toolbar];
    
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [toolbar sizeToFit];
    
    CGRect navFrame = self.view.bounds;
    navFrame.size.height = 44.f;
    navFrame.origin.y = self.view.bounds.size.height - navFrame.size.height;
    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:navFrame];
    navBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.navigationBar = navBar;
    
    [self.view addSubview:navBar];
    
    UINavigationItem *appNavigationItem = [[UINavigationItem alloc] initWithTitle:nil];
    [navBar pushNavigationItem:appNavigationItem animated:NO];
    
    self.gravatarImageView = [[GravatarImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, 30.f, 30.f)];
    self.gravatarImageView.email = self.account.email;
    UIView *navAccountButton = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.bounds.size.width * 0.75f, 30.f)];
    
    CGRect labelFrame = navAccountButton.frame;
    labelFrame.size.width -= self.gravatarImageView.frame.size.width + 5.f;
    labelFrame.origin.x = self.gravatarImageView.frame.size.width + 5.f;
    UILabel *accountLabel = [[UILabel alloc] initWithFrame:labelFrame];
    accountLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    accountLabel.backgroundColor = [UIColor clearColor];
    accountLabel.textColor = [UIColor whiteColor];
    accountLabel.shadowColor = [UIColor blackColor];
    accountLabel.shadowOffset = CGSizeMake(0.f, -1.f);
    accountLabel.text = self.account.email;
        
    [navAccountButton addSubview:accountLabel];

    [navAccountButton addSubview:self.gravatarImageView];
    
    
    appNavigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navAccountButton];
    appNavigationItem.titleView.hidden = YES;
    
    self.accountNavigationItem = appNavigationItem;
    
    CGRect contentFrame = self.view.bounds;
    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];

    contentFrame.size.height += statusBarFrame.size.height - navFrame.size.height;
    contentFrame.origin.y = -statusBarFrame.size.height;
    
    self.contentView = [[UIView alloc] initWithFrame:contentFrame];
    [self.view addSubview:self.contentView];
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    
    self.photosController = [[PhotoSelectionViewController alloc] initWithCollectionViewLayout:nil];
    self.photosController.title = NSLocalizedString(@"Photos", @"Title for photo selection view");
    self.photosController.delegate = self;
    
    self.photosController.view.frame = self.contentView.bounds;
    [self.contentView addSubview:self.photosController.view];
    
    [self.view bringSubviewToFront:toolbar];
        
}

- (void)viewDidAppear:(BOOL)animated {
    if (!self.account.isConfigured) {
        [self showLoginForm:nil];
    } else {
        UIBarButtonItem *logOut = [[UIBarButtonItem alloc]
                                   initWithTitle:NSLocalizedString(@"Log Out", "Log out button")
                                   style:UIBarButtonItemStyleBordered
                                   target:self action:@selector(logout:)
                                   ];
        [self.accountNavigationItem setRightBarButtonItem:logOut animated:animated];

    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (void)failedAuth:(NSNotification *)notification {
    [self showLoginForm:nil];
}

- (void)logout:(id)sender {
    [self.account logOut];
    // show the login view
    [self showLoginForm:nil];
}

- (void)showLoginForm:(id)sender {
    
    AddAccountViewController *addAccount = [[AddAccountViewController alloc] initWithNibName:nil bundle:nil];
    addAccount.title = NSLocalizedString(@"Log In", @"Log In view title");
    addAccount.delegate = self;
    UINavigationController *modal = [[UINavigationController alloc] initWithRootViewController:addAccount];
    modal.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    [self presentViewController:modal animated:YES completion:nil];

}

#pragma mark - Delegate Methods

- (void)photoSelector:(PhotoSelectionViewController *)photoSelector didSelectAsset:(id)asset {
    PhotoEditorViewController *editorController = [[PhotoEditorViewController alloc] init];
    ALAssetRepresentation *rep = [asset defaultRepresentation];
    UIImage *image = [UIImage imageWithCGImage:[rep fullResolutionImage] scale:rep.scale orientation:rep.orientation];
    editorController.photo = image;
    editorController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    editorController.delegate = self;
    [self presentViewController:editorController animated:YES completion:nil];
}

- (void)photoEditor:(PhotoEditorViewController *)photoEditor didFinishEditingImage:(CGImageRef)imageRef {
    
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    NSData *data = UIImageJPEGRepresentation(image, 0.9f);
    [self.account.client saveData:data withRating:GravatarClientImageRatingG onSucces:^(GravatarRequest *request, NSArray *params) {
        NSLog(@"Uploaded data: %@", params);
    } onFailure:^(GravatarRequest *request, NSDictionary *fault) {
        NSLog(@"Failed to upload data: %@", fault);
    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addAccountViewControllerDidLogIn:(AddAccountViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
    self.account = viewController.account;
    self.gravatarImageView.email = self.account.email;
}



@end
