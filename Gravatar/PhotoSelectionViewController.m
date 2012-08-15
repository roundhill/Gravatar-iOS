//
//  PhotoSelectionViewController.m
//  Gravatar
//
//  Created by Beau Collins on 8/7/12.
//  Copyright (c) 2012 Beau Collins. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "PhotoSelectionViewController.h"

float const PhotoSelectionViewControllerThumbSize = 76.f;

@interface PhotoSelectionViewController ()
@property (nonatomic, retain) NSMutableArray *photos;
@property (nonatomic, retain) ALAssetsLibrary *library;
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
    
    self.photos = [NSMutableArray array];
	// Do any additional setup after loading the view.

    self.library = [[ALAssetsLibrary alloc] init];
    [self.library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group != nil) {

            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result != nil) {
                    [self.photos addObject:result];
                }
            }];
            [self.collectionView reloadData];
            *stop = YES;
        }
        
    } failureBlock:^(NSError *error) {
        NSLog(@"Failed to load photos: %@", error);
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    cell.backgroundColor = [UIColor blackColor];
    ALAsset *asset = [self.photos objectAtIndex:indexPath.row];
    CGImageRef image = [asset thumbnail];
    UIImageView *thumbView = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:image]];
    thumbView.frame = CGRectMake(0.f, 0.f, PhotoSelectionViewControllerThumbSize, PhotoSelectionViewControllerThumbSize);
    [cell addSubview:thumbView];
    cell.clipsToBounds = YES;
    return cell;
}

#pragma mark - UICollectionViewDelegate Methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ALAsset *photo = [self.photos objectAtIndex:indexPath.row];
    [self.delegate photoSelector:self didSelectAsset:photo];
    
    
}

@end
