//
//  GravatarTitleView.m
//  Gravatar
//
//  Created by Beau Collins on 8/20/12.
//  Copyright (c) 2012 Beau Collins. All rights reserved.
//

#import "GravatarTitleView.h"

@interface GravatarTitleView ()

@property (nonatomic, strong) UILabel *emailLabel;
@property (nonatomic, strong, readwrite) UILabel *descriptionLabel;
@property (nonatomic, strong) UIButton *gripButton;
@property (nonatomic, strong) UIView *activityView;


@end

@implementation GravatarTitleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.gripButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *gripImage = [UIImage imageNamed:@"grip"];
        
        
        [self.gripButton setImage:gripImage forState:UIControlStateNormal];
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
        self.activityView.backgroundColor = [UIColor greenColor];
        
        [self addSubview:self.gripButton];
        [self addSubview:self.emailLabel];
        [self addSubview:self.descriptionLabel];
        [self addSubview:self.activityView];
        
        
        [self addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[activity(40)]-5-[label]-5-[grip(22)]|"
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
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[activity]|"
                                                 options:kNilOptions
                                                 metrics:nil
                                                   views:@{@"activity":self.activityView}]];
        
        
        self.emailLabel.text = @"HI";
        self.descriptionLabel.text = @"HI";
        
    }
    return self;
}

- (void)applyLabelStyleToLabel:(UILabel *)label {
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    label.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    label.shadowOffset = CGSizeMake(0.f,-1.f);
}

- (void)setAccount:(GravatarAccount *)account {
    if (_account != account) {
        _account = account;
        [self displayAccount];
    }
}


- (void)displayAccount {
    self.emailLabel.text = self.account.email;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    NSLog(@"Draw me? %@", NSStringFromCGRect(rect));
}
*/


@end
