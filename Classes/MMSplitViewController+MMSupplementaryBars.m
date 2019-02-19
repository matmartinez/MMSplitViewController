//
//  MMSplitViewController+MMSupplementaryBars.m
//  MMSplitViewController
//
//  Created by Matías Martínez on 2/12/19.
//  Copyright © 2019 Matías. All rights reserved.
//

#import "MMSplitViewController+MMSupplementaryBars.h"
#import "MMSnapHeaderView.h"
#import "MMSnapFooterView.h"
#import <objc/runtime.h>

@interface MMSnapSupplementaryView (MMSnapSupplementaryViewPrivate)

@property (weak, nonatomic, readwrite) UIViewController *viewController;
@property (weak, nonatomic, readwrite) MMSplitViewController *splitViewController;

@end

@implementation MMSplitViewController (MMSupplementaryBars)

NS_INLINE void MMSwizzleInstanceMethod(Class class, SEL originalSelector, SEL swizzledSelector){
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL didAddMethod =
    class_addMethod(class,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        MMSwizzleInstanceMethod(class, @selector(viewControllersDidChange:), @selector(snapSupplementaryView_viewControllersDidChange:));
        MMSwizzleInstanceMethod(class, @selector(willDisplayViewController:), @selector(snapSupplementaryView_willDisplayViewController:));
        MMSwizzleInstanceMethod(class, @selector(willSnapToViewController:), @selector(snapSupplementaryView_willSnapToViewController:));
    });
}

- (NSMutableArray <MMSnapSupplementaryView *> *)allSupplementaryViews
{
    const SEL key = @selector(allSupplementaryViews);
    NSMutableArray *storage = objc_getAssociatedObject(self, key);
    if (!storage) {
        storage = [NSMutableArray array];
        objc_setAssociatedObject(self, key, storage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return storage;
}

- (__kindof MMSnapSupplementaryView *)_supplementaryViewWithClass:(Class)viewClass forViewController:(UIViewController *)viewController
{
    if (![self.viewControllers containsObject:viewController]) {
        return nil;
    }
    
    NSMutableArray <MMSnapSupplementaryView *> *allSupplementaryViews = self.allSupplementaryViews;
    MMSnapSupplementaryView *view = nil;
    
    for (MMSnapSupplementaryView *v in allSupplementaryViews.copy) {
        if ([v isKindOfClass:viewClass] && v.viewController == viewController) {
            view = v;
            break;
        }
    }
    
    if (!view) {
        view = [[viewClass alloc] initWithFrame:CGRectZero];
        view.splitViewController = self;
        view.viewController = viewController;
        
        [view didMoveToSnapController];
        
        if (view) {
            [allSupplementaryViews addObject:view];
        }
    }
    
    return view;
}

#pragma mark - Fun swizzling of subclassing hooks.

- (void)snapSupplementaryView_viewControllersDidChange:(NSArray <UIViewController *> *)previousViewControllers
{
    [self snapSupplementaryView_viewControllersDidChange:previousViewControllers];
    
    NSArray <MMSnapSupplementaryView *> *allSupplementaryViews = self.allSupplementaryViews.copy;
    
    if (allSupplementaryViews.count == 0) {
        return;
    }
    
    NSArray <UIViewController *> *viewControllers = self.viewControllers;
    
    NSMutableArray <UIViewController *> *removedViewControllers = [NSMutableArray array];
    
    for (UIViewController *viewController in previousViewControllers) {
        if (![viewControllers containsObject:viewController]) {
            [removedViewControllers addObject:viewController];
        }
    }
    
    // Notify all views of change, removed unused:
    for (MMSnapSupplementaryView *view in allSupplementaryViews) {
        UIViewController *viewController = view.viewController;
        
        if ([removedViewControllers containsObject:viewController]) {
            [view willMoveFromSnapController];
            [self.allSupplementaryViews removeObject:view];
        } else if ([viewControllers containsObject:viewController]) {
            [view didMoveToSnapController];
        }
        
        [view snapControllerViewControllersDidChange];
    }
}

- (void)snapSupplementaryView_willSnapToViewController:(UIViewController *)viewController
{
    [self snapSupplementaryView_willSnapToViewController:viewController];
    
    for (MMSnapSupplementaryView *view in self.allSupplementaryViews.copy) {
        [view snapControllerWillSnapToViewController:viewController];
    }
}

- (void)snapSupplementaryView_willDisplayViewController:(UIViewController *)viewController
{
    [self snapSupplementaryView_willDisplayViewController:viewController];
    
    for (MMSnapSupplementaryView *view in self.allSupplementaryViews.copy) {
        if (view.viewController == viewController) {
            [view snapControllerWillDisplayViewController];
        }
    }
}

#pragma mark - API.

- (MMSnapHeaderView *)headerViewForViewController:(UIViewController *)viewController
{
    return [self _supplementaryViewWithClass:[MMSnapHeaderView class] forViewController:viewController];
}

- (MMSnapFooterView *)footerViewForViewController:(UIViewController *)viewController
{
    return [self _supplementaryViewWithClass:[MMSnapFooterView class] forViewController:viewController];
}

@end
