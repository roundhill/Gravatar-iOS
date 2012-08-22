//
//  CircularProgressIndicator.m
//  Gravatar
//
//  Created by Beau Collins on 8/21/12.
//  Copyright (c) 2012 Beau Collins. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CircularProgressIndicatorView.h"

@implementation CircularProgressIndicatorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _percentComplete = 0.f;
        _color = [UIColor whiteColor];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setPercentComplete:(CGFloat)percentComplete {
    if (_percentComplete != percentComplete) {
        _percentComplete = percentComplete;
        [self setNeedsDisplay];
    }
}

- (void)setColor:(UIColor *)color {
    if (_color != color) {
        _color = color;
        [self setNeedsDisplay];
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {

    CGFloat radius = floorf(MIN(rect.size.width-1.f, rect.size.height-1.f) * 0.5f);
    CGPoint center = CGPointMake(rect.size.width * 0.5f, rect.size.height * 0.5f);
    CGRect fullRect = CGRectMake(0.f, 0.f, radius * 2.f, radius * 2.f);
    fullRect.origin.x = (rect.size.width - fullRect.size.width) * 0.5f;
    fullRect.origin.y = (rect.size.height - fullRect.size.height) * 0.5f;
    UIBezierPath *path;
    UIBezierPath *circle = [UIBezierPath bezierPathWithOvalInRect:fullRect];
    
    if(self.percentComplete >= 1.f){
        path = circle;
    } else {
        CGFloat startPercent = 270.f;
        CGFloat endPercent = fmodf(startPercent + 360.f * self.percentComplete, 360.f);
        CGFloat radPerDegree = M_PI / 180.f;
        path = [UIBezierPath bezierPath];
        [path addArcWithCenter:center
                        radius:radius
                    startAngle:startPercent * radPerDegree
                      endAngle:endPercent * radPerDegree
                     clockwise:YES];
        
        
        [path addLineToPoint:center];
        [path closePath];

    }
    
    NSLog(@"Drawing circle with %f", self.percentComplete);

    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // create the gutter cirlce
    
    CGContextSaveGState(ctx);
    
    // Path to draw gradient into
    CGContextAddPath(ctx, [circle CGPath]);
    // Shadow for inset appearance
    CGContextSetShadowWithColor(ctx,
                                CGSizeMake(0.f, 1.f), 1.f,
                                [[[UIColor whiteColor] colorWithAlphaComponent:0.5f] CGColor]
                                );
    // Fill the path, color does not matter since it's going to be erased
    [[UIColor purpleColor] setFill];
    CGContextFillPath(ctx);
    // Add same path for clipping and the clear the rect effectively punching
    // out the cirlce so now we only have the shadow that goes beyond the
    // circle's edges. Now the shadow won't show through the gradient fill
    // that follows
    CGContextAddPath(ctx, [circle CGPath]);
    CGContextClip(ctx);
    CGContextClearRect(ctx, fullRect);
    
    // Construct gradient for gutter color
    UIColor *blackColor = [UIColor blackColor];
    NSArray *colors = @[
        (id)[[blackColor colorWithAlphaComponent:0.3f] CGColor],
        (id)[[blackColor colorWithAlphaComponent:0.1f] CGColor]
    ];
    CGGradientRef gradient = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), (__bridge CFArrayRef) colors, NULL);
    CGPoint gradientStart = CGPointMake(CGRectGetMidX(fullRect), CGRectGetMinY(fullRect));
    CGPoint gradientEnd = CGPointMake(gradientStart.x, CGRectGetMaxY(fullRect));
    CGContextDrawLinearGradient(ctx, gradient, gradientStart, gradientEnd, kCGGradientDrawsBeforeStartLocation|kCGGradientDrawsAfterEndLocation);
    // Clear out all paths/colors whatever
    CGContextRestoreGState(ctx);
    
    
    // Now draw the pie portion
    if (self.percentComplete > 0.f) {
        CGContextSaveGState(ctx);
        
        [self.color setFill];
        CGContextAddPath(ctx, [path CGPath]);
        CGContextFillPath(ctx);
        CGContextRestoreGState(ctx);
    }
    
}


@end
