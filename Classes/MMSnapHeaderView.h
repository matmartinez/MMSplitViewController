//
//  MMSnapHeaderView.h
//  MMSnapController
//
//  Created by Matías Martínez on 1/27/15.
//  Copyright (c) 2015 Matías Martínez. All rights reserved.
//

#import "MMSnapSupplementaryView.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Navigational controls displayed in a bar along the top of the screen, in conjunction with a @c MMSplitViewController.
 *
 *  @note Not all features of @c UINavigationBar are supported or replicated. Consider embedding your view controller into a @c UINavigationController instead.
 */
@interface MMSnapHeaderView : MMSnapSupplementaryView

/**
 *  The title displayed in the header view.
 */
@property (copy, nonatomic, nullable) NSString *title;

/**
 *  The subtitle displayed in the header view.
 */
@property (copy, nonatomic, nullable) NSString *subtitle;

/**
 *  A custom view displayed in the center of the header.
 */
@property (strong, nonatomic, nullable) UIView *titleView;

/**
 *  The title to use when a back button is needed on the header view.
 */
@property (copy, nonatomic) NSString *backButtonTitle;

/**
 *  A Boolean value that determines whether the back button is hidden.
 */
@property (assign, nonatomic) BOOL hidesBackButton;

/**
 *  A Boolean value indicating whether the title should be displayed in a large format.
 */
@property (assign, nonatomic) BOOL displaysLargeTitle;

/**
 *  A custom button item displayed on the left edge of the header view.
 */
@property (strong, nonatomic, nullable) UIButton *leftButton;

/**
 *  A custom view displayed on the right edge of the header view.
 *  Add a stack view with buttons to have multiple right buttons, for example.
 */
@property (strong, nonatomic, nullable) UIView *rightView;

/**
 *  Display attributes for the bar’s title text.
 */
@property (nonatomic, copy, nullable) NSDictionary <NSAttributedStringKey, id> *titleTextAttributes UI_APPEARANCE_SELECTOR;

/**
 *  Display attributes for the bar’s subtitle text.
 */
@property (nonatomic, copy, nullable) NSDictionary <NSAttributedStringKey, id> *subtitleTextAttributes UI_APPEARANCE_SELECTOR;

/**
 *  The separator color for a single line running across the bar’s width.
 */
@property (strong, nonatomic, nullable) UIColor *separatorColor UI_APPEARANCE_SELECTOR;

/**
 *  The view used as the background of the header view.
 */
@property (strong, nonatomic, nullable) UIView *backgroundView;

@end

@interface MMSnapHeaderView (MMSnapHeaderViewLargeTitleSupport)

/**
 *  Asks the header view to calculate and return the size that best fits the specified size and scroll offset.
 *
 *  @param size   The size for which the view should calculate its best-fitting size.
 *  @param offset The vertical origin of the content view is offset from the origin of the scroll view.
 *
 *  @return A new size that fits the header view.
 */
- (CGSize)sizeThatFits:(CGSize)size withVerticalScrollOffset:(CGFloat)offset;

/**
 *  Asks the header view to calculate and return the content offset for a scroll view interacting with the header view.
 *
 *  @param targetOffset The expected offset when the scrolling action decelerates to a stop.
 *  @param velocity     The velocity of the scroll view (in points) at the moment the touch was released.
 *
 *  @return A new scroll offset that suits the header view.
 */
- (CGFloat)preferredVerticalScrollOffsetForTargetOffset:(CGFloat)targetOffset withVerticalVelocity:(CGFloat)velocity;

/**
 *  Determines if the header view supports its large title configuration for the specified size.
 *
 *  @param size   The size for which the view should calculate its large title configuration.
 *
 *  @return Returns @c YES if the header view can display its large title.
 */
- (BOOL)displaysLargeTitleWithSize:(CGSize)size;

/**
 *  Determines if the header view should animate its content views as the user scrolls.
 */
@property (assign, nonatomic) BOOL contentIsBeingScrolled;

@end

NS_ASSUME_NONNULL_END
