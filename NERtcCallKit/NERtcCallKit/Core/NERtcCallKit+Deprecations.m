//
//  NERtcCallKit+Deprecations.m
//  NERtcCallKit
//
//  Created by Wenchao Ding on 2021/6/3.
//  Copyright © 2021 Wenchao Ding. All rights reserved.
//

#import "NERtcCallKit+Deprecations.h"
#import "NCKRuntimeUtils.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

@implementation NERtcCallKit (Deprecations)

- (void)call:(NSString *)userID
        type:(NERtcCallType)type
  completion:(void (^)(NSError * _Nullable))completion {
    [self call:userID type:type attachment:nil completion:completion];
}

- (void)groupCall:(NSArray<NSString *> *)userIDs
          groupID:(NSString *)groupID
             type:(NERtcCallType)type
       completion:(void (^)(NSError * _Nullable))completion {
    [self groupCall:userIDs groupID:groupID type:type attachment:nil completion:completion];
}

- (void)groupInvite:(NSArray<NSString *> *)userIDs
            groupID:(NSString *)groupID
         completion:(void (^)(NSError * _Nullable))completion {
    [self groupInvite:userIDs groupID:groupID attachment:nil completion:completion];
}

@end

#pragma clang diagnostic pop
