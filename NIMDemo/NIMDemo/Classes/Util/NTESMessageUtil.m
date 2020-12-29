//
//  NTESMessageUtil.m
//  NIM
//
//  Created by Netease on 2019/10/17.
//  Copyright © 2019 Netease. All rights reserved.
//

#import "NTESMessageUtil.h"
#import "NIMMessageUtil.h"

@implementation NTESMessageUtil

+ (NSString *)messageContent:(NIMMessage *)message {
    NSString *text = nil;
    if (message.messageType == NIMMessageTypeCustom) {
        text = [self customMessageContent:message];
    } else {
        text = [NIMMessageUtil messageContent:message];
    }
    return text;
}

+ (NSString *)customMessageContent:(NIMMessage *)message {
    NSString *text = nil;
    NIMCustomObject *object = message.messageObject;
    if ([object.attachment isKindOfClass:[NTESSnapchatAttachment class]])
    {
        text = @"[阅后即焚]".ntes_localized;
    }
    else if ([object.attachment isKindOfClass:[NTESJanKenPonAttachment class]])
    {
        text = @"[猜拳]".ntes_localized;
    }
    else if ([object.attachment isKindOfClass:[NTESChartletAttachment class]])
    {
        text = @"[贴图]".ntes_localized;
    }
    else if ([object.attachment isKindOfClass:[NTESWhiteboardAttachment class]])
    {
        text = @"[白板]".ntes_localized;
    }
    else if ([object.attachment isKindOfClass:[NTESRedPacketAttachment class]])
    {
        text = @"[红包消息]".ntes_localized;
    }
    else if ([object.attachment isKindOfClass:[NTESRedPacketTipAttachment class]])
    {
        NTESRedPacketTipAttachment *attach = (NTESRedPacketTipAttachment *)object.attachment;
        text = attach.formatedMessage;
    }
    else if ([object.attachment isKindOfClass:[NTESMultiRetweetAttachment class]])
    {
        text = @"[聊天记录]".ntes_localized;
    }
    else
    {
        text = @"[未知消息]".ntes_localized;
    }
    return text;
}
@end
