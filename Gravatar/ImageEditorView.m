//
//  ImageEditorView.m
//  Gravatar
//
//  Created by Beau Collins on 8/13/12.
//  Copyright (c) 2012 Beau Collins. All rights reserved.
//

#import "ImageEditorView.h"

@interface ImageEditorView()
@property (nonatomic, readwrite) CGFloat maxScale;
@property (nonatomic, readwrite) CGFloat minScale;

@end

@implementation ImageEditorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageScale = 1.f;
    }
    return self;
}


- (void)setImageFromAsset:(ALAsset *)asset {
    ALAssetRepresentation *rep = [asset defaultRepresentation];
    CGImageRef cgimage = [rep fullResolutionImage];
    self.image = [UIImage imageWithCGImage:cgimage scale:rep.scale orientation:rep.orientation];
    
    [self setNeedsDisplay];
}

- (void)setImageScale:(CGFloat)imageScale {
    if (_imageScale != imageScale) {
        _imageScale = imageScale;
        [self setNeedsDisplay];
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    NSLog(@"Draw the image: %@", self.image);
    // find the best scale
    CGRect cropRect = CGRectZero;
    
    cropRect.size.height = MIN(rect.size.width, rect.size.height) - 40.f;
    cropRect.size.width = cropRect.size.height;
    cropRect.origin.y = (rect.size.height - cropRect.size.height) * 0.5f;
    cropRect.origin.x = (rect.size.width - cropRect.size.width) * 0.5f;
    
    CGRect smallestFit = CGRectZero;
    CGFloat scale;
    if (self.image.size.width < self.image.size.height) {
        scale = cropRect.size.width/self.image.size.width;
    } else {
        scale = cropRect.size.height/self.image.size.height;
    }
    self.minScale = scale;
    smallestFit.size.width = self.image.size.width * scale * self.imageScale;
    smallestFit.size.height = self.image.size.height * scale * self.imageScale;
    
    // center it
    smallestFit.origin.y = (rect.size.height - smallestFit.size.height) * 0.5f;
    
    smallestFit.origin.x = (rect.size.width - smallestFit.size.width) * 0.5f;
    
    [self.image drawInRect:smallestFit];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGPathRef path = [[UIBezierPath bezierPathWithRect:cropRect] CGPath];
    [[[UIColor whiteColor] colorWithAlphaComponent:0.8f] setStroke];
    CGContextSetLineWidth(ctx, 2.f);
    CGContextAddPath(ctx, path);
    CGContextStrokePath(ctx);
    
}


@end
