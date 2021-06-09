//
//  NERtcCallKit.h
//  NERtcCallKit
//
//  Created by Wenchao Ding on 2020/10/28.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <NIMSDK/NIMSDK.h>
#import <NERtcSDK/NERtcSDK.h>
#import "NERtcCallOptions.h"
#import "NERtcCallKitConsts.h"

//! Project version number for NERtcCallKit.
FOUNDATION_EXPORT double NERtcCallKitVersionNumber;

//! Project version string for NERtcCallKit.
FOUNDATION_EXPORT const unsigned char NERtcCallKitVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <NERtcCallKit/PublicHeader.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NERtcCallKitDelegate <NSObject>

@optional

/// 收到邀请的回调
/// @param invitor 邀请方
/// @param userIDs 房间中的被邀请的所有人（不包含邀请者）
/// @param isFromGroup 是否是群组
/// @param groupID 群组ID
/// @param type 通话类型
- (void)onInvited:(NSString *)invitor
          userIDs:(NSArray<NSString *> *)userIDs
      isFromGroup:(BOOL)isFromGroup
          groupID:(nullable NSString *)groupID
             type:(NERtcCallType)type;

/// 接受邀请的回调
/// @param userID 接受者
- (void)onUserEnter:(NSString *)userID;

/// 拒绝邀请的回调
/// @param userID 拒绝者
- (void)onUserReject:(NSString *)userID;

/// 取消邀请的回调
/// @param userID 邀请方
- (void)onUserCancel:(NSString *)userID;

/// 用户离开的回调.
/// @param userID 用户userID
- (void)onUserLeave:(NSString *)userID;

/// 用户异常离开的回调
/// @param userID 用户userID
- (void)onUserDisconnect:(NSString *)userID;

/// 用户接受邀请的回调
/// @param userID 用户userID
- (void)onUserAccept:(NSString *)userID;

/// 忙线
/// @param userID 忙线的用户ID
- (void)onUserBusy:(NSString *)userID;

/// 通话类型切换的回调（仅1对1呼叫有效）
/// @param callType 切换后的类型
- (void)onCallTypeChange:(NERtcCallType)callType;

/// 通话结束
- (void)onCallEnd;

/// 呼叫超时
- (void)onCallingTimeOut;

/// 连接断开
/// @param reason 断开原因
- (void)onDisconnect:(NSError *)reason;

/// 发生错误
- (void)onError:(NSError *)error;

/// 启用/禁用相机
/// @param available 是否可用
/// @param userID 用户ID
- (void)onCameraAvailable:(BOOL)available userID:(NSString *)userID;

/// 启用/禁用麦克风
/// @param available 是否可用
/// @param userID 用户userID
- (void)onAudioAvailable:(BOOL)available userID:(NSString *)userID;

/// 首帧解码成功的回调
/// @param userID 用户id
/// @param width 宽度
/// @param height 高度
- (void)onFirstVideoFrameDecoded:(NSString *)userID width:(uint32_t)width height:(uint32_t)height;

/// 网络状态监测回调
/// @param stats key为用户ID, value为对应网络状态
- (void)onUserNetworkQuality:(NSDictionary<NSString *, NERtcNetworkQualityStats *> *)stats;

/// 呼叫请求已被其他端接收的回调
- (void)onOtherClientAccept;

/// 呼叫请求已被其他端拒绝的回调
- (void)onOtherClientReject;

@end

@interface NERtcCallKit : NSObject

/// 通话状态
@property (nonatomic, assign, readonly) NERtcCallStatus callStatus;

/// 单位:秒,IM服务器邀请2分钟后无响应为超时,最大值不超过2分钟。
@property (nonatomic, assign) NSTimeInterval timeOutSeconds;

/// 安全模式音视频房间token获取，nil表示非安全模式. Block中一定要调用complete
@property (nonatomic, copy, nullable) NERtcCallKitTokenHandler tokenHandler;

/// 单例
+ (instancetype)sharedInstance;

/// 初始化，所有功能需要先初始化
/// @param appKey 云信后台注册的appKey
- (void)setupAppKey:(NSString *)appKey options:(nullable NERtcCallOptions *)options;

/// 登录IM接口，所有功能需要先进行登录后才能使用
/// @param userID IM用户accid
/// @param token IM用户token
/// @param completion 回调
- (void)login:(NSString *)userID
        token:(NSString *)token
   completion:(nullable void(^)(NSError * _Nullable error))completion;

/// 更新APNS deviceToken
/// @param deviceToken 注册获得的deviceToken
- (void)updateApnsToken:(NSData *)deviceToken;

/// 登出
- (void)logout:(nullable void(^)(NSError * _Nullable error))completion;

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

/// 呼叫过程中邀请用户加入（仅限群呼）
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

/// 设置自己画面
/// @param localView 渲染自己画面的View
/// @discussion localView上不建议有任何subview
- (void)setupLocalView:(nullable UIView *)localView;

/// 设置其他用户画面
/// @param remoteView 渲染其他画面的View
/// @param userID 其他用户ID
/// @discussion remoteView上不建议有任何subview
- (void)setupRemoteView:(nullable UIView *)remoteView forUser:(NSString *)userID;

/// 是否开启摄像头
/// @param enable 是否开启
- (void)enableLocalVideo:(BOOL)enable;

/// 切换摄像头
- (void)switchCamera;

/// 麦克风静音
/// @param mute YES：静音 NO：开启
- (void)muteLocalAudio:(BOOL)mute;

/// 在通话过程中切换通话类型。非通话过程中调用无效。仅支持1对1通话。
/// @param type 通话类型: 音频/视频
/// @param completion 切换完成的回调
/// @discussion 切换完成后，组件内部会将己端和对端调用-enableLocalVideo:，此时外部不建议再调用-enableLocalVideo:，防止状态错乱.
- (void)switchCallType:(NERtcCallType)type completion:(nullable void(^)(NSError * _Nullable error))completion;

/// 是否使用扬声器模式
/// @param speaker YES：扬声器 NO：听筒
/// @param error 错误，成功为nil
- (void)setLoudSpeakerMode:(BOOL)speaker error:(NSError * _Nullable * _Nullable)error;

/// 指定对某个用户静音。
/// @param mute 是否静音
/// @param userID 用户ID
/// @param error 错误，成功为nil
/// @discussion 只能不接收指定用户的音频，并不影响房间中其他人接受该用户的音频
- (void)setAudioMute:(BOOL)mute forUser:(NSString *)userID error:(NSError * _Nullable * _Nullable)error;

/// 添加代理 接受回调
/// @param delegate 代理对象
- (void)addDelegate:(id<NERtcCallKitDelegate>)delegate;

/// 移除代理
/// @param delegate 代理对象
- (void)removeDelegate:(id<NERtcCallKitDelegate>)delegate;

/// 版本号
+ (NSString *)versionCode;

@end

NS_ASSUME_NONNULL_END
