//
//  NCKEvent.h
//  NERtcCallKit
//
//  Created by Wenchao Ding on 2021/5/25.
//  Copyright © 2021 Wenchao Ding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NCKEventType.h"

NS_ASSUME_NONNULL_BEGIN

@interface NCKEvent : NSObject<NSSecureCoding>

/// 事件类型
@property (nonatomic, copy) NCKEventType type;

/// IM accid
@property (nonatomic, copy) NSString *accid;

/// 时间
@property (nonatomic, strong) NSDate *date;

/// 版本号
@property (nonatomic, copy) NSString *version;

/// 获取对应类型的事件模型
/// @return 相应的事件模型
+ (nullable instancetype)eventWithType:(NCKEventType)type;

/// 序列化成JSON对象
/// @return 序列化结果
- (NSDictionary *)JSONObject;

@end

NS_ASSUME_NONNULL_END
