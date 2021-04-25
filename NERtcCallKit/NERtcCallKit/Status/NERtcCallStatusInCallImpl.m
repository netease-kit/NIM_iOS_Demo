//
//  NERtcCallStatusInCallImpl.m
//  NERtcCallKit
//
//  Created by Wenchao Ding on 2020/11/24.
//  Copyright © 2020 Wenchao Ding. All rights reserved.
//

#import "NERtcCallStatusInCallImpl.h"
#import <NIMSDK/NIMSDK.h>
#import <NERtcSDK/NERtcSDK.h>
#import "NERtcCallKitContext.h"
#import "NERtcCallKit+Private.h"
#import "NERtcCallKitErrors.h"
#import "NERtcCallKitUtils.h"

@implementation NERtcCallStatusInCallImpl

@synthesize context;

- (NERtcCallStatus)callStatus {
    return NERtcCallStatusInCall;
}

- (void)call:(NSString *)userID
        type:(NERtcCallType)type
  completion:(void (^)(NSError * _Nullable))completion {
    if (!completion) return;
    
    NSError *error = [NSError errorWithDomain:kNERtcCallKitErrorDomain code:20004 userInfo:@{NSLocalizedDescriptionKey: @"已在通话中，不能再次呼叫"}];
    completion(error);
}

- (void)groupCall:(NSArray<NSString *> *)userIDs
          groupID:(NSString *)groupID
             type:(NERtcCallType)type
       completion:(void (^)(NSError * _Nullable))completion {
    
    if (!completion) return;
    
    NSError *error = [NSError errorWithDomain:kNERtcCallKitErrorDomain code:20004 userInfo:@{NSLocalizedDescriptionKey: @"已在通话中，不能再次呼叫"}];
    completion(error);
}

- (void)hangup:(void (^)(NSError * _Nullable))completion {
    // 信令 离开频道
    dispatch_group_t group = dispatch_group_create();
    NSArray<NIMSignalingInviteRequest *> *inviteInfos = self.context.inviteList.allValues;
    for (NIMSignalingInviteRequest *invite in inviteInfos) {
        NIMSignalingCancelInviteRequest *cancel = [[NIMSignalingCancelInviteRequest alloc] init];
        cancel.requestId = invite.requestId;
        cancel.accountId = invite.accountId;
        cancel.channelId = invite.channelId;
        cancel.offlineEnabled = invite.offlineEnabled;
        dispatch_group_enter(group);
        [NIMSDK.sharedSDK.signalManager signalingCancelInvite:cancel completion:^(NSError * _Nullable error) {
            if (error) {
                [NERtcCallKit.sharedInstance.delegateProxy onError:error];
            }
            dispatch_group_leave(group);
        }];
    }
    // RTC 离开频道
//    [NERtcEngine.sharedEngine leaveChannel];
    
    dispatch_group_notify(group, NSOperationQueue.currentQueue.underlyingQueue ?: dispatch_get_main_queue(), ^{
        [NERtcCallKit.sharedInstance closeSignalChannel:^{
            if (completion) {
                completion(nil);
            }
        }];
    });
}

- (void)leave:(void (^)(NSError * _Nullable))completion
{
    NIMSignalingLeaveChannelRequest *request = [[NIMSignalingLeaveChannelRequest alloc] init];
    request.channelId = self.context.channelInfo.channelId;
    [NIMSDK.sharedSDK.signalManager signalingLeaveChannel:request completion:^(NSError * _Nullable error) {
        [self.context cleanUp];
        NERtcCallKit.sharedInstance.callStatus = NERtcCallStatusIdle;
        if (completion) {
            completion(nil);
        }
    }];
    // RTC 离开频道
    [[NERtcEngine sharedEngine] leaveChannel];
}

- (void)cancel:(void (^)(NSError * _Nullable))completion {
    if (!completion) return;
    
    NSError *error = [NSError errorWithDomain:kNERtcCallKitErrorDomain code:20016 userInfo:@{NSLocalizedDescriptionKey: @"已经在通话中了，不能取消"}];
    completion(error);
}

- (void)accept:(void (^)(NSError * _Nullable))completion {
    if (!completion) return;
    
    NSError *error = [NSError errorWithDomain:kNERtcCallKitErrorDomain code:20020 userInfo:@{NSLocalizedDescriptionKey: @"不存在需要接通的呼叫"}];
    completion(error);
}

- (void)reject:(void (^)(NSError * _Nullable))completion {
    if (!completion) return;
    
    NSError *error = [NSError errorWithDomain:kNERtcCallKitErrorDomain code:20024 userInfo:@{NSLocalizedDescriptionKey: @"不存在需要拒绝的呼叫"}];
    completion(error);
}

- (void)switchCallType:(NERtcCallType)type completion:(void (^)(NSError * _Nullable))completion {
    
    if (self.context.isGroupCall) { // 仅限1to1
        if (completion) {
            NSError *error = [NSError errorWithDomain:kNERtcCallKitErrorDomain code:kNERtcCallKit1to1LimitError userInfo:@{NSLocalizedDescriptionKey: kNERtcCallKit1to1LimitErrorDescription}];
            completion(error);
        }
    }
    // 规避异常调用
    if (type == NERtcCallTypeAudio && self.context.channelInfo.channelType == NIMSignalingChannelTypeAudio) {
        completion(nil);
        return;
    }
    if (type == NERtcCallTypeAudio && self.context.channelInfo.channelType == NIMSignalingChannelTypeAudio) {
        completion(nil);
        return;
    }
    NIMSignalingControlRequest *control = [[NIMSignalingControlRequest alloc] init];
    control.channelId = self.context.channelInfo.channelId;
    control.accountId = self.context.remoteUserID;
    NSDictionary *params = @{@"cid": @2, @"type": @(type)};
    control.customInfo = [NERtcCallKitUtils JSONStringWithObject:params];
    [NIMSDK.sharedSDK.signalManager signalingControl:control completion:^(NSError * _Nullable error) {
        if (error) {
            if (completion) {
                completion(error);
            }
            return;
        }
        NIMSignalingChannelType channelType = type == NERtcCallTypeVideo ? NIMSignalingChannelTypeVideo : NIMSignalingChannelTypeAudio;
        self.context.channelInfo.channelType = channelType;
        BOOL videoEnable = self.context.channelInfo.channelType == NIMSignalingChannelTypeVideo;
        [NERtcEngine.sharedEngine enableLocalVideo:videoEnable];
        if (completion) {
            completion(nil);
        }
    }];
}

- (void)groupInvite:(NSArray<NSString *> *)userIDs
            groupID:(NSString *)groupID
         completion:(void (^)(NSError * _Nullable))completion {
    
    if (!self.context.isGroupCall) {
        NSError *error = [NSError errorWithDomain:kNERtcCallKitErrorDomain code:20032 userInfo:@{NSLocalizedDescriptionKey: @"只能在多人呼叫模式下邀请"}];
        return completion(error);
    }
    
    // 已经在邀请中的或者已经在房间内的过滤
    NSArray *invitedAccids = [self.context.inviteList.allValues valueForKeyPath:@"accountId"];
    NSSet *invitedAccidSet = invitedAccids ? [NSSet setWithArray:invitedAccids] : nil;
    userIDs = [userIDs filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        NSString *accid = evaluatedObject;
        return [self.context memberOfAccid:accid] == nil && ![invitedAccidSet containsObject:accid];
    }]];
    
    [NERtcCallKit.sharedInstance batchInvite:userIDs groupID:groupID completion:completion];
    [NERtcCallKit.sharedInstance waitTimeout];
}

- (void)onTimeout {
    [NERtcCallKit.sharedInstance cancelInvites:nil];
}

@end
