//
//  MMSplitPaneView.m
//  MMSplitViewController
//
//  Created by Matías Martínez on 1/29/19.
//  Copyright © 2019 Matías. All rights reserved.
//

#import "MMSplitPaneView.h"
#import "MMSplitSeparatorView.h"

@interface MMSplitPaneView ()

@property (assign, nonatomic, getter=isPagingEnabled) BOOL pagingEnabled;
@property (assign, nonatomic) CGFloat huggingProgress;
@property (strong, nonatomic) UIView *overlayView;
@property (strong, nonatomic) UIScrollView *containerView;

@end

@implementation MMSplitPaneView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIScrollView *containerView = [[UIScrollView alloc] initWithFrame:(CGRect){ .size = frame.size }];
        containerView.translatesAutoresizingMaskIntoConstraints = NO;
        containerView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        containerView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;;
        containerView.bounces = NO;
        containerView.scrollEnabled = NO;
        containerView.showsHorizontalScrollIndicator = NO;
        containerView.showsVerticalScrollIndicator = NO;
        containerView.clipsToBounds = NO;
        
        _containerView = containerView;
        
        [self addSubview:containerView];
        
        MMSplitSeparatorView *separatorView = [[MMSplitSeparatorView alloc] initWithFrame:CGRectZero];
        
        _separatorView = separatorView;
        
        [self addSubview:separatorView];
        
        UIView *overlayView = [[UIView alloc] initWithFrame:CGRectZero];
        overlayView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.1f];
        overlayView.userInteractionEnabled = NO;
        
        self.overlayView = overlayView;
        
        [containerView addSubview:overlayView];
        
        [self configureForHugging];
    }
    return self;
}

- (void)layout
{
    CGRect bounds = (CGRect){
        .size = self.bounds.size
    };
    
    CGRect rect = bounds;
    
    if (self.huggingProgress > 0.0f) {
        const CGFloat maximumOffset = (CGRectGetWidth(rect) / 2.0f);
        
        rect = CGRectOffset(rect, self.huggingProgress * maximumOffset, 0.0f);
    }
    
    self.containerView.frame = rect;
    self.overlayView.frame = bounds;
    
    if (!CGRectEqualToRect(bounds, self.contentView.frame)) {
        self.contentView.frame = bounds;
    }
    
    CGSize separatorSize = [self.separatorView sizeThatFits:rect.size];
    CGRect separatorRect = (CGRect){
        .origin.x = CGRectGetMaxX(self.bounds) - separatorSize.width,
        .size = separatorSize
    };
    
    self.separatorView.frame = separatorRect;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layout];
}

- (void)configureForHugging
{
    const CGFloat progress = self.huggingProgress;
    
    self.overlayView.alpha = progress;
    self.overlayView.hidden = (progress == 0.0f);
    self.separatorView.shadowOpacity = progress;
}

#pragma mark - Properties.

- (void)setContentView:(UIView *)contentView
{
    if (contentView != _contentView) {
        [_contentView removeFromSuperview];
        
        _contentView = contentView;
        
        [self.containerView insertSubview:contentView atIndex:0];
        [self layout];
    }
}

#pragma mark <MMSplitHuggingSupport>

- (void)setHuggingProgress:(CGFloat)progress
{
    if (progress != _huggingProgress) {
        _huggingProgress = progress;
        
        [self configureForHugging];
        [self layout];
    }
}

- (void)setPagingEnabled:(BOOL)isPagingEnabled
{
    if (_pagingEnabled != isPagingEnabled) {
        _pagingEnabled = isPagingEnabled;
        
        self.separatorView.style = isPagingEnabled ? MMSplitSeparatorStyleDropShadow : MMSplitSeparatorStyleSingleLine;
    }
}

@end
