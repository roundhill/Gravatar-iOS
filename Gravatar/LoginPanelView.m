//
//  LoginPanelView.m
//  Gravatar
//
//  Created by Beau Collins on 8/7/12.
//  Copyright (c) 2012 Beau Collins. All rights reserved.
//

#import "LoginPanelView.h"

@implementation LoginPanelView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    
    self.layer.masksToBounds = NO;
    self.backgroundColor = [UIColor clearColor];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect
                                               byRoundingCorners:UIRectCornerAllCorners
                                                     cornerRadii:CGSizeMake(2.f, 2.f)];
    
    [[UIColor colorWithHue:0.f saturation:0.f brightness:0.98f alpha:1.f] setFill];
    [path fill];
    
    self.layer.shadowOpacity = .5f;
    self.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.layer.shadowPath = [path CGPath];
    self.layer.shadowRadius = 5.f;
    self.layer.shadowOffset = CGSizeMake(0.f,0.f);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(ctx, 1.f);
    CGFloat mid = floorf(rect.size.height * 0.5f) + 0.5f;
    [[[UIColor blackColor] colorWithAlphaComponent:0.05f] setStroke];
    CGContextMoveToPoint(ctx, 0.f, mid);
    CGContextAddLineToPoint(ctx, rect.size.width, mid);
    CGContextStrokePath(ctx);
    [[UIColor whiteColor] setStroke];
    CGContextMoveToPoint(ctx, 0.f, mid+1.f);
    CGContextAddLineToPoint(ctx, rect.size.width, mid+1.f);
    CGContextStrokePath(ctx);
        
}


@end
