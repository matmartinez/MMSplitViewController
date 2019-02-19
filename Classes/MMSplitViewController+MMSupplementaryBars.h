//
//  MMSplitViewController+MMSupplementaryBars.h
//  MMSplitViewController
//
//  Created by Matías Martínez on 2/12/19.
//  Copyright © 2019 Matías. All rights reserved.
//

#import "MMSplitViewController.h"

@class MMSnapHeaderView;
@class MMSnapFooterView;

NS_ASSUME_NONNULL_BEGIN

/**
 *  This category provides a mechanism to use the included @c MMSnapHeaderView and @c MMSnapFooterView classes.
 *  These are meant to provide a similar look and feel to @c UINavigationBar and @c UIToolbar, but lack several features.
 *  You may want to use an embed @c UINavigationController instead for each pane.
 */
@interface MMSplitViewController (MMSupplementaryBars)

/**
 *  Returns an @c MMSnapHeaderView instance configured for the specified view controller.
 *
 *  Usually, you add a header view to your view controller’s view hierarchy to provide navigation controls.
 *
 *  @param viewController The view controller whose header view you want.
 *
 *  @return A header view instance or @c nil.
 *
 *  @note Subsecuent calls to this method will return the previously instantiated header view as long as the view controller is part of the stack.
 */
- (nullable MMSnapHeaderView *)headerViewForViewController:(UIViewController *)viewController;

/**
 *  Returns an @c MMSnapFooterView instance configured for the specified view controller.
 *
 *  Usually, you add a footer view to your view controller’s view hierarchy to provide additional navigation controls.
 *
 *  @param viewController The view controller whose footer view you want.
 *
 *  @return A footer view instance or @c nil.
 *
 *  @note Subsecuent calls to this method will return the previously instantiated footer view as long as the view controller is part of the stack.
 */
- (nullable MMSnapFooterView *)footerViewForViewController:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
