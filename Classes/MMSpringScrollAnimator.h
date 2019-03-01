//
//  MMSpringScrollAnimator.h
//  MMSnapController
//
//  Created by Matías Martínez on 2/2/15.
//  Copyright (c) 2015 Matías Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  An object that provides physics-related capabilities to animate scroll views.
 */
@interface MMSpringScrollAnimator : NSObject

/**
 *  Returns an animator instance configured with the specified scroll view.
 *
 *  @param scrollView The scroll view that will be the target of the animation.
 *
 *  @return An animator instance.
 */
- (instancetype)initWithTargetScrollView:(UIScrollView *)scrollView;

/**
 *  The scroll view that will be the target of the animation.
 */
@property (weak, nonatomic, readonly) UIScrollView *scrollView;

/**
 *  The scroll view delegate used to notify animation state. By default, @c -scrollView's own delegate.
 */
@property (weak, nonatomic) id <UIScrollViewDelegate> delegate;

/**
 *  Returns YES if currently animating.
 */
@property (readonly, nonatomic) BOOL isAnimating;

/**
 *  Starts the animation an finished at the specified content offset.
 *
 *  @param contentOffset The content offset at which stop animating.
 *  @param duration The total duration of the animation, measured in seconds.
 */
- (void)animateScrollToContentOffset:(CGPoint)contentOffset duration:(NSTimeInterval)duration;

/**
 *  Stops the animation at its current state.
 *
 *  @note Must be called when user starts dragging and animation should stop.
 */
- (void)cancelAnimation;

/**
  *  The mass of the object attached to the end of the spring. Must be greater than 0.
  *  Defaults to one.
 */
@property (assign, nonatomic) CGFloat mass;

/**
 *  The spring stiffness coefficient. Must be greater than 0.
 *  Defaults to 100.
 */
@property (assign, nonatomic) CGFloat stiffness;

/*
 *  The damping coefficient. Must be greater than or equal to 0.
 *  Defaults to 10.
 */
@property (assign, nonatomic) CGFloat damping;

/*
 * The initial velocity of the object attached to the spring. Defaults
 * to zero, which represents an unmoving object. Negative values
 * represent the object moving away from the spring attachment point,
 * positive values represent the object moving towards the spring
 * attachment point.
 */
@property (assign, nonatomic) CGFloat initialVelocity;

@end
