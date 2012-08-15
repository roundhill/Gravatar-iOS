//
//  PhotoEditorViewController.h
//  Gravatar
//
//  Created by Beau Collins on 8/8/12.
//  Copyright (c) 2012 Beau Collins. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@protocol PhotoEditorViewControllerDelegate;

@interface PhotoEditorViewController : UIViewController
@property (nonatomic, assign) id<PhotoEditorViewControllerDelegate> delegate;
@property (nonatomic, strong) ALAsset *asset;
@property (nonatomic, strong) UIImage *photo;

- (void)setAsset:(ALAsset *)asset andAnimate:(BOOL)animate zoomFromRect:(CGRect)rect;
@end

@protocol PhotoEditorViewControllerDelegate <NSObject>

-(void)photoEditor:(PhotoEditorViewController *)photoEditor didFinishEditingImage:(UIImage *)image;

@end