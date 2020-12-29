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
#import "NERtcCallKit_Private.h"
#import "NERtcCallKitErrors.h"

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
    [NERtcCallKit.sharedInstance cancelInvites:^(NSError * _Nullable error) {
        [NERtcEngine.sharedEngine leaveChannel];
        [NERtcCallKit.sharedInstance send1to1CallRecord:NIMRtcCallStatusCanceled];
        [NERtcCallKit.sharedInstance closeSignalChannel:^{
            if (completion) {
                completion(nil);
            }
        }];
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
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    NSString *JSONString = [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
    control.customInfo = JSONString;
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


@end
