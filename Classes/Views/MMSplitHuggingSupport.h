//
//  MMSplitHuggingSupport.h
//  MMSplitViewController
//
//  Created by Matías Martínez on 2/7/19.
//  Copyright © 2019 Matías. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MMSplitHuggingSupport <NSObject>

- (void)setHuggingProgress:(CGFloat)progress;
- (void)setPagingEnabled:(BOOL)pagingEnabled;

@end

NS_ASSUME_NONNULL_END
