//
//  MMSnapHeaderView.m
//  MMSnapController
//
//  Created by Matías Martínez on 1/27/15.
//  Copyright (c) 2015 Matías Martínez. All rights reserved.
//

#import "MMSnapHeaderView.h"
#import "MMSplitViewController+MMSupplementaryBars.h"

@interface MMSnapHeaderView () {
    struct {
        unsigned int usingMultilineHeading : 1;
        unsigned int usingCustomTitleView : 1;
        unsigned int showsRightView : 1;
        unsigned int showsLeftButton : 1;
        unsigned int showsBackButton : 1;
        unsigned int usingRegularBackButton : 1;
        unsigned int showsLargeTitle: 1;
        unsigned int showsHeading: 1;
    } _configurationOptions;
    
    CGSize _largeTitleSize;
}

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *largeTitleLabel;
@property (strong, nonatomic) UILabel *subtitleLabel;
@property (strong, nonatomic) UIView *headingContainer;

@property (strong, nonatomic) UIButton *regularBackButton;
@property (strong, nonatomic) UIButton *compactBackButton;
@property (assign, nonatomic) BOOL backActionAvailable;

@property (readonly, nonatomic) BOOL pagingEnabled;
@property (assign, nonatomic) BOOL rotatesBackButton;
@property (assign, nonatomic) CGFloat interSpacing;
@property (assign, nonatomic) CGFloat barButtonSpacing;
@property (assign, nonatomic) CGFloat backButtonSpacing;

@property (strong, nonatomic) UIView *separatorView;
@property (strong, nonatomic) UIView *largeHeaderContainer;
@property (strong, nonatomic) UIView *largeHeaderSeparatorView;

@property (assign, nonatomic, readonly) CGFloat regularHeight;
@property (assign, nonatomic, readonly) CGFloat largeHeaderHeight;
@property (assign, nonatomic) CGFloat largeHeaderScaleFactor;
@property (assign, nonatomic) BOOL contentIsBeingScrolled;

@end

@interface _MMSnapHeaderContainerView : UIView

@end

@implementation MMSnapHeaderView

#define UIKitLocalizedString(key) [[NSBundle bundleWithIdentifier:@"com.apple.UIKit"] localizedStringForKey:key value:@"" table:nil]

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) \
([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = NO;
        
        // Metrics.
        _regularHeight = self.class._UINavigationBarDefaultHeight;
        _largeHeaderHeight = 52.0f;
        _backButtonSpacing = 8.0f;
        _barButtonSpacing = 8.0f;
        _interSpacing = 5.0;
        _largeHeaderScaleFactor = 1.0f;
        
        // Defaults.
        _separatorColor = [UIColor colorWithWhite:0.0f alpha:0.2f];
        _largeTitleSize = CGSizeZero;
        
        // Configuration.
        _configurationOptions.showsHeading = YES;
        
        // Background view.
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        backgroundView.backgroundColor = [UIColor whiteColor];
        backgroundView.userInteractionEnabled = NO;
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
        if (@available(iOS 13.0, *)) {
            backgroundView.backgroundColor = [UIColor systemBackgroundColor];
        }
#endif
        
        _backgroundView = backgroundView;
        
        [self addSubview:backgroundView];
        
        // Separator view.
        UIView *separatorView = [[UIView alloc] initWithFrame:CGRectZero];
        separatorView.backgroundColor = _separatorColor;
        separatorView.userInteractionEnabled = NO;
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
        if (@available(iOS 13.0, *)) {
            separatorView.backgroundColor = [UIColor separatorColor];
        }
#endif
        
        _separatorView = separatorView;
        
        [self addSubview:separatorView];
        
        // Heading container.
        UIView *headingContainer = [[_MMSnapHeaderContainerView alloc] initWithFrame:CGRectZero];
        
        _headingContainer = headingContainer;
        
        [self addSubview:headingContainer];
        
        // Title label.
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.accessibilityTraits |= UIAccessibilityTraitHeader;
        
        _titleLabel = titleLabel;
        
        [headingContainer addSubview:titleLabel];
        
        // Subtitle label.
        UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        
        _subtitleLabel = subtitleLabel;
        
        [headingContainer addSubview:subtitleLabel];
        
        // Large title label.
        if ([self.class _UINavigationBarUsesLargeTitles]) {
            UIView *largeHeaderContainer = [[UIView alloc] initWithFrame:CGRectZero];
            largeHeaderContainer.clipsToBounds = YES;
            
            _largeHeaderContainer = largeHeaderContainer;
            
            [self addSubview:largeHeaderContainer];
            
            UILabel *largeTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            largeTitleLabel.accessibilityTraits |= UIAccessibilityTraitHeader;
            
            _largeTitleLabel = largeTitleLabel;
            
            [largeHeaderContainer addSubview:largeTitleLabel];
            
            UIView *largeHeaderSeparatorView = [[UIView alloc] initWithFrame:CGRectZero];
            largeHeaderSeparatorView.backgroundColor = [_separatorColor colorWithAlphaComponent:0.1f];
            
            _largeHeaderSeparatorView = largeHeaderSeparatorView;
            
            [largeHeaderContainer addSubview:largeHeaderSeparatorView];
        }
        
        // Buttons.
        UIButton *regularBackButton = [UIButton buttonWithType:UIButtonTypeSystem];
        UIButton *compactBackButton = [UIButton buttonWithType:UIButtonTypeSystem];
        
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        NSString *imageName;
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"11.0")) {
            imageName = @"MMSnapIndicatorRounded";
        } else {
            imageName = @"MMSnapBackIndicatorDefault";
        }
        
        UIImage *backButtonImage = [[UIImage imageNamed:imageName inBundle:bundle compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        backButtonImage.accessibilityLabel = UIKitLocalizedString(@"Back");
        
        for (UIButton *backButton in @[ regularBackButton, compactBackButton ]) {
            [backButton setImage:backButtonImage forState:UIControlStateNormal];
            [backButton addTarget:self action:@selector(_backButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
            
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
            if (@available(iOS 13.4, *)) {
                backButton.pointerInteractionEnabled = YES;
            }
#endif
        }
        
        static const CGFloat chevronTitleSpacing = 6.0f;
        [regularBackButton setTitleEdgeInsets:UIEdgeInsetsMake(0, chevronTitleSpacing, 0, -chevronTitleSpacing)];
        [regularBackButton setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, chevronTitleSpacing)];
        
        _regularBackButton = regularBackButton;
        _compactBackButton = compactBackButton;
        
        [self addSubview:regularBackButton];
        [self addSubview:compactBackButton];
        
        // Assign fonts.
        [self _assignFonts];
        
        // Size.
        [self sizeToFit];
    }
    return self;
}

- (void)_assignFonts
{
    static const CGFloat headingPointSize = 17.0f;
    static const CGFloat subheadingPointSize = 14.0f;
    static const CGFloat largeHeadingPointSize = 32.0f;
    
    _configurationOptions.usingMultilineHeading = (self.subtitle.length > 0 && self.title.length > 0);
    
    if (_configurationOptions.usingMultilineHeading) {
        _titleLabel.font = self.titleTextAttributes[NSFontAttributeName] ?: [UIFont boldSystemFontOfSize:subheadingPointSize];
        _subtitleLabel.font = self.subtitleTextAttributes[NSFontAttributeName] ?: [UIFont systemFontOfSize:subheadingPointSize];
    } else {
        _titleLabel.font = self.titleTextAttributes[NSFontAttributeName] ?: [UIFont boldSystemFontOfSize:headingPointSize];
    }
    
    _regularBackButton.titleLabel.font = [UIFont systemFontOfSize:headingPointSize];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
    if (@available(iOS 8.2, *)) {
        _largeTitleLabel.font = [UIFont systemFontOfSize:largeHeadingPointSize weight:UIFontWeightBold];
    }
#endif
}

#pragma mark - Actions.

- (void)_backButtonTouchUpInside:(id)sender
{
    MMSplitViewController *snapController = self.splitViewController;
    UIViewController *viewController = self.viewController;
    
    BOOL isFirstVisibleViewController = snapController.visibleViewControllers.firstObject == viewController;
    if (isFirstVisibleViewController) {
        UIViewController *previousViewController = self.previousViewController;
        [snapController scrollToViewController:previousViewController animated:YES];
    } else {
        [snapController scrollToViewController:viewController animated:YES];
    }
}

#pragma mark - Layout.

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    const CGRect bounds = (CGRect){
        .size = self.bounds.size
    };
    
    CGFloat interSpacing = _interSpacing;
    CGFloat edgeSpacing = _barButtonSpacing;
    CGFloat backEdgeSpacing = _backButtonSpacing;
    
    if ([self.class _UINavigationBarDoubleEdgesRequired]) {
        if (CGRectGetWidth(bounds) > [self.class _UINavigationBarDoubleEdgesThreshold]) {
            edgeSpacing = [self.class _UINavigationBarDoubleEdgesSpacing];
        }
    }
    
    // Rects to calculate.
    UIView *actualLeftButton = nil;
    
    // First, what we should display here?
    BOOL pagingEnabled = self.pagingEnabled;
    BOOL canToggleVisibility = [self.splitViewController canToggleVisibilityForViewController:self.viewController];
    
    BOOL showsLeftButton = _leftButton != nil;
    BOOL showsRightView = _rightView != nil;
    BOOL showsBackButton = canToggleVisibility && !showsLeftButton && !_hidesBackButton && _backActionAvailable;
    BOOL usesMultilineHeading = _configurationOptions.usingMultilineHeading;
    BOOL usesCustomTitleView = _titleView != nil;
    
    UIEdgeInsets barButtonsInsets = (UIEdgeInsets){
        .left = (showsBackButton ? backEdgeSpacing : edgeSpacing),
        .right = edgeSpacing
    };
    
    UIEdgeInsets contentInset = UIEdgeInsetsZero;
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
    if (@available(iOS 11.0, *)) {
        contentInset.left += self.safeAreaInsets.left;
        contentInset.right += self.safeAreaInsets.right;
    }
#endif
    
    const CGRect contentRect = ({
        UIEdgeInsets insets = contentInset;
        insets.left += barButtonsInsets.left;
        insets.right += barButtonsInsets.right;
        
        CGRect rect = UIEdgeInsetsInsetRect(bounds, insets);
        rect.size.height = self.regularHeight;
        rect;
    });
    
    const CGSize fit = contentRect.size;
    
    // Calculate title width.
    CGSize sizeNeededToFitTitle = CGSizeZero;
    CGSize tSize = CGSizeZero;
    CGSize sSize = CGSizeZero;
    
    if (usesCustomTitleView) {
        sizeNeededToFitTitle = [_titleView sizeThatFits:fit];
    } else {
        tSize = [_titleLabel sizeThatFits:fit];
        sSize = [_subtitleLabel sizeThatFits:fit];
        
        if (usesMultilineHeading) {
            sizeNeededToFitTitle = CGSizeMake(MAX(tSize.width, sSize.width), tSize.height + sSize.height);
        } else {
            sizeNeededToFitTitle = tSize;
        }
    }
    
    // Calculate back button.
    BOOL useRegularBackButton = NO;
    if (showsBackButton) {
        if (pagingEnabled) {
            CGFloat rightCompression = 0.0f;
            if (showsRightView) {
                rightCompression = [_rightView sizeThatFits:fit].width;
            }
            
            CGFloat availableTitleBackWidth = CGRectGetWidth(contentRect) - rightCompression - edgeSpacing;
            CGFloat regularBackButtonWidth = [_regularBackButton sizeThatFits:fit].width;
            
            useRegularBackButton = (regularBackButtonWidth + interSpacing + sizeNeededToFitTitle.width < availableTitleBackWidth);
            if (useRegularBackButton) {
                actualLeftButton = _regularBackButton;
            } else {
                actualLeftButton = _compactBackButton;
            }
        } else {
            actualLeftButton = _compactBackButton;
        }
    } else {
        actualLeftButton = _leftButton;
    }
    
    // Layout for once!
    CGSize leftButtonSize = [actualLeftButton sizeThatFits:fit];
    CGRect leftButtonRect = (CGRect){
        .origin.x = CGRectGetMinX(contentRect),
        .origin.y = ceilf((CGRectGetHeight(contentRect) - leftButtonSize.height) / 2.0f),
        .size = leftButtonSize
    };
    
    CGSize rightViewSize = [_rightView sizeThatFits:fit];
    CGRect rightViewRect = (CGRect){
        .origin.x = CGRectGetMaxX(contentRect) - rightViewSize.width,
        .origin.y = ceilf((CGRectGetHeight(contentRect) - rightViewSize.height) / 2.0f),
        .size = rightViewSize
    };
    
    // Title.
    CGRect titleAlignmentRect = UIEdgeInsetsInsetRect(contentRect, (UIEdgeInsets){
        .left = leftButtonSize.width + interSpacing,
        .right = rightViewSize.width + interSpacing
    });
    
    // Align components.
    const CGFloat titleAlignmentHeight = sizeNeededToFitTitle.height;
    
    CGRect titleLabelRect = CGRectZero;
    CGRect subtitleLabelRect = CGRectZero;
    CGRect titleViewRect = CGRectZero;
    
    CGFloat horizontalAlignDimension = 0.0f;
    
    if (usesCustomTitleView) {
        titleViewRect = (CGRect){
            .origin.y = ceilf((CGRectGetMidY(contentRect) - (titleAlignmentHeight / 2.0f))),
            .size.width = MIN(sizeNeededToFitTitle.width, CGRectGetWidth(titleAlignmentRect)),
            .size.height = sizeNeededToFitTitle.height
        };
        
        horizontalAlignDimension = CGRectGetWidth(titleViewRect);
    } else {
        titleLabelRect = (CGRect){
            .origin.y = ceilf(CGRectGetMidY(contentRect) - (titleAlignmentHeight / 2.0f)),
            .size.width = MIN(tSize.width, CGRectGetWidth(titleAlignmentRect)),
            .size.height = tSize.height
        };
        
        subtitleLabelRect = (CGRect){
            .origin.y = ceilf(CGRectGetMaxY(titleLabelRect)),
            .size.width = MIN(sSize.width, CGRectGetWidth(titleAlignmentRect)),
            .size.height = sSize.height
        };
        
        horizontalAlignDimension = MAX(CGRectGetWidth(titleLabelRect), CGRectGetWidth(subtitleLabelRect));
    }
    
    const CGRect boundsInsetRect = UIEdgeInsetsInsetRect(bounds, contentInset);
    const CGFloat offsetBoundsRectCentered = (CGRectGetMidX(boundsInsetRect) - (horizontalAlignDimension / 2.0f));
    const BOOL canCenterOnContentRect = CGRectGetMinX(titleAlignmentRect) < offsetBoundsRectCentered;
    
    CGRect horizontalAlignmentRect = titleAlignmentRect;
    if (canCenterOnContentRect) {
        horizontalAlignmentRect = boundsInsetRect;
    }
    
    titleLabelRect.origin.x = ceilf(CGRectGetMidX(horizontalAlignmentRect) - (CGRectGetWidth(titleLabelRect) / 2.0f));
    subtitleLabelRect.origin.x = ceilf(CGRectGetMidX(horizontalAlignmentRect) - (CGRectGetWidth(subtitleLabelRect) / 2.0f));
    titleViewRect.origin.x = ceilf(CGRectGetMidX(horizontalAlignmentRect) - (CGRectGetWidth(titleViewRect) / 2.0f));
    
    // Large heading.
    if ([self.class _UINavigationBarUsesLargeTitles]) {
        static const CGFloat headerScaleDelta = 0.1f;
        static const CGFloat maximumScale = 1.0f + headerScaleDelta;
        
        CGRect largeContentRect = UIEdgeInsetsInsetRect(bounds, (UIEdgeInsets){ .left = edgeSpacing, .right = edgeSpacing });
        
        const CGFloat regularHeight = _regularHeight;
        const CGFloat largeHeaderHeight = _largeHeaderHeight;
        const CGSize calculatedTitleSize = _largeTitleSize;
        
        CGSize largeHeaderSize = calculatedTitleSize;
        largeHeaderSize.width = CGRectGetWidth(largeContentRect);
        
        CGRect largeHeaderRect = (CGRect){
            .origin.x = CGRectGetMinX(largeContentRect),
            .origin.y = (CGRectGetHeight(largeContentRect) - (regularHeight + largeHeaderHeight)) + roundf((largeHeaderHeight - largeHeaderSize.height) / 2.0f) - 1.0f,
            .size = largeHeaderSize
        };
        
        CGRect largeHeaderContainerRect = UIEdgeInsetsInsetRect(bounds, (UIEdgeInsets){
            .top = regularHeight
        });
        
        CGRect largeHeaderSeparatorRect = (CGRect){
            .origin.x = CGRectGetMinX(largeHeaderRect),
            .size.width = calculatedTitleSize.width,
            .size.height = 1.0f
        };
        
        const BOOL showsLargeHeaderSeparator = CGRectIntersectsRect(largeHeaderSeparatorRect, CGRectInset(largeHeaderRect, 0.0f, 10.0f));
        
        _largeHeaderSeparatorView.alpha = showsLargeHeaderSeparator;
        _largeHeaderSeparatorView.frame = largeHeaderSeparatorRect;
        _largeHeaderContainer.frame = largeHeaderContainerRect;
        
        const BOOL enabled = (calculatedTitleSize.width * maximumScale <= CGRectGetWidth(largeContentRect));
        const BOOL showsLargeTitle = (enabled) && (CGRectGetHeight(bounds) > regularHeight);
        const BOOL showsHeading = (enabled) && (CGRectGetHeight(bounds) > regularHeight + (interSpacing * 2.0f));
        
        if (showsHeading != _configurationOptions.showsHeading) {
            const BOOL animated = (self.window != nil) && self.contentIsBeingScrolled;
            
            dispatch_block_t animations = ^{
                self.headingContainer.alpha = showsHeading ? 0.0f : 1.0f;
            };
            
            if (animated) {
                [UIView animateWithDuration:0.15f delay:0.0f options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:animations completion:NULL];
            } else {
                animations();
            }
        }
        
        CGFloat scale = 1.0f;
        
        if (self.contentIsBeingScrolled) {
            static const CGFloat maginificationThreshold = 74.0f;
            
            CGFloat maginificationDistance = CGRectGetHeight(bounds) - (regularHeight + largeHeaderHeight);
            CGFloat percentage = (maginificationDistance / maginificationThreshold);
            
            scale = 1.0f + (percentage * headerScaleDelta);
            scale = MAX(MIN(scale, maximumScale), 1.0f);
        }
        
        self.largeHeaderScaleFactor = scale;
        
        _largeTitleLabel.frame = largeHeaderRect;
        _largeTitleLabel.hidden = !showsLargeTitle;
        
        _configurationOptions.showsLargeTitle = showsLargeTitle;
        _configurationOptions.showsHeading = showsHeading;
    }
    
    // Background & separator.
    CGRect separatorRect = (CGRect){
        .origin.y = CGRectGetHeight(bounds),
        .size.width = CGRectGetWidth(bounds),
        .size.height = 1.0f / [UIScreen mainScreen].scale,
    };
    
    CGRect statusBarRect = [self convertRect:[UIApplication sharedApplication].statusBarFrame fromView:nil];
    
    CGRect backgroundRect = UIEdgeInsetsInsetRect(bounds, (UIEdgeInsets){
        .top = MIN(CGRectGetMinY(statusBarRect), 0),
    });
    
    // Apply computed properties.
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    actualLeftButton.frame = leftButtonRect;
    [CATransaction commit];
    
    _rightView.frame = rightViewRect;
    _titleLabel.frame = titleLabelRect;
    _subtitleLabel.frame = subtitleLabelRect;
    _titleView.frame = titleViewRect;
    _titleLabel.hidden = usesCustomTitleView;
    _subtitleLabel.hidden = usesCustomTitleView;
    _separatorView.frame = separatorRect;
    _backgroundView.frame = backgroundRect;
    _headingContainer.frame = bounds;
    
    // Use alpha instead of hidden, so clients can get a fade animation when needed.
    _regularBackButton.alpha = !useRegularBackButton || !showsBackButton ? 0.0f : 1.0f;
    _compactBackButton.alpha = useRegularBackButton || !showsBackButton ? 0.0f : 1.0f;
    
    // Save configuration.
    _configurationOptions.showsBackButton = showsBackButton;
    _configurationOptions.showsLeftButton = showsLeftButton;
    _configurationOptions.showsBackButton = showsBackButton;
    _configurationOptions.usingRegularBackButton = useRegularBackButton;
    _configurationOptions.usingCustomTitleView = usesCustomTitleView;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGFloat height = self.regularHeight;
    
    if ([self displaysLargeTitleWithSize:size]) {
        height += self.largeHeaderHeight;
    }
    
    size.height = height;
    
    return size;
}

- (void)didMoveToWindow
{
    [super didMoveToWindow];
    
    if (self.window != nil) {
        [self setNeedsLayout];
    }
}

#pragma mark - Updates.

- (void)snapControllerWillDisplayViewController
{
    UIViewController *previousViewController = self.previousViewController;
    if (previousViewController) {
        MMSnapHeaderView *headerView = (MMSnapHeaderView *)[self.splitViewController headerViewForViewController:previousViewController];
        NSString *backTitle = headerView.backButtonTitle ?: headerView.title ?: previousViewController.title;
        
        [self.regularBackButton setTitle:backTitle forState:UIControlStateNormal];
        
        [self setBackActionAvailable:(previousViewController != nil)];
        [self setNeedsLayout];
    }
}

- (void)didMoveToSnapController
{
    if (!self.pagingEnabled) {
        BOOL firstVisibleViewController = (self.splitViewController.visibleViewControllers.firstObject == self.viewController);
        
        [self setRotatesBackButton:!firstVisibleViewController];
    } else {
        [self setRotatesBackButton:NO];
    }
}

- (void)snapControllerWillSnapToViewController:(UIViewController *)viewController
{
    if (!self.pagingEnabled) {
        [self setRotatesBackButton:(viewController != self.viewController)];
    } else {
        [self setRotatesBackButton:NO];
    }
}

- (void)snapControllerViewControllersDidChange
{
    [self setNeedsLayout];
}

#pragma mark - Back rotation.

- (void)setRotatesBackButton:(BOOL)rotatesBackButton
{
    if (rotatesBackButton != _rotatesBackButton) {
        _rotatesBackButton = rotatesBackButton;
        
        CGAffineTransform t = rotatesBackButton ? CGAffineTransformMakeRotation(M_PI) : CGAffineTransformIdentity;
        
        BOOL animated = self.window != nil;
        if (animated) {
            [UIView animateWithDuration:0.5f delay:0 usingSpringWithDamping:0.9f initialSpringVelocity:1.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                self->_compactBackButton.transform = t;
            } completion:NULL];
        } else {
            _compactBackButton.transform = t;
        }
    }
}

- (BOOL)pagingEnabled
{
    return self.splitViewController.displayMode == MMViewControllerDisplayModeSinglePage;
}

#pragma mark - Hit testing.

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hitTest = [super hitTest:point withEvent:event];
    if (!hitTest || hitTest == self || hitTest == self.backgroundView || hitTest == self.titleView) {
        for (UIView *subview in self.subviews) {
            UIButton *button = (UIButton *)subview;
            
            if ([button isKindOfClass:[UIButton class]]) {
                CGRect rect = CGRectZero;
                rect.origin.x = CGRectGetMinX(button.frame);
                rect.size.width = CGRectGetWidth(button.frame);
                rect.size.height = self.regularHeight;
                
                CGRect targetPointInsideHeaderRect = CGRectInset(rect, -15.0f, -15.0f);
                
                if (CGRectContainsPoint(targetPointInsideHeaderRect, point)) {
                    return button;
                }
            }
        }
    }
    return hitTest;
}

#pragma mark - Props.

- (void)setTitle:(NSString *)title
{
    if (![title isEqualToString:self.title]) {
        _title = title;
        _titleLabel.text = title;
        _largeTitleLabel.text = title;
        _largeTitleSize = [_largeTitleLabel sizeThatFits:(CGSize){ CGFLOAT_MAX, CGFLOAT_MAX }];
        
        [self _assignFonts];
        [self setNeedsLayout];
    }
}

- (void)setSubtitle:(NSString *)subtitle
{
    if (![subtitle isEqualToString:self.subtitle]) {
        _subtitle = subtitle;
        _subtitleLabel.text = subtitle;
        
        [self _assignFonts];
        [self setNeedsLayout];
    }
}

- (void)setTitleView:(UIView *)titleView
{
    if (titleView != _titleView) {
        [_titleView removeFromSuperview];
        
        _titleView = titleView;
        
        if (titleView) {
            [_headingContainer addSubview:titleView];
            [self setNeedsLayout];
        }
    }
}

- (void)setHidesBackButton:(BOOL)hidesBackButton
{
    if (hidesBackButton != self.hidesBackButton) {
        _hidesBackButton = hidesBackButton;
        [self setNeedsLayout];
    }
}

- (void)setLeftButton:(UIButton *)leftButton
{
    if (leftButton != self.leftButton) {
        [_leftButton removeFromSuperview];
        
        _leftButton = leftButton;
        
        [self addSubview:leftButton];
        [self setNeedsLayout];
    }
}

- (void)setRightView:(UIView *)rightView
{
    if (rightView != self.rightView) {
        [_rightView removeFromSuperview];
        
        _rightView = rightView;
        
        [self addSubview:rightView];
        [self setNeedsLayout];
    }
}

#pragma mark - Appearance.

- (void)setBackgroundView:(UIView *)backgroundView
{
    if (backgroundView != _backgroundView) {
        [_backgroundView removeFromSuperview];
        
        _backgroundView = backgroundView;
        
        [self insertSubview:backgroundView atIndex:0];
        [self setNeedsLayout];
    }
}

- (void)setSeparatorColor:(UIColor *)separatorColor
{
    if (separatorColor != _separatorColor) {
        _separatorColor = separatorColor;
        _separatorView.backgroundColor = separatorColor;
        _largeHeaderSeparatorView.backgroundColor = [separatorColor colorWithAlphaComponent:0.1f];
    }
}

- (void)setTitleTextAttributes:(NSDictionary *)titleTextAttributes
{
    if (![titleTextAttributes isEqualToDictionary:_titleTextAttributes]) {
        _titleTextAttributes = titleTextAttributes;
        
        [self _applyTextAttribures:titleTextAttributes toTextLabel:_titleLabel];
        [self _assignFonts];
    }
}

- (void)setSubtitleTextAttributes:(NSDictionary *)subtitleTextAttributes
{
    if (![subtitleTextAttributes isEqualToDictionary:_subtitleTextAttributes]) {
        _subtitleTextAttributes = subtitleTextAttributes;
        
        [self _applyTextAttribures:subtitleTextAttributes toTextLabel:_subtitleLabel];
        [self _assignFonts];
    }
}

- (void)setDisplaysLargeTitle:(BOOL)displaysLargeTitle
{
    if (![self.class _UINavigationBarUsesLargeTitles]) {
        return;
    }
    
    if (displaysLargeTitle != _displaysLargeTitle) {
        _displaysLargeTitle = displaysLargeTitle;
        
        [self sizeToFit];
    }
}

- (void)setLargeHeaderScaleFactor:(CGFloat)scaleFactor
{
    if (scaleFactor != _largeHeaderScaleFactor) {
        _largeHeaderScaleFactor = scaleFactor;
        _largeTitleLabel.transform = CGAffineTransformMakeScale(scaleFactor, scaleFactor);
    }
}

- (void)_applyTextAttribures:(NSDictionary *)textAttributes toTextLabel:(UILabel *)textLabel
{
    [textAttributes enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *attribute = key;
        
        if ([attribute isEqualToString:NSForegroundColorAttributeName]) {
            [textLabel setTextColor:obj];
        } else if ([attribute isEqualToString:NSFontAttributeName]) {
            [textLabel setFont:obj];
        } else if ([attribute isEqualToString:NSShadowAttributeName]) {
            NSShadow *textShadow = obj;
            
            [textLabel setShadowColor:textShadow.shadowColor];
            [textLabel setShadowOffset:textShadow.shadowOffset];
        }
    }];
}

#pragma mark - Large titles.

- (BOOL)displaysLargeTitleWithSize:(CGSize)size
{
    if (self.displaysLargeTitle) {
        const CGFloat spacing = [self.class _UINavigationBarDoubleEdgesRequired] ? [self.class _UINavigationBarDoubleEdgesSpacing] :  _barButtonSpacing;
        const CGFloat allowedWidth = size.width - (spacing * 2.0f);
        
        if (_largeTitleSize.width > allowedWidth) {
            return NO;
        }
        
        if (size.height < [self.class _UINavigationBarLargeTitlesHeightThreshold]) {
            return NO;
        }
        
        return YES;
    }
    return NO;
}

- (CGSize)sizeThatFits:(CGSize)size withVerticalScrollOffset:(CGFloat)offset
{
    const CGSize preferredSize = [self sizeThatFits:size];
    
    if ([self displaysLargeTitleWithSize:size]) {
        size.height = MAX(preferredSize.height + (offset * -1.0f), self.regularHeight);
    } else {
        size.height = preferredSize.height;
    }
    
    return size;
}

- (CGFloat)preferredVerticalScrollOffsetForTargetOffset:(CGFloat)offset withVerticalVelocity:(CGFloat)velocity
{
    if (_configurationOptions.showsLargeTitle) {
        const CGFloat collapsableHeight = self.largeHeaderHeight;
        
        if (offset < collapsableHeight) {
            static const CGFloat flickVelocity = 0.3f;
            const BOOL flicked = fabs(velocity) > flickVelocity;
            const BOOL isHalfway = (offset > collapsableHeight / 2.0f);
            
            if (isHalfway && flicked) {
                offset = (velocity > 0.0 ? collapsableHeight : 0.0f);
            } else {
                offset = (isHalfway ? collapsableHeight : 0.0f);
            }
        }
    }
    
    return offset;
}

#pragma mark - UIKit compatibility.

+ (BOOL)_UINavigationBarDoubleEdgesRequired
{
    static BOOL supported;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        supported = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0");
    });
    return supported;
}

+ (CGFloat)_UINavigationBarDoubleEdgesThreshold
{
    static CGFloat threshold;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"11.0")) {
            threshold = 0.0f;
        } else {
            threshold = 320.0f;
        }
    });
    return threshold;
}

+ (CGFloat)_UINavigationBarDoubleEdgesSpacing
{
    return 16.0f;
}

+ (BOOL)_UINavigationBarUsesLargeTitles
{
    static BOOL use;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        use = (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"11.0"));
    });
    return use;
}

+ (CGFloat)_UINavigationBarLargeTitlesHeightThreshold
{
    return 420.0f;
}

+ (CGFloat)_UINavigationBarDefaultHeight
{
    static CGFloat height;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        const BOOL modernBars = (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"12.0"));
        const BOOL userInterfaceIdiomPad = (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad);
        
        height = (modernBars && userInterfaceIdiomPad) ? 50.0f : 44.0f;
    });
    return height;
}

@end

@implementation _MMSnapHeaderContainerView

- (void)setNeedsLayout
{
    [super setNeedsLayout];
    [self.superview setNeedsLayout];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    const BOOL result = [super pointInside:point withEvent:event];
    if (result) {
        for (UIView *view in self.subviews) {
            if (CGRectContainsPoint(view.frame, point)) {
                return YES;
            }
        }
    }
    return NO;
}

@end
