//
//  NERtcCallKitUtils.m
//  NERtcCallKit
//
//  Created by Wenchao Ding on 2020/11/24.
//  Copyright © 2020 Wenchao Ding. All rights reserved.
//

#import "NERtcCallKitUtils.h"
//#import <NIMSDK/NIMSDK.h>

@implementation NERtcCallKitUtils

+ (NSString *)generateRequestID {
    NSInteger random = arc4random() % 1000;
    NSString *requestID = [NSString stringWithFormat:@"%.f%zd",[NSDate timeIntervalSinceReferenceDate],random];
    return requestID;
}

+ (NSString *)displayNameForUser:(NSString *)userID groupID:(NSString *)groupID {
//    if (groupID.length) {
//        NIMTeamMember *member = [NIMSDK.sharedSDK.teamManager teamMember:userID inTeam:groupID];
//        if (member.nickname.length) {
//            return member.nickname;
//        }
//    }
//    NIMUser *info = [NIMSDK.sharedSDK.userManager userInfo:userID];
//    if (info.alias.length) {
//        return info.alias;
//    }
//    return userID;
    return @"";
}

+ (NSString *)JSONStringWithObject:(id)JSONObject {
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:JSONObject options:0 error:nil] ?: NSData.data;
    NSString *JSONString = [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
    return JSONString;
}

+ (id)JSONObjectWithString:(NSString *)JSONString {
    NSData *data = [JSONString dataUsingEncoding:NSUTF8StringEncoding] ?: NSData.data;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    return dic;
}

@end
