//
//  MMSnapFooterView.h
//  MMSnapController
//
//  Created by Matías Martínez on 1/27/15.
//  Copyright (c) 2015 Matías Martínez. All rights reserved.
//

#import "MMSnapSupplementaryView.h"

extern const CGFloat MMSnapFooterFlexibleWidth;

@interface MMSnapFooterView : MMSnapSupplementaryView

@property (copy, nonatomic) NSArray *items;

- (void)setItems:(NSArray *)items animated:(BOOL)animated;

@property (strong, nonatomic) UIColor *separatorColor UI_APPEARANCE_SELECTOR;

@property (strong, nonatomic) UIView *backgroundView;

@end

@interface MMSnapFooterSpace : NSObject

@property (assign, nonatomic) CGFloat width;

@end
