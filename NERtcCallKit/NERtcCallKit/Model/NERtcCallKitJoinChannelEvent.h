//
//  NERtcCallKitJoinChannelEvent.h
//  NERtcCallKit
//
//  Created by Wenchao Ding on 2021/5/25.
//  Copyright © 2021 Wenchao Ding. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NERtcCallKitJoinChannelEvent : NSObject

/// IM userID
@property (nonatomic, copy) NSString *accid;

/// 音视频用户id
@property (nonatomic, assign) uint64_t uid;

/// 音视频channelId
@property (nonatomic, assign) uint64_t cid;

/// 音视频channelName
@property (nonatomic, copy) NSString *cname;

@end

NS_ASSUME_NONNULL_END
