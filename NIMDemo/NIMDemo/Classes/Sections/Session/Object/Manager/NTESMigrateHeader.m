//
//  NTESMigrateHeader.m
//  NIM
//
//  Created by Netease on 2019/10/16.
//  Copyright © 2019 Netease. All rights reserved.
//

#import "NTESMigrateHeader.h"
#import "NSDictionary+NTESJson.h"

static NSString *const kNTESMigrateHeaderVersion = @"version";
static NSString *const kNTESMigrateHeaderTerminal = @"terminal";
static NSString *const kNTESMigrateHeaderSDKVersion = @"sdk_version";
static NSString *const kNTESMigrateHeaderAPPVersion = @"app_version";
static NSString *const kNTESMigrateHeaderMessageCount = @"message_count";

@implementation NTESMigrateHeader


+ (instancetype)initWithDefaultConfig {
    NTESMigrateHeader *ret = [[NTESMigrateHeader alloc] init];
    ret.version = 0;
    ret.clientType = NIMLoginClientTypeiOS;
    ret.sdkVersion = [NIMSDK sharedSDK].sdkVersion;
    ret.appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    return ret;
}

+ (instancetype)initWithRawContent:(NSData *)data {
    if (!data) {
        return nil;
    }
    id jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if (![jsonData isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    NSDictionary *dict = (NSDictionary *)jsonData;
    NTESMigrateHeader *info = [[NTESMigrateHeader alloc] init];
    info.version = [dict jsonInteger:kNTESMigrateHeaderVersion];
    info.clientType = [dict jsonInteger:kNTESMigrateHeaderTerminal];
    info.sdkVersion = [dict jsonString:kNTESMigrateHeaderSDKVersion];
    info.appVersion = [dict jsonString:kNTESMigrateHeaderAPPVersion];
    info.totalInfoCount = [dict jsonInteger:kNTESMigrateHeaderMessageCount];
    return info;
}

- (nullable NSData *)toRawContent {
    
    if ([self invalid]) {
        return nil;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[kNTESMigrateHeaderVersion] = @(_version);
    dic[kNTESMigrateHeaderTerminal] = @(_clientType);
    dic[kNTESMigrateHeaderSDKVersion] = _sdkVersion;
    dic[kNTESMigrateHeaderAPPVersion] = _appVersion;
    dic[kNTESMigrateHeaderMessageCount] = @(_totalInfoCount);
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
    return jsonData;
}

- (BOOL)invalid {
    return (_totalInfoCount == 0 ||
            _version != 0);
}

@end
