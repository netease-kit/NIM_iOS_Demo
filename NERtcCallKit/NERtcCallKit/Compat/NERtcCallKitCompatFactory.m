//
//  NERtcCallKitCompatFactory.m
//  NERtcCallKit
//
//  Created by Wenchao Ding on 2021/4/12.
//  Copyright © 2021 Wenchao Ding. All rights reserved.
//

#import "NERtcCallKitCompatFactory.h"
#import "NERtcCallKitCompat_1_0_0.h"
#import "NERtcCallKitCompat_1_1_0.h"

#define NERtcCallKitCompatImpl(VER) \
- (NERtcCallKitCompat_##VER *)compat_##VER { \
    if (!_compat_##VER) { \
        _compat_##VER = NERtcCallKitCompat_##VER.new; \
    } \
    return _compat_##VER; \
}

@interface NERtcCallKitCompatFactory ()

@property (nonatomic, strong) NERtcCallKitCompat_1_0_0 *compat_1_0_0;
@property (nonatomic, strong) NERtcCallKitCompat_1_1_0 *compat_1_1_0;

@end

@implementation NERtcCallKitCompatFactory

+ (instancetype)defaultFactory {
    static dispatch_once_t onceToken;
    static NERtcCallKitCompatFactory *instance;
    dispatch_once(&onceToken, ^{
        instance = NERtcCallKitCompatFactory.new;
    });
    return instance;
}

- (id<INERtcCallKitCompat>)compatWithVersion:(NSString *)version {
    NSLog(@"CK: handle version: %@", version);
    if (!version.length || [version compare:@"1.1.0" options:NSNumericSearch] == NSOrderedAscending) {
        return self.compat_1_0_0;
    }
    return self.compat_1_1_0;
}

NERtcCallKitCompatImpl(1_0_0)
NERtcCallKitCompatImpl(1_1_0)

@end

#undef NERtcCallKitCompatImpl
