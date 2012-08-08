//
//  RCAccountTextField.m
//  Gravatar
//
//  Created by Beau Collins on 8/6/12.
//  Copyright (c) 2012 Beau Collins. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "RCAccountTextField.h"

@implementation RCAccountTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
}
*/

- (CGRect)textRectForBounds:(CGRect)bounds {
    CGRect newBounds = [super textRectForBounds:bounds];
    newBounds.origin.x = 10.f;
    newBounds.size.width -= 20.f;
    return newBounds;
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    CGRect newBounds = [super editingRectForBounds:bounds];
    newBounds.origin.x = 10.f;
    newBounds.size.width -= 20.f;
    return newBounds;
}

- (CGRect)clearButtonRectForBounds:(CGRect)bounds {
    bounds = [super clearButtonRectForBounds:bounds];
    bounds.origin.x -= 0.f;
    return bounds;
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds {
    CGRect rightBounds = [super rightViewRectForBounds:bounds];
    rightBounds.origin.x -= 3.f;
    rightBounds.origin.y = (self.bounds.size.height - rightBounds.size.height) * 0.5f;
    return rightBounds;
}


@end

