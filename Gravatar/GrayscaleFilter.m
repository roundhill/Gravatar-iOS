//
//  GrayscaleFilter.m
//  Gravatar
//
//  Created by Dan Roundhill on 9/6/12.
//  Copyright (c) 2012 Beau Collins. All rights reserved.
//

#import "GrayscaleFilter.h"

@implementation GrayscaleFilter

+ (NSString *)filterName {
    return @"Black and White";
}

- (CIImage *)processCIImage:(CIImage *)image withContext:(CIContext *)context {
    CIFilter *filter = [CIFilter filterWithName:@"CIColorMonochrome"];
    [filter setDefaults];
    
    [filter setValue:image forKey:@"inputImage"];
    [filter setValue:[CIColor colorWithString:@"0.8 0.8 0.8 0.8"] forKey:@"inputColor"];
    
    return filter.outputImage;
}

@end
