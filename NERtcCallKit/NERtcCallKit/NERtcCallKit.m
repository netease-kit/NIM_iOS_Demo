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
#import "NERtcCallKit_Private.h"
#import "NERtcCallKitErrors.h"

#import "NERtcCallStatusIdleImpl.h"
#import "NERtcCallStatusCallingImpl.h"
#import "NERtcCallStatusCalledImpl.h"
#import "NERtcCallStatusInCallImpl.h"

@interface NERtcCallKit() <NIMSignalManagerDelegate,NERtcEngineDelegateEx,INERtcCallStatus,NERtcEngineMediaStatsObserver>

@property (nonatomic, strong) NERtcCallKitDelegateProxy *delegateProxy;

@property (nonatomic, weak) id<INERtcCallStatus> currentStatus;

@property (nonatomic, strong) id<INERtcCallStatus> idleStatus;
@property (nonatomic, strong) id<INERtcCallStatus> callingStatus;
@property (nonatomic, strong) id<INERtcCallStatus> calledStatus;
@property (nonatomic, strong) id<INERtcCallStatus> inCallStatus;

@end

@implementation NERtcCallKit

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
    [NERtcEngine.sharedEngine removeEngineMediaStatsObserver:self];
}

#pragma mark - 初始化

- (void)setupAppKey:(NSString *)appKey
            options:(nullable NERtcCallOptions *)options {
    // IM
    NIMSDKOption *option = [NIMSDKOption optionWithAppKey:appKey];
    option.apnsCername = options.APNSCerName;
    option.pkCername = options.APNSCerName;
    [[NIMSDK sharedSDK] registerWithOption:option];
    [[[NIMSDK sharedSDK] signalManager] addDelegate:self];
    // Rtc
    NERtcEngine *coreEngine = [NERtcEngine sharedEngine];
    NERtcEngineContext *context = [[NERtcEngineContext alloc] init];
    context.engineDelegate = self;
    context.appKey = appKey;
    [coreEngine setupEngineWithContext:context];
    NERtcVideoEncodeConfiguration *config = [[NERtcVideoEncodeConfiguration alloc] init];
    config.maxProfile = kNERtcVideoProfileHD720P;
    [coreEngine setLocalVideoConfig:config];
    [coreEngine enableLocalAudio:YES];
    [coreEngine enableLocalVideo:YES];
    [coreEngine addEngineMediaStatsObserver:self];
    
    [coreEngine setParameters:@{kNERtcKeyVideoStartWithBackCamera: @NO}]; // 强制前置摄像头
    
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
    NERtcVideoCanvas *canvas = [[NERtcVideoCanvas alloc] init];
    canvas.renderMode = kNERtcVideoRenderScaleCropFill;
    canvas.container = localView;
    [NERtcEngine.sharedEngine setupLocalVideoCanvas:canvas];
    __unused int ret;
    if (localView) {
        ret = [NERtcEngine.sharedEngine startPreview];
    } else {
        ret = [NERtcEngine.sharedEngine stopPreview];
    }
}

- (void)setupRemoteView:(UIView *)remoteView forUser:(nonnull NSString *)userID {
    NERtcVideoCanvas *canvas = [[NERtcVideoCanvas alloc] init];
    canvas.renderMode = kNERtcVideoRenderScaleCropFill;
    canvas.container = remoteView;
    
    NIMSignalingMemberInfo *member = [self.context memberOfAccid:userID];
    [NERtcEngine.sharedEngine setupRemoteVideoCanvas:canvas forUserID:member.uid];
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

- (void)switchCallType:(NERtcCallType)type completion:(void (^)(NSError * _Nullable))completion {
    [self.currentStatus switchCallType:type completion:completion];
}

- (void)addDelegate:(id<NERtcCallKitDelegate>)delegate {
    [self.delegateProxy addDelegate:delegate];
}

- (void)removeDelegate:(id<NERtcCallKitDelegate>)delegate {
    [self.delegateProxy removeDelegate:delegate];
}

#pragma mark - INERtcCallStatus

- (void)call:(NSString *)userID
        type:(NERtcCallType)type
  completion:(void (^)(NSError * _Nullable))completion {
    [self.currentStatus call:userID type:type completion:completion];
}

- (void)groupCall:(NSArray<NSString *> *)userIDs
          groupID:(nullable NSString *)groupID
             type:(NERtcCallType)type
       completion:(void (^)(NSError * _Nullable))completion {
    [self.currentStatus groupCall:userIDs groupID:groupID type:type completion:completion];
}

- (void)cancel:(void(^)(NSError * __nullable error))completion {
    [self.currentStatus cancel:completion];
}

- (void)accept:(nullable void(^)(NSError * _Nullable error))completion {
    [self.currentStatus accept:completion];
}

- (void)reject:(void(^)(NSError * __nullable error))completion {
    [self.currentStatus reject:completion];
}

- (void)hangup:(void (^)(NSError * _Nullable))completion {
    [self.currentStatus hangup:completion];
}

- (void)leave:(void (^)(NSError * _Nullable))completion {
    [self.currentStatus leave:completion];
}

- (NERtcCallStatus)callStatus {
    return self.currentStatus.callStatus;
}

- (void)setCallStatus:(NERtcCallStatus)callStatus {
    _callStatus = callStatus;
    switch (_callStatus) {
        case NERtcCallStatusIdle:
            self.currentStatus = self.idleStatus;
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
    switch (eventType) {
        case NIMSignalingEventTypeClose: {
            NSLog(@"eventType:NIMSignalingEventTypeClose");
            self.callStatus = NERtcCallStatusIdle;
            [NERtcEngine.sharedEngine leaveChannel];
            [self cancelTimeout];
            [self.context cleanUp];
            [self.delegateProxy onCallEnd];
            break;
        }
        case NIMSignalingEventTypeJoin: {
            NSLog(@"eventType:NIMSignalingEventTypeJoin");
            NIMSignalingJoinNotifyInfo *joinInfo = (NIMSignalingJoinNotifyInfo *)notifyResponse;
            [self.context addMember:joinInfo.member];
            break;
        }
        case NIMSignalingEventTypeLeave: {
            NSLog(@"eventType:NIMSignalingEventTypeLeave");
            break;
        }
        case NIMSignalingEventTypeInvite: {
            NSLog(@"eventType:NIMSignalingEventTypeInvite");
            NIMSignalingInviteNotifyInfo *info = (NIMSignalingInviteNotifyInfo *)notifyResponse;
            [self _handleInviteInfo:info];
            break;
        }
        case NIMSignalingEventTypeCancelInvite: {
            NSLog(@"eventType:NIMSignalingEventTypeCancelInvite");
            self.callStatus = NERtcCallStatusIdle;
            NIMSignalingCancelInviteNotifyInfo *info = (NIMSignalingCancelInviteNotifyInfo *)notifyResponse;
            [self.delegateProxy onUserCancel:info.fromAccountId];
            [self.context cleanUp];
            break;
        }
        case NIMSignalingEventTypeReject: {
            NSLog(@"eventType:NIMSignalingEventTypeReject");
            [self cancelTimeout];
            if (!self.context.isGroupCall) {
                self.callStatus = NERtcCallStatusIdle;
            }
            NIMSignalingRejectNotifyInfo *info = (NIMSignalingRejectNotifyInfo *)notifyResponse;
            if ([info.customInfo isEqualToString:kNERtcCallKitBusyCode]) {
                [self send1to1CallRecord:NIMRtcCallStatusBusy];
                [self.delegateProxy onUserBusy:info.fromAccountId];
            } else {
                [self send1to1CallRecord:NIMRtcCallStatusRejected];
                [self.delegateProxy onUserReject:info.fromAccountId];
            }
            self.context.inviteList[info.requestId ?: @""] = nil;
            break;
        }
        case NIMSignalingEventTypeAccept: {
            NSLog(@"eventType:NIMSignalingEventTypeAccept");
            [self cancelTimeout];
            NIMSignalingAcceptNotifyInfo *accept = (NIMSignalingAcceptNotifyInfo *)notifyResponse;
            self.context.inviteList[accept.requestId ?: @""] = nil;
            if (!self.context.isGroupCall) {
                NSString *channelID = self.context.channelInfo.channelId;
                uint64_t myUid = self.context.localUid;
                [self joinRtcChannel:channelID myUid:myUid completion:^(NSError * _Nullable error) {
                    if (error) {
                        NSLog(@"JOIN RTC Channel Error %@", error);
                        [self closeSignalChannel:^{
                            if (error.code != kNERtcCallKitChannelIsClosedError) {
                                [self.delegateProxy onError:error];
                                [self.delegateProxy onCallEnd];
                            }
                        }];
                        return;
                    }
                    NIMSignalingControlRequest *control = [[NIMSignalingControlRequest alloc] init];
                    control.channelId = channelID;
                    control.accountId = accept.fromAccountId;
                    
                    NSDictionary *dic = @{@"cid": @1};
                    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
                    NSString *customInfo = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    control.customInfo = customInfo;
                    
                    [NIMSDK.sharedSDK.signalManager signalingControl:control completion:^(NSError * _Nullable error) {
                        if (error && error.code != NIMRemoteErrorCodeSignalResRoomNotExists) {
                            [self closeSignalChannel:^{
                                [self.delegateProxy onError:error];
                                [self.delegateProxy onCallEnd];
                            }];
                            return;
                        }
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
            NSData *data = [controlInfo.customInfo dataUsingEncoding:NSUTF8StringEncoding];
            if (!data) {
                NSLog(@"Error: received an invalid control event with info: %@", controlInfo.customInfo);
                return;
            }
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSInteger cid = [dic[@"cid"] integerValue];
            if (cid == 1) { // Join
                NSString *channelID = self.context.inviteInfo.channelInfo.channelId;
                uint64_t myUid = self.context.localUid;
                [self joinRtcChannel:channelID myUid:myUid completion:^(NSError * _Nullable error) {
                    if (error) {
                        [self closeSignalChannel:^{
                            [self.delegateProxy onError:error];
                            [self.delegateProxy onCallEnd];
                        }];
                        return;
                    }
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
        NSLog(@"info.time:%lld createTimeStamp:%llu expireTimeStamp:%llu",info.time,info.channelInfo.createTimeStamp,info.channelInfo.expireTimeStamp);
        if (info.eventType == NIMSignalingEventTypeInvite) {
            if (!inviteInfo || info.time > inviteInfo.time) {
                inviteInfo = (NIMSignalingInviteNotifyInfo *)info;
            }
        } else if (info.eventType == NIMSignalingEventTypeCancelInvite) {
            NIMSignalingCancelInviteNotifyInfo *cancelInfo = (NIMSignalingCancelInviteNotifyInfo *)info;
            [cancelSet addObject:cancelInfo.requestId?:@""];
        }
    }
    BOOL isValid = inviteInfo && inviteInfo.channelInfo && !inviteInfo.channelInfo.invalid  && ![cancelSet containsObject:inviteInfo.requestId];
    if (isValid) {
        [self _handleInviteInfo:inviteInfo];
    }
}

// 多端同步通知
- (void)nimSignalingMultiClientSyncNotifyEventType:(NIMSignalingEventType)eventType response:(NIMSignalingNotifyInfo *)notifyResponse {
    NSLog(@"%s, %@", __FUNCTION__, @(eventType));
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

#pragma mark - NERtcEngineDelegateEx
//  其他用户加入频道
- (void)onNERtcEngineUserDidJoinWithUserID:(uint64_t)userID userName:(NSString *)userName {
    NIMSignalingMemberInfo *member = [self.context memberOfUid:userID];
    [self.delegateProxy onUserEnter:member.accountId];
}
// 对方打开摄像头
- (void)onNERtcEngineUserVideoDidStartWithUserID:(uint64_t)userID videoProfile:(NERtcVideoProfileType)profile {
    [NERtcEngine.sharedEngine subscribeRemoteVideo:YES forUserID:userID streamType:kNERtcRemoteVideoStreamTypeHigh];
    NIMSignalingMemberInfo *member = [self.context memberOfUid:userID];
    [self.delegateProxy onCameraAvailable:YES userID:member.accountId];
}

// 对方关闭了摄像头
- (void)onNERtcEngineUserVideoDidStop:(uint64_t)userID {
    NIMSignalingMemberInfo *member = [self.context memberOfUid:userID];
    [self.delegateProxy onCameraAvailable:NO userID:member.accountId];
}

// 对方打开音频
- (void)onNERtcEngineUserAudioDidStart:(uint64_t)userID {
    NIMSignalingMemberInfo *member = [self.context memberOfUid:userID];
    [self.delegateProxy onAudioAvailable:YES userID:member.accountId];
}

// 对方关闭音频
- (void)onNERtcEngineUserAudioDidStop:(uint64_t)userID {
    NIMSignalingMemberInfo *member = [self.context memberOfUid:userID];
    [self.delegateProxy onAudioAvailable:NO userID:member.accountId];
}

// 对方离开视频
- (void)onNERtcEngineUserDidLeaveWithUserID:(uint64_t)userID reason:(NERtcSessionLeaveReason)reason {
    NIMSignalingMemberInfo *member = [self.context memberOfUid:userID];
    if (!member) { // 此时有可能房间被销毁了
        return;
    }
    [self.context removeMember:member];
    if (reason == kNERtcSessionLeaveTimeout) {
        [self.delegateProxy onUserDisconnect:member.accountId];
    } else if (reason == kNERtcSessionLeaveNormal) {
        [self.delegateProxy onUserLeave:member.accountId];
    }
}

// 断开连接
- (void)onNERtcEngineDidDisconnectWithReason:(NERtcError)reason {
    if (!self.context.channelInfo) {
        return;
    }
    NSError *error = reason == kNERtcNoError ? nil : [NSError errorWithDomain:kNERtcCallKitErrorDomain code:reason userInfo:@{NSLocalizedDescriptionKey: NERtcErrorDescription(reason)}];
    [self.delegateProxy onDisconnect:error];
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

#pragma mark - timer

- (void)waitTimeout {
    [self cancelTimeout];
    [self performSelector:@selector(timeout) withObject:nil afterDelay:self.timeOutSeconds];
}

- (void)timeout {
    if (self.callStatus == NERtcCallStatusCalling) {
        [self cancelInvites:^(NSError * _Nullable error) {
            [self send1to1CallRecord:NIMRtcCallStatusTimeout];
            [self closeSignalChannel:^{
                [self.delegateProxy onCallingTimeOut];
            }];
        }];
    } else if (self.callStatus == NERtcCallStatusCalled) {
        self.callStatus = NERtcCallStatusIdle;
        [self.delegateProxy onCallingTimeOut];
    }
}

- (void)cancelTimeout {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
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
    NSError *error;
    NSData *customJSONData = [info.customInfo dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *customInfo = [NSJSONSerialization JSONObjectWithData:customJSONData ?: NSData.data options:NSJSONReadingAllowFragments error:&error];
    if (error) {
        [self.delegateProxy onError:error];
        return;
    }
    BOOL isFromGroup = [customInfo[@"callType"] isEqual:@1];
    self.context.inviteInfo = info;
    
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

#pragma mark - set
- (void)setTimeOutSeconds:(NSTimeInterval)timeOutSeconds {
    _timeOutSeconds = MIN(timeOutSeconds, kNERtcCallKitMaxTimeOut);
}

- (void)send1to1CallRecord:(NIMRtcCallStatus)callStatus
{
    if (self.context.isGroupCall) {
        return;
    }
    NSString *remoteUserID = self.context.inviteList.allValues.firstObject.accountId;
    NIMMessage *message = [[NIMMessage alloc] init];
    NIMSession *session = [NIMSession session:remoteUserID type:NIMSessionTypeP2P];
    NIMRtcCallRecordObject *record = [[NIMRtcCallRecordObject alloc] init];
    record.callStatus = callStatus;
    record.callType = self.context.channelInfo.channelType == NIMSignalingChannelTypeAudio ? NIMRtcCallTypeAudio : NIMRtcCallTypeVideo;
    record.channelID = self.context.channelInfo.channelId;
    message.messageObject = record;
    NSError *error;
    [NIMSDK.sharedSDK.chatManager sendMessage:message toSession:session error:&error];
    if (error) {
        [self.delegateProxy onError:error];
    }
}

- (void)closeSignalChannel:(void (^)(void))completion
{
    if (!self.context.channelInfo) {
        if (self.callStatus != NERtcCallStatusIdle) { // 理论上不会走到这里
            self.callStatus = NERtcCallStatusIdle;
            NSLog(@"Error: channel has been cleared while calling status is %@", @(self.callStatus));
        }
        if (completion) {
            completion();
        }
        return;
    }
    NIMSignalingCloseChannelRequest *close = [[NIMSignalingCloseChannelRequest alloc] init];
    close.channelId = self.context.channelInfo.channelId;
    [NIMSDK.sharedSDK.signalManager signalingCloseChannel:close completion:^(NSError * _Nullable error) {
        [NERtcEngine.sharedEngine leaveChannel];
        self.callStatus = NERtcCallStatusIdle;
        [self.context cleanUp];
        if (error) {
            [self.delegateProxy onError:error];
        }
        if (completion) {
            completion();
        }
    }];
}

- (void)cancelInvites:(void(^)(NSError * __nullable error))completion
{
    dispatch_group_t group = dispatch_group_create();
    NSArray<NIMSignalingInviteRequest *> *inviteRequests = self.context.inviteList.allValues;
    for (NIMSignalingInviteRequest *invite in inviteRequests) {
        NIMSignalingCancelInviteRequest *cancel = [[NIMSignalingCancelInviteRequest alloc] init];
        cancel.requestId = invite.requestId;
        cancel.accountId = invite.accountId;
        cancel.channelId = invite.channelId;
        cancel.offlineEnabled = invite.offlineEnabled;
        dispatch_group_enter(group);
        [NIMSDK.sharedSDK.signalManager signalingCancelInvite:cancel completion:^(NSError * _Nullable error) {
            if (error && error.code != NIMRemoteErrorCodeSignalResPeerPushOffline && error.code != NIMRemoteErrorCodeSignalResPeerNIMOffline) {
                [self.delegateProxy onError:error];
            }
            dispatch_group_leave(group);
        }];
    }
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (completion) {
            completion(nil);
        }
    });
}

- (void)joinRtcChannel:(NSString *)channelID
                 myUid:(uint64_t)myUid
            completion:(void(^)(NSError * _Nullable error))completion {
    
    NSLog(@"----> joinChannel: %@, uid : %lld", channelID, self.context.localUid);
    
    if (!self.tokenHandler) {
        int ret = [NERtcEngine.sharedEngine joinChannelWithToken:@""
                                                     channelName:channelID
                                                           myUid:myUid
                                                      completion:^(NSError * _Nullable error, uint64_t channelId, uint64_t elapesd) {
            if (completion) {
                completion(error);
            }
        }];
        if (ret == kNERtcErrInvalidState) {
            NSError *error = [NSError errorWithDomain:kNERtcCallKitErrorDomain code:kNERtcErrInvalidState userInfo:@{NSLocalizedDescriptionKey: NERtcErrorDescription(kNERtcErrInvalidState)}];
            completion(error);
        }
        return;
    }
    self.tokenHandler(self.context.localUid, ^(NSString *token, NSError *error) {
        if (error) {
            NSLog(@"Request token for channel failed. ChannelID: %@, myUid: %@", channelID, @(myUid));
            if (completion) {
                completion(error);
            }
            return;
        }
        NSLog(@"Request token success for channel: %@, myUid: %@, token: %@", channelID, @(myUid), token);
        if (!self.context.channelInfo) {
            if (completion) {
                NSError *error = [NSError errorWithDomain:kNERtcCallKitErrorDomain code:kNERtcCallKitChannelIsClosedError userInfo:@{NSLocalizedDescriptionKey: kNERtcCallKitChannelIsClosedErrorDescription}];
                completion(error);
            }
            return;
        }
        BOOL videoEnable = self.context.channelInfo.channelType == NIMSignalingChannelTypeVideo;
        [NERtcEngine.sharedEngine enableLocalVideo:videoEnable];
        int ret = [NERtcEngine.sharedEngine joinChannelWithToken:token
                                                     channelName:channelID
                                                           myUid:myUid
                                                      completion:^(NSError * _Nullable error, uint64_t channelId, uint64_t elapesd) {
            NSLog(@"Join channel complete channel: %@, myUid: %@", channelID, @(myUid));
            if (completion) {
                completion(error);
            }
        }];
        if (ret == kNERtcErrInvalidState) {
            NSError *error = [NSError errorWithDomain:kNERtcCallKitErrorDomain code:kNERtcErrInvalidState userInfo:@{NSLocalizedDescriptionKey: NERtcErrorDescription(kNERtcErrInvalidState)}];
            completion(error);
        }
    });
}

@end
