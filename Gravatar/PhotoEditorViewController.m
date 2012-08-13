//
//  PhotoEditorViewController.m
//  Gravatar
//
//  Created by Beau Collins on 8/8/12.
//  Copyright (c) 2012 Beau Collins. All rights reserved.
//

#import "PhotoEditorViewController.h"
#import "ImageEditorView.h"

const float PhotoEditorViewControllerBarHeight = 44.f;

@interface PhotoEditorViewController ()
@property (nonatomic, strong) UIToolbar *bar;
@property (nonatomic, strong) ImageEditorView *editorView;
@end

@implementation PhotoEditorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView {
    [super loadView];
    self.view.backgroundColor = [UIColor blackColor];
    self.bar = [[UIToolbar alloc] initWithFrame:CGRectZero];
    self.bar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:self.bar];
    
    self.editorView = [[ImageEditorView alloc] initWithFrame:CGRectZero];
    self.editorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.editorView.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.5f];
    [self.view addSubview:self.editorView];
    
}

- (void)viewWillLayoutSubviews {
    
    CGRect viewBounds = self.view.bounds;
    CGRect barFrame = CGRectMake(0.f, 0.f, viewBounds.size.width, PhotoEditorViewControllerBarHeight);
    barFrame.origin.y = viewBounds.size.height - barFrame.size.height;
    
    self.bar.frame = barFrame;
    
    CGRect editorFrame = CGRectMake(0.f, 0.f, viewBounds.size.width, viewBounds.size.height - barFrame.size.height);
    self.editorView.frame = editorFrame;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(finished:)];
    [self.view addGestureRecognizer:tap];
    
    [self.editorView setImageFromAsset:self.photo];
    
}


- (void)finished:(UITapGestureRecognizer *)tap {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
