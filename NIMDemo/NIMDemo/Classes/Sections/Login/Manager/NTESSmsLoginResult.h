//
//  NTESSmsLoginResult.h
//  NIM
//
//  Created by Wenchao Ding on 2021/7/2.
//  Copyright © 2021 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NTESSmsLoginResult : NSObject

/// 手机号
@property (nonatomic, copy) NSString *mobile;

/// IM账号
@property (nonatomic, copy) NSString *imAccid;

/// IM密码
@property (nonatomic, copy) NSString *imToken;

/// 昵称
@property (nonatomic, copy) NSString *nickname;

/// 头像
@property (nonatomic, strong) NSURL *avatarURL;

/// 根据字典初始化
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
