//
//  NTESSmsLoginParams.h
//  NIM
//
//  Created by Wenchao Ding on 2021/7/2.
//  Copyright © 2021 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NTESSmsLoginParams : NSObject

/// 手机号
@property (nonatomic, copy) NSString *mobile;

/// 短信验证码
@property (nonatomic, copy) NSString *smsCode;

/// 字典
- (NSDictionary *)toDictionary;

@end

NS_ASSUME_NONNULL_END
