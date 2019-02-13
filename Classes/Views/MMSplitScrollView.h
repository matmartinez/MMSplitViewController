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

@interface MMSplitScrollView : UIScrollView

@property (copy, nonatomic, nullable) NSArray <UIView *> *panes;

@property (copy, nonatomic, readonly) NSIndexSet *indexesForVisiblePanes;

@property (weak, nonatomic, nullable) id <MMSplitScrollViewDelegate> delegate;
@property (readonly, nonatomic) UITapGestureRecognizer *snapTapGestureRecognizer;

- (void)invalidatePaneSizes;

- (void)scrollToPane:(UIView *)pane animated:(BOOL)animated;

- (CGRect)rectForPane:(UIView *)pane;

- (NSArray <UIView *> *)panesInRect:(CGRect)rect;

@end

NS_ASSUME_NONNULL_END
