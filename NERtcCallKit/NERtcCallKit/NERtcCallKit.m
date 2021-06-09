//
//  NERtcCallKit.m
//  NLiteAVDemo
//
//  Created by Wenchao Ding on 2020/10/28.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NERtcCallKit.h"

#import "NERtcCallKitDelegateProxy.h"
#import "NERtcCallKitConsts.h"
#import "NERtcCallKitContext.h"
#import "INERtcCallStatus.h"

#import "NERtcCallStatusIdleImpl.h"
#import "NERtcCallKit+Private.h"
#import "NERtcCallKitErrors.h"
#import "NERtcCallKitUtils.h"
#import "NERtcCallKitCompatFactory.h"

#import "NERtcCallStatusIdleImpl.h"
#import "NERtcCallStatusCallingImpl.h"
#import "NERtcCallStatusCalledImpl.h"
#import "NERtcCallStatusInCallImpl.h"

#import "NERtcCallKit+Private.h"

static NSString * kNERtcCallKitMarketVersion = @"1.2.1";

@interface NERtcCallKit() <NIMSignalManagerDelegate,NIMLoginManagerDelegate,NERtcEngineDelegateEx,INERtcCallStatus,NERtcEngineMediaStatsObserver>

@property (nonatomic, strong) NERtcCallKitDelegateProxy *delegateProxy;

@property (nonatomic, weak) id<INERtcCallStatus> currentStatus;

@property (nonatomic, strong) id<INERtcCallStatus> idleStatus;
@property (nonatomic, strong) id<INERtcCallStatus> callingStatus;
@property (nonatomic, strong) id<INERtcCallStatus> calledStatus;
@property (nonatomic, strong) id<INERtcCallStatus> inCallStatus;

@end
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wincomplete-implementation"
#pragma GCC diagnostic ignored "-Wprotocol"
@implementation NERtcCallKit
#pragma GCC diagnostic pop

@synthesize context;
@synthesize callStatus = _callStatus;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static NERtcCallKit *instance;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.context = [[NERtcCallKitContext alloc] init];
        self.delegateProxy = [[NERtcCallKitDelegateProxy alloc] init];
        self.idleStatus = [[NERtcCallStatusIdleImpl alloc] init];
        self.idleStatus.context = self.context;
        self.callingStatus = [[NERtcCallStatusCallingImpl alloc] init];
        self.callingStatus.context = self.context;
        self.calledStatus = [[NERtcCallStatusCalledImpl alloc] init];
        self.calledStatus.context = self.context;
        self.inCallStatus = [[NERtcCallStatusInCallImpl alloc] init];
        self.inCallStatus.context = self.context;
        self.currentStatus = self.idleStatus;
        self.timeOutSeconds = kNERtcCallKitMaxTimeOut;
    }
    return self;
}

- (id)copy {
    return [self.class sharedInstance];
}

- (id)mutableCopy {
    return [self.class sharedInstance];
}

- (void)dealloc {
    [NIMSDK.sharedSDK.signalManager removeDelegate:self];
    [NIMSDK.sharedSDK.loginManager removeDelegate:self];
    [NERtcEngine.sharedEngine removeEngineMediaStatsObserver:self];
}

#pragma mark - 初始化

- (void)setupAppKey:(NSString *)appKey
            options:(nullable NERtcCallOptions *)options {
    // IM
    NIMSDKOption *option = [NIMSDKOption optionWithAppKey:appKey];
    option.apnsCername = options.APNSCerName;
    option.pkCername = options.APNSCerName;
    [NIMSDK.sharedSDK registerWithOption:option];
    [NIMSDK.sharedSDK.signalManager addDelegate:self];
    [NIMSDK.sharedSDK.loginManager addDelegate:self];
    // Rtc
    NERtcEngine *coreEngine = [NERtcEngine sharedEngine];
    NERtcEngineContext *context = [[NERtcEngineContext alloc] init];
    context.engineDelegate = self;
    context.appKey = appKey;
    [coreEngine setupEngineWithContext:context];
    NERtcVideoEncodeConfiguration *config = [[NERtcVideoEncodeConfiguration alloc] init];
    config.width = 540;
    config.height = 960;
    config.frameRate = kNERtcVideoFrameRateFps15;
    [coreEngine setLocalVideoConfig:config];
    [coreEngine setAudioProfile:kNERtcAudioProfileStandardExtend scenario:kNERtcAudioScenarioDefault];
    [coreEngine enableLocalAudio:YES];
    [coreEngine enableLocalVideo:YES];
    [coreEngine addEngineMediaStatsObserver:self];
    [coreEngine setParameters:@{kNERtcKeyVideoStartWithBackCamera: @NO, // 强制前置摄像头
                                kNERtcKeyAutoSubscribeAudio: @NO}]; // 关闭自动订阅
    self.context.appKey = appKey;
}

- (void)updateApnsToken:(NSData *)deviceToken {
    [[NIMSDK sharedSDK] updateApnsToken:deviceToken];
}

#pragma mark - 登录

- (void)login:(NSString *)userID
        token:(NSString *)token
   completion:(void (^)(NSError * _Nullable))completion {
    [[[NIMSDK sharedSDK] loginManager] login:userID token:token completion:^(NSError * _Nullable error) {
        if (completion) {
            completion(error);
        }
    }];
}

- (void)logout:(void (^)(NSError * _Nullable))completion {
    [NIMSDK.sharedSDK.loginManager logout:completion];
}

- (void)setupLocalView:(nullable UIView *)localView {
    __unused int ret;
    if (localView) {
        NERtcVideoCanvas *canvas = [[NERtcVideoCanvas alloc] init];
        canvas.renderMode = kNERtcVideoRenderScaleCropFill;
        canvas.container = localView;
        [NERtcEngine.sharedEngine setupLocalVideoCanvas:canvas];
        ret = [NERtcEngine.sharedEngine startPreview];
    } else {
        [NERtcEngine.sharedEngine setupLocalVideoCanvas:nil];
        ret = [NERtcEngine.sharedEngine stopPreview];
    }
}

- (void)setupRemoteView:(UIView *)remoteView forUser:(nonnull NSString *)userID {
    NIMSignalingMemberInfo *member = [self.context memberOfAccid:userID];
    if (!member) {
        return NCKLogError(@"Member of userID: %@ does NOT exist", userID);
    }
    if (remoteView) {
        NERtcVideoCanvas *canvas = [[NERtcVideoCanvas alloc] init];
        canvas.renderMode = kNERtcVideoRenderScaleCropFill;
        canvas.container = remoteView;
        
        [NERtcEngine.sharedEngine setupRemoteVideoCanvas:canvas forUserID:member.uid];
        [NERtcEngine.sharedEngine subscribeRemoteVideo:YES forUserID:member.uid streamType:kNERtcRemoteVideoStreamTypeHigh];
    } else {
        [NERtcEngine.sharedEngine setupRemoteVideoCanvas:nil forUserID:member.uid];
        [NERtcEngine.sharedEngine subscribeRemoteVideo:NO forUserID:member.uid streamType:kNERtcRemoteVideoStreamTypeHigh];
    }
}

- (void)enableLocalVideo:(BOOL)enable {
    [[NERtcEngine sharedEngine] enableLocalVideo:enable];
}

- (void)switchCamera {
    [[NERtcEngine sharedEngine] switchCamera];
}

- (void)muteLocalAudio:(BOOL)mute {
    [[NERtcEngine sharedEngine] muteLocalAudio:mute];
}

- (void)setLoudSpeakerMode:(BOOL)speaker error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    int ret = [NERtcEngine.sharedEngine setLoudspeakerMode:speaker];
    if (ret != 0) {
        *error = [NSError errorWithDomain:kNERtcCallKitErrorDomain code:ret userInfo:@{NSLocalizedDescriptionKey: NERtcErrorDescription(ret)}];
    }
}

- (void)setAudioMute:(BOOL)mute forUser:(NSString *)userID error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    NIMSignalingMemberInfo *member = [self.context memberOfAccid:userID];
    if (!member) {
        *error = [NSError errorWithDomain:kNERtcCallKitErrorDomain code:kNERtcCallKitUserNotJoinedError userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"用户%@未加入房间", userID]}];
        return;
    }
    int ret = [NERtcEngine.sharedEngine subscribeRemoteAudio:!mute forUserID:member.uid];
    if (ret != 0) {
        *error = [NSError errorWithDomain:kNERtcCallKitErrorDomain code:ret userInfo:@{NSLocalizedDescriptionKey: NERtcErrorDescription(ret)}];
        return;
    }
}

#pragma mark - Forwarding

- (id)forwardingTargetForSelector:(SEL)aSelector {
    if ([self.currentStatus respondsToSelector:aSelector]) {
        return self.currentStatus;
    } else if ([self.delegateProxy respondsToSelector:aSelector]) {
        return self.delegateProxy;
    }
    return [super forwardingTargetForSelector:aSelector];
}

- (void)setCallStatus:(NERtcCallStatus)callStatus {
    _callStatus = callStatus;
    NCKLogInfo(@"Set call status %@", @(callStatus));
    switch (_callStatus) {
        case NERtcCallStatusIdle:
            self.currentStatus = self.idleStatus;
            [self.context cleanUp];
            break;
        case NERtcCallStatusCalling:
            self.currentStatus = self.callingStatus;
            break;
        case NERtcCallStatusCalled:
            self.currentStatus = self.calledStatus;
            break;
        case NERtcCallStatusInCall:
            self.currentStatus = self.inCallStatus;
            break;
        default:
            break;
    }
}

#pragma mark - Signal Delegate
/// 在线通知
- (void)nimSignalingOnlineNotifyEventType:(NIMSignalingEventType)eventType
                                 response:(NIMSignalingNotifyInfo *)notifyResponse {
    NCKLogInfo(@"Receive signaling event: %ld", eventType);
    switch (eventType) {
        case NIMSignalingEventTypeClose: {
            if (self.context.channelInfo && ![notifyResponse.channelInfo.channelId isEqualToString:self.context.channelInfo.channelId]) {
                NCKLogError(@"Received event from previous channel: %@, current channel is: %@", notifyResponse.channelInfo.channelId, self.context.channelInfo.channelId);
            } else {
                [self onCallEnd];
            }
            break;
        }
        case NIMSignalingEventTypeJoin: {
            NIMSignalingJoinNotifyInfo *joinInfo = (NIMSignalingJoinNotifyInfo *)notifyResponse;
            [self.context addMember:joinInfo.member];
            break;
        }
        case NIMSignalingEventTypeLeave: {
            break;
        }
        case NIMSignalingEventTypeInvite: {
            NIMSignalingInviteNotifyInfo *info = (NIMSignalingInviteNotifyInfo *)notifyResponse;
            [self _handleInviteInfo:info];
            break;
        }
        case NIMSignalingEventTypeCancelInvite: {
            self.callStatus = NERtcCallStatusIdle;
            NIMSignalingCancelInviteNotifyInfo *info = (NIMSignalingCancelInviteNotifyInfo *)notifyResponse;
            [self.delegateProxy onUserCancel:info.fromAccountId];
            break;
        }
        case NIMSignalingEventTypeReject: {
            [self cancelTimeout];
            NIMSignalingRejectNotifyInfo *info = (NIMSignalingRejectNotifyInfo *)notifyResponse;
            if ([info.customInfo isEqualToString:kNERtcCallKitBusyCode]) {
                [self send1to1CallRecord:NIMRtcCallStatusBusy];
                [self.delegateProxy onUserBusy:info.fromAccountId];
            } else {
                [self send1to1CallRecord:NIMRtcCallStatusRejected];
                [self.delegateProxy onUserReject:info.fromAccountId];
            }
            if (!self.context.isGroupCall) {
                [self closeSignalChannel:nil];
            }
            self.context.inviteList[info.requestId ?: @""] = nil;
            break;
        }
        case NIMSignalingEventTypeAccept: {
            if (self.callStatus != NERtcCallStatusCalling) {
                NCKLogError(@"Receive accept event but status is %@", @(self.callStatus));
                return;
            }
            NIMSignalingAcceptNotifyInfo *accept = (NIMSignalingAcceptNotifyInfo *)notifyResponse;
            self.context.inviteList[accept.requestId ?: @""] = nil;
            if (!self.context.isGroupCall) {
                uint64_t myUid = self.context.localUid;
                NSDictionary *acceptInfo = [NERtcCallKitUtils JSONObjectWithString:accept.customInfo];
                self.context.compat = [NERtcCallKitCompatFactory.defaultFactory compatWithVersion:acceptInfo[@"version"]];
                NSString *channelId = self.context.channelInfo.channelId;
                NSString *channelName = [self.context.compat realChannelName:self.context.channelInfo];
                self.context.channelInfo.channelName = channelName;
                [self waitTokenTimeout:30 completion:^(NSString * _Nonnull token) {
                    [self joinRtcChannel:channelName myUid:myUid token:self.context.token completion:^(NSError * _Nullable error) {
                        if (error && error.code != kNERtcCallKitChannelIsClosedError) {
                            NCKLogError(@"JOIN RTC Channel Error %@", error);
                            [self closeSignalChannel:^{
                                [self.delegateProxy onError:error];
                                [self.delegateProxy onCallEnd];
                            }];
                            return;
                        }
                        [self.context.compat callerSendCid1To:accept.fromAccountId channel:channelId];
                    }];
                }];
            }
            if (self.context.channelInfo) { // 如果已经退出了，但多人通话中再次加入通话成员，则不处理
                self.callStatus = NERtcCallStatusInCall;
                [self.delegateProxy onUserAccept:accept.fromAccountId];
            }
            break;
        }
        case NIMSignalingEventTypeContrl: {
            NIMSignalingControlNotifyInfo *controlInfo = (NIMSignalingControlNotifyInfo *)notifyResponse;
            NSDictionary *dic = [NERtcCallKitUtils JSONObjectWithString:controlInfo.customInfo];
            NSInteger cid = [dic[@"cid"] integerValue];
            if (cid == 1) { // 对端发来cid=1，说明是老版本，等待token并加入
                NSString *channelName = self.context.channelInfo.channelId;
                uint64_t myUid = self.context.localUid;
                [self waitTokenTimeout:30 completion:^(NSString * _Nonnull token) {
                    [self joinRtcChannel:channelName
                                   myUid:myUid
                                   token:self.context.token
                              completion:^(NSError * _Nullable error) {
                        if (error) {
                            [self closeSignalChannel:^{
                                [self.delegateProxy onError:error];
                                [self.delegateProxy onCallEnd];
                            }];
                            return;
                        }
                    }];
                }];
            } else if (cid == 2) { // Switch call type
                NSNumber *typeNum = dic[@"type"];
                NSAssert([typeNum isKindOfClass:NSNumber.class], @"Type should be number, but is %@", typeNum.class);
                NERtcCallType type = typeNum.integerValue;
                NIMSignalingChannelType channelType = type == NERtcCallTypeVideo ? NIMSignalingChannelTypeVideo : NIMSignalingChannelTypeAudio;
                self.context.channelInfo.channelType = channelType;
                BOOL videoEnable = self.context.channelInfo.channelType == NIMSignalingChannelTypeVideo;
                [NERtcEngine.sharedEngine enableLocalVideo:videoEnable];
                [self.delegateProxy onCallTypeChange:type];
            }
            break;
        }
        default:
            break;
    }
}

/// 离线通知
- (void)nimSignalingOfflineNotify:(NSArray <NIMSignalingNotifyInfo *> *)notifyResponse {
    NIMSignalingInviteNotifyInfo *inviteInfo = nil;
    NSMutableSet<NSString *> *cancelSet = NSMutableSet.set;
    // 获取最近一次有效的、未被取消的离线邀请信息
    for (NIMSignalingNotifyInfo *info in notifyResponse.reverseObjectEnumerator) {
        NCKLogInfo(@"info.time:%lld createTimeStamp:%llu expireTimeStamp:%llu",info.time,info.channelInfo.createTimeStamp,info.channelInfo.expireTimeStamp);
        if (info.eventType == NIMSignalingEventTypeInvite) {
            if (!inviteInfo || info.time > inviteInfo.time) {
                inviteInfo = (NIMSignalingInviteNotifyInfo *)info;
            }
        } else if (info.eventType == NIMSignalingEventTypeCancelInvite) {
            NIMSignalingCancelInviteNotifyInfo *cancelInfo = (NIMSignalingCancelInviteNotifyInfo *)info;
            [cancelSet addObject:cancelInfo.requestId?:@""];
        } else if ((!info.channelInfo.invalid || info.eventType == NIMSignalingEventTypeClose) && [info.channelInfo.channelId isEqualToString:self.context.channelInfo.channelId]) {
            [self nimSignalingOnlineNotifyEventType:info.eventType response:info];
        }
    }
    BOOL isValid = inviteInfo && inviteInfo.channelInfo && !inviteInfo.channelInfo.invalid  && ![cancelSet containsObject:inviteInfo.requestId];
    if (isValid) {
        [self _handleInviteInfo:inviteInfo];
    }
}

// 多端同步通知
- (void)nimSignalingMultiClientSyncNotifyEventType:(NIMSignalingEventType)eventType response:(NIMSignalingNotifyInfo *)notifyResponse {
    NCKLogInfo(@"Receive multiclient sync notify %ld", @(eventType));
    switch (eventType) {
        case NIMSignalingEventTypeAccept:
            self.callStatus = NERtcCallStatusIdle;
            [self.delegateProxy onOtherClientAccept];
            break;
        case NIMSignalingEventTypeReject:
            self.callStatus = NERtcCallStatusIdle;
            [self.delegateProxy onOtherClientReject];
            break;
        default:
            break;
    }
}

- (void)nimSignalingChannelsSyncNotify:(NSArray<NIMSignalingChannelDetailedInfo *> *)notifyResponse {
    if (NIMSDK.sharedSDK.loginManager.currentLoginClients.count > 0) {
        [notifyResponse enumerateObjectsUsingBlock:^(NIMSignalingChannelDetailedInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            // 如果被踢掉，重新登录后可能还在信令房间，此时会收到channel sync回调，主动离开房间
            NIMSignalingLeaveChannelRequest *request = [[NIMSignalingLeaveChannelRequest alloc] init];
            request.channelId = obj.channelId;
            [NIMSDK.sharedSDK.signalManager signalingLeaveChannel:request completion:nil];
        }];
    }
}

- (void)onKickout:(NIMLoginKickoutResult *)result {
    [self onCallEnd];
}

#pragma mark - NERtcEngineDelegateEx
//  其他用户加入频道
- (void)onNERtcEngineUserDidJoinWithUserID:(uint64_t)userID userName:(NSString *)userName {
    [self.context fetchMemberWithUid:userID completion:^(NIMSignalingMemberInfo * _Nonnull member) {
        [self.delegateProxy onUserEnter:member.accountId];
    }];
}

// 对方打开摄像头
- (void)onNERtcEngineUserVideoDidStartWithUserID:(uint64_t)userID videoProfile:(NERtcVideoProfileType)profile {
    [self.context fetchMemberWithUid:userID completion:^(NIMSignalingMemberInfo * _Nonnull member) {
        [NERtcEngine.sharedEngine subscribeRemoteVideo:YES forUserID:userID streamType:kNERtcRemoteVideoStreamTypeHigh];
        [self.delegateProxy onCameraAvailable:YES userID:member.accountId];
    }];
}

// 对方关闭了摄像头
- (void)onNERtcEngineUserVideoDidStop:(uint64_t)userID {
    [self.context fetchMemberWithUid:userID completion:^(NIMSignalingMemberInfo * _Nonnull member) {
        [self.delegateProxy onCameraAvailable:NO userID:member.accountId];
    }];
}

// 对方打开音频
- (void)onNERtcEngineUserAudioDidStart:(uint64_t)userID {
    [NERtcEngine.sharedEngine subscribeRemoteAudio:YES forUserID:userID];
    [self.context fetchMemberWithUid:userID completion:^(NIMSignalingMemberInfo * _Nonnull member) {
        [self.delegateProxy onAudioAvailable:YES userID:member.accountId];
    }];
}

// 对方关闭音频
- (void)onNERtcEngineUserAudioDidStop:(uint64_t)userID {
    [NERtcEngine.sharedEngine subscribeRemoteAudio:NO forUserID:userID];
    [self.context fetchMemberWithUid:userID completion:^(NIMSignalingMemberInfo * _Nonnull member) {
        [self.delegateProxy onAudioAvailable:NO userID:member.accountId];
    }];
}

// 对方离开视频
- (void)onNERtcEngineUserDidLeaveWithUserID:(uint64_t)userID reason:(NERtcSessionLeaveReason)reason {
    if (!self.context.channelInfo) { // 此时有可能房间被销毁了
        return;
    }
    [self.context fetchMemberWithUid:userID completion:^(NIMSignalingMemberInfo * _Nonnull member) {
        [self.context removeMember:member];
        if (reason == kNERtcSessionLeaveTimeout || reason == kNERtcSessionLeaveForKick) {
            [self.delegateProxy onUserDisconnect:member.accountId];
        } else if (reason == kNERtcSessionLeaveNormal) {
            [self.delegateProxy onUserLeave:member.accountId];
        }
    }];
}

// 断开连接
- (void)onNERtcEngineDidDisconnectWithReason:(NERtcError)reason {
    if (!self.context.channelInfo) {
        return;
    }
    self.callStatus = NERtcCallStatusIdle;
    NSError *error = reason == kNERtcNoError ? nil : [NSError errorWithDomain:kNERtcCallKitErrorDomain code:reason userInfo:@{NSLocalizedDescriptionKey: NERtcErrorDescription(reason)}];
    [self.delegateProxy onDisconnect:error];
}

- (void)onEngineFirstAudioFrameDecoded:(uint64_t)userID {
    if (self.context.channelInfo.channelType == NIMSignalingChannelTypeAudio) {
        [self cancelTimeout];
    }
}

- (void)onEngineFirstVideoFrameDecoded:(uint64_t)userID width:(uint32_t)width height:(uint32_t)height {
    if (self.context.channelInfo.channelType == NIMSignalingChannelTypeVideo) {
        [self cancelTimeout];
    }
    [self.context fetchMemberWithUid:userID completion:^(NIMSignalingMemberInfo * _Nonnull member) {
        NCKLogInfo(@"First video data decoded from user: %@", member.accountId);
        [self.delegateProxy onFirstVideoFrameDecoded:member.accountId width:width height:height];
    }];
}

- (void)onNERtcEngineFirstVideoDataDidReceiveWithUserID:(uint64_t)userID {
    NIMSignalingMemberInfo *member = [self.context memberOfUid:userID];
    NCKLogInfo(@"First video data received from user: %@", member.accountId);
}

// 网络状态
- (void)onNetworkQuality:(NSArray<NERtcNetworkQualityStats *> *)stats {
    NSMutableDictionary *dic = NSMutableDictionary.dictionary;
    for (NERtcNetworkQualityStats *stat in stats) {
        NSString *userID = [self.context memberOfUid:stat.userId].accountId;
        dic[userID?:@""] = stat;
    }
    [self.delegateProxy onUserNetworkQuality:[NSDictionary dictionaryWithDictionary:dic]];
}

#pragma mark - private method
- (void)_rejectInvite:(NIMSignalingInviteNotifyInfo *)info {
    NIMSignalingRejectRequest *rejectRequest = [[NIMSignalingRejectRequest alloc] init];
    rejectRequest.channelId = info.channelInfo.channelId;
    rejectRequest.accountId = info.fromAccountId;
    rejectRequest.requestId = info.requestId;
    rejectRequest.customInfo = kNERtcCallKitBusyCode;
    [[[NIMSDK sharedSDK] signalManager] signalingReject:rejectRequest completion:^(NSError * _Nullable error) {
    }];
}

- (void)_handleInviteInfo:(NIMSignalingInviteNotifyInfo *)info {
    if (self.callStatus != NERtcCallStatusIdle) {
        // 忙线中
        [self _rejectInvite:info];
        return;
    }
    NSDictionary *customInfo = [NERtcCallKitUtils JSONObjectWithString:info.customInfo];
    if (!customInfo) {
        NCKLogError(@"customInfo of %@ should not be nil!", info.requestId);
        return;
    }
    BOOL isFromGroup = [customInfo[@"callType"] isEqual:@1];
    self.context.inviteInfo = info;
    self.context.compat = [NERtcCallKitCompatFactory.defaultFactory compatWithVersion:customInfo[@"version"]];
    
    NSString *invitee = info.fromAccountId;
    NERtcCallType type = info.channelInfo.channelType == NIMSignalingChannelTypeAudio ? NERtcCallTypeAudio : NERtcCallTypeVideo;
    self.context.isGroupCall = isFromGroup;

    self.callStatus = NERtcCallStatusCalled;
    
    if (isFromGroup) {
        NSArray<NSString *> *userIDs = customInfo[@"callUserList"] ?: @[];
        NSString *groupID = customInfo[@"groupID"];
        self.context.groupID = groupID;
        [self.delegateProxy onInvited:invitee userIDs:userIDs isFromGroup:YES groupID:groupID type:type];
    } else {
        [self.delegateProxy onInvited:invitee userIDs:@[info.toAccountId] isFromGroup:NO groupID:nil type:type];
    }
    [self waitTimeout];
}

- (void)onCallEnd {
    self.callStatus = NERtcCallStatusIdle;
    [NERtcEngine.sharedEngine leaveChannel];
    [self cancelTimeout];
    [self.context cleanUp];
    [self.delegateProxy onCallEnd];
    NCKLogFlush();
}

#pragma mark - set
- (void)setTimeOutSeconds:(NSTimeInterval)timeOutSeconds {
    _timeOutSeconds = MIN(timeOutSeconds, kNERtcCallKitMaxTimeOut);
}

+ (NSString *)versionCode {
    return kNERtcCallKitMarketVersion;
}

@end
