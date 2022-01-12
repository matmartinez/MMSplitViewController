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

#pragma mark - Overridings.

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configure];
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    [super didMoveToParentViewController:parent];
    
    if ([parent isKindOfClass:[MMSplitViewController class]]) {
        self.headerView = [(MMSplitViewController *)parent headerViewForViewController:self];
        
        [self configure];
    }
}

#pragma mark - Setup

- (void)configure
{
    if (self.isViewLoaded) {
        [self.headerView sizeToFit];
        self.tableView.tableHeaderView = self.headerView;
    }
    
    self.headerView.title = self.title;
    
    if (@available(iOS 9.0, *)) {
        [self setupRightView];
    }
}

- (void)setupRightView API_AVAILABLE(ios(9.0))
{
    // Example View 1
    UIButton *firstButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [firstButton addTarget:self action:@selector(_firstButtonMethod:) forControlEvents:UIControlEventTouchUpInside];
    
    // Example View 2
    UIButton *secondButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [secondButton addTarget:self action:@selector(_secondButtonMethod:) forControlEvents:UIControlEventTouchUpInside];
    
    // Example Stack View
    UIStackView *stackView = [[UIStackView alloc] init];
    
    stackView.axis = UILayoutConstraintAxisHorizontal;
    stackView.distribution = UIStackViewDistributionEqualSpacing;
    stackView.alignment = UIStackViewAlignmentTrailing;
    stackView.spacing = 10;
    
    [stackView addArrangedSubview:firstButton];
    [stackView addArrangedSubview:secondButton];
    
    stackView.translatesAutoresizingMaskIntoConstraints = false;
    
    [self.headerView setRightView: stackView];
}

- (void)setTitle:(NSString *)title
{
    [super setTitle:title];
    [self configure];
}

#pragma mark - Actions.

- (void)_firstButtonMethod:(id)sender {
    [self presentAlertWithTitle:@"First Button Tapped" message:nil];
}

- (void)_secondButtonMethod:(id)sender {
    [self presentAlertWithTitle:@"Second Button Tapped" message:nil];
}

#pragma mark - Methods.

- (void)presentAlertWithTitle:(nullable NSString *)title message:(nullable NSString *)message {
    UIAlertController * alert = [UIAlertController alertControllerWithTitle : title
                                                                    message : message
                                                             preferredStyle : UIAlertControllerStyleAlert];
    
    UIAlertAction * ok = [UIAlertAction
                          actionWithTitle:@"OK"
                          style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction * action)
                          { }];
    
    [alert addAction:ok];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alert animated:YES completion:nil];
    });
}

#pragma mark - UITableView Delegate and DataSource.

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
