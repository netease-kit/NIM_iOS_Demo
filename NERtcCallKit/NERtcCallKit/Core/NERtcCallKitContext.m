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
#import "NCKEventReporter.h"

@interface NERtcCallKitContext ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, NIMSignalingMemberInfo *> *accidMembers;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NIMSignalingMemberInfo *> *uidMembers;

@property (nonatomic, strong) NSCondition *tokenLock;

@property (nonatomic, strong) dispatch_queue_t memberQueue;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, dispatch_semaphore_t> *memberSemas;

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
        self.memberQueue = dispatch_queue_create("com.netease.yunxin.kit.call.member", DISPATCH_QUEUE_SERIAL);
        self.memberSemas = NSMutableDictionary.dictionary;
    }
    return self;
}

- (void)setChannelInfo:(NIMSignalingChannelDetailedInfo *)channelInfo
{
    _channelInfo = channelInfo;
    [self updateMemberIndexes];
}

- (void)updateMemberIndexes {
    NCKLogInfo(@"members:%@",self.channelInfo.members);
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
    [self.tokenLock signal];
    [self.memberSemas removeAllObjects];
    self.compat = nil;
    [NCKEventReporter.sharedReporter flushAsync];
    NCKLogFlush();
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
        NSNumber *nuid = @(member.uid);
        self.uidMembers[nuid] = member;
        dispatch_semaphore_t sema = self.memberSemas[nuid];
        if (sema) {
            NCKLogInfo(@"Finish waiting member for uid: %@", nuid);
            dispatch_semaphore_signal(sema);
            self.memberSemas[nuid] = nil;
        }
    }
}

- (void)removeMember:(NIMSignalingMemberInfo *)member {
    self.accidMembers[member.accountId?:@""] = nil;
    self.uidMembers[@(member.uid)] = nil;
}

- (void)fetchMemberWithUid:(uint64_t)uid completion:(nonnull void (^)(NIMSignalingMemberInfo * _Nonnull))completion {
    NSNumber *nuid = @(uid);
    NIMSignalingMemberInfo *member = self.uidMembers[nuid];
    if (member) {
        return completion(member);
    }
    dispatch_async(self.memberQueue, ^{
        NIMSignalingMemberInfo *member = self.uidMembers[nuid];
        self.memberSemas[nuid] = dispatch_semaphore_create(0);
        if (member) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(member);
            });
            self.memberSemas[nuid] = nil;
            return;
        }
        dispatch_semaphore_wait(self.memberSemas[nuid], DISPATCH_TIME_FOREVER);
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(self.uidMembers[nuid]);
        });
    });
}

@end
