//
//  NTESSmsRegisterParams.m
//  NIM
//
//  Created by Wenchao Ding on 2021/7/9.
//  Copyright © 2021 Netease. All rights reserved.
//

#import "NTESSmsRegisterParams.h"

@implementation NTESSmsRegisterParams

- (NSDictionary *)toDictionary {
    NSMutableDictionary *mutableDic = NSMutableDictionary.dictionary;
    mutableDic[@"mobile"] = self.mobile;
    mutableDic[@"smsCode"] = self.smsCode;
    if (self.nickname) {
        mutableDic[@"nickname"] = self.nickname;
    }
    return [NSDictionary dictionaryWithDictionary:mutableDic];
}

@end
