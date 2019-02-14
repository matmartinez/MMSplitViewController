//
//  MMSplitViewController+MMSupplementaryBars.h
//  MMSplitViewController
//
//  Created by Matías Martínez on 2/12/19.
//  Copyright © 2019 Matías. All rights reserved.
//

#import "MMSplitViewController.h"

@class MMSnapHeaderView;
@class MMSnapFooterView;

NS_ASSUME_NONNULL_BEGIN

@interface MMSplitViewController (MMSupplementaryBars)

- (nullable MMSnapHeaderView *)headerViewForViewController:(UIViewController *)viewController;
- (nullable MMSnapFooterView *)footerViewForViewController:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
