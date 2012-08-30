//
//  FilterLibrary.h
//  Gravatar
//
//  Created by Beau Collins on 8/30/12.
//  Copyright (c) 2012 Beau Collins. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseFilter.h"

@interface FilterLibrary : NSObject
@property (nonatomic, strong, readonly) NSMutableOrderedSet *filters;

- (id)initWithDefaultFilters;

- (UIImage *)imageWithUIImage:(UIImage *)image usingFilter:(BaseFilter *)filter;
- (UIImage *)imageWithCGImage:(CGImageRef)image usingFilter:(BaseFilter *)filter;
- (UIImage *)imageWithCIImage:(CIImage *)image usingFilter:(BaseFilter *)filter;

- (BaseFilter *)filterForIndex:(NSUInteger)idx;
+ (void)registerFilter:(Class)filter;
+ (NSOrderedSet *)defaultFilters;

@end
