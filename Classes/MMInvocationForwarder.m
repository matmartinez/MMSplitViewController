//
//  MMInvocationForwarder.m
//  MMSplitViewController
//
//  Created by Matías Martínez on 1/29/19.
//  Copyright © 2019 Matías. All rights reserved.
//

#import "MMInvocationForwarder.h"

@interface MMInvocationForwarder ()

@property (strong, nonatomic) NSHashTable *targetTable;

@end

@implementation MMInvocationForwarder

- (instancetype)init
{
    self = [super init];
    if (self) {
        _targetTable = [NSHashTable weakObjectsHashTable];
    }
    return self;
}

- (void)addTarget:(id)target
{
    NSParameterAssert(target);
    [self.targetTable addObject:target];
}

- (void)removeTarget:(id)target
{
    NSParameterAssert(target);
    [self.targetTable removeObject:target];
}

- (NSArray *)allTargets
{
    return [self.targetTable.allObjects copy];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([super respondsToSelector:aSelector]) {
        return YES;
    }
    
    for (id delegate in self.allTargets) {
        if ([delegate respondsToSelector:aSelector]) {
            return YES;
        }
    }
    return NO;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSMethodSignature *signature = [super methodSignatureForSelector:aSelector];
    
    if (!signature) {
        for (id delegate in self.allTargets) {
            if ([delegate respondsToSelector:aSelector]) {
                return [delegate methodSignatureForSelector:aSelector];
            }
        }
    }
    
    return signature;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    for (id delegate in self.allTargets) {
        if ([delegate respondsToSelector:[anInvocation selector]]) {
            [anInvocation invokeWithTarget:delegate];
        }
    }
}

@end
