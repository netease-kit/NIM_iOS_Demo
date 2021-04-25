//
//  NERtcCallStatusCallingImpl.m
//  NERtcCallKit
//
//  Created by Wenchao Ding on 2020/11/24.
//  Copyright © 2020 Wenchao Ding. All rights reserved.
//

#import "NERtcCallStatusCallingImpl.h"
#import "NERtcCallKitContext.h"
#import <NERtcSDK/NERtcSDK.h>
#import "NERtcCallKit+Private.h"
#import "NERtcCallKitErrors.h"
#import "NERtcCallKitUtils.h"

@implementation NERtcCallStatusCallingImpl

@synthesize context;

- (NERtcCallStatus)callStatus
{
    return NERtcCallStatusCalling;
}

- (void)call:(NSString *)userID
        type:(NERtcCallType)type
  completion:(void (^)(NSError * _Nullable))completion {
    
    if (!completion) return;
    
    NSError *error = [NSError errorWithDomain:kNERtcCallKitErrorDomain code:20002 userInfo:@{NSLocalizedDescriptionKey: @"已在通话中"}];
    completion(error);
}

- (void)groupCall:(NSArray<NSString *> *)userIDs
          groupID:(NSString *)groupID
             type:(NERtcCallType)type
       completion:(void (^)(NSError * _Nullable))completion {
    
    if (!completion) return;
    
    NSError *error = [NSError errorWithDomain:kNERtcCallKitErrorDomain code:20002 userInfo:@{NSLocalizedDescriptionKey: @"已在通话中"}];
    completion(error);
}

- (void)hangup:(void (^)(NSError * _Nullable))completion
{
    [self cancel:completion];
}

- (void)leave:(void (^)(NSError * _Nullable))completion
{
    if (!completion) return;
    
    NSError *error = [NSError errorWithDomain:kNERtcCallKitErrorDomain code:20010 userInfo:@{NSLocalizedDescriptionKey: @"离开失败，还没有进行通话"}];
    completion(error);
    
}

- (void)cancel:(void(^)(NSError * __nullable error))completion {
    [NERtcCallKit.sharedInstance cancelTimeout];
    [NERtcCallKit.sharedInstance cancelInvites:nil];
    [NERtcCallKit.sharedInstance send1to1CallRecord:NIMRtcCallStatusCanceled];
    [NERtcCallKit.sharedInstance closeSignalChannel:^{
        if (completion) {
            completion(nil);
        }
    }];
}

- (void)accept:(void (^)(NSError * _Nullable))completion
{
    if (!completion) return;
    
    NSError *error = [NSError errorWithDomain:kNERtcCallKitErrorDomain code:20018 userInfo:@{NSLocalizedDescriptionKey: @"接受失败，正在进行呼叫"}];
    completion(error);
}

- (void)reject:(void (^)(NSError * _Nullable))completion
{
    if (!completion) return;
    
    NSError *error = [NSError errorWithDomain:kNERtcCallKitErrorDomain code:20022 userInfo:@{NSLocalizedDescriptionKey: @"拒绝失败，正在进行呼叫"}];
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
    [NERtcCallKit.sharedInstance cancelInvites:^(NSError * _Nullable error) {
        [NERtcCallKit.sharedInstance send1to1CallRecord:NIMRtcCallStatusTimeout];
        [NERtcCallKit.sharedInstance closeSignalChannel:^{
            [NERtcCallKit.sharedInstance.delegateProxy onCallingTimeOut];
        }];
    }];
}


@end
