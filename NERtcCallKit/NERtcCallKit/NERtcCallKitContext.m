//
//  NERtcCallKitContext.m
//  NERtcCallKit
//
//  Created by Wenchao Ding on 2020/11/24.
//  Copyright © 2020 Wenchao Ding. All rights reserved.
//

#import "NERtcCallKitContext.h"
#import <NIMSDK/NIMSDK.h>
#import "NERtcCallKitConsts.h"

@interface NERtcCallKitContext ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, NIMSignalingMemberInfo *> *accidMembers;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NIMSignalingMemberInfo *> *uidMembers;

@property (nonatomic, strong) NSCondition *tokenLock;

@end

@implementation NERtcCallKitContext

- (instancetype)init {
    self = [super init];
    if (self) {
        self.accidMembers = NSMutableDictionary.dictionary;
        self.uidMembers = NSMutableDictionary.dictionary;
        self.inviteList = NSMutableDictionary.dictionary;
        self.tokenLock = [[NSCondition alloc] init];
        self.token = @"";
    }
    return self;
}

- (void)setChannelInfo:(NIMSignalingChannelDetailedInfo *)channelInfo
{
    _channelInfo = channelInfo;
    [self updateMemberIndexes];
}

- (void)updateMemberIndexes {
    NSLog(@"members:%@",self.channelInfo.members);
    [self.accidMembers removeAllObjects];
    [self.uidMembers removeAllObjects];
    for (NIMSignalingMemberInfo *member in self.channelInfo.members) {
        self.accidMembers[member.accountId] = member;
        self.uidMembers[@(member.uid)] = member;
    }
}

- (void)cleanUp {
    [self.accidMembers removeAllObjects];
    [self.uidMembers removeAllObjects];
    [self.inviteList removeAllObjects];
    self.channelInfo = nil;
    self.groupID = nil;
    self.remoteUserID = nil;
    self.token = @"";
}

- (uint64_t)localUid {
    return self.accidMembers[self.userID?:@""].uid;
}

- (NSString *)userID {
    return NIMSDK.sharedSDK.loginManager.currentAccount;
}

- (NSString *)userName {
    NIMUser *user = [[NIMSDK sharedSDK].userManager userInfo:self.userID];
    if (user.alias.length) {
        return user.alias;
    }
    NIMUserInfo *userInfo = user.userInfo;
    if (userInfo.nickName.length) {
        return userInfo.nickName;
    }
    return self.userID;
}

- (NIMSignalingMemberInfo *)memberOfUid:(uint64_t)uid {
    return self.uidMembers[@(uid)];
}

- (NIMSignalingMemberInfo *)memberOfAccid:(NSString *)accid {
    return self.accidMembers[accid?:@""];
}

- (NSArray<NIMSignalingMemberInfo *> *)allMembers {
    return self.accidMembers.allValues;
}

- (void)addMember:(NIMSignalingMemberInfo *)member {
    if (member.accountId) {
        self.accidMembers[member.accountId] = member;
    }
    if (member.uid) {
        self.uidMembers[@(member.uid)] = member;
    }
}

- (void)removeMember:(NIMSignalingMemberInfo *)member {
    self.accidMembers[member.accountId?:@""] = nil;
    self.uidMembers[@(member.uid)] = nil;
}

@end
