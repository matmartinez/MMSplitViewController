//
//  MMSplitPaneView.h
//  MMSplitViewController
//
//  Created by Matías Martínez on 1/29/19.
//  Copyright © 2019 Matías. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMSplitHuggingSupport.h"

@class MMSplitSeparatorView;

NS_ASSUME_NONNULL_BEGIN

@interface MMSplitPaneView : UIView <MMSplitHuggingSupport>

@property (nonatomic, strong, nullable) UIView *contentView;
@property (nonatomic, strong, readonly) MMSplitSeparatorView *separatorView;

@end

NS_ASSUME_NONNULL_END
