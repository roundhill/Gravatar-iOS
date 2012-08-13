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
-(void)setImageFromAsset:(ALAsset *)asset;
@end
