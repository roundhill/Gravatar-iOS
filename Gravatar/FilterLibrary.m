//
//  FilterLibrary.m
//  Gravatar
//
//  Created by Beau Collins on 8/30/12.
//  Copyright (c) 2012 Beau Collins. All rights reserved.
//

#import <CoreImage/CoreImage.h>
#import "FilterLibrary.h"

@interface FilterLibrary ()

@property (nonatomic, strong, readwrite) NSMutableOrderedSet *filters;
@property (nonatomic, strong) CIContext *coreImageContext;
@end

@implementation FilterLibrary

- (id)initWithDefaultFilters {
    if (self = [super init]) {
        
        // set the default set of filters
        [self loadDefaultFilters];
        self.coreImageContext = [CIContext contextWithOptions:nil];
    }
    return self;
}

- (void)loadDefaultFilters {
    NSOrderedSet *defaultFilters = [[self class] defaultFilters];
    self.filters = [[NSMutableOrderedSet alloc] initWithCapacity:[defaultFilters count]];
    [defaultFilters enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Class filter = (Class)obj;
        [self.filters addObject:[[filter alloc] init]];
    }];
}

- (BaseFilter *)filterForIndex:(NSUInteger)idx {
    BaseFilter *filter = (BaseFilter *)[self.filters objectAtIndex:idx];
    return filter;
}



static NSMutableOrderedSet *filters;

+ (void)initialize {
    if (filters == nil) {
        filters = [[NSMutableOrderedSet alloc] init];
    }
}

+ (void)registerFilter:(Class)filter {
    [filters addObject:filter];
    
}

+ (NSOrderedSet *)defaultFilters {
    return filters;
}

// for maximum convenience returns a UIImage to be used based on the
// uiimage and filter provided
- (UIImage *)imageWithUIImage:(UIImage *)image usingFilter:(BaseFilter *)filter {
    
    CIImage *unfiltered;
    
    if ([image CIImage] != nil) {
        // reuse the CIImage used to build it
        unfiltered = [image CIImage];
    } else {
        unfiltered = [CIImage imageWithCGImage:[image CGImage]];
    }
    
    return [self imageWithCIImage:unfiltered usingFilter:filter];
    
    
}

- (UIImage *)imageWithCGImage:(CGImageRef)image usingFilter:(BaseFilter *)filter {
    
    CIImage *unfiltered = [CIImage imageWithCGImage:image];
    return [self imageWithCIImage:unfiltered usingFilter:filter];

}

- (UIImage *)imageWithCIImage:(CIImage *)image usingFilter:(BaseFilter *)filter {
    
    CIImage *filtered = [filter processCIImage:image withContext:self.coreImageContext];
    CGImageRef output = [self.coreImageContext createCGImage:filtered
                                                    fromRect:[filtered extent]];
    
    UIImage *outputImage = [UIImage imageWithCGImage:output];
    CGImageRelease(output);
    
    return outputImage;

}

@end
