//
//  PixelateFilter.m
//  Gravatar
//
//  Created by Beau Collins on 8/30/12.
//  Copyright (c) 2012 Beau Collins. All rights reserved.
//

#import "DotScreen.h"

@implementation DotScreen

+ (NSString *)filterName {
    return @"Pixelate";
}

- (CIImage *)processCIImage:(CIImage *)image withContext:(CIContext *)context {
    
    CIFilter *monochrome = [CIFilter filterWithName:@"CIColorMonochrome"];
    CIFilter *screen = [CIFilter filterWithName:@"CIDotScreen"];
    
    [screen setValue:image forKey:@"inputImage"];
    [screen setValue:[NSNumber numberWithInt:8] forKey:@"inputWidth"];
    [monochrome setValue:screen.outputImage forKey:@"inputImage"];
    [monochrome setValue:[CIColor colorWithString:@"0.7 0.7 0.0 1"] forKey:@"inputColor"];
    
    
    return monochrome.outputImage;
    
}

@end
