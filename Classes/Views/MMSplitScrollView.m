//
//  MMSplitScrollView.m
//  MMSplitViewController
//
//  Created by Matías Martínez on 1/29/19.
//  Copyright © 2019 Matías. All rights reserved.
//

#import "MMSplitScrollView.h"
#import "MMSplitPaneView.h"
#import "MMInvocationForwarder.h"
#import "MMSpringScrollAnimator.h"
#import "MMSplitHuggingSupport.h"
#import "MMRoundedCornerOverlayView.h"

@interface MMSplitScrollView () <UIScrollViewDelegate, UIGestureRecognizerDelegate> {
    struct {
        unsigned int delegateWillDisplayView : 1;
        unsigned int delegateDidEndDisplayingView : 1;
        unsigned int delegateWillSnapToPage : 1;
        unsigned int delegateDidSnapToPage : 1;
        unsigned int delegateSizeForPage : 1;
    } _delegateFlags;
}

@property (strong, nonatomic) NSArray <NSValue *> *framesForPanes;
@property (assign, nonatomic) CGSize calculatedBoundsSize;
@property (assign, nonatomic, getter=isContentSizeInvalidated) BOOL contentSizeInvalidated;
@property (assign, nonatomic) NSInteger snappedPaneIndex;
@property (strong, nonatomic) NSMutableSet <UIView *> *visiblePanes;
@property (strong, nonatomic) MMSpringScrollAnimator *scrollAnimator;
@property (strong, nonatomic) MMRoundedCornerOverlayView *bounceCornersOverlayView;

@property (strong, nonatomic) MMInvocationForwarder *delegateForwarder;
@property (weak, nonatomic) id <MMSplitScrollViewDelegate> clientDelegate;

@end

@implementation MMSplitScrollView

@dynamic delegate;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (void)_commonInit
{
    self.contentSizeInvalidated = YES;
    self.calculatedBoundsSize = CGSizeZero;
    self.visiblePanes = [NSMutableSet set];
    self.snappedPaneIndex = NSNotFound;
    
    // Tap to snap gesture:
    UITapGestureRecognizer *snapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(snapTapGestureRecognized:)];
    snapGestureRecognizer.delegate = self;
    
    _snapTapGestureRecognizer = snapGestureRecognizer;
    
    [self addGestureRecognizer:snapGestureRecognizer];
    
    // Custom animator for content offset updates.
    MMSpringScrollAnimator *springScrollAnimator = [[MMSpringScrollAnimator alloc] initWithTargetScrollView:self];
    springScrollAnimator.mass = 1;
    springScrollAnimator.stiffness = 280;
    springScrollAnimator.damping = 50;
    springScrollAnimator.delegate = self;
    
    self.scrollAnimator = springScrollAnimator;
    
    // UIScrollView properties:
    self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    self.showsHorizontalScrollIndicator = NO;
    self.bounces = YES;
    self.decelerationRate = UIScrollViewDecelerationRateFast;
    self.scrollsToTop = NO;
    
    // Delegate ownership.
    MMInvocationForwarder *delegateForwarder = [[MMInvocationForwarder alloc] init];
    [delegateForwarder addTarget:self];
    
    self.delegateForwarder = delegateForwarder;
    
    [super setDelegate:(id <UIScrollViewDelegate>)delegateForwarder];
}

- (void)scrollToPane:(UIView *)pane animated:(BOOL)animated
{
    if (!pane) {
        return;
    }
    
    animated = animated && [UIView areAnimationsEnabled];
    
    if ([self.panes containsObject:pane]) {
        const CGRect frame = [self rectForPane:pane];
        
        CGRect bounds = self.bounds;
        CGSize contentSize = self.contentSize;
        
        CGFloat maximumContentOffsetX = contentSize.width - CGRectGetWidth(bounds);
        CGPoint contentOffset = CGPointMake(MIN(maximumContentOffsetX, frame.origin.x), 0);
        
        if (!CGPointEqualToPoint(contentOffset, self.contentOffset)) {
            if (_delegateFlags.delegateWillSnapToPage) {
                [self _notifySnapToTargetContentOffset:contentOffset completed:NO];
            }
            
            if (animated) {
                [self.scrollAnimator animateScrollToContentOffset:contentOffset duration:0.55];
            } else {
                [self setContentOffset:contentOffset];
            }
        }
    }
}

- (NSArray <UIView *> *)panesInRect:(CGRect)rect
{
    if (self.panes.count == 0) {
        return @[];
    }
    
    NSMutableArray *visiblePanes = [NSMutableArray arrayWithCapacity:self.panes.count];
    
    NSUInteger idx = 0;
    for (NSValue *frame in self.framesForPanes) {
        if (CGRectIntersectsRect(frame.CGRectValue, rect)) {
            [visiblePanes addObject:self.panes[idx]];
        }
        idx += 1;
    }
    
    return visiblePanes.copy;
}

- (NSIndexSet *)indexesForVisiblePanes
{
    if (self.panes.count == 0) {
        return [NSIndexSet indexSet];
    }
    
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    
    for (UIView *pane in self.visiblePanes) {
        [indexSet addIndex:[self.panes indexOfObject:pane]];
    }
    
    return indexSet;
}

- (CGRect)rectForPane:(UIView *)pane
{
    NSUInteger idx = [self.panes indexOfObject:pane];
    if (idx != NSNotFound) {
        return self.framesForPanes[idx].CGRectValue;
    }
    return CGRectNull;
}

- (void)calculateLayoutForCurrentBounds
{
    // Layout if bounds size changes:
    if (self.isContentSizeInvalidated) {
        self.contentSizeInvalidated = NO;
        
        UIView *leadingPane = nil;
        
        for (UIView *pane in self.panes) {
            if ([self.visiblePanes containsObject:pane]) {
                leadingPane = pane;
                break;
            }
        }
        
        [self reloadSizingData];
        [self scrollToPane:leadingPane animated:NO];
    }
}

- (void)notifyPaneBeingSnappedIfNeeded
{
    if (self.isTracking || self.isDecelerating) {
        return;
    }
    
    if (self.panes.count > 0 && self.snappedPaneIndex != self.indexesForVisiblePanes.firstIndex) {
        CGPoint contentOffset = self.contentOffset;
        
        [self _notifySnapToTargetContentOffset:contentOffset completed:NO];
        
        if (self.layer.animationKeys) {
            [CATransaction setCompletionBlock:^{
                [self _notifySnapToTargetContentOffset:contentOffset completed:YES];
            }];
        } else {
            [self _notifySnapToTargetContentOffset:contentOffset completed:YES];
        }
    }
}

- (void)layoutVisiblePanes
{
    CGRect bounds = self.bounds;
    CGPoint contentOffset = self.contentOffset;
    
    CGRect visibleRect = bounds;
    visibleRect.origin = contentOffset;
    
    const auto NSArray <UIView *> *visiblePanes = [self panesInRect:visibleRect];
    const auto id <MMSplitScrollViewDelegate> delegate = self.delegate;
    
    const BOOL delegateDidEndDisplayingView = _delegateFlags.delegateDidEndDisplayingView;
    const BOOL delegateWillDisplayView = _delegateFlags.delegateWillDisplayView;
    
    // Collect and remove panes that shouldn't be visible anymore:
    NSMutableSet *removedPanes = [NSMutableSet set];
    
    for (UIView *pane in self.visiblePanes) {
        if (![visiblePanes containsObject:pane]) {
            [pane removeFromSuperview];
            [removedPanes addObject:pane];
            
            if (delegateDidEndDisplayingView) {
                [delegate scrollView:self didEndDisplayingView:pane atPage:[self.panes indexOfObject:pane]];
            }
        }
    }
    
    [self.visiblePanes minusSet:removedPanes];
    
    // Layout visible panes:
    for (UIView *pane in visiblePanes) {
        const BOOL isBeingDisplayed = [self.visiblePanes containsObject:pane];
        
        NSUInteger idx = [self.panes indexOfObject:pane];
        CGRect rect = self.framesForPanes[idx].CGRectValue;
        
        if ([self shouldPinToVisibleBoundsInPane:pane]) {
            CGRect availableRect = rect;
            rect.origin.x = MIN(CGRectGetMinX(availableRect), contentOffset.x);
        }
        
        if (!CGRectEqualToRect(pane.frame, rect)) {
            pane.frame = rect;
        }
        
        if ([pane conformsToProtocol:@protocol(MMSplitHuggingSupport)]) {
            const BOOL isBehindContentOffset = (CGRectGetMinX(rect) < contentOffset.x);
            const BOOL canDisappear = CGRectGetMaxX(rect) <= self.contentSize.width - CGRectGetWidth(bounds);
            
            CGFloat percent = 0.0f;
            if (canDisappear && isBehindContentOffset) {
                CGFloat distance = CGRectGetMinX(bounds) - CGRectGetMinX(rect);
                CGFloat maximum = CGRectGetWidth(rect);
                
                percent = MAX(MIN(distance / maximum, 1.0f), 0.0f);
            }
            
            [(id <MMSplitHuggingSupport>)pane setHuggingProgress:percent];
            [(id <MMSplitHuggingSupport>)pane setPagingEnabled:self.isPagingEnabled];
        }
        
        if (!isBeingDisplayed) {
            if (delegateWillDisplayView) {
                [delegate scrollView:self willDisplayView:pane atPage:idx];
            }
            
            UIView *siblingPane = (idx + 1 < self.panes.count) ? self.panes[idx + 1] : nil;
            if (siblingPane != nil) {
                [self insertSubview:pane belowSubview:siblingPane];
            } else {
                [self addSubview:pane];
            }
            
            [self.visiblePanes addObject:pane];
        }
    }
}

- (BOOL)shouldPinToVisibleBoundsInPane:(UIView *)pane
{
    if (self.isPagingEnabled) {
        return NO;
    }
    
    if ([self.panes indexOfObject:pane] != 0) {
        return NO;
    }
    
    if ([pane isKindOfClass:[MMSplitPaneView class]]) {
        MMSplitPaneView *splitPaneView = (MMSplitPaneView *)pane;
        
        return [splitPaneView.contentView isKindOfClass:[MMSplitScrollView class]];
    }
    
    return pane;
}

- (void)layoutBounceCornersOverlayIfNeeded
{
    if (!self.overlayScreenCornersWhenBouncing) {
        return;
    }
    
    CGRect bounds = self.bounds;
    CGSize contentSize = self.contentSize;
    CGPoint contentOffset = self.contentOffset;
    
    const CGFloat maximumContentOffset = (contentSize.width - CGRectGetWidth(bounds));
    const BOOL isBouncing = (contentOffset.x < 0.0f || contentOffset.x > maximumContentOffset);
    
    UIRectCorner corners = 0;
    CGRect frame = bounds;
    
    if (isBouncing) {
        const CGRect screenRect = self.window.bounds;
        const CGRect externalRect = [self convertRect:bounds toView:self.window];
        
        const BOOL isAtBeginning = (contentOffset.x < 0.0f);
        
        if (isAtBeginning && CGRectGetMinX(externalRect) == CGRectGetMinX(screenRect)) {
            BOOL atLeastOnePinnedPane = NO;
            if (isAtBeginning) {
                for (UIView *pane in _visiblePanes) {
                    if ([self shouldPinToVisibleBoundsInPane:pane]) {
                        atLeastOnePinnedPane = YES;
                        break;
                    }
                }
            }
            
            if (!atLeastOnePinnedPane) {
                corners = (UIRectCornerTopLeft | UIRectCornerBottomLeft);
            }
        }
        
        if (!isAtBeginning && CGRectGetMaxX(externalRect) == CGRectGetMaxX(screenRect)) {
            corners = (UIRectCornerTopRight | UIRectCornerBottomRight);
        }
        
        frame.origin.x = isAtBeginning ? 0.0f : maximumContentOffset;
    }
    
    if (corners != 0) {
        self.bounceCornersOverlayView.frame = frame;
        self.bounceCornersOverlayView.overlayRoundedCorners = corners;
        
        [self addSubview:self.bounceCornersOverlayView];
    } else {
        [self.bounceCornersOverlayView removeFromSuperview];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self calculateLayoutForCurrentBounds];
    [self layoutVisiblePanes];
    [self layoutBounceCornersOverlayIfNeeded];
    [self notifyPaneBeingSnappedIfNeeded];
}

- (void)setBounds:(CGRect)bounds
{
    if (!CGRectEqualToRect(bounds, self.bounds)) {
        if (!CGSizeEqualToSize(bounds.size, self.bounds.size)) {
            self.contentSizeInvalidated = YES;
        }
        
        [super setBounds:bounds];
    }
}

- (void)setFrame:(CGRect)frame
{
    if (!CGRectEqualToRect(frame, self.frame)) {
        if (!CGSizeEqualToSize(frame.size, self.frame.size)) {
            self.contentSizeInvalidated = YES;
        }
        
        [super setFrame:frame];
    }
}

- (void)setPagingEnabled:(BOOL)pagingEnabled
{
    if (pagingEnabled != self.isPagingEnabled) {
        [super setPagingEnabled:pagingEnabled];
        
        [self invalidatePaneSizes];
    }
}

- (void)reloadSizingData
{
    CGRect bounds = (CGRect){
        .size = self.bounds.size
    };
    
    const BOOL isPagingEnabled = self.isPagingEnabled;
    const auto id <MMSplitScrollViewDelegate> delegate = self.delegate;
    
    CGSize contentSize = bounds.size;
    CGPoint offset = CGPointZero;
    NSUInteger idx = 0;
    
    NSMutableArray <NSValue *> *framesForPanes = [NSMutableArray arrayWithCapacity:self.panes.count];
    
    for (UIView *pane in self.panes) {
        CGSize size = contentSize;
        
        if (!isPagingEnabled && _delegateFlags.delegateSizeForPage) {
            size.width = [delegate scrollView:self sizeForView:pane atPage:idx].width;
        }
        
        CGRect rect = (CGRect){
            .origin = offset,
            .size = size
        };
        
        [framesForPanes addObject:[NSValue valueWithCGRect:rect]];
        
        offset.x = CGRectGetMaxX(rect);
        idx += 1;
    }
    
    self.framesForPanes = framesForPanes;
    self.contentSize = (CGSize){ offset.x, contentSize.height };
}

- (void)setPanes:(NSArray<UIView *> *)panes
{
    if (![panes isEqualToArray:_panes]) {
        NSMutableSet *removedPanes = [NSMutableSet set];
        for (UIView *visiblePane in self.visiblePanes) {
            if (![panes containsObject:visiblePane]) {
                [visiblePane removeFromSuperview];
                [removedPanes addObject:visiblePane];
            }
        }
        [self.visiblePanes minusSet:removedPanes];
        
        _panes = [panes copy];
        
        [self reloadSizingData];
        [self invalidatePaneSizes];
    }
}

- (void)setDelegate:(id<MMSplitScrollViewDelegate>)delegate
{
    id <MMSplitScrollViewDelegate> previousDelegate = self.clientDelegate;
    if (previousDelegate != nil && previousDelegate != (id)self) {
        [self.delegateForwarder removeTarget:previousDelegate];
    }
    
    if (delegate != nil) {
        [self.delegateForwarder addTarget:delegate];
    }
    
    self.clientDelegate = delegate;
    
    [super setDelegate:nil];
    [super setDelegate:(id <UIScrollViewDelegate>)self.delegateForwarder];
    
    _delegateFlags.delegateSizeForPage = [delegate respondsToSelector:@selector(scrollView:sizeForView:atPage:)];
    _delegateFlags.delegateWillSnapToPage = [delegate respondsToSelector:@selector(scrollView:willSnapToView:atPage:)];
    _delegateFlags.delegateDidSnapToPage = [delegate respondsToSelector:@selector(scrollView:didSnapToView:atPage:)];
    _delegateFlags.delegateDidEndDisplayingView = [delegate respondsToSelector:@selector(scrollView:didEndDisplayingView:atPage:)];
    _delegateFlags.delegateWillDisplayView = [delegate respondsToSelector:@selector(scrollView:willDisplayView:atPage:)];
}

- (id<MMSplitScrollViewDelegate>)delegate
{
    return _clientDelegate;
}

- (void)invalidatePaneSizes
{
    if (self.isContentSizeInvalidated) {
        return;
    }
    
    [self setContentSizeInvalidated:YES];
    [self setNeedsLayout];
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    // If UIScrollView's paging is off, do our own targetContentOffset calculations.
    if (!self.isPagingEnabled) {
        *targetContentOffset = [self _targetContentOffsetForProposedContentOffset:*targetContentOffset withScrollingVelocity:velocity];
    }
    
    if (!CGPointEqualToPoint(*targetContentOffset, scrollView.contentOffset)) {
        [self _notifySnapToTargetContentOffset:*targetContentOffset completed:NO];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // Notify the delegate snapping did happen.
    [self _notifySnapToTargetContentOffset:scrollView.contentOffset completed:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    // If user begin dragging, cancel the scroll animation and remove animation views.
    if (self.scrollAnimator.isAnimating) {
        [self.scrollAnimator cancelAnimation];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    // Notify the delegate snapping did happen after animation completes.
    [self _notifySnapToTargetContentOffset:scrollView.contentOffset completed:YES];
}

#pragma mark - Adjusting content offset.

- (void)_notifySnapToTargetContentOffset:(CGPoint)targetContentOffset completed:(BOOL)completed
{
    id <MMSplitScrollViewDelegate> delegate = self.delegate;
    
    CGRect proposedRect = self.bounds;
    proposedRect.origin.x = MIN(ceil(targetContentOffset.x), self.contentSize.width - CGRectGetWidth(proposedRect));
    proposedRect.origin.y = ceil(targetContentOffset.y);
    
    UIView *pane = [self panesInRect:proposedRect].firstObject;
    if (pane) {
        NSUInteger page = [self.panes indexOfObject:pane];
        if (completed) {
            if (_delegateFlags.delegateDidSnapToPage) {
                [delegate scrollView:self didSnapToView:pane atPage:page];
            }
        } else {
            if (_delegateFlags.delegateWillSnapToPage) {
                [delegate scrollView:self willSnapToView:pane atPage:page];
            }
        }
        
        self.snappedPaneIndex = page;
    }
}

- (CGPoint)_targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    CGRect targetRect = self.bounds;
    targetRect.origin = proposedContentOffset;
    
    CGFloat offsetAdjustment = CGRectGetMinX(targetRect);
    
    UIView *firstPane = [self panesInRect:targetRect].firstObject;
    if (firstPane) {
        CGRect frame = [self rectForPane:firstPane];
        
        // Go to next/prev one.
        if (CGRectGetMinX(targetRect) > CGRectGetMidX(frame) || fabs(velocity.x) > 0) {
            // Don't go over contentSize (keep this page if so).
            if (CGRectGetMaxX(frame) < self.contentSize.width) {
                offsetAdjustment = CGRectGetMaxX(frame);
            } else {
                offsetAdjustment = CGRectGetMinX(frame);
            }
            
            if (fabs(velocity.x) > 0 && velocity.x < 0) {
                offsetAdjustment = CGRectGetMinX(frame);
            }
        } else {
            offsetAdjustment = CGRectGetMinX(frame);
        }
    }
    
    return CGPointMake(offsetAdjustment, proposedContentOffset.y);
}

#pragma mark - UIScrollView overrides.

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (![super gestureRecognizerShouldBegin:gestureRecognizer]) {
        return NO;
    }
    
    const CGPoint location = [gestureRecognizer locationInView:self];
    const CGRect rect = (CGRect){ .origin = location };
    
    UIView *paneView = [self panesInRect:rect].firstObject;
    
    if (gestureRecognizer == self.snapTapGestureRecognizer) {
        CGRect visibleRect = self.bounds;
        visibleRect.origin = self.contentOffset;
        
        if (CGRectContainsRect(visibleRect, paneView.frame)) {
            return NO;
        }
        
        return YES;
    }
    
    if (paneView != nil && [self shouldPinToVisibleBoundsInPane:paneView]) {
        return NO;
    }

    return YES;
}

- (BOOL)isDecelerating
{
    return [super isDecelerating] || [self.scrollAnimator isAnimating];
}

#pragma mark - Tap to snap.

- (void)snapTapGestureRecognized:(UITapGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateRecognized) {
        const CGPoint location = [gestureRecognizer locationInView:self];
        const CGRect rect = (CGRect){ .origin = location };
        
        UIView *paneView = [self panesInRect:rect].firstObject;
        
        [self scrollToPane:paneView animated:YES];
    }
}

#pragma mark - Bounce corners.

- (void)setOverlayScreenCornersWhenBouncing:(BOOL)overlayScreenCornersWhenBouncing
{
    if (overlayScreenCornersWhenBouncing != _overlayScreenCornersWhenBouncing) {
        _overlayScreenCornersWhenBouncing = overlayScreenCornersWhenBouncing;
        
        if (overlayScreenCornersWhenBouncing) {
            self.bounceCornersOverlayView = [[MMRoundedCornerOverlayView alloc] initWithFrame:CGRectZero];
            
            [self setNeedsLayout];
        } else {
            [self.bounceCornersOverlayView removeFromSuperview];
            self.bounceCornersOverlayView = nil;
        }
    }
}

@end
