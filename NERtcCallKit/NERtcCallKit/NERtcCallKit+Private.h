//
//  NERtcCallKit+Private.h
//  NERtcCallKit
//
//  Created by Wenchao Ding on 2020/11/24.
//  Copyright © 2020 Wenchao Ding. All rights reserved.
//

#import "NERtcCallKit.h"
#import "NERtcCallKitDelegateProxy.h"
#import "NERtcCallKitContext.h"


NS_ASSUME_NONNULL_BEGIN

@interface NERtcCallKit (Private)

/// 当前通话状态
@property (nonatomic, assign) NERtcCallStatus callStatus;

/// 代理派发
@property (nonatomic, strong, readonly) NERtcCallKitDelegateProxy *delegateProxy;

/// 发送话单
- (void)send1to1CallRecord:(NIMRtcCallStatus)callStatus;

/// 信令邀请
- (void)signalingInvite:(NSString *)userID
                callees:(nullable NSArray<NSString *> *)callees
            isFromGroup:(BOOL)isFromGroup
                groupID:(nullable NSString *)groupID
             completion:(nullable void (^)(NSError * _Nullable error))completion;

/// 批量邀请
- (void)batchInvite:(NSArray<NSString *> *)userIDs
            groupID:(nullable NSString *)groupID
         completion:(nullable void(^)(NSError * _Nullable error))completion;

/// 取消邀请
- (void)cancelInvites:(nullable void(^)(NSError * _Nullable error))completion;

// 关闭信令房间
- (void)closeSignalChannel:(nullable void(^)(void))completion;

// 加载token
- (void)fetchToken:(nullable void(^)(NSString *token, NSError * _Nullable error))completion;

// 等待token
- (void)waitTokenTimeout:(NSTimeInterval)timeout completion:(void(^)(NSString *token))completion;

/// 加入音视频频道
- (void)joinRtcChannel:(NSString *)channelID
                 myUid:(uint64_t)myUid
            completion:(void(^)(NSError * _Nullable error))completion;

// 带token直接加入频道
- (void)joinRtcChannel:(NSString *)channelID
                 myUid:(uint64_t)myUid
                 token:(NSString *)token
            completion:(void(^)(NSError * _Nullable error))completion;

/// 等待超时
- (void)waitTimeout;

/// 取消超时
- (void)cancelTimeout;

@end

NS_ASSUME_NONNULL_END
