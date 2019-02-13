//
//  MainViewController.m
//  MMSplitViewController
//
//  Created by Matías Martínez on 1/22/19.
//  Copyright © 2019 Matías. All rights reserved.
//

#import "MainViewController.h"
#import "FauxListViewController.h"
#import "MMSplitViewController.h"

@interface MainViewController () <MMSplitViewControllerDelegate>

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSMutableArray <UIViewController *> *viewControllers = [NSMutableArray array];
    
    for (NSInteger page = 0; page < 4; page += 1) {
        FauxListViewController *viewController = [[FauxListViewController alloc] init];
        viewController.title = @(page + 1).stringValue;
        viewController.selectionHandler = ^(FauxListViewController *sender, NSUInteger row) {
            UIViewController *targetViewController = (page + 1 < viewControllers.count) ? viewControllers[page + 1] : nil;
            
            [sender showViewController:targetViewController sender:nil];
        };
        [viewControllers addObject:viewController];
    }
    
    MMSplitViewController *controller = [[MMSplitViewController alloc] init];
    controller.viewControllers = viewControllers;
    controller.delegate = self;
    
    [self addChildViewController:controller];
    
    controller.view.frame = self.view.bounds;
    controller.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    
    [self.view addSubview:controller.view];
}

- (MMViewControllerColumnSize)splitViewController:(MMSplitViewController *)splitViewController columnSizeForViewController:(UIViewController *)viewController
{
    if (splitViewController.viewControllers[2] == viewController) {
        return MMViewControllerColumnSizeSecondary;
    }
    
    if (splitViewController.viewControllers[3] == viewController) {
        return MMViewControllerColumnSizeAuxiliary;
    }
    
    return MMViewControllerColumnSizePrimary;
}

@end
