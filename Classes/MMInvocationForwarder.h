//
//  MMInvocationForwarder.h
//  MMSplitViewController
//
//  Created by Matías Martínez on 1/29/19.
//  Copyright © 2019 Matías. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MMInvocationForwarder <ObjectType> : NSObject

- (void)addTarget:(ObjectType)target;
- (void)removeTarget:(ObjectType)target;

@property (copy, nonatomic, readonly) NSArray <ObjectType> *allTargets;

@end

NS_ASSUME_NONNULL_END
