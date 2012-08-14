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
const float PhotoEditorViewControllerCropInset = 44.f;

@interface PhotoEditorViewController ()
@property (nonatomic, strong) UIToolbar *bar;
@property (nonatomic, strong) UIView *editorView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIPinchGestureRecognizer *scaleGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) CropView *cropView;
@property (nonatomic) CGFloat cropViewScalingFactor;
@property (nonatomic) CGFloat imageZoom, minImageZoom, maxImageZoom, imageZoomAnchor, imageZoomVelocity;
@property (nonatomic) CGPoint imagePanAnchor, imageCenter, cropViewCenter, imagePanVelocity, zoomTranslation;
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
    [self.editorView setClipsToBounds:YES];
    self.editorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:self.editorView];
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.editorView addSubview:self.imageView];

    self.bar = [[UIToolbar alloc] initWithFrame:CGRectZero];
    self.bar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:self.bar];
    
    self.cropView = [[CropView alloc] initWithFrame:CGRectZero];
    self.cropView.autoresizesSubviews = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.editorView addSubview:self.cropView];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Editor view size:
    
    CGRect viewBounds = self.view.bounds;
    CGRect barFrame = CGRectMake(0.f, 0.f, viewBounds.size.width, PhotoEditorViewControllerBarHeight);
    barFrame.origin.y = viewBounds.size.height - barFrame.size.height;
    
    self.bar.frame = barFrame;
    
    CGRect editorFrame = CGRectMake(0.f, 0.f, viewBounds.size.width, viewBounds.size.height - barFrame.size.height);
    self.editorView.frame = editorFrame;
    
    [self.cropView sizeToFit];

    
    
	// Do any additional setup after loading the view.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(finished:)];
    [self.bar addGestureRecognizer:tap];
    
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
    self.scaleGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinched:)];
    
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapped:)];
    self.tapGesture.numberOfTapsRequired = 2;
    
    ALAssetRepresentation *photoRep = [self.photo defaultRepresentation];
    self.imageView.image = [UIImage imageWithCGImage:[photoRep fullResolutionImage] scale:photoRep.scale orientation:photoRep.orientation];
    
    [self.imageView sizeToFit];
        
    // we want a rect that's square
    self.cropView.cropFrame = [self cropRectForSize:self.editorView.frame.size];
    
    [self makeImageScalingBoundariesForSize:self.cropView.cropFrame.size];
    
    
    self.imageZoom = 1.f;
    self.imageCenter = CGPointZero;

}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self.cropView sizeToFit];
    self.cropView.cropFrame = [self cropRectForSize:self.editorView.frame.size];
    [self.cropView setNeedsDisplay];
    [self makeImageScalingBoundariesForSize:self.cropView.cropFrame.size];
    [self scaleImageView];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.editorView addGestureRecognizer:self.scaleGesture];
    [self.editorView addGestureRecognizer:self.tapGesture];
    [self.editorView addGestureRecognizer:self.panGesture];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.editorView removeGestureRecognizer:self.scaleGesture];
    [self.editorView removeGestureRecognizer:self.tapGesture];
    [self.editorView removeGestureRecognizer:self.panGesture];
}


- (void)finished:(UITapGestureRecognizer *)tap {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)doubleTapped:(UITapGestureRecognizer *)tap {
    [UIView animateWithDuration:0.2f animations:^{
        self.imageZoom = 1.f;
        self.imageCenter = CGPointZero;
    }];
}

- (void)panned:(UIPanGestureRecognizer *)pan {
    if (pan.state == UIGestureRecognizerStateBegan) {
        self.imagePanAnchor = self.imageCenter;
    }
    CGPoint delta = [pan translationInView:self.editorView];
    self.imagePanVelocity = [pan velocityInView:self.editorView];
    self.imageCenter = CGPointMake(self.imagePanAnchor.x + delta.x, self.imagePanAnchor.y + delta.y);
    if (pan.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:0.1f animations:^{
            [self positionImageToValidPosition];
        }];
    }
    
}

- (void)pinched:(UIPinchGestureRecognizer *)pinch {
    if (pinch.state == UIGestureRecognizerStateBegan) {
        self.imageZoomAnchor = self.imageZoom;
        CGPoint location = [pinch locationInView:self.imageView];
        CGSize imageSize = self.imageView.bounds.size;
        self.imageView.layer.anchorPoint = CGPointMake(location.x/imageSize.width,location.y/imageSize.height);
        self.imageView.center = [pinch locationInView:self.editorView];
    }
    
    self.imageZoomVelocity = pinch.velocity;
    self.imageZoom = self.imageZoomAnchor * pinch.scale;
    
    
    if (pinch.state == UIGestureRecognizerStateEnded) {

        [UIView animateWithDuration:.1f delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self zoomImageToValidZoom];
        } completion:nil];
    }
        

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [self.editorView removeGestureRecognizer:self.panGesture];
    [self.editorView removeGestureRecognizer:self.scaleGesture];
    self.panGesture = nil;
    self.scaleGesture = nil;
    // Dispose of any resources that can be recreated.
}

- (CGRect)cropRectForSize:(CGSize)size {
    CGRect cropRect;
    cropRect.size.width = MIN(size.width, size.height) - PhotoEditorViewControllerCropInset;
    cropRect.size.height = cropRect.size.width;
    cropRect.origin.x = (size.width - cropRect.size.width) * 0.5f;
    cropRect.origin.y = (size.height - cropRect.size.height) * 0.5f;
    return cropRect;
}

- (void)makeImageScalingBoundariesForSize:(CGSize)size {
    // figure out the initial scale of the image to fill the rect
    CGSize imageSize = self.imageView.image.size;
    if (imageSize.width > imageSize.height) {
        self.cropViewScalingFactor = size.height / imageSize.height;
    } else {
        self.cropViewScalingFactor = size.width / imageSize.width;
    }
    self.minImageZoom = 1.f;
    self.maxImageZoom = 1/self.cropViewScalingFactor;
    
    CGSize editorSize = self.editorView.frame.size;
    self.cropViewCenter = CGPointMake(editorSize.width * 0.5f, editorSize.height * 0.5f);
           
}

- (void)setImageZoom:(CGFloat)imageZoom {
    if (imageZoom != _imageZoom) {
        
        _imageZoom = imageZoom;
        [self scaleImageView];
        
 }
}

- (void)setImageCenter:(CGPoint)imageCenter {
    if(!CGPointEqualToPoint(imageCenter, _imageCenter)){
        NSLog(@"Setting imageCenter: %@", NSStringFromCGPoint(imageCenter));
        _imageCenter = imageCenter;
    }
    [self positionImageView];
}

- (void)scaleImageView {
    
    CGFloat zoom = self.imageZoom;
    CGFloat over = 0.f;
    CGFloat direction = 1.f;
    if (zoom < self.minImageZoom) {
        over = self.minImageZoom - zoom;
        zoom = self.minImageZoom;
        direction = -1.f;
    } else if(zoom > self.maxImageZoom) {
        over = zoom - self.maxImageZoom;
        zoom = self.maxImageZoom;
    }
    
    if (over > 0) {
        zoom += direction * over ;
    }
    
    CGFloat scale = zoom * self.cropViewScalingFactor;
    
    self.imageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, scale, scale);
        
}

- (void)positionImageView {
    
    CGPoint center = self.imageCenter;
    
    CGSize imageSize = self.imageView.bounds.size;
    CGSize cropSize = self.cropView.cropFrame.size;
    

    CGPoint anchor = self.cropViewCenter;
    self.imageView.center = CGPointMake(center.x + anchor.x, center.y + anchor.y);
    
    
    
}

- (void)zoomImageToValidZoom {
    if(self.imageZoom > self.maxImageZoom){
        self.imageZoom = self.maxImageZoom;
    } else if(self.imageZoom < self.minImageZoom){
        self.imageZoom = self.minImageZoom;
    }
}

- (void)positionImageToValidPosition {
    CGPoint center = self.imageCenter;
    CGSize imageSize = self.imageView.frame.size;
    CGSize cropSize = self.cropView.cropFrame.size;
    
    CGFloat xBound = (imageSize.width - cropSize.width) * 0.5f;
    CGFloat yBound = (imageSize.height - cropSize.height) * 0.5f;
    if (center.x < -xBound) {
        center.x = -xBound;
    } else if (center.x > xBound){
        center.x = xBound;
    }
    
    if (center.y < -yBound) {
        center.y = -yBound;
    } else if (center.y > yBound){
        center.y = yBound;
    }
        
    self.imageCenter = center;
}


@end
