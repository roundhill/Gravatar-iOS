//
//  PhotoEditorViewController.m
//  Gravatar
//
//  Created by Beau Collins on 8/8/12.
//  Copyright (c) 2012 Beau Collins. All rights reserved.
//

#import "PhotoEditorViewController.h"
#import "CropView.h"

const float PhotoEditorViewControllerBarHeight = 44.f;
const float PhotoEditorViewControllerCropInset = 22.f;

@interface PhotoEditorViewController () <UINavigationBarDelegate>
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTapGesture;
@property (nonatomic) CGPoint imageOrigin, panAnchor;
@property (nonatomic) CGFloat defaultImageScale, imageScale, pinchAnchor, maxImageScale, minImageScale;
@property (nonatomic, strong) UINavigationBar *bar;

@property (nonatomic) CropView *cropView;
@property (nonatomic, strong) UIView *editorView;
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
    
    self.editorView = [[UIView alloc] initWithFrame:CGRectZero];
    self.editorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.editorView];
    self.editorView.backgroundColor = [UIColor blackColor];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.imageView = [[UIImageView alloc] initWithImage:self.photo];
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
        
    CGRect editorFrame = self.view.bounds;
    editorFrame.size.height -= PhotoEditorViewControllerBarHeight;
    self.editorView.frame = editorFrame;
    self.editorView.backgroundColor = [UIColor blackColor];
    

    [self.editorView addSubview:self.imageView];


    self.cropView = [[CropView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.cropView];
    
    [self setImageConstraints];
    
    CGRect barFrame = self.view.frame;
    barFrame.size.height = PhotoEditorViewControllerBarHeight;
    barFrame.origin.y = self.view.frame.size.height - PhotoEditorViewControllerBarHeight;
    self.bar = [[UINavigationBar alloc] initWithFrame:barFrame];
    [self.view addSubview:self.bar];
    self.bar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    UINavigationItem *backItem = [[UINavigationItem alloc] initWithTitle:NSLocalizedString(@"Photos", @"Back Button")];
    UINavigationItem *cropItem = [[UINavigationItem alloc] initWithTitle:NSLocalizedString(@"Crop", @"Crop Title")];
    [self.bar pushNavigationItem:backItem animated:NO];
    [self.bar pushNavigationItem:cropItem animated:NO];
    
    cropItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Use Photo", @"Button to initiate cropping and uploading of the photo") style:UIBarButtonItemStyleBordered target:self action:@selector(cropPhoto:)];
    
    self.bar.delegate = self;
    
    self.editorView.frame = self.cropView.cropFrame;
    
    self.imageScale = 1.f;
    self.imageOrigin = CGPointZero;

    
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
    
    self.imageView = nil;

}

- (void)setImageConstraints {
    
    CGSize viewSize = self.view.bounds.size;
    viewSize.height -= PhotoEditorViewControllerBarHeight;
    CGSize imageSize = self.imageView.image.size;

    self.imageView.center = CGPointMake(viewSize.width * 0.5f, viewSize.height * 0.5f);

    CGRect cropFrame;
    cropFrame.size.width = MIN(viewSize.width, viewSize.height) - PhotoEditorViewControllerCropInset;
    cropFrame.size.height = cropFrame.size.width;
    cropFrame.origin.x = (viewSize.width - cropFrame.size.width) * 0.5f;
    cropFrame.origin.y = (viewSize.height - cropFrame.size.height) * 0.5f;
    self.cropView.cropFrame = cropFrame;
    
    CGSize cropSize = cropFrame.size;
    
    CGFloat anchorScale;
    if (imageSize.width < imageSize.height) {
        anchorScale = cropSize.width / imageSize.width;
    } else {
        anchorScale = cropSize.height / imageSize.height;
    }
    
    self.minImageScale = 1.f;
    self.maxImageScale = 1/anchorScale;
    
    self.defaultImageScale = anchorScale;


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
    
    CGFloat scale = [self scaleFloat:self.imageScale withinMin:self.minImageScale andMax:self.maxImageScale];
        
    scale *= self.defaultImageScale;
    
    CGAffineTransform scaleTransform = CGAffineTransformScale(CGAffineTransformIdentity, scale, scale);
    
    
    CGRect cropRect = [self.view convertRect:self.editorView.frame toView:self.imageView];
    CGRect imageRect = self.imageView.bounds;
    
    CGFloat minX = (cropRect.size.width - imageRect.size.width) * 0.5f;
    CGFloat maxX = (imageRect.size.width - cropRect.size.width) * 0.5f;
    CGFloat minY = (cropRect.size.height - imageRect.size.height) * 0.5f;
    CGFloat maxY = (imageRect.size.height - cropRect.size.height) * 0.5f;
    
    CGPoint origin = self.imageOrigin;
    
    if (self.imageScale >= 1.f) {
        origin.x = [self scaleFloat:origin.x withinMin:minX andMax:maxX andScale:1/scale];
        origin.y = [self scaleFloat:origin.y withinMin:minY andMax:maxY andScale:1/scale];
    }

    self.imageView.transform = CGAffineTransformTranslate(scaleTransform, origin.x, origin.y);
    
}

- (void)updateImageViewToNearestValidState {
        
    if (self.imageScale < self.minImageScale) {
        self.imageScale = self.minImageScale;
    } else if (self.imageScale > self.maxImageScale){
        self.imageScale = self.maxImageScale;
    }
    
    
    [self updateImageView];
        
        
    CGRect cropRect = [self.view convertRect:self.editorView.frame toView:self.imageView];
    CGRect imageRect = self.imageView.bounds;
    
    CGFloat minX = (cropRect.size.width - imageRect.size.width) * 0.5f;
    CGFloat maxX = (imageRect.size.width - cropRect.size.width) * 0.5f;
    CGFloat minY = (cropRect.size.height - imageRect.size.height) * 0.5f;
    CGFloat maxY = (imageRect.size.height - cropRect.size.height) * 0.5f;
    
    CGPoint origin = self.imageOrigin;
    origin.x = MIN(MAX(origin.x, minX), maxX);
    origin.y = MIN(MAX(origin.y, minY), maxY);
    
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
    CGSize cropSize = cropRect.size;
    CGImageRef imageRef = self.photo.CGImage; //CGImageCreateWithImageInRect([self.photo CGImage], cropRect);
    CGAffineTransform transform = CGAffineTransformIdentity;
    NSLog(@"Identity: %@", NSStringFromCGAffineTransform(transform));
    switch (self.photo.imageOrientation) {
        case UIImageOrientationUpMirrored:
            NSLog(@"Orientation is up mirrored");
            transform = CGAffineTransformTranslate(transform, cropSize.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);            
            break;
        case UIImageOrientationDown:
            NSLog(@"UIImageOrientationDown");
            transform = CGAffineTransformTranslate(transform, cropSize.width, cropSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
        case UIImageOrientationDownMirrored:
            NSLog(@"Orientation is Down mirrored");
            transform = CGAffineTransformScale(transform, -1, -1);
            break;
        case UIImageOrientationLeft:
            NSLog(@"Orientation is left");
            transform = CGAffineTransformTranslate(transform, cropSize.width, 0.f);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
        case UIImageOrientationLeftMirrored:
            NSLog(@"Orientation is left mirrored");
            transform = CGAffineTransformRotate(transform, M_PI_2);
            transform = CGAffineTransformScale(transform, -1, 1);
        case UIImageOrientationRight:
            NSLog(@"Orientation is right");
            transform = CGAffineTransformTranslate(transform, 0, cropSize.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationRightMirrored:
            NSLog(@"Orientation is right mirrored");
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
            NSLog(@"Orientation is up");
            break;
    }
    
    
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                cropRect.size.width,
                                                cropRect.size.height,
                                                CGImageGetBitsPerComponent(imageRef),
                                                0,
                                                CGImageGetColorSpace(imageRef),
                                                CGImageGetBitmapInfo(imageRef)
                                                );
    
    if (self.photo.imageOrientation != UIImageOrientationUp) {
    }
    CGContextConcatCTM(bitmap, transform);
    CGContextDrawImage(bitmap, cropRect, imageRef);
    CGImageRef cropped = CGBitmapContextCreateImage(bitmap);
    
    CGContextRelease(bitmap);
    
    UIImage *image = [UIImage imageWithCGImage:cropped];
    CGImageRelease(cropped);
    
    [self.delegate photoEditor:self didFinishEditingImage:image];
    
}



#pragma mark - UINavigationBarDelegate methods

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    [self closePhotoEditor:nil];
    return NO;
}



@end
