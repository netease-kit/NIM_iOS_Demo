//
//  NERtcCallKitDelegateProxy.h
//  NERtcCallKit
//
//  Created by Wenchao Ding on 2020/10/28.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NERtcCallKit.h"

NS_ASSUME_NONNULL_BEGIN

@interface NERtcCallKitDelegateProxy : NSProxy

/// 普通初始化
/// @return NERtcCallKitDelegateProxy对象
- (instancetype)init;

/// 初始化
/// @param deprecations 代理方法与废弃方法的映射
/// @return NERtcCallKitDelegateProxy对象
- (instancetype)initWithDeprecations:(nullable NSDictionary<NSString *, NSString *> *)deprecations;

/// 添加通知代理
/// @param delegate 代理对象
- (void)addDelegate:(id)delegate;

/// 移除通知代理
/// @param delegate 代理对象
- (void)removeDelegate:(id)delegate;

@end

NS_ASSUME_NONNULL_END
