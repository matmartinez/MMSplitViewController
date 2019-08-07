//
//  MMSplitSeparatorView.m
//  MMSplitViewController
//
//  Created by Matías Martínez on 1/29/19.
//  Copyright © 2019 Matías. All rights reserved.
//

#import "MMSplitSeparatorView.h"

@interface MMSplitSeparatorView ()

@property (strong, nonatomic) UIView *separatorLineView;
@property (strong, nonatomic) UIView *dropShadowView;

@end

@interface _MMSplitSeparatorDropShadowView : UIView

@end

@implementation MMSplitSeparatorView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _shadowOpacity = 1.0f;
        
        // Gradient layer.
        UIView *dropShadowView = [[_MMSplitSeparatorDropShadowView alloc] initWithFrame:CGRectZero];
        
        self.dropShadowView = dropShadowView;
        
        [self addSubview:dropShadowView];
        
        // Separator layer.
        UIView *separatorLineView = [[UIView alloc] initWithFrame:CGRectZero];
        separatorLineView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.25f];
        separatorLineView.userInteractionEnabled = NO;
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
        if (@available(iOS 13.0, *)) {
            separatorLineView.backgroundColor = [UIColor separatorColor];
        }
#endif
        
        self.separatorLineView = separatorLineView;
        
        [self addSubview:separatorLineView];
    }
    return self;
}

- (void)setShadowOpacity:(CGFloat)shadowOpacity
{
    if (shadowOpacity != _shadowOpacity) {
        _shadowOpacity = shadowOpacity;
        
        self.separatorLineView.alpha = (1.0f - shadowOpacity);
        self.dropShadowView.alpha = shadowOpacity;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = (CGRect){
        .size = self.bounds.size
    };
    
    CGFloat separatorWidth = 1.0f / UIScreen.mainScreen.scale;
    CGRect separatorRect = (CGRect){
        .origin.x = CGRectGetWidth(bounds) - separatorWidth,
        .size.width = separatorWidth,
        .size.height = CGRectGetHeight(bounds)
    };
    
    self.separatorLineView.frame = separatorRect;
    
    CGRect shadowGradientRect = bounds;
    
    self.dropShadowView.frame = shadowGradientRect;
}

- (void)setStyle:(MMSplitSeparatorStyle)style
{
    if (style != _style) {
        _style = style;
        
        self.separatorLineView.hidden = (style != MMSplitSeparatorStyleSingleLine);
        self.dropShadowView.hidden = (style != MMSplitSeparatorStyleDropShadow);
    }
}

- (CGSize)sizeThatFits:(CGSize)size
{
    size.width = 10.0f;
    
    return size;
}

@end

@implementation _MMSplitSeparatorDropShadowView

+ (Class)layerClass
{
    return [CAGradientLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CAGradientLayer *gradientLayer = (id)self.layer;
        gradientLayer.startPoint = CGPointZero;
        gradientLayer.endPoint = CGPointMake(1, 0);
        gradientLayer.colors = @[ (id)[UIColor colorWithWhite:0.0f alpha:0.0f].CGColor,
                                  (id)[UIColor colorWithWhite:0.0f alpha:0.25f].CGColor ];
    }
    return self;
}

@end
