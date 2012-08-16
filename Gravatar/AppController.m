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
#import "GravatarImageView.h"

@interface AppController () <PhotoSelectionViewControllerDelegate, PhotoEditorViewControllerDelegate, AddAccountViewControllerDelegate, UINavigationBarDelegate>
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
    self.navigationBar.delegate = self;
    
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
    appNavigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back-grid"] style:UIBarButtonItemStyleBordered target:nil action:nil];
    
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
    
    self.editorController = [[PhotoEditorViewController alloc] init];
    self.editorController.delegate = self;
        
    [self.view bringSubviewToFront:toolbar];
    [self.view bringSubviewToFront:self.navigationBar];
        
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

-(void)stopEditing:(id)sender {
    
    // tell the photoEditor to stop using the editing interface
    [UIView animateWithDuration:0.2f animations:^{
        self.photosController.view.transform = CGAffineTransformIdentity;
        self.photosController.view.alpha = 1.f;
    }];

    [self.editorController stopEditingOnComplete:^{
        [self.editorController.view removeFromSuperview];
    }];
    
}

#pragma mark - Delegate Methods

- (void)photoSelector:(PhotoSelectionViewController *)photoSelector didSelectAsset:(ALAsset *)asset atIndexPath:(NSIndexPath *)indexPath {
    
    UINavigationItem *editorNavItem = [[UINavigationItem alloc] initWithTitle:@"Edit"];
    editorNavItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Use" style:UIBarButtonItemStyleBordered target:self.editorController action:@selector(cropPhoto:)];
    
    
    [self.navigationBar pushNavigationItem:editorNavItem animated:NO];

    
    [self.contentView addSubview:self.editorController.view];
    self.editorController.view.frame = self.contentView.bounds;
    
    // Figure out the position of the selected item
    UICollectionViewCell *cell = [photoSelector.collectionView cellForItemAtIndexPath:indexPath];
    
    // convert the rect to the photo editor's space
    CGRect startingPosition = [self.editorController.view convertRect:cell.frame fromView:photoSelector.collectionView];
    
    [UIView animateWithDuration:0.2f animations:^{
        self.photosController.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8f, 0.8f);
        self.photosController.view.alpha = 0.f;
    }];
    
    // set the asset for the editor and give it a frame to animate from
    [self.editorController setAsset:asset andAnimate:YES zoomFromRect:startingPosition];

    
}

- (void)photoEditor:(PhotoEditorViewController *)photoEditor didFinishEditingImage:(UIImage *)image {
    
    [self stopEditing:nil];
    
    [self.navigationBar popNavigationItemAnimated:NO];
    
    NSData *data = UIImageJPEGRepresentation(image, 0.9f);
    [self.account.client saveData:data withRating:GravatarClientImageRatingG onSucces:^(GravatarRequest *request, NSArray *params) {
        NSLog(@"Uploaded data: %@", params);
    } onFailure:^(GravatarRequest *request, NSDictionary *fault) {
        NSLog(@"Failed to upload data: %@", fault);
    }];
    
}

- (void)addAccountViewControllerDidLogIn:(AddAccountViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
    self.account = viewController.account;
    self.gravatarImageView.email = self.account.email;
}

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    [self stopEditing:nil];
    [navigationBar setItems:@[self.accountNavigationItem] animated:NO];
    return NO;
}




@end
