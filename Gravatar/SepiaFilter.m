//
//  SepiaFilter.m
//  Gravatar
//
//  Created by Beau Collins on 8/30/12.
//  Copyright (c) 2012 Beau Collins. All rights reserved.
//

#import "SepiaFilter.h"

@implementation SepiaFilter

+ (NSString *)filterName {
    return @"Sepia";
}

- (CIImage *)processCIImage:(CIImage *)image withContext:(CIContext *)context {
    
    CIFilter *sepia = [CIFilter filterWithName:@"CISepiaTone"];
    [sepia setDefaults];
    [sepia setValue:image forKey:@"inputImage"];
    
    return sepia.outputImage;
    
}

@end
