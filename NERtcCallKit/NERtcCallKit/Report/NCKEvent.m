//
//  NCKEvent.m
//  NERtcCallKit
//
//  Created by Wenchao Ding on 2021/5/25.
//  Copyright © 2021 Wenchao Ding. All rights reserved.
//

#import "NCKEvent.h"
#import <NIMSDK/NIMSDK.h>
#import "NERtcCallKit+Private.h"

@implementation NCKEvent

+ (nullable instancetype)eventWithType:(NCKEventType)type {
    if (!NIMSDK.sharedSDK.loginManager.isLogined) return nil;
    if (NERtcCallKit.sharedInstance.context.isGroupCall) return nil;
    NCKEvent *instance = self.new;
    instance.type = type;
    instance.accid = NIMSDK.sharedSDK.loginManager.currentAccount;
    instance.date = NSDate.date;
    instance.version = [NSBundle bundleForClass:self].infoDictionary[@"CFBundleShortVersionString"] ?: @"unknown";
    return instance;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.type = [coder decodeObjectForKey:@"id"];
        self.accid = [coder decodeObjectForKey:@"accid"];
        self.date = [coder decodeObjectForKey:@"date"];
        self.version = [coder decodeObjectForKey:@"version"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.type forKey:@"id"];
    [coder encodeObject:self.type forKey:@"accid"];
    [coder encodeObject:self.type forKey:@"date"];
    [coder encodeObject:self.version forKey:@"version"];
}

- (NSDictionary *)JSONObject {
    return @{
        @"id": self.type,
        @"accid": self.accid,
        @"appKey": NIMSDK.sharedSDK.appKey,
        @"date": @((UInt64)(self.date.timeIntervalSince1970*1000)),
        @"platform": @"iOS",
        @"version": self.version,
    };
}

@end
