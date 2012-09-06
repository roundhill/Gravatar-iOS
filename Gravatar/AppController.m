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
#import "GravatarTitleView.h"
#import "DefaultFilter.h"
#import "SepiaFilter.h"
#import "DotScreen.h"
#import "MonochromeFilter.h"
#import "GrayscaleFilter.h"

@interface AppController () <PhotoSelectionViewControllerDelegate, PhotoEditorViewControllerDelegate, AddAccountViewControllerDelegate, UINavigationBarDelegate>
@property (nonatomic, strong) GravatarImageView *gravatarImageView;
@property (nonatomic, strong) GravatarTitleView *appTitleView;
@property (nonatomic, strong) id accountStatusListener;
@property (nonatomic, strong, readwrite) FilterLibrary *filterLibrary;

@end

@implementation AppController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.appTitleView = [[GravatarTitleView alloc] initWithFrame:CGRectMake(0.f, 0.f, 320.f, 44.f)];
        self.navigationItem.titleView = self.appTitleView;
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back-grid"] style:UIBarButtonItemStyleBordered target:nil action:nil];

        void (^statusChangeBLock)(NSNotification *notification) = ^(NSNotification *notification){
            GravatarAccount *account = (GravatarAccount *)notification.object;
            if (account.accountState == GravatarAccountStateLoggedOut) {
                [self failedAuth:notification];
            }
        };
        
        self.accountStatusListener = [[NSNotificationCenter defaultCenter]
                                      addObserverForName:GravatarAccountStateChangeNotification
                                      object:nil
                                      queue:[NSOperationQueue mainQueue]
                                      usingBlock:statusChangeBLock];
        
        self.account = [GravatarAccount defaultAccount];
        
        // register the filters
        [DefaultFilter class];
        [SepiaFilter class];
        [DotScreen class];
        [MonochromeFilter class];
        [GrayscaleFilter class];
        
        self.filterLibrary = [[FilterLibrary alloc] initWithDefaultFilters];
        

    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self.accountStatusListener];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
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
    
    [navBar pushNavigationItem:self.navigationItem animated:NO];
        
        
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
    self.editorController.filterLibrary = self.filterLibrary;
    
        
    [self.view bringSubviewToFront:toolbar];
    [self.view bringSubviewToFront:self.navigationBar];
        
}

- (void)viewDidAppear:(BOOL)animated {
    if (!self.account.isConfigured) {
        [self showLoginForm:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

//- (GravatarTitleView *)appTitleView {
//    return (GravatarTitleView *)self.navigationItem.titleView;
//}


- (void)setAccount:(GravatarAccount *)account {
    if (account != _account) {
        _account = account;
        self.emails = account.emails;
        self.selectedEmailIndexes = [NSIndexSet indexSet];
        self.appTitleView.account = account;
        
        [self.account loadEmails];
        
    }
}


- (void)refreshPhotos {
    [self.photosController refreshPhotos];
}

- (void)failedAuth:(NSNotification *)notification {
    if ([self isViewLoaded]) {
        [self showLoginForm:nil];
    }
}

- (void)logout:(id)sender {
    [self.account logOut];
    // show the login view
    [self showLoginForm:nil];
}

- (void)showLoginForm:(id)sender {
    
    AddAccountViewController *addAccount = [[AddAccountViewController alloc] initWithNibName:nil bundle:nil];
    addAccount.account = self.account;
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
        
    
    [self.navigationBar pushNavigationItem:self.editorController.navigationItem animated:NO];

    
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
    
    [self.account saveImage:image forEmails:self.account.emails];
    
}

- (void)addAccountViewControllerDidLogIn:(AddAccountViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:nil];
    self.account = viewController.account;
    self.gravatarImageView.email = self.account.email;
    self.appTitleView.account = nil;
    self.appTitleView.account = self.account;
}

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    [self stopEditing:nil];
    [navigationBar setItems:@[self.navigationItem] animated:NO];
    return NO;
}





@end
