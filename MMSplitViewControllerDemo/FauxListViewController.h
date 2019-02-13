//
//  FauxListViewController.h
//  MMSplitViewController
//
//  Created by Matías Martínez on 1/22/19.
//  Copyright © 2019 Matías. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FauxListViewController : UITableViewController

@property (copy, nonatomic) void (^selectionHandler)(FauxListViewController *, NSUInteger row);

@end

NS_ASSUME_NONNULL_END
