//
//  NTESNoticationUtil.m
//  NIM
//
//  Created by Genning on 2020/8/27.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NTESNoticationUtil.h"
#import "NIMGlobalMacro.h"

@implementation NTESNoticationUtil

+ (NSString *)revokeNoticationContent:(NIMRevokeMessageNotification *)note {
    NSMutableString *ret = [NSMutableString stringWithFormat:@"[系统通知][%@]".nim_localized,
                            [self revokeTypeContent:note.notificationType]];
    return ret;
}

+ (NSString *)revokeTypeContent:(NIMRevokeMessageNotificationType)type {
    NSString *ret = @"点对点消息撤回".nim_localized;
    switch (type) {
        case NIMRevokeMessageNotificationTypeP2P:
        {
            ret = @"点对点消息撤回".nim_localized;
            break;
        }
        case NIMRevokeMessageNotificationTypeTeam:
        {
            ret = @"群消息撤回".nim_localized;
            break;
        }
        case NIMRevokeMessageNotificationTypeSuperTeam:
        {
            ret = @"超大群消息撤回".nim_localized;
            break;
        }
        case NIMRevokeMessageNotificationTypeP2POneWay:
        {
            ret = @"点对点消息单向撤回".nim_localized;
            break;
        }
        case NIMRevokeMessageNotificationTypeTeamOneWay:
        {
            ret = @"群消息单向撤回".nim_localized;
            break;
        }
        default:
            break;
    }
    return ret;
}

@end
