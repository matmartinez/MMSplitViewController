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
 *  The default value to apply to a given dimension.
 */
extern CGFloat const MMSplitViewControllerAutomaticDimension;

/**
 *  A split view controller is a container view controller that manages a stack of child view controllers users can manipulate using gestures.
 
    In this type of interface, changes in a primary view controller (the master) drive changes in a secondary view controller (the detail). The view controllers can be arranged so that they are side-by-side, or so that only one at a time is visible. Also and depending on the available app size, a view controller can be only partially visible.
 
    When building your app’s user interface, the split view controller is typically the root view controller of your app’s window, but it may be embedded in another view controller. The split view controller has no significant appearance of its own. Most of its appearance is defined by the child view controllers you install. You can configure the child view controllers programmatically by assigning the view controllers to the viewControllers property. The child view controllers can be custom view controllers or other container view controller, such as navigation controllers.
 */
@interface MMSplitViewController : UIViewController

/**
 *  The array of view controllers managed by the receiver.
 *
 *  @discussion When configuring the split view controller, you can use this property to assign view controllers that you want displayed. After the view controllers are set, the split view controller uses information from the -c MMSplitViewControllerDelegate protocol to assign the primary and secondary column sizes.
 
     After the split view controller is onscreen, you can add more child view controllers using the @c -showViewController:sender: method. Although you can still change the view controllers in this property directly, you should do so only if you manually manage your app’s view controller transitions.
 
 *  @note This property will always return the complete view controller stack. To obtain the visible view controllers, see @c -visibleViewControllers.
 *
 */
@property (nonatomic, copy) NSArray <__kindof UIViewController *> *viewControllers;

/**
 *  Scrolls the split view controller to the specified view controller.
 *
 *  @param viewController A view controller part of the view controller stack.
 *  @param animated       Specify @c YES if you want to animate the transition.
 *
 *  @note This method does nothing if the view controller is not part of the child view controller stack.
 */
- (void)scrollToViewController:(UIViewController *)viewController animated:(BOOL)animated;

/**
 *  The preferred arrangement of the split view controller interface.
 *
 *  @discussion Use this property to specify the display mode that you prefer to use. The split view controller makes every effort to adopt the interface you specify but may use a different type of interface if there is not enough space to support your preferred choice. If changing the value of this property leads to an actual change in the current display mode, the split view controller animates the resulting change.
 
    Setting the value of this property to @c MMViewControllerDisplayModeAutomatic causes the split view controller to choose the most appropriate display mode for the currently available space. The default value of this property is @c MMViewControllerDisplayModeAutomatic.
 */
@property (nonatomic, assign) MMViewControllerDisplayMode preferredDisplayMode;

/**
 *  The current arrangement of the split view controller’s contents.
 *
 *  @note This property reflects the arrangement of the split interface. The value in this property is never set to @c MMViewControllerDisplayModeAutomatic. To change the current display mode, change the value of the @c -preferredDisplayMode property.
 */
@property (nonatomic, assign, readonly) MMViewControllerDisplayMode displayMode;

/**
 *  The view controllers associated with the currently visible views in the split interface.
 *
 *  @note Because the split interface can be manipulated with gestures, this method can return view controllers that correspond to an interactive transition that are partially visible. If you're interested in the current snapped view controller, see the methods from the @c MMSplitViewControllerDelegate protocol.
 */
@property (nonatomic, copy, readonly) NSArray <UIViewController *> *visibleViewControllers;

/**
 *  A view controller that is partially visible on an edge of the screen, or @c nil.
 *
 *  When the split interface arranges views side-by-side, a view controller that's not snapped can be partially visible on an edge of the screen. You can use this property to determine showing this view controller when you drive changes to the interface.
 *
 *  @note This method will always return @c nil if the display mode is MMViewControllerDisplayModeSinglePage.
 */
@property (nonatomic, readonly, nullable) UIViewController *partiallyVisibleViewController;

/**
 *  The relative width of the primary view controller’s content.
 *
 *  Use this property to specify your preferred width for the primary view controller’s view. The value of this property is a floating-point number between @c 0.0 and @c 1.0 that represents the percentage of the overall width of the split view controller. For example, the value @c 0.4 represents 40% of the current width. The default value of this property is @c MMSplitViewControllerAutomaticDimension, which results in an appropriate width for the primary view controller.
 
 *  The actual width of the primary view controller is constrained by the values in the @c minimumPrimaryColumnWidth and @c maximumPrimaryColumnWidth properties. The split view controller makes every other attempt to honor the width you specify but may change this value to accommodate the available space. You can get the actual width assigned to the primary view controller’s view from the @c primaryColumnWidth property.
 */
@property (nonatomic, assign) CGFloat preferredPrimaryColumnWidthFraction;

/**
 *  The relative width of the primary view controller’s content.
 *
 *  This property contains the actual width applied to the primary view controller’s view.
 */
@property (nonatomic, readonly) CGFloat primaryColumnWidth;

/**
 *  The minimum width (in points) required for the primary view controller’s content.
 *
 *  Use this property in conjunction with the maximumPrimaryColumnWidth property to ensure the width of the primary view controller’s content is set to an acceptable value. The preliminary width is specified by the @c preferredPrimaryColumnWidthFraction property, which is applied to the split view controller’s width and checked against these bounds. If the resulting width is less than the value in this property, it is set to the value in this property.
 *
 *  The default value of this property is @c MMSplitViewControllerAutomaticDimension, which corresponds to a minimum width of 320 points.
 */
@property (nonatomic, assign) CGFloat minimumPrimaryColumnWidth;

/**
 *  The maximum width (in points) allowed for the primary view controller’s content.
 *
 *  Use this property in conjunction with the @c minimumPrimaryColumnWidth property to ensure the width of the primary view controller’s content is set to an acceptable value. The preliminary width is specified by the @c preferredPrimaryColumnWidthFraction property, which is applied to the split view controller’s width and checked against these bounds. If the resulting width is greater than the value in this property, it is set to the value in this property.
 *
 *  The default value of this property is @c MMSplitViewControllerAutomaticDimension, which corresponds to a minimum width of 400 points.
 */
@property (nonatomic, assign) CGFloat maximumPrimaryColumnWidth;

/**
 *  The minimum width (in points) required for the secondary view controller’s content.
 *
 *  Use this property to ensure the width of the secondary view controller’s content is set to an acceptable value. The preliminary width is specified by split view controller’s bounds minus the primary column width and checked against these bounds. If the resulting width is less than the value in this property, it is set to the value in this property.
 *
 *  The default value of this property is @c MMSplitViewControllerAutomaticDimension, which corresponds to a minimum width of 410 points.
 */
@property (nonatomic, assign) CGFloat minimumSecondaryColumnWidth;

/**
 *  This property determines if the split view controller should attempt to mask the view’s content to the device’s screen corner radius.
 *
 *  The default value of this property is @c YES.
 */
@property (nonatomic, assign) BOOL includesOpaqueRoundedCornersOverlay;

/**
 *  Determines if gestures are disabled to transition between child view controllers.
 *
 *  The default value of this property is @c NO.
 *
 *  @note If you set this property to @c YES, the split view controller disables the gesture recognizers for changing the current snapped view controller.
 */
@property (nonatomic, assign) BOOL disablesInteractiveSnapGestures;

/**
 *  The delegate you want to receive split view controller messages.
 *
 *  The split view controller uses its delegate to manage the sizing and snapping behavior of related view controllers. For more information about the methods you can implement in your delegate, see @c MMSplitViewControllerDelegate.
 */
@property (weak, nonatomic, nullable) id <MMSplitViewControllerDelegate> delegate;

/**
 *  Determines if the visibility of the specified view controller can be toggled or not, if the current display mode allows it.
 *
 *  Depending on the current app size, scrolling gestures may be disabled for the split view controller, eliminating the need for a button or another control that hides the specified view controller. Use this method to determine if such a control should be needed.
 *
 *  @param viewController The view controller to which determine visibility toggle elegibility.
 *
 *  @return This method returns @c YES if the split view controller can collapse the specified view controller, or @c NO to indicate that the visibility of the specified view controller cannot be changed.
 */
- (BOOL)canToggleVisibilityForViewController:(UIViewController *)viewController;

/**
 *  Tells the split view controller to invalidate the size of the columns.
 *
 *  The split view controller uses its delegate to manage the sizing of related view controllers. Use this method to reflect changes in your delegate.
 */
- (void)invalidateColumnSizes;

@end

@interface MMSplitViewController (MMSplitViewControllerSubclassingHooks)

/**
 *  Called by the split view controller when the view controllers change.
 *
 *  @param previousViewControllers The view controller array before the split view controller changed.
 */
- (void)viewControllersDidChange:(nullable NSArray <UIViewController *> *)previousViewControllers NS_REQUIRES_SUPER;

/**
 *  Called by the split view controller when it will display the specified view controller.
 *
 *  @param viewController The view controller that is being displayed.
 */
- (void)willDisplayViewController:(UIViewController *)viewController NS_REQUIRES_SUPER;

/**
 *  Called by the split view controller when it snap the specified view controller.
 *
 *  @param viewController The view controller that is being snapped.
 */
- (void)willSnapToViewController:(UIViewController *)viewController NS_REQUIRES_SUPER;

@end

NS_ASSUME_NONNULL_END
