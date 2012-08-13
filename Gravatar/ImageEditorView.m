//
//  ImageEditorView.m
//  Gravatar
//
//  Created by Beau Collins on 8/13/12.
//  Copyright (c) 2012 Beau Collins. All rights reserved.
//

#import "ImageEditorView.h"

@implementation ImageEditorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)setImageFromAsset:(ALAsset *)asset {
    ALAssetRepresentation *rep = [asset defaultRepresentation];
    CGImageRef cgimage = [rep fullResolutionImage];
    self.image = [UIImage imageWithCGImage:cgimage scale:rep.scale orientation:rep.orientation];
    
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    NSLog(@"Draw the image: %@", self.image);
    // find the best scale
    CGRect smallestFit = CGRectZero;
    CGFloat scale;
    if (self.image.size.width < self.image.size.height) {
        scale = rect.size.width/self.image.size.width;
    } else {
        scale = rect.size.height/self.image.size.height;
    }
    smallestFit.size.width = self.image.size.width * scale;
    smallestFit.size.height = self.image.size.height * scale;
    
    // center it
    smallestFit.origin.y = (rect.size.height - smallestFit.size.height) * 0.5f;
    
    smallestFit.origin.x = (rect.size.width - smallestFit.size.width) * 0.5f;
    
    [self.image drawInRect:smallestFit];
    
}


@end
