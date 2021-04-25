//
//  NERtcCallKitStatusProtocol.h
//  NERtcCallKit
//
//  Created by Wenchao Ding on 2020/11/24.
//  Copyright © 2020 Wenchao Ding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NERtcCallKitConsts.h"

@class NERtcCallKitContext;

NS_ASSUME_NONNULL_BEGIN

@protocol INERtcCallStatus <NSObject>

/// 当前通话状态
@property (nonatomic, assign, readonly) NERtcCallStatus callStatus;

/// 通话上下文
@property (nonatomic, strong) NERtcCallKitContext *context;

/// 开始呼叫
/// @param userID 呼叫的用户ID
/// @param type 通话类型
/// @param completion 回调
- (void)call:(NSString *)userID
        type:(NERtcCallType)type
  completion:(nullable void(^)(NSError * _Nullable error))completion;

/// 多人呼叫
/// @param userIDs  呼叫的用户ID数组 (不包含自己)
/// @param type 通话类型
/// @param completion 回调
- (void)groupCall:(NSArray<NSString *> *)userIDs
          groupID:(nullable NSString *)groupID
             type:(NERtcCallType)type
       completion:(nullable void(^)(NSError * _Nullable error))completion;

/// 呼叫过程中邀请用户加入
/// @param userIDs  呼叫的用户ID数组 (不包含自己)
/// @param completion 回调
- (void)groupInvite:(NSArray<NSString *> *)userIDs
            groupID:(nullable NSString *)groupID
         completion:(nullable void(^)(NSError * _Nullable error))completion;

/// 取消呼叫
/// @param completion 回调
- (void)cancel:(nullable void(^)(NSError * _Nullable error))completion;

/// 接受呼叫
/// @param completion 回调
//- (void)accept:(nullable void(^)(NSError * _Nullable error))completion;
- (void)accept:(nullable void(^)(NSError * _Nullable error))completion;

/// 拒绝呼叫
/// @param completion 回调
- (void)reject:(nullable void(^)(NSError * _Nullable error))completion;

/// 挂断
/// @param completion 回调
- (void)hangup:(nullable void(^)(NSError * _Nullable error))completion;

/// 离开，不挂断
/// @param completion 回调
- (void)leave:(nullable void(^)(NSError * _Nullable error))completion;

/// 在通话过程中切换通话类型。非通话过程中调用无效。仅支持1对1通话。
/// @param type 通话类型: 音频/视频
/// @param completion 切换完成的回调
- (void)switchCallType:(NERtcCallType)type completion:(nullable void(^)(NSError * _Nullable error))completion;

/// 超时回调
- (void)onTimeout;

@end

NS_ASSUME_NONNULL_END
