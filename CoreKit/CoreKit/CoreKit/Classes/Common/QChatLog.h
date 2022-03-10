//
//  QChatLog.h
//  NERoomKit
//
//  Created by 周晓路 on 2022/1/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 日志
@interface QChatLog : NSObject
/// 初始化
+ (void)setUp;
/// info类型 log
+ (void)infoLog:(NSString *)className desc:(NSString *)desc;
/// warn类型 log
+ (void)warnLog:(NSString *)className desc:(NSString *)desc;
/// error类型 log
+ (void)errorLog:(NSString *)className desc:(NSString *)desc;
@end

NS_ASSUME_NONNULL_END
