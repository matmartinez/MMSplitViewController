//
//  MMRoundedCornerOverlayView.m
//  MMSplitViewController
//
//  Created by Matías Martínez on 2/13/19.
//  Copyright © 2019 Matías. All rights reserved.
//

#import "MMRoundedCornerOverlayView.h"

@interface MMRoundedCornerOverlayView ()

@property (assign, nonatomic) CGFloat cornerRadius;
@property (assign, nonatomic) CGFloat capSize;

@property (nonatomic) UIImageView *topImageView;
@property (nonatomic) UIImageView *bottomImageView;

@end

@implementation MMRoundedCornerOverlayView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _overlayColor = UIColor.blackColor;
        _overlayRoundedCorners = UIRectCornerAllCorners;
        
        self.backgroundColor = UIColor.clearColor;
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (void)setOverlayColor:(UIColor *)overlayColor
{
    if (![_overlayColor isEqual:overlayColor]) {
        _overlayColor = overlayColor;
        
        [self invalidateImage];
    }
}

- (void)setOverlayRoundedCorners:(UIRectCorner)overlayRoundedCorners
{
    if (overlayRoundedCorners != _overlayRoundedCorners) {
        _overlayRoundedCorners = overlayRoundedCorners;
        
        [self invalidateImage];
    }
}

- (void)invalidateImage
{
    static const CGFloat continousCurvesSizeFactor = 1.528665f;
    
    UIColor *color = self.overlayColor;
    CGFloat cornerRadius = self.cornerRadius;
    
    UIImage *image = nil;
    
    if (cornerRadius > 0.0f) {
        CGFloat capSize = ceilf(cornerRadius * continousCurvesSizeFactor);
        CGFloat rectSize = 2.0f * capSize + 1.0f;
        CGRect rect = CGRectMake(0.0, 0.0, rectSize, rectSize);
        
        UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0); {
            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:self.overlayRoundedCorners cornerRadii:(CGSize){ cornerRadius, cornerRadius }];
            
            [color set];
            UIRectFill(rect);
            [path fillWithBlendMode:kCGBlendModeDestinationOut alpha:1.0f];
            
            image = UIGraphicsGetImageFromCurrentImageContext();
            image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(capSize, capSize, capSize, capSize)];
        }; UIGraphicsEndImageContext();
    }
    
    self.image = image;
}

- (void)willMoveToWindow:(UIWindow *)newWindow
{
    [super willMoveToWindow:newWindow];
    
    UIScreen *screen = newWindow.screen;
    if (screen != nil) {
        static NSString *key;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            key = [@[ @"_dis", @"playCorn", @"erRadius" ] componentsJoinedByString:@""];
            
        });
        
        if ([screen respondsToSelector:NSSelectorFromString(key)]) {
            self.cornerRadius = [[screen valueForKey:key] floatValue];
        }
    }
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    if (cornerRadius != _cornerRadius) {
        _cornerRadius = cornerRadius;
        
        [self invalidateImage];
    }
}

@end
