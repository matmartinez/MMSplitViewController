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

/**
 *  Constants indicating the preferred size for a child view controller in a column.
 */
typedef NS_ENUM(NSUInteger, MMViewControllerColumnSize) {
    /**
     *  A primary-sized column for a master view controller. Typically, changes in this view controller (the master) drive changes in a secondary view controller (the detail).
     *
     * @note The split view controller automatically can group multiple primary-sized columns together into a single column if appropriate for the current display mode.
     */
    MMViewControllerColumnSizePrimary,
    
    /**
     *  A secondary-sized column for a detail view controller. Typically, changes in a primary view controller (the master) drive changes in a secondary view controller (the detail).
     */
    MMViewControllerColumnSizeSecondary,
    
    /**
     *  An auxiliary-sized column for a view controller to display alongside a detail view controller. Based on the current app size, an auxiliary view controller can be displayed as a third column right next to a detail view controller.
     *
     * @note An auxiliary sized column can only be displayed by taking available space from secondary view controller if the current app size allows it. If this is not possible, the column will be displayed regularly as a primary-sized column, with no size changes to its adjacent secondary-sized column.
     *
     */
    MMViewControllerColumnSizeAuxiliary,
    
    /**
     *  A fullscreen-sized column in which the view controller covers the screen.
     */
    MMViewControllerColumnSizeFullscreen,
    
    /**
     *  The default column size for a child view controller.
     */
    MMViewControllerColumnSizeDefault = MMViewControllerColumnSizePrimary
};

/**
 *  Constants describing the possible display modes for a split view controller.
 */
typedef NS_ENUM(NSUInteger, MMViewControllerDisplayMode){
    /**
     *  The split view controller automatically decides the most appropriate display mode based on the device and the current app size. You can assign this constant as the value of the @c preferredDisplayMode property but this value is never reported by the @c displayMode property.
     */
    MMViewControllerDisplayModeAutomatic,
    
    /**
     *  The view controllers are displayed as pages of content, so that only one at a time is visible.
     */
    MMViewControllerDisplayModeSinglePage,
    
    /**
     *  The view controllers are displayed side-by-side onscreen.
     */
    MMViewControllerDisplayModeAllVisible,
};

/**
 *  The @c MMSplitViewControllerDelegate protocol defines methods that allow you to manage changes to a split view interface. Use the methods of this protocol to respond to changes in the current display mode and to the current snapped view controller. When the split view interface collapses and scrolls, or when a new view controller is added to the interface, you can also use these methods to configure the child view controllers appropriately.
 */
@protocol MMSplitViewControllerDelegate <NSObject>
@optional

/**
 *  Called by the split view controller when it needs the column size to use for displaying a child view controller.
 *
 *  @param splitViewController The split view controller instance.
 *  @param viewController      The view controller being displayed.
 *
 *  @return A constant indicating the size of the column.
 */
- (MMViewControllerColumnSize)splitViewController:(MMSplitViewController *)splitViewController columnSizeForViewController:(UIViewController *)viewController;

/**
 *  Tells the delegate that the display mode for the split view controller is about to change.
 *
 *  @note The split view controller calls this method when its display mode is about to change. Because changing the display mode usually means hiding or showing child view controllers, you can implement this method and use it to add or remove controls.
 *
 *  @param splitViewController   The split view controller instance.
 *  @param displayMode           The new display mode that is about to be applied to the split view controller.
 *  @param transitionCoordinator The transition coordinator object managing the display mode change. You can use this object to animate your changes or get information about the transition that is in progress.
 */
- (void)splitViewController:(MMSplitViewController *)splitViewController willChangeToDisplayMode:(MMViewControllerDisplayMode)displayMode transitionCoordinator:(nullable id <UIViewControllerTransitionCoordinator>)transitionCoordinator;

/**
 *  Called just before the split view controller displays a view controller's view.
 *
 *  @param splitViewController The split view controller instance.
 *  @param viewController The view controller being displayed.
 */
- (void)splitViewController:(MMSplitViewController *)splitViewController willDisplayViewController:(UIViewController *)viewController;

/**
 *  Called after the split controller removes a view controller's view.
 *
 *  @param splitViewController The split view controller instance.
 *  @param viewController The view controller being hidden.
 */
- (void)splitViewController:(MMSplitViewController *)splitViewController didEndDisplayingViewController:(UIViewController *)viewController;

/**
 *  Called just before a view controller is snapped on the split interface.
 *
 *  @param splitViewController The split view controller instance.
 *  @param viewController The view controller being snapped.
 */
- (void)splitViewController:(MMSplitViewController *)splitViewController willSnapToViewController:(UIViewController *)viewController;

/**
 *  Called after a view controller was snapped on the split interface.
 *
 *  @param splitViewController The split view controller instance..
 *  @param viewController The view controller that was snapped.
 */
- (void)splitViewController:(MMSplitViewController *)splitViewController didSnapToViewController:(UIViewController *)viewController;

@end

/**
 *  A split view controller is a container view controller that manages a stack of child view controllers users can manipulate using gestures.
 
    In this type of interface, changes in a primary view controller (the master) drive changes in a secondary view controller (the detail). The view controllers can be arranged so that they are side-by-side, or so that only one at a time is visible. Also and depending on the available app size, a view controller can be only partially visible.
 
    When building your app’s user interface, the split view controller is typically the root view controller of your app’s window, but it may be embedded in another view controller. The split view controller has no significant appearance of its own. Most of its appearance is defined by the child view controllers you install. You can configure the child view controllers programmatically by assigning the view controllers to the viewControllers property. The child view controllers can be custom view controllers or other container view controller, such as navigation controllers.
 */
@interface MMSplitViewController : UIViewController

@property (nonatomic, copy, null_resettable) NSArray <UIViewController *> *viewControllers;

- (void)scrollToViewController:(UIViewController *)viewController animated:(BOOL)animated;

// Returns whatever display mode the split view controller is in.
@property (nonatomic, assign) MMViewControllerDisplayMode preferredDisplayMode;

// Defines the preferred display mode the split view controller is in.
@property (nonatomic, assign, readonly) MMViewControllerDisplayMode displayMode;

// Returns the visible view controllers.
@property (nonatomic, copy, readonly) NSArray <UIViewController *> *visibleViewControllers;

// Returns the current partially visible view controller, if the current mode allows it.
@property (nonatomic, readonly, nullable) UIViewController *partiallyVisibleViewController;

// An animatable property that can be used to adjust the relative width of the primary view controller in the split view controller. This preferred width will be limited by the maximum and minimum properties (and potentially other system heuristics).
@property (nonatomic, assign) CGFloat preferredPrimaryColumnWidthFraction; // default: UISplitViewControllerAutomaticDimension

// An animatable property that can be used to adjust the minimum absolute width of the primary view controller in the split view controller.
@property (nonatomic, assign) CGFloat minimumPrimaryColumnWidth; // default: UISplitViewControllerAutomaticDimension

// An animatable property that can be used to adjust the maximum absolute width of the primary view controller in the split view controller.
@property (nonatomic, assign) CGFloat maximumPrimaryColumnWidth; // default: UISplitViewControllerAutomaticDimension

// An animatable property that can be used to adjust the minimum absolute width of the secondary view controller in the split view controller.
@property (nonatomic, assign) CGFloat minimumSecondaryColumnWidth; // default: UISplitViewControllerAutomaticDimension

// By default YES.
@property (nonatomic, assign) BOOL includesOpaqueRoundedCornersOverlay;

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
