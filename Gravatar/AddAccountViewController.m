//
//  AddAccountViewController.m
//  Gravatar
//
//  Created by Beau Collins on 8/6/12.
//  Copyright (c) 2012 Beau Collins. All rights reserved.
//

#import "AddAccountViewController.h"
#import "GravatarImageView.h"

@interface AddAccountViewController () <UITextFieldDelegate>
@property (nonatomic, strong) IBOutlet UITextField *emailField;
@property (nonatomic, strong) IBOutlet UITextField *passwordField;
@property (nonatomic, strong) IBOutlet UIButton *logInButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *logInNavButton;
@property (nonatomic, strong) IBOutlet UIView *loginPanel;

- (IBAction)logIn:(id)sender;

@end

@implementation AddAccountViewController

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
    [nc addObserver:self selector:@selector(emailChanged:) name:UITextFieldTextDidChangeNotification object:self.emailField];

    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gravatar-blue-nav"]];
    self.view.backgroundColor = [UIColor colorWithRed:48.f/255.f green:139.f/255.f blue:192.f/255.f alpha:1.f];
    
    self.emailField.rightView = [[GravatarImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, 32.f, 32.f)];
    self.emailField.rightViewMode = UITextFieldViewModeAlways;
    
    UIImage *buttonActive = [[UIImage imageNamed:@"blue-button-active"]
                             resizableImageWithCapInsets:UIEdgeInsetsMake(2.f, 4.f, 2.f, 4.f)];
    
    UIImage *buttonPressed = [[UIImage imageNamed:@"blue-button-pressed"]
                              resizableImageWithCapInsets:UIEdgeInsetsMake(2.f, 4.f, 2.f, 4.f)];
    
    [self.logInButton setBackgroundImage:buttonActive forState:UIControlStateNormal];
    [self.logInButton setBackgroundImage:buttonPressed forState:UIControlStateHighlighted];
    
    [self.emailField becomeFirstResponder];
    
    UIBarButtonItem *cancelButton = self.navigationItem.leftBarButtonItem;
    UIImage *barButtonActiveImage = [[UIImage imageNamed:@"add-account-navbar-button-active"]
                                     resizableImageWithCapInsets:UIEdgeInsetsMake(2.f, 2.f, 2.f, 2.f)];
    UIImage *barButtonPressedImage = [[UIImage imageNamed:@"add-account-navbar-button-pressed"]
                                      resizableImageWithCapInsets:UIEdgeInsetsMake(2.f, 2.f, 2.f, 2.f)];
    UIImage *barButtonActiveLandscapeImage = [[UIImage imageNamed:@"add-account-navbar-button-active-landscape"]
                                     resizableImageWithCapInsets:UIEdgeInsetsMake(2.f, 2.f, 2.f, 2.f)];
    UIImage *barButtonPressedLandscapeImage = [[UIImage imageNamed:@"add-account-navbar-button-pressed-landscape"]
                                      resizableImageWithCapInsets:UIEdgeInsetsMake(2.f, 2.f, 2.f, 2.f)];
    
    [cancelButton setBackgroundImage:barButtonActiveImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [cancelButton setBackgroundImage:barButtonPressedImage forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    [cancelButton setBackgroundImage:barButtonActiveLandscapeImage forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
    [cancelButton setBackgroundImage:barButtonPressedLandscapeImage forState:UIControlStateHighlighted barMetrics:UIBarMetricsLandscapePhone];
    
    self.logInNavButton = [self barButtonItemForLogIn];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
        self.navigationItem.rightBarButtonItem = self.logInNavButton;
    }

}

- (UIBarButtonItem *)barButtonItemForLogIn {
    UIBarButtonItem *login = [[UIBarButtonItem alloc]
                              initWithTitle:NSLocalizedString(@"Log In", @"Log In button for navigation bar")
                              style:UIBarButtonItemStyleDone
                              target:self
                              action:@selector(logIn:)];
    
    UIEdgeInsets edge = UIEdgeInsetsMake(4.f, 4.f, 4.f, 4.f);
    UIImage *activeImage = [[UIImage imageNamed:@"login-navbar-button-active"] resizableImageWithCapInsets:edge];
    UIImage *activeImageLandscape = [[UIImage imageNamed:@"login-navbar-button-active-landscape"] resizableImageWithCapInsets:edge];
    UIImage *pressedImage = [[UIImage imageNamed:@"login-navbar-button-pressed"] resizableImageWithCapInsets:edge];
    UIImage *pressedImageLandscape = [[UIImage imageNamed:@"login-navbar-button-pressed"] resizableImageWithCapInsets:edge];
    
    
    [login setBackgroundImage:activeImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [login setBackgroundImage:activeImageLandscape forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
    [login setBackgroundImage:pressedImage forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    [login setBackgroundImage:pressedImageLandscape forState:UIControlStateHighlighted barMetrics:UIBarMetricsLandscapePhone];
    
    return login;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    self.logInNavButton = nil;
    
}

- (void)logIn:(id)sender {
    self.account = [GravatarAccount defaultAccount];
    self.account.email = self.emailField.text;
    self.account.password = self.passwordField.text;
    
    [self disableInterface];
    
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    CGRect frame = activity.frame;
    frame.origin.x = self.logInButton.frame.size.width - 10.f - frame.size.width;
    frame.origin.y = floorf((self.logInButton.frame.size.height - frame.size.height) * 0.5f);
    activity.frame = frame;
    [activity startAnimating];
        
    [self.logInButton addSubview:activity];
    
    [self.account.client callMethod:@"test" withArguments:nil onSucces:^(GravatarRequest *request, NSArray *params) {
        [self.delegate addAccountViewControllerDidLogIn:self];
    } onFailure:^(GravatarRequest *request, NSDictionary *fault) {
        NSLog(@"Failed log in! %@", fault);
        [self enableInterface];
        [activity removeFromSuperview];
        [self.emailField becomeFirstResponder];

    }];
    
}

- (void)disableInterface {
    self.emailField.enabled = NO;
    self.passwordField.enabled = NO;
    self.logInButton.enabled = NO;
    self.logInNavButton.enabled = NO;

}

- (void)enableInterface {
    self.emailField.enabled = YES;
    self.passwordField.enabled = YES;
    self.logInButton.enabled = YES;
    self.logInNavButton.enabled = YES;
}

- (void)emailChanged:(NSNotification *)sender {
    self.emailField.rightView.hidden = YES;
    int64_t delayInSeconds = 1.f;
    NSString *email = self.emailField.text;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if ([email isEqualToString:self.emailField.text]) {
            GravatarImageView *imageView = (GravatarImageView *)self.emailField.rightView;
            imageView.email = self.emailField.text;
            self.emailField.rightView.hidden = NO;
        }
    });
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    if (UIDeviceOrientationIsLandscape(toInterfaceOrientation)) {
        [self.navigationItem setRightBarButtonItem:self.logInNavButton animated:YES];
    } else {
        [self.navigationItem setRightBarButtonItem:nil animated:YES];
    }
    
}
@end
