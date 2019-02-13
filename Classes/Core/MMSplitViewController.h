//
//  MMSplitViewController.h
//  MMSplitViewController
//
//  Created by Matías Martínez on 1/22/19.
//  Copyright © 2019 Matías. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MMSplitViewController;

typedef NS_ENUM(NSUInteger, MMViewControllerColumnSize) {
    MMViewControllerColumnSizePrimary, // The master view controller.
    MMViewControllerColumnSizeSecondary, // The detail view controller.
    MMViewControllerColumnSizeAuxiliary, // An third optional view controller to display alongside the secondary view controller.
    MMViewControllerColumnSizeFullscreen,
    MMViewControllerColumnSizeDefault = MMViewControllerColumnSizePrimary
};

typedef NS_ENUM(NSUInteger, MMViewControllerDisplayMode){
    MMViewControllerDisplayModeAutomatic,
    MMViewControllerDisplayModeSinglePage,
    MMViewControllerDisplayModeAllVisible,
};

@protocol MMSplitViewControllerDelegate <NSObject>
@optional

- (MMViewControllerColumnSize)splitViewController:(MMSplitViewController *)splitViewController columnSizeForViewController:(UIViewController *)viewController;

- (void)splitViewController:(MMSplitViewController *)splitViewController willChangeToDisplayMode:(MMViewControllerDisplayMode)displayMode transitionCoordinator:(nullable id <UIViewControllerTransitionCoordinator>)coordinator;

/**
 *  Called just before the snap controller displays a view controller's view.
 *
 *  @param splitViewController The snap controller.
 *  @param viewController The view controller being displayed.
 */
- (void)splitViewController:(MMSplitViewController *)splitViewController willDisplayViewController:(UIViewController *)viewController;

/**
 *  Called after the snap controller removes a view controller's view.
 *
 *  @param splitViewController The snap controller.
 *  @param viewController The view controller being hidden.
 */
- (void)splitViewController:(MMSplitViewController *)splitViewController didEndDisplayingViewController:(UIViewController *)viewController;

/**
 *  Called just before a view controller is snapped in the interface.
 *
 *  @param splitViewController The snap controller.
 *  @param viewController The view controller being snapped.
 */
- (void)splitViewController:(MMSplitViewController *)splitViewController willSnapToViewController:(UIViewController *)viewController;

/**
 *  Called after the snap controller has snapped a view controller in the interface.
 *
 *  @param splitViewController The snap controller.
 *  @param viewController The view controller that was snapped.
 */
- (void)splitViewController:(MMSplitViewController *)splitViewController didSnapToViewController:(UIViewController *)viewController;

@end

@interface MMSplitViewController : UIViewController

@property (nonatomic, copy, null_resettable) NSArray <UIViewController *> *viewControllers;

- (void)scrollToViewController:(UIViewController *)viewController animated:(BOOL)animated;

// Returns whatever display mode the split view controller is in.
@property (nonatomic, assign, readonly) MMViewControllerDisplayMode displayMode;

// Returns the visible view controllers.
@property (nonatomic, copy, readonly) NSArray <UIViewController *> *visibleViewControllers;

@property (nonatomic, readonly) UIViewController *partiallyVisibleViewController;

// An animatable property that can be used to adjust the relative width of the primary view controller in the split view controller. This preferred width will be limited by the maximum and minimum properties (and potentially other system heuristics).
@property (nonatomic, assign) CGFloat preferredPrimaryColumnWidthFraction; // default: UISplitViewControllerAutomaticDimension

// An animatable property that can be used to adjust the minimum absolute width of the primary view controller in the split view controller.
@property (nonatomic, assign) CGFloat minimumPrimaryColumnWidth; // default: UISplitViewControllerAutomaticDimension

// An animatable property that can be used to adjust the maximum absolute width of the primary view controller in the split view controller.
@property (nonatomic, assign) CGFloat maximumPrimaryColumnWidth; // default: UISplitViewControllerAutomaticDimension

// An animatable property that can be used to adjust the minimum absolute width of the secondary view controller in the split view controller.
@property (nonatomic, assign) CGFloat minimumSecondaryColumnWidth; // default: UISplitViewControllerAutomaticDimension

@property (weak, nonatomic, nullable) id <MMSplitViewControllerDelegate> delegate;

// Returns YES if the view controller can be toggled hidden and visible if the current display mode allows it.
- (BOOL)canToggleVisibilityForViewController:(UIViewController *)viewController;

@end

@interface MMSplitViewController (MMSplitSubclassingHooks)

- (void)viewControllersDidChange:(NSArray <UIViewController *> *)previousViewControllers;
- (void)willDisplayViewController:(UIViewController *)viewController;
- (void)willSnapToViewController:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
