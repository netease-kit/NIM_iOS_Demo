//
//  NTESImportMessageDelegateImpl.m
//  NIM
//
//  Created by Sampson on 2018/12/16.
//  Copyright © 2018 Netease. All rights reserved.
//

#import "NTESImportMessageDelegateImpl.h"
#import "NTESRedPacketAttachment.h"
#import "NTESRedPacketTipAttachment.h"
#import "NTESJanKenPonAttachment.h"
#import "NTESWhiteboardAttachment.h"
#import "NTESSnapchatAttachment.h"


@implementation NTESImportMessageDelegateImpl

// 对于自定义消息的类型，用户需自行处理是否支持历史消息迁移
- (BOOL)shouldImportMessage:(NIMMessage *)message {
    if (message.messageType == NIMMessageTypeCustom) {
        NIMCustomObject *customObject = message.messageObject;
        id<NIMCustomAttachment> attachment = customObject.attachment;
        
        // 支持的自定义消息
        if ([attachment isKindOfClass:[NTESJanKenPonAttachment class]]) {
            return YES;
        }
        
        // 其他类型的过滤
        return NO;
    }
    return YES;
}

- (void)onMessageWillImport:(NIMMessage *)message {
    
}

@end
