//
//  NERtcCallStatusCalledImpl.m
//  NERtcCallKit
//
//  Created by Wenchao Ding on 2020/11/24.
//  Copyright © 2020 Wenchao Ding. All rights reserved.
//

#import "NERtcCallStatusCalledImpl.h"
#import <NERtcSDK/NERtcSDK.h>
#import <NIMSDK/NIMSDK.h>
#import "NERtcCallKit_Private.h"
#import "NERtcCallKitContext.h"
#import "NERtcCallKitErrors.h"

@implementation NERtcCallStatusCalledImpl

@synthesize context;

- (NERtcCallStatus)callStatus {
    return NERtcCallStatusCalled;
}

- (void)call:(NSString *)userID
        type:(NERtcCallType)type
  completion:(void (^)(NSError * _Nullable))completion {
    if (!completion) return;
    
    NSError *error = [NSError errorWithDomain:kNERtcCallKitErrorDomain code:20003 userInfo:@{NSLocalizedDescriptionKey: @"正在被呼叫，不能发起呼叫"}];
    completion(error);
}

- (void)groupCall:(NSArray<NSString *> *)userIDs groupID:(NSString *)groupID type:(NERtcCallType)type completion:(void (^)(NSError * _Nullable))completion {
    if (!completion) return;
    
    NSError *error = [NSError errorWithDomain:kNERtcCallKitErrorDomain code:20003 userInfo:@{NSLocalizedDescriptionKey: @"正在被呼叫，不能发起呼叫"}];
    completion(error);
}

- (void)hangup:(void (^)(NSError * _Nullable))completion {
    if (!completion) return;
    
    NSError *error = [NSError errorWithDomain:kNERtcCallKitErrorDomain code:20007 userInfo:@{NSLocalizedDescriptionKey: @"正在被呼叫，不能挂断"}];
    completion(error);
}

- (void)leave:(void (^)(NSError * _Nullable))completion {
    if (!completion) return;
    
    NSError *error = [NSError errorWithDomain:kNERtcCallKitErrorDomain code:20011 userInfo:@{NSLocalizedDescriptionKey: @"未进行通话，不能离开"}];
    completion(error);
}

- (void)cancel:(void (^)(NSError * _Nullable))completion {
    if (!completion) return;
    
    NSError *error = [NSError errorWithDomain:kNERtcCallKitErrorDomain code:20015 userInfo:@{NSLocalizedDescriptionKey: @"未发起通话，不能取消"}];
    completion(error);
}

- (void)accept:(void (^)(NSError * _Nullable))completion {
    [NERtcCallKit.sharedInstance cancelTimeout];
    self.context.remoteUserID = self.context.inviteInfo.fromAccountId;
    NIMSignalingAcceptRequest *accept = [[NIMSignalingAcceptRequest alloc] init];
    accept.channelId = self.context.inviteInfo.channelInfo.channelId;
    accept.accountId = self.context.inviteInfo.fromAccountId;
    accept.requestId = self.context.inviteInfo.requestId;
    accept.autoJoin = YES;
    [[[NIMSDK sharedSDK] signalManager] signalingAccept:accept completion:^(NSError * _Nullable error, NIMSignalingChannelDetailedInfo * _Nullable response) {
        if (error) {
            NERtcCallKit.sharedInstance.callStatus = NERtcCallStatusIdle;
            if (completion) {
                completion(error);
            }
            return;
        }
        NSLog(@"****接收邀请error：%@response：%@",error,response);
        self.context.channelInfo = response;
        NERtcCallKit.sharedInstance.callStatus = NERtcCallStatusInCall;
        if (self.context.isGroupCall) {
            // groupCall下，accept后直接进入rtc房间
            NSString *channelID = response.channelId;
            uint64_t myUid = self.context.localUid;
            [NERtcCallKit.sharedInstance joinRtcChannel:channelID myUid:myUid completion:^(NSError * _Nullable outError) {
                if (outError) {
                    // 如果RTC加入失败则退出
                    [NERtcCallKit.sharedInstance leave:^(NSError * _Nullable error) {
                        if (completion) {
                            completion(outError);
                        }
                    }];
                    return;
                } else {
                    if (completion) {
                        completion(nil);
                    }
                }
            }];
        } else {
            // 1to1下，接受成功还需要等待信令cid=1握手
            if (completion) {
                completion(nil);
            }
        }
    }];
}

- (void)reject:(void (^)(NSError * _Nullable))completion {
    [NERtcCallKit.sharedInstance cancelTimeout];
    NIMSignalingRejectRequest *rejectRequest = [[NIMSignalingRejectRequest alloc] init];
    rejectRequest.channelId = self.context.inviteInfo.channelInfo.channelId;
    rejectRequest.accountId = self.context.inviteInfo.fromAccountId;
    rejectRequest.requestId = self.context.inviteInfo.requestId;
    [[[NIMSDK sharedSDK] signalManager] signalingReject:rejectRequest completion:^(NSError * _Nullable error) {
        NERtcCallKit.sharedInstance.callStatus = NERtcCallStatusIdle;
        if (completion) {
            completion(error);
        }
    }];
}

- (void)switchCallType:(NERtcCallType)type completion:(void (^)(NSError * _Nullable))completion
{
    if (!completion) return;
    
    NSError *error = [NSError errorWithDomain:kNERtcCallKitErrorDomain code:20027 userInfo:@{NSLocalizedDescriptionKey: @"只能在呼叫过程中切换"}];
    completion(error);
}

@end
