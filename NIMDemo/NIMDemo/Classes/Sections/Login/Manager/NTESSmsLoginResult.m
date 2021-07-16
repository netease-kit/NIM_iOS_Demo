//
//  NTESSmsLoginResult.m
//  NIM
//
//  Created by Wenchao Ding on 2021/7/2.
//  Copyright © 2021 Netease. All rights reserved.
//

#import "NTESSmsLoginResult.h"

@implementation NTESSmsLoginResult

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.mobile = dictionary[@"mobile"];
        self.imAccid = dictionary[@"imAccid"];
        self.imToken = dictionary[@"imToken"];
        if ([dictionary[@"avatar"] isKindOfClass:NSString.class]) {
            self.avatarURL = [NSURL URLWithString:dictionary[@"avatar"]];
        }
        self.nickname = dictionary[@"nickname"];
    }
    return self;
}

@end
