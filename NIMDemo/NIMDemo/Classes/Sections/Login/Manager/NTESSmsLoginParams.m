//
//  NTESSmsLoginParams.m
//  NIM
//
//  Created by Wenchao Ding on 2021/7/2.
//  Copyright © 2021 Netease. All rights reserved.
//

#import "NTESSmsLoginParams.h"

@implementation NTESSmsLoginParams

- (NSDictionary *)toDictionary {
    NSMutableDictionary *mutableDic = NSMutableDictionary.dictionary;
    mutableDic[@"mobile"] = self.mobile;
    mutableDic[@"smsCode"] = self.smsCode;
    return [NSDictionary dictionaryWithDictionary:mutableDic];
}

@end
