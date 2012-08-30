//
//  FilterPickerView.m
//  Gravatar
//
//  Created by Beau Collins on 8/29/12.
//  Copyright (c) 2012 Beau Collins. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "FilterPickerView.h"

@interface FilterPickerView ()

@property (nonatomic) NSUInteger selectedIndex;
@property (nonatomic, strong) NSMutableArray *filterButtons;
- (void)removeAllFilterButtons;
- (void)createFilterButtons;
- (void)rebuildFilterButtons;
- (void)selectFilter:(id)sender;

@end

@implementation FilterPickerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.selectedIndex = 0;
    }
    return self;
}

- (void)setFilterLibrary:(FilterLibrary *)filterLibrary {
    if (_filterLibrary != filterLibrary) {
        _filterLibrary = filterLibrary;
        [self rebuildFilterButtons];
    }
}

- (void)rebuildFilterButtons {
    [self removeAllFilterButtons];
    [self createFilterButtons];
}

- (void)removeAllFilterButtons {
    [self.filterButtons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView *button = (UIView *)obj;
        [button removeFromSuperview];
    }];
    self.filterButtons = [NSMutableArray arrayWithCapacity:[self.filterLibrary.filters count]];
}

- (void)createFilterButtons {
    
    
    FilterLibrary *library = self.filterLibrary;

    [library.filters enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        BaseFilter *filter = (BaseFilter *)obj;
        
        UIButton *button = [[UIButton alloc] initWithFrame:[self rectForButtonIndex:idx]];
        
        [button setImage:[library imageWithUIImage:self.sampleImage usingFilter:filter] forState:UIControlStateNormal];
        
        button.backgroundColor = [UIColor blackColor];
        button.layer.cornerRadius = 2.f;
        button.layer.masksToBounds = YES;
        
        [button addTarget:self
                   action:@selector(selectFilter:)
         forControlEvents:UIControlEventTouchUpInside];
        
        [self.filterButtons addObject:button];
        [self addSubview:button];
        
    }];
}

- (CGRect)rectForButtonIndex:(NSUInteger)idx {
    CGRect rect = CGRectMake(0.f, 0.f, 44.f, 44.f);
    rect.origin.x = 5.f + (idx * 48.f);
    return rect;
}

- (void)selectFilter:(id)sender {
    NSUInteger idx = [self.filterButtons indexOfObject:sender];
    if (idx == NSNotFound) {
        idx = 0;
    }
    self.selectedIndex = idx;
    [self.delegate filterPickerView:self didSelectFilter:self.selectedFilter];
}

- (BaseFilter *)selectedFilter {
    return [self.filterLibrary filterForIndex:self.selectedIndex];
}

- (void)setSampleImage:(UIImage *)sampleImage {
    if (sampleImage != _sampleImage) {
        _sampleImage = sampleImage;
        // update the buttons
        [self.filterButtons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UIButton *button = (UIButton *)obj;
            BaseFilter *filter = [self.filterLibrary filterForIndex:idx];
            [button setImage:[self.filterLibrary imageWithUIImage:self.sampleImage usingFilter:filter] forState:UIControlStateNormal];
            
        }];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
