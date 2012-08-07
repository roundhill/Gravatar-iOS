//
//  RCAppDelegate.m
//  Gravatar
//
//  Created by Beau Collins on 8/3/12.
//  Copyright (c) 2012 Beau Collins. All rights reserved.
//

#import "RCAppDelegate.h"
#import "GravatarClient.h"
#import "GravatarRequest.h"
#import "AddAccountViewController.h"

@interface RCAppDelegate () <GravatarRequestDelegate>
@property (nonatomic, strong) GravatarClient *client;
@end

@implementation RCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    UITableViewController *accounts = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    
    accounts.title = NSLocalizedString(@"Accounts", @"Gravatar accounts list title");
    
    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:accounts];
    
    accounts.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAccount:)];
    
    self.window.rootViewController = controller;
    
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
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Account Management

- (void)addAccount:(id)sender {
    
    AddAccountViewController *addAccount = [[AddAccountViewController alloc] initWithNibName:nil bundle:nil];
    addAccount.title = NSLocalizedString(@"Add Account", @"Add Account view title");
    
    addAccount.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self.window.rootViewController action:@selector(dismissModalViewControllerAnimated:)];
    UINavigationController *modal = [[UINavigationController alloc] initWithRootViewController:addAccount];
    
    modal.navigationBar.shadowImage = nil;
    UIImage *navBackground = [[UIImage imageNamed:@"unified-nav"] resizableImageWithCapInsets:UIEdgeInsetsMake(39, 1.f, 1.f, 1.f)];
    [modal.navigationBar setBackgroundImage:navBackground forBarMetrics:UIBarMetricsDefault];
    [modal.navigationBar setShadowImage:[UIImage imageNamed:@"no-shadow"]];
    NSLog(@"Shadow: %@", modal.navigationBar.shadowImage);
    [self.window.rootViewController presentViewController:modal animated:YES completion:nil];
    
}

#pragma mark - GravatarRequestDelegate methods

- (void)request:(GravatarRequest *)request didFinishWithParams:(NSArray *)params {
    NSLog(@"Response params");
    NSLog(@"%@", params);
}

- (void)request:(GravatarRequest *)request didFinishWithFault:(NSDictionary *)fault {
    NSLog(@"Fault!");
    NSLog(@"%@", fault);
}

@end
