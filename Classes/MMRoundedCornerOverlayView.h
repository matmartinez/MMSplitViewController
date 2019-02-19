//
//  MMRoundedCornerOverlayView.h
//  MMSplitViewController
//
//  Created by Matías Martínez on 2/13/19.
//  Copyright © 2019 Matías. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  An overlay view that resembles the shape of the display screen corners.
 */
@interface MMRoundedCornerOverlayView : UIImageView

/**
 *  The color of the overlay. By default, @c UIColor.black\.
 */
@property (strong, nonatomic, nullable) UIColor *overlayColor;

/**
 *  The corresponding screen corners you want to mask. By default @c UIRectCornerAllCorners\.
 */
@property (assign, nonatomic) UIRectCorner overlayRoundedCorners;

@end

NS_ASSUME_NONNULL_END
