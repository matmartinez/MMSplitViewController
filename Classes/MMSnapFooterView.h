//
//  MMSnapFooterView.h
//  MMSnapController
//
//  Created by Matías Martínez on 1/27/15.
//  Copyright (c) 2015 Matías Martínez. All rights reserved.
//

#import "MMSnapSupplementaryView.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Navigational controls displayed in a bar along the bottom of the screen, in conjunction with a @c MMSplitViewController.
 *
 *  @note Not all features of @c UIToolbar are supported or replicated. Consider embedding your view controller into a @c UINavigationController instead.
 */
@interface MMSnapFooterView : MMSnapSupplementaryView

/**
 *  Sets the items on the footer view by animating the changes.
 *
 *  The items, instances of @c UIView and/or @c MMSnapFooterSpace, that are visible on the toolbar in the order they appear in this array. Any changes to this property are not animated. Use the @c setItems:animated: method to animate changes.
 *
 *  The default value is @c nil.
 */
@property (copy, nonatomic, nullable) NSArray *items;

/**
 *  The items displayed on the footer view.
 *
 *  The items, instances of @c UIView and/or @c MMSnapFooterSpace, that are visible on the toolbar in the order they appear in this array.
 *
 *  @param items    The items to display on the toolbar.
 *  @param animated A Boolean value if set to @c YES animates the transition to the items; otherwise, does not.
 */
- (void)setItems:(nullable NSArray *)items animated:(BOOL)animated;

/**
 *  The separator color for a single line running across the bar’s width.
 */
@property (strong, nonatomic, nullable) UIColor *separatorColor UI_APPEARANCE_SELECTOR;

/**
 *  The view used as the background of the footer view.
 */
@property (strong, nonatomic, nullable) UIView *backgroundView;

@end

/**
 *  The value for spacing that is distributed equally between the other items.
 */
extern const CGFloat MMSnapFooterFlexibleWidth;

/**
 *  An object that represents a blank space to add between other items.
 */
@interface MMSnapFooterSpace : NSObject

/**
 *  The width of the spacing.
 *
 *  The default value is @c 44.0f.
 */
@property (assign, nonatomic) CGFloat width;

@end

NS_ASSUME_NONNULL_END
