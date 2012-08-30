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
#import "FilterPickerView.h"

const float PhotoEditorViewControllerCropInset = 22.f;

@interface PhotoEditorViewController () <FilterPickerViewDelegate> {
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
@property (nonatomic) UIView *backgroundView;
@property (nonatomic) CIContext *filterContext;
@property (nonatomic) CIFilter *filter;
@property (nonatomic) FilterPickerView *filterPickerScrollView;

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

- (NSString *)title {
    return @"Edit";
}

- (UINavigationItem *)navigationItem {
    
    UINavigationItem *editorNavItem = super.navigationItem;
        
    editorNavItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Use" style:UIBarButtonItemStyleBordered target:self action:@selector(cropPhoto:)];

    return [super navigationItem];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    self.filterContext = [CIContext contextWithOptions:nil];
    
    self.filter = [CIFilter filterWithName:@"CIDotScreen"];
    [self.filter setDefaults];
    
    self.view.backgroundColor = [UIColor blackColor];
    
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
        
    [self.view addSubview:self.imageView];
    
    
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
    self.panGesture.maximumNumberOfTouches = 1;
    self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinched:)];
    self.doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapped:)];
    self.doubleTapGesture.numberOfTapsRequired = 2;
    self.doubleTapGesture.numberOfTouchesRequired = 1;

    [self.view bringSubviewToFront:self.cropView];
    
    CGRect pickerFrame = CGRectMake(0.f, self.view.bounds.size.height - 74.f, self.view.bounds.size.width, 44.f);
    self.filterPickerScrollView = [[FilterPickerView alloc] initWithFrame:pickerFrame];
    self.filterPickerScrollView.sampleImage = [UIImage imageNamed:@"filter-sample"];

    self.filterPickerScrollView.filterLibrary = self.filterLibrary;
    self.filterPickerScrollView.delegate = self;
    
    [self.view addSubview:self.filterPickerScrollView];

    
    self.imageOrigin = self.editorView.center;
        
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
//    [self removeGestures];
    
//    [self.imageView removeFromSuperview];
//    [self.cropView removeFromSuperview];
//    [self.editorView removeFromSuperview];
    
//    self.cropView = nil;
//    self.editorView = nil;
//    self.imageView = nil;
    
//    self.panGesture = nil;
//    self.pinchGesture = nil;
//    self.doubleTapGesture = nil;
    

}

#pragma mark - FilterPickerViewDelegate

- (void)filterPickerView:(FilterPickerView *)filterPickerView didSelectFilter:(BaseFilter *)filter {
    NSLog(@"use this filter: %@", filter);
    ALAssetRepresentation *rep = [self.asset defaultRepresentation];
    self.imageView.image = [self.filterLibrary imageWithCGImage:rep.fullScreenImage usingFilter:filter];
}

#pragma mark - Editor Methods

- (void)addGestures {
    [self.editorView addGestureRecognizer:self.panGesture];
    [self.editorView addGestureRecognizer:self.pinchGesture];
    [self.editorView addGestureRecognizer:self.doubleTapGesture];
}

- (void)removeGestures {
    [self.editorView removeGestureRecognizer:self.panGesture];
    [self.editorView removeGestureRecognizer:self.pinchGesture];
    [self.editorView removeGestureRecognizer:self.doubleTapGesture];

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
        
        UIImage *fullImage = [self.filterLibrary imageWithCGImage:rep.fullScreenImage
                                                      usingFilter:self.filterPickerScrollView.selectedFilter];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_closing == YES) {
                return;
            }
            self.imageView.image = fullImage;
        });
    });
    
    self.filterPickerScrollView.sampleImage = [UIImage imageWithCGImage:asset.thumbnail];
    
    CGSize assetDimensions = asset.defaultRepresentation.dimensions;
    CGRect imageFrame;
    CGSize cropSize = self.cropView.cropFrame.size;
    imageFrame.size = assetDimensions;
    imageFrame.origin = CGPointMake(0.f, 0.f);
    self.imageView.transform = CGAffineTransformIdentity;
    self.imageView.frame = imageFrame;
    self.imageView.center = self.editorView.center;
    self.imageView.image = [UIImage imageWithCGImage:asset.aspectRatioThumbnail];
    self.imageView.layer.anchorPoint = CGPointMake(0.5f, 0.5f);
    
    // set up a filter and use it?
    
    self.defaultImageScale = [self scaleToFillDimensions:assetDimensions toSize:cropSize];
        
    self.imageScale = 1.f;
    self.imageOrigin = self.editorView.center;
    
    
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
    
    self.imageView.transform = [self transformForScale:startScale];
    self.imageView.center = startCenter;
    
    self.view.alpha = 0.f;

    [UIView animateWithDuration:duration animations:^{
        
        self.view.alpha = 1.f;        
        self.cropView.alpha = 1.f;
        self.imageView.center = self.editorView.center;
        self.imageView.transform = [self transformForScale:1.f];
    } completion:^(BOOL completed){
        [self addGestures];
    }];
    
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
        
        CGAffineTransform transform = [self transformForScale:endScale];
        // account for anchorPoint
        CGSize startSize = CGSizeApplyAffineTransform(self.imageView.bounds.size, self.imageView.transform);
        CGPoint anchor = self.imageView.layer.anchorPoint;
        CGPoint offset = CGPointMake((0.5f - anchor.x) * startSize.width, (0.5f - anchor.y) * startSize.height);
        self.imageView.layer.anchorPoint = CGPointMake(0.5f, 0.5f);
        CGPoint startPoint = self.imageView.center;
        startPoint.x += offset.x;
        startPoint.y += offset.y;
        
        self.imageView.center = startPoint;
        
        [self removeGestures];
        
        [UIView animateWithDuration:0.3f animations:^{
            self.view.alpha = 0.f;
            self.cropView.alpha = 0.f;
            self.imageView.transform = transform;
            self.imageView.center = endCenter;
        } completion:^(BOOL completed) {
            self.imageView.image = nil;
            if(completeBlock != nil) completeBlock();
        }];
        
        
    }
}

- (CGAffineTransform)transformForScale:(CGFloat)scale {
    CGFloat correctedScale = scale * self.defaultImageScale;
    
    CGAffineTransform transform = CGAffineTransformScale(CGAffineTransformIdentity, correctedScale, correctedScale);
    return transform;
}

- (CGPoint)centerPointForOrigin:(CGPoint)origin andSize:(CGSize)size andAnchorPoint:(CGPoint)anchor {
    
    
    return origin;
}

- (void)animateToValidPosition {
    CGAffineTransform transform;
    // first determine if we need to scale the image
    
    self.imageScale = MAX(MIN(self.imageScale, self.maxImageScale), self.minImageScale);
    transform = [self transformForScale:self.imageScale];

    CGSize endSize = CGSizeApplyAffineTransform(self.imageView.bounds.size, transform);
    CGRect endRect = CGRectZero;
    CGRect cropRect = [self.view convertRect:self.cropView.cropFrame fromView:self.cropView];
    CGPoint anchor = self.imageView.layer.anchorPoint;
    
    endRect.size = endSize;
    endRect.origin = CGPointMake(self.imageOrigin.x - endSize.width * 0.5f, self.imageOrigin.y - endSize.height * 0.5f);
    // we need to factor in the anchor point as well
    endRect.origin.x += (0.5f - anchor.x) * endSize.width;
    endRect.origin.y += (0.5f - anchor.y) * endSize.height;
        
    CGFloat minXBound = CGRectGetMinX(endRect) - CGRectGetMinX(cropRect);
    CGFloat maxXBound = CGRectGetMaxX(cropRect) - CGRectGetMaxX(endRect);
    CGPoint origin = self.imageOrigin;
    if (minXBound > 0.f) {
        origin.x += -minXBound;
    } else if(maxXBound > 0.f){
        origin.x += maxXBound;
    }
    
    CGFloat minYBound = CGRectGetMinY(endRect) - CGRectGetMinY(cropRect);
    CGFloat maxYBound = CGRectGetMaxY(cropRect) - CGRectGetMaxY(endRect);
    
    if (minYBound > 0.f) {
        origin.y += -minYBound;
    } else if(maxYBound > 0.f){
        origin.y += maxYBound;
    }
    
    self.imageOrigin = origin;
    
    [UIView animateWithDuration:0.2f animations:^{
        self.imageView.transform = transform;
        self.imageView.center = self.imageOrigin;
    }];
    
    
}

- (void)panned:(UIPanGestureRecognizer *)pan {
        
    CGPoint delta = [pan translationInView:self.editorView];
    CGPoint center = CGPointMake(self.imageOrigin.x + delta.x, self.imageOrigin.y + delta.y);
    self.imageView.center = center;
    
    CGRect frame = self.imageView.frame;
    CGRect cropFrame = self.editorView.frame;
    
    // make adjustments if the cropFrame is beyond the possible bounds
    CGFloat minXBound = CGRectGetMinX(frame) - CGRectGetMinX(cropFrame);
    CGFloat maxXBound = CGRectGetMaxX(cropFrame) - CGRectGetMaxX(frame);
    
    if (minXBound > 0.f) {
        center.x -= minXBound - powf(minXBound, 0.8f);
    } else if(maxXBound > 0.f){
        center.x += maxXBound - powf(maxXBound, 0.8f);
    }
    
    CGFloat minYBound = CGRectGetMinY(frame) - CGRectGetMinY(cropFrame);
    CGFloat maxYBound = CGRectGetMaxY(cropFrame) - CGRectGetMaxY(frame);
    if (minYBound > 0.f) {
        center.y -= minYBound - powf(minYBound, 0.8f);
    } else if(maxYBound > 0.f){
        center.y += maxYBound - powf(maxYBound, 0.8f);
    }
    
    self.imageView.center = center;
    
    if (pan.state == UIGestureRecognizerStateEnded) {
        self.imageOrigin = center;
        [self animateToValidPosition];
    }    
    
}

- (void)pinched:(UIPinchGestureRecognizer *)pinch {
    
    if (pinch.state == UIGestureRecognizerStateBegan) {
        CGPoint pinchOrigin = [pinch locationInView:self.imageView];
        CGSize imageSize = self.imageView.bounds.size;
        self.imageView.layer.anchorPoint = CGPointMake(pinchOrigin.x/imageSize.width, pinchOrigin.y/imageSize.height);
        self.imageView.center = [pinch locationInView:self.imageView.superview];
    }
    
    CGFloat scale = self.imageScale * pinch.scale;
    CGFloat over = 1.f;
    
    // make sure the scale is within bounds
    if (scale > self.maxImageScale) {
        over = scale/self.maxImageScale;
        scale = self.maxImageScale;
    } else if (scale < self.minImageScale){
        over = scale/self.minImageScale;
        scale = self.minImageScale;
    }
    
    over = sqrtf(over);
    
    scale *= over;
        
    self.imageView.transform = [self transformForScale:scale];
    
    if (pinch.state == UIGestureRecognizerStateEnded) {
        
        self.imageScale = scale;
        self.imageOrigin = self.imageView.center;
        
        [self animateToValidPosition];
    }


}

- (void)doubleTapped:(UITapGestureRecognizer *)tap {
    
    self.imageScale = 1.f;
    self.imageOrigin = self.editorView.center;
    
    // we're going to scale it down to original size
    CGAffineTransform transform = [self transformForScale:self.imageScale];
    // Size of image at new transform
    CGSize size = CGSizeApplyAffineTransform(self.imageView.bounds.size, transform);
    CGPoint anchor = self.imageView.layer.anchorPoint;
    // Figure out the offset created by the anchor point
    CGPoint offset = CGPointMake((0.5f - anchor.x) * size.width, (0.5f - anchor.y) * size.height);
    CGPoint endPoint = self.imageOrigin;
    endPoint.x -= offset.x;
    endPoint.y -= offset.y;
    
    [UIView animateWithDuration:0.2f animations:^{
        self.imageView.transform = transform;
        self.imageView.center = endPoint;
    } completion:^(BOOL finished) {
        // now that we're all done, reset the anchor point
        self.imageView.layer.anchorPoint = CGPointMake(0.5f, 0.5f);
        // set the image to the true center
        self.imageView.center = self.imageOrigin;
    }];
    
}

- (void)cropPhoto:(id)sender {
    // using the crop reference, crop the photo
    
    CGRect cropRect = [self.imageView convertRect:self.editorView.frame fromView:self.view];
    
    ALAssetRepresentation *rep = self.asset.defaultRepresentation;
    UIImage *filteredImage = [self.filterLibrary imageWithCGImage:rep.fullResolutionImage usingFilter:self.filterPickerScrollView.selectedFilter];
    UIImage  *image = [UIImage imageWithCGImage:filteredImage.CGImage scale:rep.scale orientation:rep.orientation];
    
    
    UIGraphicsBeginImageContextWithOptions(image.size, YES, image.scale);
    [image drawAtPoint:CGPointZero];
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

- (CGPoint)centerWithAnchor {
    CGSize size = self.imageView.frame.size;
    CGPoint anchor = self.imageView.layer.anchorPoint;
    CGPoint offset = CGPointMake((anchor.x - 0.5f) * size.width , (anchor.y - 0.5f) * size.height);
    return CGPointMake(self.imageOrigin.x + offset.x, self.imageOrigin.y + offset.y);
}

@end
