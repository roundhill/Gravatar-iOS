//
//  PhotoSelectionViewController.h
//  Gravatar
//
//  Created by Beau Collins on 8/7/12.
//  Copyright (c) 2012 Beau Collins. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PhotoSelectionViewControllerDelegate;

@interface PhotoSelectionViewController : UICollectionViewController

@property (nonatomic, assign) id<PhotoSelectionViewControllerDelegate> delegate;

@end

@protocol PhotoSelectionViewControllerDelegate <NSObject>

- (void)photoSelector:(PhotoSelectionViewController*)photoSelector didSelectAsset:(ALAsset *)asset;

@end
