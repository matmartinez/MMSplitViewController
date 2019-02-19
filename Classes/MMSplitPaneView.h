//
//  MMSplitPaneView.h
//  MMSplitViewController
//
//  Created by Matías Martínez on 1/29/19.
//  Copyright © 2019 Matías. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMSplitHuggingSupporting.h"

@class MMSplitSeparatorView;

NS_ASSUME_NONNULL_BEGIN

/**
 *  A container view for panes in an split view that supports hugging transitions.
 */
@interface MMSplitPaneView : UIView <MMSplitHuggingSupporting>

/**
 *  The main view to which you add your pane’s custom content.
 *
 *  @note By default the value of this property is @c nil.
 */
@property (nonatomic, strong, nullable) UIView *contentView;

/**
 *  A separator view for the pane view.
 */
@property (nonatomic, strong, readonly) MMSplitSeparatorView *separatorView;

@end

NS_ASSUME_NONNULL_END
