//
//  NERtcCallKit+Private.h
//  NERtcCallKit
//
//  Created by Wenchao Ding on 2020/11/24.
//  Copyright © 2020 Wenchao Ding. All rights reserved.
//

#import "NERtcCallKit.h"
#import "NERtcCallKitDelegateProxy.h"

NS_ASSUME_NONNULL_BEGIN

@interface NERtcCallKit (Private)

@property (nonatomic, assign) NERtcCallStatus callStatus;

@property (nonatomic, readonly) NERtcCallKitDelegateProxy *delegateProxy;

- (void)send1to1CallRecord:(NIMRtcCallStatus)callStatus;
- (void)cancelInvites:(void(^)(NSError * __nullable error))completion;
- (void)closeSignalChannel:(nullable void(^)(void))completion;

- (void)joinRtcChannel:(NSString *)channelID
                 myUid:(uint64_t)myUid
            completion:(void(^)(NSError * _Nullable error))completion;

- (void)waitTimeout;
- (void)timeout;
- (void)cancelTimeout;

@end

NS_ASSUME_NONNULL_END
