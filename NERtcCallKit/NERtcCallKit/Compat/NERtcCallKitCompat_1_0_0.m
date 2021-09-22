//
//  NERtcCallKitCompat_1_0_0.m
//  NERtcCallKit
//
//  Created by Wenchao Ding on 2021/4/12.
//  Copyright © 2021 Wenchao Ding. All rights reserved.
//

#import "NERtcCallKitCompat_1_0_0.h"
#import <NIMSDK/NIMSDK.h>
#import "NERtcCallKit+Private.h"
#import "NERtcCallKitUtils.h"

@implementation NERtcCallKitCompat_1_0_0

- (void)calleeJoinRtcOnAccept:(NSString *)channelName
                        myUid:(uint64_t)myUid
                   completion:(void (^)(NSError * _Nullable))completion {
    // 对端如果是1.0.0，accept之后什么也不做，等待cid=1的控制信令
    if (completion) {
        completion(nil);
    }
}

- (void)callerSendCid1To:(NSString *)userID channel:(NSString *)channelID {
    // 对端如果是1.0.0，发送cid=1的控制信令
    NIMSignalingControlRequest *control = [[NIMSignalingControlRequest alloc] init];
    control.channelId = channelID;
    control.accountId = userID;
    
    NSDictionary *dic = @{@"cid": @1};
    control.customInfo = [NERtcCallKitUtils JSONStringWithObject:dic];
    
    [NIMSDK.sharedSDK.signalManager signalingControl:control completion:^(NSError * _Nullable error) {
        if (error && error.code != NIMRemoteErrorCodeSignalResRoomNotExists) {
            [NERtcCallKit.sharedInstance closeSignalChannel:^{
                [NERtcCallKit.sharedInstance.delegateProxy onError:error];
                [NERtcCallKit.sharedInstance.delegateProxy onCallEnd];
            }];
            return;
        }
    }];
}

- (NSString *)realChannelName:(NIMSignalingChannelInfo *)channelInfo {
    return channelInfo.channelId;
}

@end
