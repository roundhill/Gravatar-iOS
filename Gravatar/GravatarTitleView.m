//
//  GravatarTitleView.m
//  Gravatar
//
//  Created by Beau Collins on 8/20/12.
//  Copyright (c) 2012 Beau Collins. All rights reserved.
//

#import "GravatarTitleView.h"
#import "GravatarImageView.h"
#import "CircularProgressIndicatorView.h"

@interface GravatarTitleView ()

@property (nonatomic, strong) UILabel *emailLabel;
@property (nonatomic, strong, readwrite) UILabel *descriptionLabel;
@property (nonatomic, strong) UIButton *gripButton;
@property (nonatomic, strong) UIView *activityView;
@property (nonatomic, strong) GravatarImageView *gravatarImage;
@property (nonatomic, strong) CircularProgressIndicatorView *progressIndicatorView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

@end

@implementation GravatarTitleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.gripButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *gripImage = [UIImage imageNamed:@"grip"];
        UIImage *gripHighlightedImage = [UIImage imageNamed:@"grip-highlighted"];
        
        [self.gripButton setImage:gripImage forState:UIControlStateNormal];
        [self.gripButton setImage:gripHighlightedImage forState:UIControlStateHighlighted];
        self.gripButton.translatesAutoresizingMaskIntoConstraints = NO;
                
        self.emailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.emailLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self applyLabelStyleToLabel:self.emailLabel];
        
        self.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self applyLabelStyleToLabel:self.descriptionLabel];        
        self.descriptionLabel.font = [UIFont italicSystemFontOfSize:[UIFont smallSystemFontSize]];
        
        self.activityView = [[UIView alloc] initWithFrame:CGRectZero];
        self.activityView.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.gravatarImage = [[GravatarImageView alloc] initWithFrame:CGRectMake(1.f, 1.f, 38.f, 38.f)];
        self.gravatarImage.translatesAutoresizingMaskIntoConstraints = NO;
        [self.activityView addSubview:self.gravatarImage];
        
        self.progressIndicatorView = [[CircularProgressIndicatorView alloc] initWithFrame:CGRectMake(4.f, 4.f, 32.f, 32.f)];
        self.progressIndicatorView.alpha = 0.f;
        [self.activityView addSubview:self.progressIndicatorView];
        
        self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        // 15	72	96	
        self.activityIndicatorView.color = [UIColor colorWithRed:15/255.f green:72/255.f blue:96/155.f alpha:1.f];
        [self.activityIndicatorView startAnimating];
        self.activityIndicatorView.center = CGPointMake(20.f, 20.f);
        self.activityIndicatorView.alpha = 0.f;
        [self.activityView addSubview:self.activityIndicatorView];
        
        [self addSubview:self.gripButton];
        [self addSubview:self.emailLabel];
        [self addSubview:self.descriptionLabel];
        [self addSubview:self.activityView];
        
        [self addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[activity(40)]-5-[label]-5-[grip(40)]|"
                                                 options:kNilOptions
                                                 metrics:nil
                                                   views:@{@"grip":self.gripButton, @"label":self.emailLabel, @"activity":self.activityView}]];
        
        [self addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:[label(==email)]-5-[grip]"
                                                 options:kNilOptions
                                                 metrics:nil
                                                   views:@{@"grip":self.gripButton, @"email":self.emailLabel, @"label":self.descriptionLabel}]];
        
        [self addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[grip]|"
                                                 options:kNilOptions
                                                 metrics:nil
                                                   views:@{@"grip":self.gripButton}]];
        
        [self addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-4-[label][descriptionLabel]-6-|"
                                                 options:kNilOptions
                                                 metrics:nil
                                                   views:@{@"label":self.emailLabel, @"descriptionLabel":self.descriptionLabel}]];
        
        [self addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[activity(40@100)]-2-|"
                                                 options:kNilOptions
                                                 metrics:nil
                                                   views:@{@"activity":self.activityView}]];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reloadGravatar:)];
        [self.gravatarImage addGestureRecognizer:tap];
        [self.gravatarImage setUserInteractionEnabled:YES];
        
    }
    return self;
}

- (void)applyLabelStyleToLabel:(UILabel *)label {
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    label.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.2f];
    label.shadowOffset = CGSizeMake(0.f,-1.f);
}

- (void)setAccount:(GravatarAccount *)account {
    if (_account != account) {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc removeObserver:self name:nil object:_account];
        _account = account;
        [self displayAccount];
        [nc addObserver:self
               selector:@selector(uploadProgressUpdated:)
                   name:GravatarAccountUploadProgressNotification
                 object:account];
        
        [nc addObserver:self
               selector:@selector(accountStateChanged:)
                   name:GravatarAccountStateChangeNotification
                 object:account];
        
        self.gravatarImage.email = account.email;
                
    }
}


- (void)displayAccount {
    self.emailLabel.text = self.account.email;
}

- (void)accountStateChanged:(NSNotification *)notification {
    switch (self.account.accountState) {
        case GravatarAccountStateIdle:
            self.descriptionLabel.text = [NSString stringWithFormat:@"Emails: %d", [self.account.emails count]];
            break;
        case GravatarAccountStateLoading:
            self.descriptionLabel.text = @"Loading account";
            break;
        case GravatarAccountStateUploading:
            self.descriptionLabel.text = @"Uploading image";
            [self showProgressView];            
            break;
        case GravatarAccountStateImageUpdated:
            [self hideProgressView];
            [self.gravatarImage reload];
            break;
        default:
            self.descriptionLabel.text = @"Authenticating";
            break;
    }
}

- (void)uploadProgressUpdated:(NSNotification *)notification {
    self.progressIndicatorView.percentComplete = self.account.uploadProgressPercent;
    if (self.account.uploadProgressPercent >= 1.f) {
        [self showActivityView];
        self.descriptionLabel.text = @"Applying image";
    }
}

- (void)showProgressView {
    
    CGAffineTransform scaleUp = CGAffineTransformScale(CGAffineTransformIdentity, 1.f, 1.f);
    CGAffineTransform scaleDown = CGAffineTransformScale(CGAffineTransformIdentity, 0.1f, 0.1f);
    self.progressIndicatorView.transform = scaleDown;
    self.progressIndicatorView.alpha = 0.f;
    [UIView animateWithDuration:0.4f animations:^{
        self.progressIndicatorView.transform = scaleUp;
        self.progressIndicatorView.alpha = 1.f;
        self.gravatarImage.transform = scaleDown;
        self.gravatarImage.alpha = 0.f;
    }];

}

- (void)showActivityView {
    CGAffineTransform scaleUp = CGAffineTransformScale(CGAffineTransformIdentity, 1.f, 1.f);
    CGAffineTransform scaleDown = CGAffineTransformScale(CGAffineTransformIdentity, 0.1f, 0.1f);
    self.activityIndicatorView.transform = scaleDown;
    [UIView animateWithDuration:0.4f animations:^{
        self.activityIndicatorView.transform = scaleUp;
        self.activityIndicatorView.alpha = 1.f;
    }];
}

- (void)hideProgressView {
    
    CGAffineTransform scaleUp = CGAffineTransformScale(CGAffineTransformIdentity, 1.f, 1.f);
    CGAffineTransform scaleDown = CGAffineTransformScale(CGAffineTransformIdentity, 0.1f, 0.1f);
    
    [UIView animateWithDuration:0.4f animations:^{
        self.progressIndicatorView.transform = scaleDown;
        self.progressIndicatorView.alpha = 0.f;
        self.activityIndicatorView.transform = scaleDown;
        self.activityIndicatorView.alpha = 0.f;
        self.gravatarImage.transform = scaleUp;
        self.gravatarImage.alpha = 1.f;
    }];
}

- (void)reloadGravatar:(id)sender {
    [self.gravatarImage reload];
}


@end
