//
//  PhotoEditorViewController.m
//  Gravatar
//
//  Created by Beau Collins on 8/8/12.
//  Copyright (c) 2012 Beau Collins. All rights reserved.
//

#import <CoreImage/CoreImage.h>
#import <QuartzCore/QuartzCore.h>
#import "PhotoEditorViewController.h"
#import "CropView.h"

const float PhotoEditorViewControllerCropInset = 22.f;

@interface PhotoEditorViewController () {
    BOOL _closing;
}
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTapGesture;
@property (nonatomic) CGPoint imageOrigin, panAnchor;
@property (nonatomic) CGFloat defaultImageScale, imageScale, pinchAnchor;
@property (nonatomic, readonly) CGFloat maxImageScale, minImageScale;
@property (nonatomic, strong) UIView *editorView;
@property (nonatomic) CGRect transitionRect;

@property (nonatomic) CropView *cropView;
@end

@implementation PhotoEditorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _defaultImageScale = 1.f;
        _imageScale = 1.f;
        _imageOrigin = CGPointZero;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    
    self.cropView = [[CropView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.cropView];
    
    
    CGSize viewSize = self.view.bounds.size;
    
    CGRect cropFrame;
    cropFrame.size.width = MIN(viewSize.width, viewSize.height) - PhotoEditorViewControllerCropInset;
    cropFrame.size.height = cropFrame.size.width;
    cropFrame.origin.x = (viewSize.width - cropFrame.size.width) * 0.5f;
    cropFrame.origin.y = (viewSize.height - cropFrame.size.height) * 0.5f;
    self.cropView.cropFrame = cropFrame;
    self.cropView.alpha = 0.f;
    
    self.editorView = [[UIView alloc] initWithFrame:self.cropView.cropFrame];
    [self.view addSubview:self.editorView];
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, cropFrame.size.width, cropFrame.size.height)];
    
    self.imageView.backgroundColor = [UIColor purpleColor];
    
    [self.view addSubview:self.imageView];
    
    
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
    self.panGesture.maximumNumberOfTouches = 1;
    self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinched:)];
    self.doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapped:)];
    self.doubleTapGesture.numberOfTapsRequired = 2;
    self.doubleTapGesture.numberOfTouchesRequired = 1;
    [self updateImageView];
    [self.editorView addGestureRecognizer:self.panGesture];
    [self.editorView addGestureRecognizer:self.pinchGesture];
    [self.editorView addGestureRecognizer:self.doubleTapGesture];
    
    [self.view bringSubviewToFront:self.cropView];
    

}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    [self.editorView removeGestureRecognizer:self.panGesture];
    [self.editorView removeGestureRecognizer:self.pinchGesture];
    [self.editorView removeGestureRecognizer:self.doubleTapGesture];
    
    self.cropView = nil;
    
    self.panGesture = nil;
    self.pinchGesture = nil;
    self.doubleTapGesture = nil;
    
    self.editorView = nil;
    self.imageView = nil;

}


- (void)viewWillLayoutSubviews {
    self.cropView.frame = self.view.bounds;
    [self.cropView setNeedsDisplay];
    self.editorView.frame = self.cropView.cropFrame;
}

- (void)setAsset:(ALAsset *)asset {
    [self setAsset:asset andAnimate:NO zoomFromRect:CGRectNull];
}

- (void)setAsset:(ALAsset *)asset andAnimate:(BOOL)animate zoomFromRect:(CGRect)rect {
    if (asset != _asset) {
        _asset = asset;
    }
    _closing = NO;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (_closing == YES) {
            return;
        }
        ALAssetRepresentation *rep = asset.defaultRepresentation;
        UIImage *fullImgae = [UIImage imageWithCGImage:rep.fullScreenImage];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_closing == YES) {
                return;
            }
            self.imageView.image = fullImgae;
        });
    });

    [self.imageView removeFromSuperview];
    self.imageView = nil;
    CGSize assetDimensions = asset.defaultRepresentation.dimensions;
    CGRect imageFrame;
    CGSize cropSize = self.cropView.cropFrame.size;
    imageFrame.size = assetDimensions;
    imageFrame.origin = CGPointMake(0.f, 0.f);
    self.imageView = [[UIImageView alloc] initWithFrame:imageFrame];
    [self.view insertSubview:self.imageView belowSubview:self.cropView];
    self.imageView.center = self.editorView.center;
    self.imageView.image = [UIImage imageWithCGImage:asset.aspectRatioThumbnail];
    
    self.imageView.transform = CGAffineTransformIdentity;
    
    
    self.defaultImageScale = [self scaleToFillDimensions:assetDimensions toSize:cropSize];
        
    _imageScale = 1.f;
    _imageOrigin = CGPointZero;
    
    CGFloat duration;
    if (animate == YES) {
        duration = 0.3f;
        self.transitionRect = rect;
    } else {
        duration = 0.f;
        self.transitionRect = CGRectNull;
    }
    
    CGPoint startCenter = CGPointMake(rect.origin.x + rect.size.width * 0.5f, rect.origin.y + rect.size.height * 0.5f);
    CGFloat startScale = [self scaleToFillDimensions:self.editorView.bounds.size toSize:rect.size];
    
    self.imageView.transform = [self transformForScale:startScale andPan:CGPointZero];
    self.imageView.center = startCenter;
    
    self.cropView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.05f, 1.05f);

    [UIView animateWithDuration:duration animations:^{
        self.cropView.alpha = 1.f;
        self.cropView.transform = CGAffineTransformIdentity;

        self.imageView.center = self.editorView.center;
        self.imageView.transform = [self transformForScale:1.f andPan:CGPointZero];
    } completion:nil];
    
}

- (void)stopEditingOnComplete:(void (^)())completeBlock {
    _closing = YES; 
    if (CGRectIsNull(self.transitionRect)) {
        if(completeBlock != nil) completeBlock();
    } else {
        
        // transform for getting the image back to default state
        // what would it take to sacle transform the crop frame size rect to the transitionRect
        CGFloat endScale = [self scaleToFillDimensions:self.editorView.bounds.size toSize:self.transitionRect.size];
        CGPoint endCenter = CGPointMake(self.transitionRect.origin.x + self.transitionRect.size.width * 0.5f, self.transitionRect.origin.y + self.transitionRect.size.height * 0.5f);
        
        CGAffineTransform transform = [self transformForScale:endScale andPan:CGPointZero];
        
        
        [UIView animateWithDuration:0.3f animations:^{
            self.cropView.alpha = 0.f;
            self.imageView.transform = transform;
            self.imageView.center = endCenter;
        } completion:^(BOOL finished) {
            if(completeBlock != nil) completeBlock();
        }];
        
        
    }
}

- (CGAffineTransform)transformForScale:(CGFloat)scale andPan:(CGPoint)position {
    CGFloat correctedScale = scale * self.defaultImageScale;
    //scale, than translate
    CGAffineTransform transform = CGAffineTransformScale(CGAffineTransformIdentity, correctedScale, correctedScale);
    return CGAffineTransformTranslate(transform, position.x, position.y);
    
}

- (void)panned:(UIPanGestureRecognizer *)pan {
    if (pan.state == UIGestureRecognizerStateBegan) {
        self.panAnchor = self.imageOrigin;
    }
    
    if (pan.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:0.1f animations:^{
            [self updateImageViewToNearestValidState];
        }];
        return;
    }
        
    CGPoint delta = [pan translationInView:self.imageView];
    
    self.imageOrigin = CGPointMake(self.panAnchor.x + delta.x, self.panAnchor.y + delta.y);
    
    [self updateImageView];
    
}

- (void)pinched:(UIPinchGestureRecognizer *)pinch {
    
    if (pinch.state == UIGestureRecognizerStateBegan) {
        self.pinchAnchor = self.imageScale;
    }
    
    if (pinch.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:0.1f animations:^{
            [self updateImageViewToNearestValidState];
        }];
        return;
    }
    
    self.imageScale = self.pinchAnchor * pinch.scale;
    
    [self updateImageView];

}

- (void)doubleTapped:(UITapGestureRecognizer *)tap {
    
    self.imageScale = 1.f;
    self.imageOrigin = CGPointZero;
    [UIView animateWithDuration:0.2f animations:^{
        [self updateImageViewToNearestValidState];        
    }];
}


- (void)finished:(UITapGestureRecognizer *)tap {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)closePhotoEditor:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateImageView {
    
    if (self.imageView == nil) {
        return;
    }
    
    CGFloat scale = [self scaleFloat:self.imageScale withinMin:self.minImageScale andMax:self.maxImageScale];
        
    scale *= self.defaultImageScale;
    
    CGAffineTransform scaleTransform = CGAffineTransformScale(CGAffineTransformIdentity, scale, scale);
    
    
//    CGRect cropRect = [self.view convertRect:self.editorView.frame toView:self.imageView];
//    CGRect imageRect = self.imageView.bounds;
    
//    CGFloat minX = (cropRect.size.width - imageRect.size.width) * 0.5f;
//    CGFloat maxX = (imageRect.size.width - cropRect.size.width) * 0.5f;
//    CGFloat minY = (cropRect.size.height - imageRect.size.height) * 0.5f;
//    CGFloat maxY = (imageRect.size.height - cropRect.size.height) * 0.5f;
    
    CGPoint origin = self.imageOrigin;
    
//    if (self.imageScale >= 1.f) {
//        origin.x = [self scaleFloat:origin.x withinMin:minX andMax:maxX andScale:1/scale];
//        origin.y = [self scaleFloat:origin.y withinMin:minY andMax:maxY andScale:1/scale];
//    }

    self.imageView.transform = CGAffineTransformTranslate(scaleTransform, origin.x, origin.y);
    
}

- (void)updateImageViewToNearestValidState {
    
    if (self.imageView == nil) {
        return;
    }
        
    if (self.imageScale < self.minImageScale) {
        self.imageScale = self.minImageScale;
    } else if (self.imageScale > self.maxImageScale){
        self.imageScale = self.maxImageScale;
    }
    
    
    [self updateImageView];
    
    return;
        
//    CGRect cropRect = [self.view convertRect:self.editorView.frame toView:self.imageView];
//    CGRect imageRect = self.imageView.bounds;
    
//    CGFloat minX = (cropRect.size.width - imageRect.size.width) * 0.5f;
//    CGFloat maxX = (imageRect.size.width - cropRect.size.width) * 0.5f;
//    CGFloat minY = (cropRect.size.height - imageRect.size.height) * 0.5f;
//    CGFloat maxY = (imageRect.size.height - cropRect.size.height) * 0.5f;
    
    CGPoint origin = self.imageOrigin;
//    origin.x = MIN(MAX(origin.x, minX), maxX);
//    origin.y = MIN(MAX(origin.y, minY), maxY);
    
    self.imageOrigin = origin;
    
    [self updateImageView];
    
    // if it's translated outside the cropping area on the x/y axis, move it
    
}

- (CGFloat)scaleFloat:(CGFloat)number withinMin:(CGFloat)min andMax:(CGFloat)max {
    return [self scaleFloat:number withinMin:min andMax:max andScale:1.f];
}

- (CGFloat)scaleFloat:(CGFloat)number withinMin:(CGFloat)min andMax:(CGFloat)max andScale:(CGFloat)scale {
    CGFloat over = 0.f;
    CGFloat scaled = 0.f;
    if (number < min) {
        over = fabs(number - min);
        scaled = min - log1pf(over) * scale;
    } else if (number > max){
        over = fabs(number - max);
        scaled = max + log1pf(over) * scale;
    } else {
        scaled = number;
    }
    
    return scaled;
    
}

- (void)cropPhoto:(id)sender {
    // using the crop reference, crop the photo
    CGRect cropRect = [self.imageView convertRect:self.editorView.frame fromView:self.view];
    
    UIGraphicsBeginImageContextWithOptions(self.photo.size, YES, self.photo.scale);
    [self.photo drawAtPoint:CGPointZero];
    UIImage *source = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGImageRef cropped = CGImageCreateWithImageInRect(source.CGImage, cropRect);
    
    UIImage *croppedImage = [UIImage imageWithCGImage:cropped];
    
    CGImageRelease(cropped);
    
    [self.delegate photoEditor:self didFinishEditingImage:croppedImage];
}

- (CGFloat)maxImageScale {
    return 1.f/self.defaultImageScale;
}

- (CGFloat)minImageScale {
    return 1.f;
}

- (CGFloat)totalImageScale {
    return self.imageScale * self.defaultImageScale;
}

- (CGFloat)scaleToFillDimensions:(CGSize)dimensions toSize:(CGSize)size {
    
    CGFloat vertical = size.height/dimensions.height;
    CGFloat horizontal = size.width/dimensions.width;
    
    return MAX(vertical, horizontal);
    
}



@end
