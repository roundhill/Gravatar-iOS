//
//  ImageEditorView.h
//  Gravatar
//
//  Created by Beau Collins on 8/13/12.
//  Copyright (c) 2012 Beau Collins. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ImageEditorView : UIView
@property (nonatomic, strong) UIImage *image;
@property (nonatomic) CGFloat imageScale;
@property (nonatomic, readonly) CGFloat maxScale;
@property (nonatomic, readonly) CGFloat minScale;

-(void)setImageFromAsset:(ALAsset *)asset;
@end
