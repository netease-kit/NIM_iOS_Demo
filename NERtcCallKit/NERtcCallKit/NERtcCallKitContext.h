//
//  NERtcCallKitContext.h
//  NERtcCallKit
//
//  Created by Wenchao Ding on 2020/11/24.
//  Copyright © 2020 Wenchao Ding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NIMSDK/NIMSDK.h>
#import "NERtcCallKitDelegateProxy.h"
#import "NERtcCallKitConsts.h"

@protocol INERtcCallStatus ;

@class NIMSignalingChannelDetailedInfo;
@class NIMSignalingMemberInfo;

NS_ASSUME_NONNULL_BEGIN

@interface NERtcCallKitContext : NSObject

@property (nonatomic, copy) NSString *appKey;

@property (nonatomic, strong) NSMutableDictionary<NSString *, NIMSignalingInviteRequest *> *inviteList;
@property (nonatomic, strong) NIMSignalingInviteNotifyInfo *inviteInfo;
@property (nonatomic, assign) BOOL isGroupCall;
@property (nonatomic, copy, nullable) NSString *groupID;

/// 1to1专用字段，对方accid
@property (nonatomic, copy, nullable) NSString *remoteUserID;

@property (nonatomic, strong, nullable) NIMSignalingChannelDetailedInfo *channelInfo;
@property (nonatomic, readonly) uint64_t localUid;

@property (nonatomic, readonly) NSString *userID;
@property (nonatomic, readonly) NSString *userName;

/// 等待token回调
@property (nonatomic, strong, readonly) NSCondition *tokenLock;
@property (nonatomic, copy) NSString *token;

- (void)cleanUp;

- (NIMSignalingMemberInfo *)memberOfUid:(uint64_t)uid;
- (NIMSignalingMemberInfo *)memberOfAccid:(NSString *)accid;
- (NSArray<NIMSignalingMemberInfo *> *)allMembers;

- (void)addMember:(NIMSignalingMemberInfo *)member;
- (void)removeMember:(NIMSignalingMemberInfo *)member;

@end

NS_ASSUME_NONNULL_END
