//
//  PhotoEditorViewController.h
//  Gravatar
//
//  Created by Beau Collins on 8/8/12.
//  Copyright (c) 2012 Beau Collins. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PhotoEditorViewControllerDelegate;

@interface PhotoEditorViewController : UIViewController
@property (nonatomic, assign) id<PhotoEditorViewControllerDelegate> delegate;
@property (nonatomic, strong) UIImage *photo;
@end

@protocol PhotoEditorViewControllerDelegate <NSObject>

-(void)photoEditor:(PhotoEditorViewController *)photoEditor didFinishEditingImage:(UIImage *)image;

@end