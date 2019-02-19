//
//  MMSplitScrollView.h
//  MMSplitViewController
//
//  Created by Matías Martínez on 1/29/19.
//  Copyright © 2019 Matías. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MMSplitScrollView;

/**
 *  The @c MMSplitScrollViewDelegate protocol defines methods that allow you to manage the views on a split view. The methods of this protocol are all optional.
 */
@protocol MMSplitScrollViewDelegate <UIScrollViewDelegate>
@optional

/**
 *  Tells the delegate the scroll view is about to display a view for a particular page.
 *
 *  @param scrollView The scroll view.
 *  @param view       The view being displayed.
 *  @param page       A page that locates the view in @c scrollView.
 */
- (void)scrollView:(MMSplitScrollView *)scrollView willDisplayView:(UIView *)view atPage:(NSInteger)page;

/**
 *  Tells the delegate the scroll view is about to end displaying a view for a particular page.
 *
 *  @param scrollView The scroll view.
 *  @param view       The view about to end being displayed.
 *  @param page       A page that locates the view in @c scrollView.
 */
- (void)scrollView:(MMSplitScrollView *)scrollView didEndDisplayingView:(UIView *)view atPage:(NSInteger)page;

/**
 *  Tells the delegate the scroll view is about to snap to a view for a particular page.
 *
 *  @param scrollView The scroll view.
 *  @param view       The view being snapped.
 *  @param page       A page that locates the view in @c scrollView.
 */
- (void)scrollView:(MMSplitScrollView *)scrollView willSnapToView:(UIView *)view atPage:(NSInteger)page;

/**
 *  Tells the delegate the scroll view has finished snapping to a view for a particular page.
 *
 *  @param scrollView The scroll view.
 *  @param view       The view being snapped.
 *  @param page       A page that locates the view in @c scrollView.
 */
- (void)scrollView:(MMSplitScrollView *)scrollView didSnapToView:(UIView *)view atPage:(NSInteger)page;

/**
 *  Tells the delegate the scroll view has finished snapping to a view for a particular page.
 *
 *  @param scrollView The scroll view.
 *  @param view       The view being sized.
 *  @param page       A page that locates the view in @c scrollView.
 */
- (CGSize)scrollView:(MMSplitScrollView *)scrollView sizeForView:(UIView *)view atPage:(NSInteger)page;

@end

/**
 *  A view that arranges one or more views in a linear stack of panes running horizontally, and stops on the bounds of these panes when the user scrolls.
 */
@interface MMSplitScrollView : UIScrollView

/**
 *  The list of views arranged by the split view.
 */
@property (copy, nonatomic, nullable) NSArray <__kindof UIView *> *panes;

/**
 *  An set of indexes for the visible panes in the split view.
 *
 *  The value of this property is an index set, each of which corresponds to a visible pane in the scroll view. If there are no visible items, the value of this property is an empty index set.
 */
@property (copy, nonatomic, readonly) NSIndexSet *indexesForVisiblePanes;

/**
 *  The object that acts as the delegate of the split view.
 *
 *  The delegate must adopt the @c MMSplitScrollViewDelegate protocol. The delegate is not retained.
 */
@property (weak, nonatomic, nullable) id <MMSplitScrollViewDelegate> delegate;

/**
 *  The underlying gesture recognizer for snap gestures.
 *
 *  The @c snapTapGestureRecognizer is used to handle tap gestures on partially visible panes so they can be scrolled into view.
 */
@property (readonly, nonatomic) UITapGestureRecognizer *snapTapGestureRecognizer;

/**
 *  This property determines if the scroll view should attempt to mask the content view to the device’s screen corner radius.
 *
 *  The default value of this property is @c NO.
 */
@property (assign, nonatomic) BOOL overlayScreenCornersWhenBouncing;

/**
 *  Invalidates the current pane sizes and triggers a layout update.
 */
- (void)invalidatePaneSizes;

/**
 *  Scrolls through the split view until a pane is snapped at the left side of the screen.
 *
 *  @param pane     The pane view you want to snap into view.
 *  @param animated @c YES if you want to animate the change in position; @c NO if it should be immediate.
 */
- (void)scrollToPane:(UIView *)pane animated:(BOOL)animated;

/**
 *  Returns the drawing area for a specified pane of the split view.
 *
 *  @param pane A pane view of the split view.
 *
 *  @return A rectangle defining the area in which the split view draws the row or @c CGRectNull if @c pane is invalid.
 */
- (CGRect)rectForPane:(UIView *)pane;

/**
 *  An array of panes enclosed by a given rectangle.
 *
 *  @param rect A rectangle defining an area of the split view in local coordinates.
 *
 *  @return An array of panes. Returns an empty array if there aren’t any panes to return.
 */
- (NSArray <__kindof UIView *> *)panesInRect:(CGRect)rect;

@end

NS_ASSUME_NONNULL_END
