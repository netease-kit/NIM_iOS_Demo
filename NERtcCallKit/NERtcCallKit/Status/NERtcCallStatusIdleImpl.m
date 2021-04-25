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
#import "NERtcCallKit+Private.h"
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
            [NERtcCallKit.sharedInstance signalingInvite:userID
                                                 callees:nil
                                             isFromGroup:NO
                                                 groupID:nil
                                              completion:^(NSError * _Nullable error) {
                if (error) {
                    [NERtcCallKit.sharedInstance closeSignalChannel:^{
                        if (completion) {
                            NSError *error = [NSError errorWithDomain:kNERtcCallKitErrorDomain code:kNERtcCallKitInviteError userInfo:@{NSLocalizedDescriptionKey: kNERtcCallKitInviteErrorDescription}];
                            completion(error);
                        }
                    }];
                    return;
                }
                if (completion) {
                    completion(nil);
                }
            }];
            [NERtcCallKit.sharedInstance fetchToken:^(NSString * _Nonnull token, NSError * _Nullable error) {
                if (error) {
                    [NERtcCallKit.sharedInstance closeSignalChannel:^{
                        if (completion) {
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
            [NERtcCallKit.sharedInstance batchInvite:userIDs groupID:groupID completion:^(NSError * _Nullable error) {
                if (!error) {
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
            }];
            // token预加载
            [NERtcCallKit.sharedInstance fetchToken:^(NSString * _Nonnull token, NSError * _Nullable error) {
                if (error) {
                    [NERtcCallKit.sharedInstance closeSignalChannel:^{
                        if (completion) {
                            completion(error);
                        }
                    }];
                }
            }];
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

- (void)groupInvite:(NSArray<NSString *> *)userIDs
            groupID:(NSString *)groupID
         completion:(void (^)(NSError * _Nullable))completion {
    if (!completion) return;
    
    NSError *error = [NSError errorWithDomain:kNERtcCallKitErrorDomain code:20029 userInfo:@{NSLocalizedDescriptionKey: @"只能在通话中邀请"}];
    completion(error);
}

- (void)onTimeout {
    NSLog(@"Error: onTimeout shouldn't be triggerred in idle status");
}

@end
