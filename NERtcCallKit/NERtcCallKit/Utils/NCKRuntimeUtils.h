//
//  NCKRuntimeUtils.h
//  NERtcCallKit
//
//  Created by Wenchao Ding on 2021/6/1.
//  Copyright © 2021 Wenchao Ding. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NCKRuntimeUtils : NSObject

/// 方法交换
/// @param cls 类
/// @param originalSelector 被交换的方法
/// @param swizzledSelector 交换的方法
+ (void)swizzleInstanceMethod:(Class)cls
             originalSelector:(SEL)originalSelector
             swizzledSelector:(SEL)swizzledSelector;

@end

NS_ASSUME_NONNULL_END
