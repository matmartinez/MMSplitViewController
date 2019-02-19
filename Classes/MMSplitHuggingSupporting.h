//
//  MMSplitHuggingSupport.h
//  MMSplitViewController
//
//  Created by Matías Martínez on 2/7/19.
//  Copyright © 2019 Matías. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  The interface that determines whether a view object supports hugging transitions.
 */
@protocol MMSplitHuggingSupporting <NSObject>

/**
 *  The relative progress of the hugging transition.
 *
 *  The value of this property is a floating-point number between @c 0.0 and @c 1.0 that represents the percentage of the hugging transition.
 */
- (void)setHuggingProgress:(CGFloat)progress;

/**
 *  A Boolean value that determines whether paging is enabled for the scroll view.
 *
 *  If the value of this property is @c YES, the container scroll view stops on multiples of the scroll view’s bounds when the user scrolls.
 */
- (void)setPagingEnabled:(BOOL)pagingEnabled;

@end

NS_ASSUME_NONNULL_END
