//
//  NERtcCallKitCompat_1_1_0.m
//  NERtcCallKit
//
//  Created by Wenchao Ding on 2021/4/12.
//  Copyright © 2021 Wenchao Ding. All rights reserved.
//

#import "NERtcCallKitCompat_1_1_0.h"
#import "NERtcCallKit+Private.h"

@implementation NERtcCallKitCompat_1_1_0

- (void)calleeJoinRtcOnAccept:(NSString *)channelName
                        myUid:(uint64_t)myUid
                   completion:(void (^)(NSError * _Nullable))completion {
    [NERtcCallKit.sharedInstance waitTokenTimeout:30 completion:^(NSString * _Nonnull token) {
        [NERtcCallKit.sharedInstance joinRtcChannel:channelName myUid:myUid token:token completion:completion];
    }];
}

- (void)callerSendCid1To:(NSString *)userID channel:(NSString *)channelID {
    // 对方如果是1.1.0版本，不再需要cid=1的同步协议
}

- (NSString *)realChannelName:(NIMSignalingChannelInfo *)channelInfo {
    return channelInfo.channelName;
}


@end
