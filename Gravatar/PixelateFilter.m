//
//  PixelateFilter.m
//  Gravatar
//
//  Created by Beau Collins on 8/30/12.
//  Copyright (c) 2012 Beau Collins. All rights reserved.
//

#import "PixelateFilter.h"

@implementation PixelateFilter

+ (NSString *)filterName {
    return @"Pixelate";
}

- (CIImage *)processCIImage:(CIImage *)image withContext:(CIContext *)context {
    
    CIFilter *filter = [CIFilter filterWithName:@"CIPixellate"];
    [filter setValue:image forKey:@"inputImage"];
    return filter.outputImage;
    
}

@end
