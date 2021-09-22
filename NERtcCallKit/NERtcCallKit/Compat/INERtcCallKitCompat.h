//
//  INERtcCallKitCompat.h
//  NERtcCallKit
//
//  Created by Wenchao Ding on 2021/4/12.
//  Copyright © 2021 Wenchao Ding. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class NIMSignalingChannelInfo;

@protocol INERtcCallKitCompat <NSObject>

- (void)calleeJoinRtcOnAccept:(NSString *)channelName
                        myUid:(uint64_t)myUid
                   completion:(void(^)(NSError * _Nullable error))completion;


- (void)callerSendCid1To:(NSString *)userID
                 channel:(NSString *)channelID;
    
- (NSString *)realChannelName:(NIMSignalingChannelInfo *)channelInfo;

@end

NS_ASSUME_NONNULL_END
