//
//  BaseFilter.h
//  Gravatar
//
//  Created by Beau Collins on 8/30/12.
//  Copyright (c) 2012 Beau Collins. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreImage/CoreImage.h>

@interface BaseFilter : NSObject

+ (NSString *)filterName;
- (NSString *)filterName;
- (CIImage *)processCIImage:(CIImage *)image withContext:(CIContext *)context;


@end
