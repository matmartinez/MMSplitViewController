//
//  MMSnapSupplementaryView.h
//  MMSplitViewController
//
//  Created by Matías Martínez on 2/12/19.
//  Copyright © 2019 Matías. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MMSplitViewController;

NS_ASSUME_NONNULL_BEGIN

@interface MMSnapSupplementaryView : UIView

/**
 *  Called just before the snap controller displays the view controller's view associated to this supplementary view.
 */
- (void)snapControllerWillDisplayViewController;

/**
 *  Called just before a view controller will be snapped in the interface.
 *
 *  @param viewController The view controller that will be snapped.
 */
- (void)snapControllerWillSnapToViewController:(UIViewController *)viewController;

/**
 *  Called just before the supplementary view is removed from the snap controller.
 */
- (void)willMoveFromSnapController;

/**
 *  Called after the supplementary view is added to the snap controller.
 */
- (void)didMoveToSnapController;

/**
 *  Called after the snap controller has updated its stack.
 */
- (void)snapControllerViewControllersDidChange;

/**
 *  The split view controller of the recipient.
 */
@property (weak, nonatomic, readonly) MMSplitViewController *splitViewController;

/**
 *  The view controller associated to the recipient.
 */
@property (weak, readonly, nonatomic) UIViewController *viewController;

/**
 *  A convenience method that returns the previous view controller in the stack.
 */
@property (readonly, nonatomic) UIViewController *previousViewController;

@end

NS_ASSUME_NONNULL_END
