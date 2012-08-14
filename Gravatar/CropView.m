//
//  CropView.m
//  Gravatar
//
//  Created by Beau Collins on 8/13/12.
//  Copyright (c) 2012 Beau Collins. All rights reserved.
//

#import "CropView.h"

@implementation CropView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.cropFrame = CGRectZero;
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
        
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    if (!CGRectIsEmpty(self.cropFrame)) {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        [[[UIColor blackColor] colorWithAlphaComponent:0.7f] setFill];
        CGContextFillRect(ctx, rect);
        CGContextClearRect(ctx, self.cropFrame);
        [[[UIColor whiteColor] colorWithAlphaComponent:0.9f] setStroke];
        CGContextSetLineWidth(ctx, 1.f);
        CGContextStrokeRect(ctx, CGRectInset(self.cropFrame, -0.5f, -0.5f));
    }
}



@end
