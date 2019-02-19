//
//  MMInvocationForwarder.h
//  MMSplitViewController
//
//  Created by Matías Martínez on 1/29/19.
//  Copyright © 2019 Matías. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *   A proxy object that can be used to forward invocations to multiple targets.
 */
@interface MMInvocationForwarder <ObjectType> : NSObject

/**
 *  Called after a view controller was snapped on the split interface.
 *
 *  @param target An object that is a recipient of invocations sent to the receiver when an invocation occurs. @c nil is not a valid value.
 */
- (void)addTarget:(ObjectType)target;

/**
 *  Removes the specified target as the recipient of the invocations sent by the receiver.
 *
 *  @param target The recipient of the invocations to be removed.
 */
- (void)removeTarget:(ObjectType)target;

/**
 *  Returns all target objects associated with the receiver.
 */
@property (copy, nonatomic, readonly) NSArray <ObjectType> *allTargets;

@end

NS_ASSUME_NONNULL_END
