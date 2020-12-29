//
//  NERtcCallKitErrors.h
//  NERtcCallKit
//
//  Created by Wenchao Ding on 2020/11/25.
//  Copyright © 2020 Wenchao Ding. All rights reserved.
//

#ifndef NERtcCallKitErrors_h
#define NERtcCallKitErrors_h

#define kNERtcCallKitErrorDomain @"com.netease.nmc.rtc.error"
#define kNERtcCallKitBusyErrorDescription @"正在通话中"
#define kNERtcCallKitInviteErrorDescription @"邀请发送失败"
#define kNERtcCallKitCancelErrorDescription @"通话已接通，不能取消"
#define kNERtcCallKit1to1LimitErrorDescription @"该操作仅限1to1模式"
#define kNERtcCallKitChannelIsClosedErrorDescription @"通话已结束"

static const NSUInteger kNERtcCallKitBusyError = 20000;
static const NSUInteger kNERtcCallKitInviteError = 20001;
static const NSUInteger kNERtcCallKitCancelError = 20002;


static const NSUInteger kNERtcCallKitUserNotJoinedError = 20100; //!< 用户未加入
static const NSUInteger kNERtcCallKitChannelIsClosedError = 20101; //!< 频道关闭
static const NSUInteger kNERtcCallKit1to1LimitError = 20102; //!< 仅限1to1


#endif /* NERtcCallKitErrors_h */
