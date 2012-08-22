//
//  RCAppDelegate.m
//  Gravatar
//
//  Created by Beau Collins on 8/3/12.
//  Copyright (c) 2012 Beau Collins. All rights reserved.
//

#import "RCAppDelegate.h"
#import "GravatarAccount.h"
#import "EmailsViewController.h"
#import "AppController.h"


@interface RCAppDelegate () <EmailsViewControllerDelegate>
@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) AppController *appController;
- (void)applyAppearance;
@end

@implementation RCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    [self applyAppearance];
    
    
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackTranslucent;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor blackColor];
    
    self.appController = [[AppController alloc] init];
    
    self.window.rootViewController = self.appController;
    
    [self.window makeKeyAndVisible];
    

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self.appController refreshPhotos];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark Delegate Methods


- (void)emailViewController:(EmailsViewController *)emailsController didSelectEmail:(id)email {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(3.f, 3.f, 3.f, 3.f);
    layout.itemSize = CGSizeMake(77.f, 77.f);
    layout.minimumInteritemSpacing = 2.f;
    layout.minimumLineSpacing = 2.f;
    
    PhotoSelectionViewController *controller = [[PhotoSelectionViewController alloc] initWithCollectionViewLayout:layout];
    controller.title = NSLocalizedString(@"Photos", @"Title for photo selection view");
//    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];

}



#pragma mark - UIAppearance

- (void)applyAppearance {
    
    
    // navigation bar appearance
    id navigationBar = [UINavigationBar appearance];
    UIImage *shadowImage = [UIImage imageNamed:@"no-shadow"];
    [navigationBar setShadowImage:shadowImage];
    UIImage *unifiedImage = [[UIImage imageNamed:@"unified-nav"]
                             resizableImageWithCapInsets:UIEdgeInsetsMake(4.f, 4.f, 4.f, 4.f)];
    
    UIEdgeInsets smallRadius = UIEdgeInsetsMake(2.f, 2.f, 2.f, 2.f);
    
    [navigationBar setBackgroundImage:unifiedImage forBarMetrics:UIBarMetricsDefault];
    UIImage *barButtonActiveImage = [[UIImage imageNamed:@"add-account-navbar-button-active"]
                                     resizableImageWithCapInsets:smallRadius];
    UIImage *barButtonPressedImage = [[UIImage imageNamed:@"add-account-navbar-button-pressed"]
                                      resizableImageWithCapInsets:smallRadius];
    UIImage *barButtonActiveLandscapeImage = [[UIImage imageNamed:@"add-account-navbar-button-active-landscape"]
                                              resizableImageWithCapInsets:smallRadius];
    UIImage *barButtonPressedLandscapeImage = [[UIImage imageNamed:@"add-account-navbar-button-pressed-landscape"]
                                               resizableImageWithCapInsets:smallRadius];
    
    // bar button item appearance
    id barButtonItem = [UIBarButtonItem appearance];
    [barButtonItem setBackgroundImage:barButtonActiveImage
                             forState:UIControlStateNormal
                                style:UIBarButtonItemStyleBordered
                           barMetrics:UIBarMetricsDefault];
    
    [barButtonItem setBackgroundImage:barButtonActiveLandscapeImage
                             forState:UIControlStateNormal
                                style:UIBarButtonItemStyleBordered
                           barMetrics:UIBarMetricsLandscapePhone];
    
    [barButtonItem setBackgroundImage:barButtonPressedImage
                             forState:UIControlStateHighlighted
                                style:UIBarButtonItemStyleBordered
                           barMetrics:UIBarMetricsDefault];
    
    [barButtonItem setBackgroundImage:barButtonPressedLandscapeImage
                             forState:UIControlStateHighlighted
                                style:UIBarButtonItemStyleBordered
                           barMetrics:UIBarMetricsLandscapePhone];
    
    
    UIEdgeInsets backButtonInset = UIEdgeInsetsMake(2.f, 10.f, 2.f, 2.f);
    UIImage *backButtonPressedImage = [[UIImage imageNamed:@"navbar-back-button-pressed"]
                                       resizableImageWithCapInsets:backButtonInset];
    
    UIImage *backButtonActiveImage = [[UIImage imageNamed:@"navbar-back-button-active"]
                                      resizableImageWithCapInsets:backButtonInset];
    
    UIImage *backButtonActiveLandscapeImage = [[UIImage imageNamed:@"navbar-back-button-active-landscape"]
                                               resizableImageWithCapInsets:backButtonInset];
    
    UIImage *backButtonPressedLandscapeImage = [[UIImage imageNamed:@"navbar-back-button-pressed-landscape"]
                                                resizableImageWithCapInsets:backButtonInset];
    
    [barButtonItem setBackButtonBackgroundImage:backButtonActiveImage
                                       forState:UIControlStateNormal
                                     barMetrics:UIBarMetricsDefault];
    
    [barButtonItem setBackButtonBackgroundImage:backButtonPressedImage
                                       forState:UIControlStateHighlighted
                                     barMetrics:UIBarMetricsDefault];
    
    [barButtonItem setBackButtonBackgroundImage:backButtonActiveLandscapeImage
                                       forState:UIControlStateHighlighted
                                     barMetrics:UIBarMetricsLandscapePhone];
    
    [barButtonItem setBackButtonBackgroundImage:backButtonPressedLandscapeImage
                                       forState:UIControlStateHighlighted
                                     barMetrics:UIBarMetricsLandscapePhone];
    
    
    // UIToolBarAppearance
    id toolbar = [UIToolbar appearance];
    [toolbar setBackgroundImage:shadowImage forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    
    NSLog(@"Info: %@", [[NSBundle mainBundle] infoDictionary]);

}

-(void)logAllFilters {
    NSArray *properties = [CIFilter filterNamesInCategory:
                           kCICategoryBuiltIn];
    NSLog(@"%@", properties);
    for (NSString *filterName in properties) {
        CIFilter *fltr = [CIFilter filterWithName:filterName];
        NSLog(@"%@", [fltr attributes]);
    }
}


@end
