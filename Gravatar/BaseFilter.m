//
//  BaseFilter.m
//  Gravatar
//
//  Created by Beau Collins on 8/30/12.
//  Copyright (c) 2012 Beau Collins. All rights reserved.
//

#import "BaseFilter.h"
#import "FilterLibrary.h"

@implementation BaseFilter

+ (void)initialize {
    // register class with the filter library
    if (self != [BaseFilter class]) {
        NSLog(@"Hello, I am: %@ %@", self, [self filterName]);
        [FilterLibrary registerFilter:self];
    }
}

+ (NSString *)filterName {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (NSString *)filterName {
    return [[self class] filterName];
}

// hook up whatever filters necessary and return the output image
- (CIImage *)processCIImage:(CIImage *)image withContext:(CIContext *)context {
    NSLog(@"Process the image: %@", [self class]);
    return image;
    
}

@end
