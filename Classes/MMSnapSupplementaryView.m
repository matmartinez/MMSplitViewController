//
//  MMSnapSupplementaryView.m
//  MMSplitViewController
//
//  Created by Matías Martínez on 2/12/19.
//  Copyright © 2019 Matías. All rights reserved.
//

#import "MMSnapSupplementaryView.h"
#import "MMSplitViewController.h"

@interface MMSnapSupplementaryView ()

@property (weak, nonatomic, readwrite) UIViewController *viewController;
@property (weak, nonatomic, readwrite) MMSplitViewController *splitViewController;

@end

@implementation MMSnapSupplementaryView

- (UIViewController *)previousViewController
{
    __strong MMSplitViewController *snapController = self.splitViewController;
    if (snapController) {
        NSArray *viewControllers = snapController.viewControllers;
        NSUInteger idx = [viewControllers indexOfObject:self.viewController];
        if (idx != NSNotFound && idx - 1 < viewControllers.count) {
            return viewControllers[idx - 1];
        }
    }
    return nil;
}

- (void)snapControllerWillDisplayViewController
{
    
}

- (void)snapControllerWillSnapToViewController:(UIViewController *)viewController
{
    
}

- (void)willMoveToSnapController:(UIViewController *)snapController
{
    
}

- (void)willMoveFromSnapController
{
    
}

- (void)didMoveToSnapController
{
    
}

- (void)snapControllerViewControllersDidChange
{
    
}

@end
