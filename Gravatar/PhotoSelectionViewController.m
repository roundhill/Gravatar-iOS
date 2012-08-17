//
//  PhotoSelectionViewController.m
//  Gravatar
//
//  Created by Beau Collins on 8/7/12.
//  Copyright (c) 2012 Beau Collins. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PhotoSelectionViewController.h"

float const PhotoSelectionViewControllerThumbSize = 76.f;

@interface PhotoSelectionViewController ()
@property (nonatomic, retain) NSMutableArray *photos;
@property (nonatomic, retain) ALAssetsLibrary *library;
@property (nonatomic, retain) UIView *errorView;
@end

@implementation PhotoSelectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)ignoreLayout {
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(67.f, 4.f, 3.f, 3.f);
    layout.itemSize = CGSizeMake(PhotoSelectionViewControllerThumbSize, PhotoSelectionViewControllerThumbSize);
    layout.minimumInteritemSpacing = 2.f;
    layout.minimumLineSpacing = 4.f;

    if (self = [super initWithCollectionViewLayout:layout]) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    
    self.library = [[ALAssetsLibrary alloc] init];
        
}

- (void)refreshPhotos {
    
    self.photos = nil;
    
    self.photos = [NSMutableArray array];
	// Do any additional setup after loading the view.
    
    [self.library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group != nil) {
            
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result != nil) {
                    [self.photos addObject:result];
                }
            }];
            
            [self removeLibraryErrorView];
            [self.collectionView reloadData];
            
            *stop = YES;
        }
        
    } failureBlock:^(NSError *error) {
        [self displayLibraryErrorView:error];
        
    }];
    

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)removeLibraryErrorView {
    if (self.errorView != nil) {
        [self.errorView removeFromSuperview];
        self.errorView = nil;
    }
}

- (void)displayLibraryErrorView:(NSError *)error {
    [self removeLibraryErrorView];
    self.errorView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0., 200.f, 160.f)];
    self.errorView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.95f];
    [self.view addSubview:self.errorView];
    
    self.errorView.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    self.errorView.layer.cornerRadius = 2.f;
    self.errorView.layer.borderColor = [[[UIColor whiteColor] colorWithAlphaComponent:0.25f] CGColor];
    self.errorView.layer.borderWidth = 1.f;
    
    UILabel *errorLabel = [[UILabel alloc] initWithFrame:CGRectInset(self.errorView.bounds, 10.f, 10.f) ];
    errorLabel.text = NSLocalizedString(@"Sad robot :(\n\nPhotos are inaccessible.", @"Error message when library couldn't be loaded");
    errorLabel.backgroundColor = [UIColor clearColor];
    errorLabel.textColor = [UIColor whiteColor];
    errorLabel.numberOfLines = 0;
    errorLabel.textAlignment = NSTextAlignmentCenter;
    [self.errorView addSubview:errorLabel];
    self.errorView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.01f, 0.01f);
    [UIView animateWithDuration:0.2f animations:^{
        self.errorView.transform = CGAffineTransformIdentity;
    }];
    
}

#pragma mark - UICollectionViewDataSource Methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.photos count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    ALAsset *asset = [self.photos objectAtIndex:indexPath.row];
    UIImage *image = [UIImage imageWithCGImage:asset.thumbnail];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0.f,0.f, PhotoSelectionViewControllerThumbSize, PhotoSelectionViewControllerThumbSize);
    [cell.contentView addSubview:imageView];
    cell.clipsToBounds = YES;
    return cell;
}

#pragma mark - UICollectionViewDelegate Methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ALAsset *photo = [self.photos objectAtIndex:indexPath.row];
    [self.delegate photoSelector:self didSelectAsset:photo atIndexPath:indexPath];
    
    
}

@end
