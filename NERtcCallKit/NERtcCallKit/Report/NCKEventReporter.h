//
//  NCKEventReporter.h
//  NERtcCallKit
//
//  Created by Wenchao Ding on 2021/5/25.
//  Copyright © 2021 Wenchao Ding. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NCKEventReporter : NSObject

/// 获取实例
/// @return 实例对象。如果IM没有登录，则返回nil
+ (instancetype)sharedReporter;

/// 上报事件
/// @param event 事件对象
- (void)report:(nullable NSDictionary *)event;

/// 清空缓存队列
- (void)flushAsync;

@end

NS_ASSUME_NONNULL_END
