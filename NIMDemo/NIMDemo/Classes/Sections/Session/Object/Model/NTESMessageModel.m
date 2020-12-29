//
//  NTESMessageModel.m
//  NIM
//
//  Created by zhanggenning on 2019/10/21.
//  Copyright © 2019 Netease. All rights reserved.
//

#import "NTESMessageModel.h"

@implementation NTESMessageModel

- (instancetype)initWithMessage:(NIMMessage*)message
{
    self = [super initWithMessage:message];
    if (self) {
        self.shouldShowPinContent = NO;
        self.enableSubMessages = NO;
        self.enableRepliedContent = NO;
        self.enableQuickComments = NO;
    }
    return self;
}

@end
