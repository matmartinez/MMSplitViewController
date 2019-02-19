//
//  MMSpringScrollAnimator.m
//  MMSnapController
//
//  Created by Matías Martínez on 2/2/15.
//  Copyright (c) 2015 Matías Martínez. All rights reserved.
//

#import "MMSpringScrollAnimator.h"

@interface MMSpringScrollAnimator ()

@property (weak, nonatomic, readwrite) UIScrollView *scrollView;

@property (strong, nonatomic) CADisplayLink *displayLink;

@property (assign, nonatomic) CGPoint contentOffset;
@property (assign, nonatomic) CGPoint destinationContentOffset;

@property (assign, nonatomic) CFTimeInterval beginTime;
@property (assign, nonatomic) CFTimeInterval duration;

@end

@implementation MMSpringScrollAnimator

- (instancetype)initWithTargetScrollView:(UIScrollView *)scrollView
{
    self = [super init];
    if (self) {
        self.scrollView = scrollView;
        self.damping = 10;
        self.mass = 1;
        self.stiffness = 100;
        self.initialVelocity = 0;
    }
    return self;
}

- (id<UIScrollViewDelegate>)delegate
{
    return _delegate ?: self.scrollView.delegate;
}

- (void)animateScrollToContentOffset:(CGPoint)contentOffset duration:(NSTimeInterval)duration
{
    self.contentOffset = self.scrollView.contentOffset;
    self.duration = duration;
    self.beginTime = 0.0;
    
    if (CGPointEqualToPoint(contentOffset, self.contentOffset)) {
        return;
    }
    
    self.destinationContentOffset = contentOffset;
    
    if (!self.displayLink) {
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateContentOffset:)];
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
        if (@available(iOS 10.0, *)) {
            // The display link will fire at the native cadence of the display hardware.
            self.displayLink.preferredFramesPerSecond = 0;
        }
#endif
        [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    } else {
        self.displayLink.paused = NO;
    }
}

- (void)updateContentOffset:(CADisplayLink *)displayLink
{
    if (self.beginTime == 0.0) {
        self.beginTime = displayLink.timestamp;
    } else {
        const CFTimeInterval deltaTime = displayLink.timestamp - self.beginTime;
        const CGFloat progress = (CGFloat)(deltaTime / self.duration);
        
        if (progress < 1.0) {
            if (1 - progress < 0.001) {
                [self.scrollView setContentOffset:self.destinationContentOffset];
                [self stopAnimation];
            } else {
                CGFloat b = self.damping;
                CGFloat m = self.mass;
                CGFloat k = self.stiffness;
                CGFloat v0 = self.initialVelocity;
                
                CGFloat beta = b / (2.0f * m);
                CGFloat omega0 = sqrtf(k / m);
                CGFloat omega1 = sqrtf((omega0 * omega0) - (beta * beta));
                CGFloat omega2 = sqrtf((beta * beta) - (omega0 * omega0));
                CGFloat x0 = -1.0f;
                
                CGFloat t = progress;
                CGFloat envelope = expf(-beta * t);
                CGFloat fraction;
                
                if (beta < omega0) {
                    // Underdamped:
                    fraction = -x0 + envelope * (x0 * cosf(omega1 * t) + ((beta * x0 + v0) / omega1) * sinf(omega1 * t));
                } else if (beta == omega0) {
                    // Critically damped:
                    fraction = -x0 + envelope * (x0 + (beta * x0 + v0) * t);
                } else {
                    // Overdamped:
                    fraction = -x0 + envelope * (x0 * coshf(omega2 * t) + ((beta * x0 + v0) / omega2) * sinhf(omega2 * t));
                }
                
                const CGPoint from = self.contentOffset;
                const CGPoint to = self.destinationContentOffset;
                
                CGFloat deltaX = to.x - from.x;
                CGFloat deltaY = to.y - from.y;
                
                const CGPoint offset = { from.x + fraction * deltaX, from.y + fraction * deltaY };
                
                [self.scrollView setContentOffset:offset];
            }
        } else {
            [self.scrollView setContentOffset:self.destinationContentOffset];
            [self stopAnimation];
        }
    }
}

- (void)stopAnimation
{
    self.displayLink.paused = YES;
    self.beginTime = 0.0f;
    
    id <UIScrollViewDelegate> delegate = self.delegate;
    
    if ([delegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)]) {
        [delegate scrollViewDidEndScrollingAnimation:self.scrollView];
    }
}

- (void)cancelAnimation
{
    self.displayLink.paused = YES;
}

- (BOOL)isAnimating
{
    if (self.displayLink) {
        return !self.displayLink.isPaused;
    }
    return NO;
}

- (void)setMass:(CGFloat)mass
{
    NSAssert(mass > 0, @"*** error: -mass must the greater than zero.");
    
    if (mass != _mass) {
        _mass = mass;
    }
}

- (void)setStiffness:(CGFloat)stiffness
{
    NSAssert(stiffness > 0, @"*** error: -stiffness must the greater than zero.");
    
    if (stiffness != _stiffness) {
        _stiffness = stiffness;
    }
}

- (void)setDamping:(CGFloat)damping
{
    NSAssert(damping > 0, @"*** error: -damping must the greater than zero.");
    
    if (damping != _damping) {
        _damping = damping;
    }
}

@end
