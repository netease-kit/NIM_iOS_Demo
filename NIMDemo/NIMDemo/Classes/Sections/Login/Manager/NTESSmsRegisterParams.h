//
//  NTESSmsRegisterParams.h
//  NIM
//
//  Created by Wenchao Ding on 2021/7/9.
//  Copyright © 2021 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NTESSmsRegisterParams : NSObject

/// 手机号
@property (nonatomic, copy) NSString *mobile;

/// 短信验证码
@property (nonatomic, copy) NSString *smsCode;

/// 昵称
@property (nonatomic, copy, nullable) NSString *nickname;

/// 字典
- (NSDictionary *)toDictionary;

@end

NS_ASSUME_NONNULL_END
