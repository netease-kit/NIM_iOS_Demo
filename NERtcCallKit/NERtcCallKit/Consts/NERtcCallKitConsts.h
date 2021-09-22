//
//  NERtcCallKitConsts.h
//  NERtcCallKit
//
//  Created by Wenchao Ding on 2020/10/30.
//  Copyright © 2020 Netease. All rights reserved.
//

#ifndef NERtcCallKitConsts_h
#define NERtcCallKitConsts_h

typedef NS_OPTIONS(NSUInteger, NERtcCallType) {
    NERtcCallTypeVideo = 0,   ///视频
    NERtcCallTypeAudio = 1 << 0, ///音频
};

typedef NS_ENUM(NSUInteger, NERtcCallStatus) {
    NERtcCallStatusIdle = 0, /// 闲置
    NERtcCallStatusCalling = 1 << 0, /// 呼叫中
    NERtcCallStatusCalled = 1 << 1, /// 正在被呼叫
    NERtcCallStatusInCall = 1 << 2, /// 通话中
};

typedef void(^NERtcCallKitTokenHandler)(uint64_t uid, void(^complete)(NSString *token, NSError *error));

#define kNERtcCallKitBusyCode @"601"

static const NSUInteger kNERtcCallKitMaxTimeOut = 2 * 60;

#define NERtcCallKitDeprecate(msg) __attribute__((deprecated(msg)))

#endif /* NERtcCallKitConsts_h */
