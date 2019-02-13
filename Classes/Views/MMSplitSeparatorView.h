//
//  MMSplitSeparatorView.h
//  MMSplitViewController
//
//  Created by Matías Martínez on 1/29/19.
//  Copyright © 2019 Matías. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, MMSplitSeparatorStyle) {
    MMSplitSeparatorStyleSingleLine,
    MMSplitSeparatorStyleDropShadow
};

@interface MMSplitSeparatorView : UIView

@property (assign, nonatomic) MMSplitSeparatorStyle style;
@property (assign, nonatomic) CGFloat shadowOpacity;

@end

NS_ASSUME_NONNULL_END
