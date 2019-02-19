//
//  MMSplitSeparatorView.h
//  MMSplitViewController
//
//  Created by Matías Martínez on 1/29/19.
//  Copyright © 2019 Matías. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Constants indicating the style of the separator view.
 */
typedef NS_ENUM(NSUInteger, MMSplitSeparatorStyle) {
    /**
     *  The separator has a single line running across its height. This is the default value.
     */
    MMSplitSeparatorStyleSingleLine,
    
    /**
     *  The separator has only a drop shadow.
     */
    MMSplitSeparatorStyleDropShadow
};

/**
 *  A view that provides a separator and a drop shadow for split panes.
 */
@interface MMSplitSeparatorView : UIView

/**
 *  The style of the separator view.
 */
@property (assign, nonatomic) MMSplitSeparatorStyle style;

/**
 *  The opacity of the separator’s shadow.
 */
@property (assign, nonatomic) CGFloat shadowOpacity;

@end

NS_ASSUME_NONNULL_END
