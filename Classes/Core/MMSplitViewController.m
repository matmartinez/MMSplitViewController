//
//  MMSplitViewController.m
//  MMSplitViewController
//
//  Created by Matías Martínez on 1/22/19.
//  Copyright © 2019 Matías. All rights reserved.
//

#import "MMSplitViewController.h"
#import "MMSplitPaneView.h"
#import "MMSplitScrollView.h"

@interface MMSplitViewController () <MMSplitScrollViewDelegate> {
    struct {
        unsigned int delegateColumnSizeForViewController : 1;
        unsigned int delegateWillChangeToDisplayMode : 1;
        unsigned int delegateWillDisplayViewController : 1;
        unsigned int delegateDidEndDisplayingViewController : 1;
        unsigned int delegateWillSnapToViewController : 1;
        unsigned int delegateDidSnapToViewController : 1;
    } _delegateFlags;
}

@property (strong, nonatomic) MMSplitScrollView *scrollView;
@property (strong, nonatomic) MMSplitScrollView *primaryCollapsedScrollView;
@property (strong, nonatomic) MMSplitPaneView *primaryCollapsedPane;
@property (strong, nonatomic) NSMapTable <UIViewController *, MMSplitPaneView *> *panes;
@property (copy, nonatomic) NSArray <UIViewController *> *primaryCollapsedViewControllers;

@end

@implementation MMSplitViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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
    // Primary:
    _minimumPrimaryColumnWidth = 320.0f;
    _maximumPrimaryColumnWidth = 400.0f;
    _preferredPrimaryColumnWidthFraction = 0.38f;
    
    // Secondary:
    _minimumSecondaryColumnWidth = 410.0f;
    
    // Storage:
    _panes = [NSMapTable strongToStrongObjectsMapTable];
    _viewControllers = @[];
}

- (MMSplitPaneView *)primaryCollapsedPane
{
    if (!_primaryCollapsedPane) {
        _primaryCollapsedPane = [[MMSplitPaneView alloc] initWithFrame:CGRectZero];
        _primaryCollapsedPane.contentView = self.primaryCollapsedScrollView;
    }
    return _primaryCollapsedPane;
}

- (MMSplitScrollView *)primaryCollapsedScrollView
{
    if (!_primaryCollapsedScrollView) {
        _primaryCollapsedScrollView = [[MMSplitScrollView alloc] initWithFrame:CGRectZero];
        _primaryCollapsedScrollView.pagingEnabled = YES;
        _primaryCollapsedScrollView.alwaysBounceHorizontal = YES;
        _primaryCollapsedScrollView.overlayScreenCornersWhenBouncing = YES;
        _primaryCollapsedScrollView.delegate = self;
    }
    return _primaryCollapsedScrollView;
}

- (MMSplitScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[MMSplitScrollView alloc] initWithFrame:CGRectZero];
        _scrollView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        _scrollView.alwaysBounceHorizontal = YES;
        _scrollView.overlayScreenCornersWhenBouncing = YES;
        _scrollView.delegate = self;
    }
    return _scrollView;
}

- (void)setDelegate:(id<MMSplitViewControllerDelegate>)delegate
{
    if (delegate != _delegate) {
        _delegate = delegate;
        
        _delegateFlags.delegateColumnSizeForViewController = [delegate respondsToSelector:@selector(splitViewController:columnSizeForViewController:)];
        _delegateFlags.delegateWillChangeToDisplayMode = [delegate respondsToSelector:@selector(splitViewController:willChangeToDisplayMode:transitionCoordinator:)];
        _delegateFlags.delegateWillDisplayViewController = [delegate respondsToSelector:@selector(splitViewController:willDisplayViewController:)];
        _delegateFlags.delegateDidEndDisplayingViewController = [delegate respondsToSelector:@selector(splitViewController:didEndDisplayingViewController:)];
        _delegateFlags.delegateWillSnapToViewController = [delegate respondsToSelector:@selector(splitViewController:willSnapToViewController:)];
        _delegateFlags.delegateDidSnapToViewController = [delegate respondsToSelector:@selector(splitViewController:didSnapToViewController:)];
        
        if (self.isViewLoaded) {
            [self.scrollView invalidatePaneSizes];
        }
    }
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods
{
    return NO;
}

- (void)loadView
{
    self.view = self.scrollView;
}

- (NSArray<UIViewController *> *)visibleViewControllers
{
    if (!self.isViewLoaded) {
        return @[];
    }
    
    NSMutableArray <UIViewController *> *viewControllers = [NSMutableArray arrayWithCapacity:self.viewControllers.count];
    
    MMSplitScrollView *scrollView = self.scrollView;
    NSIndexSet *indexesForVisiblePanes = scrollView.indexesForVisiblePanes;
    
    [indexesForVisiblePanes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        UIViewController *viewController = [self viewControllerForPage:idx inScrollView:scrollView];
        if (viewController != nil) {
            [viewControllers addObject:viewController];
        }
    }];
    
    return viewControllers.copy;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self _configureScrollViewWithTraitCollection:self.traitCollection];
}

- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers
{
    if (!viewControllers) {
        viewControllers = @[];
    }
    
    if (![viewControllers isEqualToArray:_viewControllers]) {
        NSArray <UIViewController *> *previousViewControllers = _viewControllers;
        
        for (UIViewController *viewController in previousViewControllers) {
            if (![viewControllers containsObject:viewController]) {
                [viewController willMoveToParentViewController:nil];
                [self.panes removeObjectForKey:viewController];
                [viewController removeFromParentViewController];
            }
        }
        
        for (UIViewController *viewController in viewControllers) {
            if (viewController.parentViewController != self) {
                [viewController willMoveToParentViewController:self];
            }
        }
        
        _viewControllers = [viewControllers copy];
        
        for (UIViewController *viewController in viewControllers) {
            if (viewController.parentViewController != self) {
                [self addChildViewController:viewController];
                [viewController didMoveToParentViewController:self];
            }
            
            MMSplitPaneView *pane = [self.panes objectForKey:viewController];
            if (!pane) {
                pane = [[MMSplitPaneView alloc] init];
                
                if (viewController.isViewLoaded) {
                    pane.contentView = viewController.view;
                }
                
                [self.panes setObject:pane forKey:viewController];
            }
        }
        
        [self _configureScrollViewWithTraitCollection:self.traitCollection];
        [self viewControllersDidChange:previousViewControllers];
    }
}

- (void)viewControllersDidChange:(NSArray <UIViewController *> *)previousViewControllers
{
    // Override point for supplementary views.
}

- (void)willDisplayViewController:(UIViewController *)viewController
{
    // Override point for supplementary views.
}

- (void)willSnapToViewController:(UIViewController *)viewController
{
    // Override point for supplementary views.
}

- (MMViewControllerDisplayMode)displayMode
{
    return self.scrollView.isPagingEnabled ? MMViewControllerDisplayModeSinglePage : MMViewControllerDisplayModeAllVisible;
}

#pragma mark - Configuration.

- (void)_configureScrollViewWithTraitCollection:(UITraitCollection *)traitCollection
{
    [self _configureScrollViewWithTraitCollection:traitCollection transitionCoordinator:nil];
}

- (void)_configureScrollViewWithTraitCollection:(UITraitCollection *)traitCollection transitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    BOOL horizontallyCompact = traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact;
    BOOL pagingEnabled = horizontallyCompact;
    
    // Check which panes to compress:
    NSMutableArray <UIViewController *> *primaryViewControllersForCompression = nil;
    
    if (!pagingEnabled) {
        primaryViewControllersForCompression = [NSMutableArray arrayWithCapacity:self.viewControllers.count];
        
        for (UIViewController *viewController in self.viewControllers) {
            const MMViewControllerColumnSize size = [self columnSizeForViewController:viewController];
            
            if (size == MMViewControllerColumnSizePrimary) {
                [primaryViewControllersForCompression addObject:viewController];
            } else {
                break;
            }
        }
    }
    
    if (primaryViewControllersForCompression.count <= 1) {
        primaryViewControllersForCompression = nil;
    }
    
    self.primaryCollapsedViewControllers = primaryViewControllersForCompression;
    
    // Set view controllers:
    NSMutableArray <UIView *> *panes = [NSMutableArray arrayWithCapacity:self.viewControllers.count];
    NSMutableArray <UIView *> *nestedPanes = [NSMutableArray arrayWithCapacity:self.viewControllers.count];
    
    if (primaryViewControllersForCompression.count > 1) {
        [panes addObject:self.primaryCollapsedPane];
    }
    
    for (UIViewController *viewController in self.viewControllers) {
        MMSplitPaneView *pane = [self.panes objectForKey:viewController];
        
        if ([primaryViewControllersForCompression containsObject:viewController]) {
            [nestedPanes addObject:pane];
        } else {
            [panes addObject:pane];
        }
    }
    
    // Configure:
    self.primaryCollapsedScrollView.panes = nestedPanes;
    self.scrollView.panes = panes;
    
    // Update paging on the main scroll view:
    if (pagingEnabled != self.scrollView.isPagingEnabled) {
        MMViewControllerDisplayMode displayMode = pagingEnabled ? MMViewControllerDisplayModeSinglePage : MMViewControllerDisplayModeAllVisible;

        if (_delegateFlags.delegateWillChangeToDisplayMode) {
            [self.delegate splitViewController:self willChangeToDisplayMode:displayMode transitionCoordinator:coordinator];
        }
        
        [self.scrollView setPagingEnabled:pagingEnabled];
        [self.scrollView invalidatePaneSizes];
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    if (self.isViewLoaded) {
        [self.scrollView invalidatePaneSizes];
    }
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    [self _configureScrollViewWithTraitCollection:newCollection transitionCoordinator:coordinator];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
    [super traitCollectionDidChange:previousTraitCollection];
    [self _configureScrollViewWithTraitCollection:self.traitCollection];
}

#pragma mark - Accessors.

- (UIViewController *)viewControllerForPage:(NSInteger)page inScrollView:(MMSplitScrollView *)scrollView
{
    NSUInteger idx = page;
    NSArray <UIViewController *> *storage = nil;
    
    if (scrollView == self.scrollView) {
        storage = self.viewControllers;
        
        if (self.primaryCollapsedViewControllers.count > 0) {
            if (page == 0) {
                const auto NSIndexSet *visibleCollapsedIndexes = self.primaryCollapsedScrollView.indexesForVisiblePanes;
                
                if (visibleCollapsedIndexes.count > 0) {
                    const NSUInteger firstIndex = visibleCollapsedIndexes.firstIndex;
                    return self.primaryCollapsedViewControllers[firstIndex];
                }
                return nil;
            }
            
            idx = page + (self.primaryCollapsedViewControllers.count - 1);
        }
    } else if (scrollView == self.primaryCollapsedScrollView) {
        storage = self.primaryCollapsedViewControllers;
    }
    
    if (idx < storage.count) {
        return storage[idx];
    }
    return nil;
}

- (MMViewControllerColumnSize)columnSizeForViewController:(UIViewController *)viewController
{
    if (viewController != nil) {
        if (_delegateFlags.delegateColumnSizeForViewController) {
            return [self.delegate splitViewController:self columnSizeForViewController:viewController];
        }
    }
    return MMViewControllerColumnSizeDefault;
}

#pragma mark - <MMSplitScrollViewDelegate>

- (void)scrollView:(MMSplitScrollView *)scrollView willDisplayView:(UIView *)view atPage:(NSInteger)page
{
    UIViewController *viewController = [self viewControllerForPage:page inScrollView:scrollView];
    
    if (viewController != nil) {
        if (_delegateFlags.delegateWillDisplayViewController) {
            [self.delegate splitViewController:self willDisplayViewController:viewController];
        }
        
        [self willDisplayViewController:viewController];
        
        MMSplitPaneView *paneView = (MMSplitPaneView *)view;
        
        [viewController beginAppearanceTransition:YES animated:(scrollView.isDecelerating || scrollView.isTracking)];
        
        const BOOL configuresContentViewForViewController = (view != self.primaryCollapsedPane);
        
        if (configuresContentViewForViewController) {
            if (!paneView.contentView) {
                paneView.contentView = viewController.view;
            }
        }
        
        [viewController endAppearanceTransition];
    }
}

- (void)scrollView:(MMSplitScrollView *)scrollView didEndDisplayingView:(UIView *)view atPage:(NSInteger)page
{
    UIViewController *viewController = [self viewControllerForPage:page inScrollView:scrollView];
    
    if (viewController != nil) {
        MMSplitPaneView *paneView = (MMSplitPaneView *)view;
        
        [viewController beginAppearanceTransition:NO animated:(scrollView.isDecelerating || scrollView.isTracking)];
        
        const BOOL configuresContentViewForViewController = (view != self.primaryCollapsedPane);
        
        if (configuresContentViewForViewController) {
            paneView.contentView = nil;
        }
        
        [viewController endAppearanceTransition];
        
        if (_delegateFlags.delegateDidEndDisplayingViewController) {
            [self.delegate splitViewController:self didEndDisplayingViewController:viewController];
        }
    }
}

- (CGSize)scrollView:(MMSplitScrollView *)scrollView sizeForView:(MMSplitPaneView *)view atPage:(NSInteger)page
{
    const auto UIViewController *viewController = [self viewControllerForPage:page inScrollView:scrollView];
    const MMViewControllerColumnSize columnSize = [self columnSizeForViewController:(UIViewController *)viewController];
    
    const CGRect bounds = self.view.bounds;
    
    // Just return bounds size if fullscreen:
    if (columnSize == MMViewControllerColumnSizeFullscreen) {
        return bounds.size;
    }
    
    // Calculate primary column width:
    CGFloat widthForPrimaryColumn = round(CGRectGetWidth(bounds) * self.preferredPrimaryColumnWidthFraction);
    
    widthForPrimaryColumn = MAX(widthForPrimaryColumn, self.minimumPrimaryColumnWidth);
    widthForPrimaryColumn = MIN(widthForPrimaryColumn, self.maximumPrimaryColumnWidth);
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
    if (@available(iOS 11.0, *)) {
        const UIEdgeInsets safeAreaInsets = self.view.safeAreaInsets;
        const CGFloat estimatedMargin = MAX(safeAreaInsets.left, safeAreaInsets.right);
        
        widthForPrimaryColumn += estimatedMargin;
    }
#endif
    
    // Determine whatever paging should be enabled:
    UITraitCollection *traitCollection = self.traitCollection;
    BOOL pagingEnabled = (traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact);
    
    if (!pagingEnabled) {
        if (columnSize == MMViewControllerColumnSizePrimary || columnSize == MMViewControllerColumnSizeAuxiliary) {
            return (CGSize){ widthForPrimaryColumn, CGRectGetHeight(bounds) };
            
        } else if (columnSize == MMViewControllerColumnSizeSecondary) {
            CGFloat widthForSecondaryColumn = CGRectGetWidth(bounds) - widthForPrimaryColumn;
            
            const BOOL containsAuxiliaryColumn = [self columnSizeForViewController:[self viewControllerForPage:(page + 1) inScrollView:scrollView]] == MMViewControllerColumnSizeAuxiliary;
            
            if (containsAuxiliaryColumn) {
                const CGFloat proposedAdjustingForAuxiliaryColumn = (widthForSecondaryColumn - widthForPrimaryColumn);
                if (proposedAdjustingForAuxiliaryColumn > self.minimumSecondaryColumnWidth) {
                    widthForSecondaryColumn = proposedAdjustingForAuxiliaryColumn;
                }
            }
            
            if (widthForSecondaryColumn > self.minimumSecondaryColumnWidth) {
                return (CGSize){ widthForSecondaryColumn, CGRectGetHeight(bounds) };
            }
        }
    }
    
    return bounds.size;
}

- (void)scrollView:(MMSplitScrollView *)scrollView willSnapToView:(UIView *)view atPage:(NSInteger)page
{
    UIViewController *viewController = [self viewControllerForPage:page inScrollView:scrollView];
    
    [self willSnapToViewController:viewController];
    
    if (_delegateFlags.delegateWillSnapToViewController) {
        [self.delegate splitViewController:self willSnapToViewController:viewController];
    }
}

- (void)scrollView:(MMSplitScrollView *)scrollView didSnapToView:(UIView *)view atPage:(NSInteger)page
{
    if (_delegateFlags.delegateDidSnapToViewController) {
        UIViewController *viewController = [self viewControllerForPage:page inScrollView:scrollView];
        
        [self.delegate splitViewController:self didSnapToViewController:viewController];
    }
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    static BOOL invalidateSafeAreaInvocationNeeded;
    static SEL invalidateSafeAreaSelector;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *invalidateSafeAreaSelectorString = [@[ @"_updateCont", @"entOverlayInsetsF", @"orSelfAndChildren" ] componentsJoinedByString:@""];

        invalidateSafeAreaSelector = NSSelectorFromString(invalidateSafeAreaSelectorString);
        invalidateSafeAreaInvocationNeeded = [self respondsToSelector:invalidateSafeAreaSelector];
    });

    if (invalidateSafeAreaInvocationNeeded) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:invalidateSafeAreaSelector];
#pragma clang diagnostic pop
    }
}

#pragma mark - Showing view controllers:

- (UIViewController *)targetViewControllerForAction:(SEL)action sender:(id)sender
{
    if (action == @selector(showViewController:sender:)) {
        return self;
    }
    return [super targetViewControllerForAction:action sender:sender];
}

- (void)showViewController:(UIViewController *)vc sender:(id)sender
{
    if (!vc) {
        return;
    }
    
    if (![self.viewControllers containsObject:vc]) {
        self.viewControllers = [self.viewControllers arrayByAddingObject:vc];
    }
    
    [self scrollToViewController:vc animated:YES];
}

- (void)scrollToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (![self.viewControllers containsObject:viewController]) {
        return;
    }
    
    if ([self.primaryCollapsedViewControllers containsObject:viewController]) {
        const NSInteger idx = [self.primaryCollapsedViewControllers indexOfObject:viewController];
        
        // First, scroll the primary collapsed pane into view:
        [self.scrollView scrollToPane:self.primaryCollapsedPane animated:animated];
        
        // Actually scroll to the view controller's pane:
        [self.primaryCollapsedScrollView scrollToPane:self.primaryCollapsedScrollView.panes[idx] animated:animated];
        return;
    }
    
    NSInteger page = [self.viewControllers indexOfObject:viewController];
    
    if (self.primaryCollapsedViewControllers.count > 0) {
        page = page - (self.primaryCollapsedViewControllers.count - 1);
    }
    
    [self.scrollView scrollToPane:self.scrollView.panes[page] animated:animated];
}

- (BOOL)canToggleVisibilityForViewController:(UIViewController *)viewController
{
    if (![self.viewControllers containsObject:viewController]) {
        return NO;
    }
    
    if (self.displayMode == MMViewControllerDisplayModeSinglePage) {
        return (viewController != self.viewControllers.firstObject);
    }
    
    if ([self.primaryCollapsedViewControllers containsObject:viewController]) {
        return YES;
    }
    
    UIView *pane = [self.panes objectForKey:viewController];
    MMSplitScrollView *scrollView = self.scrollView;
    
    const CGRect paneRect = [scrollView rectForPane:pane];
    const CGFloat maximumContentOffsetX = -(scrollView.contentSize.width - CGRectGetWidth(scrollView.bounds));
    const BOOL scrollingPastPaneIsPossible = -CGRectGetMinX(paneRect) >= maximumContentOffsetX;
    
    return (scrollingPastPaneIsPossible);
}

@end
