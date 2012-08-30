//
//  MonochromeFilter.m
//  Gravatar
//
//  Created by Beau Collins on 8/30/12.
//  Copyright (c) 2012 Beau Collins. All rights reserved.
//

#import "MonochromeFilter.h"

@implementation MonochromeFilter

+ (NSString *)filterName {
    return @"Monochrome";
}

- (CIImage *)processCIImage:(CIImage *)image withContext:(CIContext *)context {
    CIFilter *filter = [CIFilter filterWithName:@"CIColorMonochrome"];
    [filter setDefaults];
    
    [filter setValue:image forKey:@"inputImage"];
    [filter setValue:[CIColor colorWithString:@"1 0.3 0.3 1"] forKey:@"inputColor"];
    
    return filter.outputImage;
}

@end
