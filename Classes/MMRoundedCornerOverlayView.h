//
//  MMRoundedCornerOverlayView.h
//  MMSplitViewController
//
//  Created by Matías Martínez on 2/13/19.
//  Copyright © 2019 Matías. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MMRoundedCornerOverlayView : UIImageView

@property (strong, nonatomic, nullable) UIColor *overlayColor;
@property (assign, nonatomic) UIRectCorner overlayRoundedCorners;

@end

NS_ASSUME_NONNULL_END
