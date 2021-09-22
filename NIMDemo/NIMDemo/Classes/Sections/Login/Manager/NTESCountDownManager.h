//
//  NTESCountDownManager.h
//  NIM
//
//  Created by Wenchao Ding on 2021/7/5.
//  Copyright © 2021 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const NTESCountDownTickNotification;  /// 通知名称
extern NSString * const NTESCountDownCounterUserInfoKey; /// 剩余计数

@interface NTESCountDownManager : NSObject

/// 是否正在计数中
@property (nonatomic, assign, readonly) BOOL isCounting;

/// 获取实例
+ (instancetype)sharedInstance;

/// 开始倒计时
/// @param seconds 倒计时秒数
- (void)start:(NSInteger)seconds;

/// 结束倒计时
- (void)stop;

@end

NS_ASSUME_NONNULL_END
