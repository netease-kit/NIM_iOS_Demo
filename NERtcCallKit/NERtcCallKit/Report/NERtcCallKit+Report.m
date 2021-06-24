//
//  NERtcCallStatusBase+Report.m
//  NERtcCallKit
//
//  Created by Wenchao Ding on 2021/6/1.
//  Copyright © 2021 Wenchao Ding. All rights reserved.
//

#import "NERtcCallKit+Report.h"
#import "NCKRuntimeUtils.h"
#import "NCKEventReporter.h"
#import "NCKEvent.h"
#import <objc/message.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

@implementation NERtcCallKit (Report)

- (void)call:(NSString *)userID
        type:(NERtcCallType)type
  attachment:(NSString *)attachment
  completion:(void (^)(NSError * _Nullable))completion {
    NCKLogInfo(@"call in status %ld", self.callStatus);
    [NCKEventReporter.sharedReporter report:[NCKEvent eventWithType:NCKEventTypeCall].JSONObject];
    ((void (*)(id, SEL, NSString *, NERtcCallType, NSString *, void(^)(NSError * _Nullable))) _objc_msgForward)(self, _cmd, userID, type, attachment, completion);
}

- (void)accept:(void (^)(NSError * _Nullable))completion {
    NCKLogInfo(@"accept in status %ld", self.callStatus);
    [NCKEventReporter.sharedReporter report:[NCKEvent eventWithType:NCKEventTypeAccept].JSONObject];
    ((void (*)(id, SEL, void(^)(NSError * _Nullable))) _objc_msgForward)(self, _cmd, completion);
}

- (void)reject:(void (^)(NSError * _Nullable))completion {
    NCKLogInfo(@"reject in status %ld", self.callStatus);
    [NCKEventReporter.sharedReporter report:[NCKEvent eventWithType:NCKEventTypeReject].JSONObject];
    ((void (*)(id, SEL, void(^)(NSError * _Nullable))) _objc_msgForward)(self, _cmd, completion);
}

- (void)hangup:(void (^)(NSError * _Nullable))completion {
    NCKLogInfo(@"hangup in status %ld", self.callStatus);
    [NCKEventReporter.sharedReporter report:[NCKEvent eventWithType:NCKEventTypeHangup].JSONObject];
    ((void (*)(id, SEL, void(^)(NSError * _Nullable))) _objc_msgForward)(self, _cmd, completion);
}

- (void)cancel:(void (^)(NSError * _Nullable))completion {
    NCKLogInfo(@"cancel in status %ld", self.callStatus);
    [NCKEventReporter.sharedReporter report:[NCKEvent eventWithType:NCKEventTypeCancel].JSONObject];
    ((void (*)(id, SEL, void(^)(NSError * _Nullable))) _objc_msgForward)(self, _cmd, completion);
}

- (void)onTimeout {
    NCKLogInfo(@"timeout in status %ld", self.callStatus);
    if (self.callStatus != NERtcCallStatusIdle) {
        [NCKEventReporter.sharedReporter report:[NCKEvent eventWithType:NCKEventTypeTimeout].JSONObject];
    }
    ((void (*)(id, SEL)) _objc_msgForward)(self, _cmd);
}

@end


#pragma clang diagnostic pop
