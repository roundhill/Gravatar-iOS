//
//  FilterPickerView.h
//  Gravatar
//
//  Created by Beau Collins on 8/29/12.
//  Copyright (c) 2012 Beau Collins. All rights reserved.
//

/*

 This views purpose is to present a horizontally scrollable selection of filters.
 
 Ideally, it is given access to a datasource that provides a list of filters with names
 and it generates a sample image for each filter that gets placed in the view as a button.
 
 A delegate should then be used to notify when a filter is picked and which filter it is.
 
 The horizontal scrolling should snap to each "page" worth of filters. The buttons should be
 around 44x44 dips
 
 Should probably just use a UIScrollView and delegate.
 
 Example usage:
 
 FilterPickerView *filterPicker = [[FilterPickerView alloc] initWithRect: filterRect];
 
 // for use as the button for each filter
 filterPicker.sampleImage = [UIImage imageNamed:"sample"];
 
 // an array of CIFilter objects
 filterPicker.filters = arrayOfCIFilterLikeObjects;
 
 // implement to the FilterPickerViewDelegate protocol
 filterPicker.delegate = self;
 
 // put the view in the hierarchy
 [self.view addSubView:filterPicker];
 
*/

#import <UIKit/UIKit.h>
#import <CoreImage/CoreImage.h>
#import "FilterLibrary.h"

@protocol FilterPickerViewDelegate;

@interface FilterPickerView : UIView

@property (nonatomic, strong) FilterLibrary *filterLibrary;
@property (nonatomic, weak) id <FilterPickerViewDelegate> delegate;
@property (nonatomic, strong) UIImage *sampleImage;
@property (nonatomic, readonly) BaseFilter *selectedFilter;

@end

@protocol FilterPickerViewDelegate <NSObject>

- (void)filterPickerView:(FilterPickerView *)filterPickerView didSelectFilter:(BaseFilter *)filter;

@end
