//
//  NERtcCallStatusIdleImpl.m
//  NERtcCallKit
//
//  Created by Wenchao Ding on 2020/11/24.
//  Copyright © 2020 Wenchao Ding. All rights reserved.
//

#import "NERtcCallStatusIdleImpl.h"
#import <NIMSDK/NIMSDK.h>
#import <NERtcSDK/NERtcSDK.h>
#import "NERtcCallKitContext.h"
#import "NERtcCallKitUtils.h"
#import "NERtcCallKit_Private.h"
#import "NERtcCallKitErrors.h"

@implementation NERtcCallStatusIdleImpl

@synthesize context;

- (NERtcCallStatus)callStatus {
    return NERtcCallStatusIdle;
}

- (void)call:(NSString *)userID type:(NERtcCallType)type completion:(void (^)(NSError * _Nullable))completion {
    self.context.isGroupCall = NO;
    self.context.remoteUserID = userID;
    NERtcCallKit.sharedInstance.callStatus = NERtcCallStatusCalling;
    NIMSignalingCreateChannelRequest *create = [[NIMSignalingCreateChannelRequest alloc] init];
    create.channelType = type == NERtcCallTypeAudio ? NIMSignalingChannelTypeAudio : NIMSignalingChannelTypeVideo;
    // 1. 创建信令频道
    [NIMSDK.sharedSDK.signalManager signalingCreateChannel:create completion:^(NSError * _Nullable error, NIMSignalingChannelInfo * _Nullable response) {
        if (error) {
            NERtcCallKit.sharedInstance.callStatus = NERtcCallStatusIdle;
            if (completion) {
                completion(error);
            }
            return;
        }
        NSString *channelID = response.channelId;
        NIMSignalingJoinChannelRequest *join = [[NIMSignalingJoinChannelRequest alloc] init];
        join.channelId = response.channelId;
        
        // 2. 加入信令频道
        [NIMSDK.sharedSDK.signalManager signalingJoinChannel:join completion:^(NSError * _Nullable error, NIMSignalingChannelDetailedInfo * _Nullable response) {
            if (error) {
                [NERtcCallKit.sharedInstance closeSignalChannel:^{
                    if (completion) {
                        completion(error);
                    }
                }];
                return;
            }
            self.context.channelInfo = response;
            // 4. 邀请
            NIMSignalingInviteRequest *invite = [[NIMSignalingInviteRequest alloc] init];
            invite.accountId = userID;
            invite.requestId = [NERtcCallKitUtils generateRequestID];
            invite.channelId = channelID;
            invite.offlineEnabled = YES;
            
            NIMSignalingPushInfo *info = [[NIMSignalingPushInfo alloc] init];
            info.needPush = YES;
            NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
            info.pushTitle = appName;
            NSString *typeString = type == NERtcCallTypeVideo ? @"视频" : @"语音";
            info.pushContent = [NSString stringWithFormat:@"%@邀请你%@通话",self.context.userName,typeString];
            NSMutableDictionary *muteDic = [NSMutableDictionary dictionary];
            if (self.context.userID) {
                muteDic[@"userID"] = self.context.userID;
            }
            info.pushPayload = [muteDic copy];
            invite.push = info;
            
            NSData *JSONData = [NSJSONSerialization dataWithJSONObject:@{@"callType": @0} options:NSJSONWritingFragmentsAllowed error:&error];
            NSString *JSONString = [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
            invite.customInfo = JSONString;
            self.context.inviteList[invite.requestId] = invite;
            [NIMSDK.sharedSDK.signalManager signalingInvite:invite completion:^(NSError * _Nullable error) {
                if (!error || error.code == NIMRemoteErrorCodeSignalResPeerPushOffline || error.code == NIMRemoteErrorCodeSignalResPeerNIMOffline) {
                    if (completion) {
                        completion(nil);
                    }
                } else {
                    [NERtcCallKit.sharedInstance closeSignalChannel:^{
                        if (completion) {
                            NSError *error = [NSError errorWithDomain:kNERtcCallKitErrorDomain code:kNERtcCallKitInviteError userInfo:@{NSLocalizedDescriptionKey: kNERtcCallKitInviteErrorDescription}];
                            completion(error);
                        }
                    }];
                }
            }];
        }];
    }];
    
    [NERtcCallKit.sharedInstance waitTimeout];
}

- (void)groupCall:(NSArray<NSString *> *)userIDs
          groupID:(NSString *)groupID
             type:(NERtcCallType)type
       completion:(void (^)(NSError * _Nullable))completion {
    self.context.isGroupCall = YES;
    self.context.groupID = groupID;
    NERtcCallKit.sharedInstance.callStatus = NERtcCallStatusCalling;

    NIMSignalingCreateChannelRequest *create = [[NIMSignalingCreateChannelRequest  alloc] init];
    create.channelType = type == NERtcCallTypeAudio ? NIMSignalingChannelTypeAudio : NIMSignalingChannelTypeVideo;
    
    // 1. 创建信令频道
    [NIMSDK.sharedSDK.signalManager signalingCreateChannel:create completion:^(NSError * _Nullable error, NIMSignalingChannelInfo * _Nullable response) {
        if (error) {
            NERtcCallKit.sharedInstance.callStatus = NERtcCallStatusIdle;
            if (completion) {
                completion(error);
            }
            return;
        }
        
        NSString *channelID = response.channelId;
        NIMSignalingJoinChannelRequest *join = [[NIMSignalingJoinChannelRequest alloc] init];
        join.channelId = channelID;
        
        // 2. 加入信令频道
        [NIMSDK.sharedSDK.signalManager signalingJoinChannel:join completion:^(NSError * _Nullable error, NIMSignalingChannelDetailedInfo * _Nullable response) {
            if (error) {
                [NERtcCallKit.sharedInstance closeSignalChannel:^{
                    if (completion) {
                        completion(error);
                    }
                }];
                return;
            }
            self.context.channelInfo = response;
            
            // 3. 加入音视频频道
            __block NSError *outError;
            dispatch_group_t group = dispatch_group_create();
            dispatch_group_enter(group);
            [NERtcCallKit.sharedInstance joinRtcChannel:channelID myUid:self.context.localUid completion:^(NSError * _Nullable error) {
                outError = error;
                dispatch_group_leave(group);
            }];
            
            // 4. 邀请
            __block BOOL success = NO;
            for (NSString *userID in userIDs) {
                if (outError) {
                    success = NO;
                    break;
                }
                NIMSignalingInviteRequest *invite = [[NIMSignalingInviteRequest alloc] init];
                invite.accountId = userID;
                invite.requestId = [NERtcCallKitUtils generateRequestID];
                invite.channelId = channelID;
                invite.offlineEnabled = YES;
                
                NSMutableDictionary *dic = NSMutableDictionary.dictionary;
                dic[@"callType"] = @1;
                dic[@"callUserList"] = userIDs;
                if (groupID) {
                    dic[@"groupID"] = groupID;
                }
                NSData *JSONData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingFragmentsAllowed error:&error];
                NSString *JSONString = [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
                invite.customInfo = JSONString;
                
                NIMSignalingPushInfo *info = [[NIMSignalingPushInfo alloc] init];
                info.needPush = YES;
                NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
                info.pushTitle = appName;
                NSString *typeString = type == NERtcCallTypeVideo ? @"视频" : @"语音";
                info.pushContent = [NSString stringWithFormat:@"%@邀请你%@通话",self.context.userID, typeString];
                NSMutableDictionary *muteDic = [NSMutableDictionary dictionary];
                if (self.context.userID) {
                    muteDic[@"userID"] = self.context.userID;
                }
                info.pushPayload = [muteDic copy];
                invite.push = info;
                
                self.context.inviteList[invite.requestId] = invite;
                dispatch_group_enter(group);
                [NIMSDK.sharedSDK.signalManager signalingInvite:invite completion:^(NSError * _Nullable error) {
                    if (error == nil || error.code == NIMRemoteErrorCodeSignalResPeerPushOffline || error.code == NIMRemoteErrorCodeSignalResPeerNIMOffline) {
                        success = YES;
                    } else {
                        [NERtcCallKit.sharedInstance.delegateProxy onError:error];
                    }
                    dispatch_group_leave(group);
                }];
            }
            
            dispatch_group_notify(group, dispatch_get_main_queue(), ^{
                if (success) {
                    if (completion) {
                        completion(nil);
                    }
                } else {
                    [NERtcCallKit.sharedInstance closeSignalChannel:^{
                        if (completion) {
                            NSError *error = outError ?: [NSError errorWithDomain:kNERtcCallKitErrorDomain code:kNERtcCallKitInviteError userInfo:@{NSLocalizedDescriptionKey: kNERtcCallKitInviteErrorDescription}];
                            completion(error);
                        }
                    }];
                }
            });
        }];
    }];
    
    [NERtcCallKit.sharedInstance waitTimeout];
}

- (void)hangup:(void (^)(NSError * _Nullable))completion
{
    if (!completion) return;
    
    NSError *error = [NSError errorWithDomain:kNERtcCallKitErrorDomain code:20005 userInfo:@{NSLocalizedDescriptionKey: @"不存在需要挂断的通话"}];
    completion(error);
}

- (void)leave:(void (^)(NSError * _Nullable))completion
{
    if (!completion) return;
    
    NSError *error = [NSError errorWithDomain:kNERtcCallKitErrorDomain code:20009 userInfo:@{NSLocalizedDescriptionKey: @"未在通话中，不能离开"}];
    completion(error);
}

- (void)cancel:(void (^)(NSError * _Nullable))completion
{
    NSError *error = [NSError errorWithDomain:kNERtcCallKitErrorDomain code:20013 userInfo:@{NSLocalizedDescriptionKey: @"未在通话中，不能取消"}];
    completion(error);
}

- (void)accept:(void (^)(NSError * _Nullable))completion
{
    if (!completion) return;
    
    NSError *error = [NSError errorWithDomain:kNERtcCallKitErrorDomain code:20017 userInfo:@{NSLocalizedDescriptionKey: @"不存在需要接通的通话"}];
    completion(error);
}

- (void)reject:(void (^)(NSError * _Nullable))completion
{
    if (!completion) return;
    
    NSError *error = [NSError errorWithDomain:kNERtcCallKitErrorDomain code:20021 userInfo:@{NSLocalizedDescriptionKey: @"未收到通话邀请"}];
    completion(error);
}

- (void)switchCallType:(NERtcCallType)type completion:(void (^)(NSError * _Nullable))completion
{
    if (!completion) return;
    
    NSError *error = [NSError errorWithDomain:kNERtcCallKitErrorDomain code:20025 userInfo:@{NSLocalizedDescriptionKey: @"只能在呼叫过程中切换"}];
    completion(error);
}

@end
