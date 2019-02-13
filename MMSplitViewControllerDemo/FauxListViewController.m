//
//  FauxListViewController.m
//  MMSplitViewController
//
//  Created by Matías Martínez on 1/22/19.
//  Copyright © 2019 Matías. All rights reserved.
//

#import "FauxListViewController.h"
#import "MMSplitViewController+MMSupplementaryBars.h"
#import "MMSnapHeaderView.h"

@interface FauxListViewController ()

@property (strong, nonatomic) MMSnapHeaderView *headerView;

@end

@implementation FauxListViewController

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    [super didMoveToParentViewController:parent];
    
    if ([parent isKindOfClass:[MMSplitViewController class]]) {
        self.headerView = [(MMSplitViewController *)parent headerViewForViewController:self];
        
        [self configure];
    }
}

- (void)setTitle:(NSString *)title
{
    [super setTitle:title];
    [self configure];
}

- (void)configure
{
    if (self.isViewLoaded) {
        [self.headerView sizeToFit];
        self.tableView.tableHeaderView = self.headerView;
    }
    
    self.headerView.title = self.title;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configure];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"reuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"Row %ld", indexPath.row + 1];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.selectionHandler) {
        self.selectionHandler(self, indexPath.row);
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

@end
