//
//  NTESLoginManager.h
//  NIM
//
//  Created by amao on 5/26/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTESSmsLoginParams.h"
#import "NTESSmsLoginResult.h"
#import "NTESSmsRegisterParams.h"

@interface NTESLoginData : NSObject
@property (nonatomic,copy)  NSString *account;
@property (nonatomic,copy)  NSString *token;
@end

@interface NTESLoginManager : NSObject

+ (instancetype)sharedManager;

@property (nonatomic,strong)    NTESLoginData   *currentLoginData;

/// 发送验证码
/// @param mobile 手机号
/// @param completion 异步回调
- (void)sendSmsCode:(NSString *)mobile completion:(void(^)(NSError *error))completion;

/// 验证码登录（获取IM账号密码）
/// @param params 参数
/// @param completion 异步回调
- (void)smsLogin:(NTESSmsLoginParams *)params
      completion:(void(^)(NTESSmsLoginResult *result, NSError *error))completion;

/// 验证码注册
/// @param params 参数
/// @param completion 异步回调
- (void)smsRegister:(NTESSmsRegisterParams *)params
         completion:(void(^)(NTESSmsLoginResult *result, NSError *error))completion;

@end
