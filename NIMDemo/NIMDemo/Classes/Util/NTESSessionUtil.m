//
//  NTESSessionUtil.m
//  NIMDemo
//
//  Created by ght on 15-1-27.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NTESSessionUtil.h"
#import "NTESLoginManager.h"
#import "NTESSnapchatAttachment.h"
#import "NTESJanKenPonAttachment.h"
#import "NTESChartletAttachment.h"
#import "UIImage+NTES.h"
#import "NIMKit.h"
#import "NTESSnapchatAttachment.h"
#import "NTESWhiteboardAttachment.h"
#import "NIMKitInfoFetchOption.h"
#import "NTESSubscribeManager.h"
#import "NIMExtensionHelper.h"
#import "NTESSubscribeDefine.h"
#import "NSDictionary+NTESJson.h"
#import "NTESDevice.h"

double OnedayTimeIntervalValue = 24*60*60;  //一天的秒数

static NSString *const NTESRecentSessionAtMark  = @"NTESRecentSessionAtMark";
static NSString *const NTESRecentSessionTopMark = @"NTESRecentSessionTopMark";


@implementation NTESSessionUtil

+ (CGSize)getImageSizeWithImageOriginSize:(CGSize)originSize
                                  minSize:(CGSize)imageMinSize
                                  maxSize:(CGSize)imageMaxSiz
{
    CGSize size;
    NSInteger imageWidth = originSize.width ,imageHeight = originSize.height;
    NSInteger imageMinWidth = imageMinSize.width, imageMinHeight = imageMinSize.height;
    NSInteger imageMaxWidth = imageMaxSiz.width, imageMaxHeight = imageMaxSiz.height;
    if (imageWidth > imageHeight) //宽图
    {
        size.height = imageMinHeight;  //高度取最小高度
        size.width = imageWidth * imageMinHeight / imageHeight;
        if (size.width > imageMaxWidth)
        {
            size.width = imageMaxWidth;
        }
    }
    else if(imageWidth < imageHeight)//高图
    {
        size.width = imageMinWidth;
        size.height = imageHeight *imageMinWidth / imageWidth;
        if (size.height > imageMaxHeight)
        {
            size.height = imageMaxHeight;
        }
    }
    else//方图
    {
        if (imageWidth > imageMaxWidth)
        {
            size.width = imageMaxWidth;
            size.height = imageMaxHeight;
        }
        else if(imageWidth > imageMinWidth)
        {
            size.width = imageWidth;
            size.height = imageHeight;
        }
        else
        {
            size.width = imageMinWidth;
            size.height = imageMinHeight;
        }
    }
    return size;
}

                                                 
+(BOOL)isTheSameDay:(NSTimeInterval)currentTime compareTime:(NSDateComponents*)older
{
    NSCalendarUnit currentComponents = (NSCalendarUnit)(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour | NSCalendarUnitMinute);
    NSDateComponents *current = [[NSCalendar currentCalendar] components:currentComponents fromDate:[NSDate dateWithTimeIntervalSinceNow:currentTime]];
    
    return current.year == older.year && current.month == older.month && current.day == older.day;
}

+(NSString*)weekdayStr:(NSInteger)dayOfWeek
{
    static NSDictionary *daysOfWeekDict = nil;
    daysOfWeekDict = @{@(1):@"星期日".ntes_localized,
                       @(2):@"星期一".ntes_localized,
                       @(3):@"星期二".ntes_localized,
                       @(4):@"星期三".ntes_localized,
                       @(5):@"星期四".ntes_localized,
                       @(6):@"星期五".ntes_localized,
                       @(7):@"星期六".ntes_localized,};
    return [daysOfWeekDict objectForKey:@(dayOfWeek)];
}


+(NSDateComponents*)stringFromTimeInterval:(NSTimeInterval)messageTime components:(NSCalendarUnit)components
{
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:components fromDate:[NSDate dateWithTimeIntervalSince1970:messageTime]];
    return dateComponents;
}


+ (NSString *)showNick:(NSString*)uid inSession:(NIMSession*)session{
    
    NSString *nickname = nil;
    if (session.sessionType == NIMSessionTypeTeam)
    {
        NIMTeamMember *member = [[NIMSDK sharedSDK].teamManager teamMember:uid inTeam:session.sessionId];
        nickname = member.nickname;
    }
    else if (session.sessionType == NIMSessionTypeSuperTeam)
    {
        NIMTeamMember *member = [[NIMSDK sharedSDK].superTeamManager teamMember:uid inTeam:session.sessionId];
        nickname = member.nickname;
    }
    if (!nickname.length) {
        NIMKitInfo *info = [[NIMKit sharedKit] infoByUser:uid option:nil];
        nickname = info.showName;
    }
    return nickname;
}


+(NSString*)showTime:(NSTimeInterval) msglastTime showDetail:(BOOL)showDetail
{
    //今天的时间
    NSDate * nowDate = [NSDate date];
    NSDate * msgDate = [NSDate dateWithTimeIntervalSince1970:msglastTime];
    NSString *result = nil;
    NSCalendarUnit components = (NSCalendarUnit)(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday|NSCalendarUnitHour | NSCalendarUnitMinute);
    NSDateComponents *nowDateComponents = [[NSCalendar currentCalendar] components:components fromDate:nowDate];
    NSDateComponents *msgDateComponents = [[NSCalendar currentCalendar] components:components fromDate:msgDate];

    NSInteger hour = msgDateComponents.hour;
    
    result = [NTESSessionUtil getPeriodOfTime:hour withMinute:msgDateComponents.minute];
    if (hour > 12)
    {
        hour = hour - 12;
    }
    if(nowDateComponents.day == msgDateComponents.day) //同一天,显示时间
    {
        result = [[NSString alloc] initWithFormat:@"%@ %zd:%02d",result,hour,(int)msgDateComponents.minute];
    }
    else if(nowDateComponents.day == (msgDateComponents.day+1))//昨天
    {
        result = showDetail?  [[NSString alloc] initWithFormat:@"%@%@ %zd:%02d",@"昨天".ntes_localized, result,hour,(int)msgDateComponents.minute] : @"昨天".ntes_localized;
    }
    else if(nowDateComponents.day == (msgDateComponents.day+2)) //前天
    {
        result = showDetail? [[NSString alloc] initWithFormat:@"%@%@ %zd:%02d",@"前天".ntes_localized, result,hour,(int)msgDateComponents.minute] : @"前天".ntes_localized;
    }
    else if([nowDate timeIntervalSinceDate:msgDate] < 7 * OnedayTimeIntervalValue)//一周内
    {
        NSString *weekDay = [NTESSessionUtil weekdayStr:msgDateComponents.weekday];
        result = showDetail? [weekDay stringByAppendingFormat:@"%@ %zd:%02d",result,hour,(int)msgDateComponents.minute] : weekDay;
    }
    else//显示日期
    {
        NSString *day = [NSString stringWithFormat:@"%zd-%zd-%zd", msgDateComponents.year, msgDateComponents.month, msgDateComponents.day];
        result = showDetail? [day stringByAppendingFormat:@"%@ %zd:%02d",result,hour,(int)msgDateComponents.minute]:day;
    }
    return result;
}

+ (NSString *)getPeriodOfTime:(NSInteger)time withMinute:(NSInteger)minute
{
    NSInteger totalMin = time *60 + minute;
    NSString *showPeriodOfTime = @"";
    if (totalMin > 0 && totalMin <= 5 * 60)
    {
        showPeriodOfTime = @"凌晨".ntes_localized;
    }
    else if (totalMin > 5 * 60 && totalMin < 12 * 60)
    {
        showPeriodOfTime = @"上午".ntes_localized;
    }
    else if (totalMin >= 12 * 60 && totalMin <= 18 * 60)
    {
        showPeriodOfTime = @"下午".ntes_localized;
    }
    else if ((totalMin > 18 * 60 && totalMin <= (23 * 60 + 59)) || totalMin == 0)
    {
        showPeriodOfTime = @"晚上".ntes_localized;
    }
    return showPeriodOfTime;
}


+ (void)sessionWithInputURL:(NSURL*)inputURL
                  outputURL:(NSURL*)outputURL
               blockHandler:(void (^)(AVAssetExportSession*))handler
{
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:asset
                                                                     presetName:AVAssetExportPresetMediumQuality];
    session.outputURL = outputURL;
    session.outputFileType = AVFileTypeMPEG4;   // 支持安卓某些机器的视频播放
    session.shouldOptimizeForNetworkUse = YES;
    [session exportAsynchronouslyWithCompletionHandler:^(void)
     {
         handler(session);
     }];
}


+ (NSDictionary *)dictByJsonData:(NSData *)data
{
    NSDictionary *dict = nil;
    if ([data isKindOfClass:[NSData class]])
    {
        NSError *error = nil;
        dict = [NSJSONSerialization JSONObjectWithData:data
                                               options:0
                                                 error:&error];
        if (error) {
            DDLogError(@"dictByJsonData failed %@ error %@",data,error);
        }
    }
    return [dict isKindOfClass:[NSDictionary class]] ? dict : nil;
}


+ (NSDictionary *)dictByJsonString:(NSString *)jsonString
{
    if (!jsonString.length) {
        return nil;
    }
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    return [NTESSessionUtil dictByJsonData:data];
}

+ (NSString *)tipOnMessageRevokedLocal:(NSString *)postscript {
    NSString *tip = @"你".ntes_localized;
    NSString *msg = [NSString stringWithFormat:@"%@撤回了一条消息".ntes_localized, tip];
    if (postscript.length != 0) {
        msg = [NSString stringWithFormat:@"%@撤回了一条消息.附言:%@".ntes_localized, tip, postscript];
    }
    return msg;
}

+ (NSString *)tipOnMessageRevoked:(NIMRevokeMessageNotification *)notification
{
    NSString *tip = @"";
    do {
        if (!notification || ![notification isKindOfClass:[NIMRevokeMessageNotification class]]) {
            tip = @"你".ntes_localized;
            break;
        }
        NIMSession *session = notification.session;
        if (session.sessionType == NIMSessionTypeTeam || session.sessionType == NIMSessionTypeSuperTeam) {
            tip = [self tipTitleFromMessageRevokeNotificationTeam:notification];
            break;
        }
        tip = [self tipTitleFromMessageRevokeNotificationP2P:notification];
    } while (false);
    
    NSString *msg = [NSString stringWithFormat:@"%@撤回了一条消息".ntes_localized, tip];
    if (notification.postscript.length != 0) {
        msg = [NSString stringWithFormat:@"%@撤回了一条消息.附言:%@".ntes_localized, tip, notification.postscript];
    }
    return msg;
}

+ (NSString *)tipTitleFromMessageRevokeNotificationP2P:(NIMRevokeMessageNotification *)notification {
    NSString *fromUid = notification.messageFromUserId;
    BOOL fromMe = [fromUid isEqualToString:[[NIMSDK sharedSDK].loginManager currentAccount]];
    return fromMe ? @"你".ntes_localized : @"对方".ntes_localized;
}

+ (NSString *)tipTitleFromMessageRevokeNotificationTeam:(NIMRevokeMessageNotification *)notification {
    NSString *tipTitle = @"";
    
    do {
        NSString *fromUid = notification.messageFromUserId;
        NSString *operatorUid = notification.fromUserId;
        BOOL revokeBySender = !operatorUid || [operatorUid isEqualToString:fromUid];
        BOOL fromMe = [fromUid isEqualToString:[[NIMSDK sharedSDK].loginManager currentAccount]];
        
        // 自己撤回自己的
        if (revokeBySender && fromMe) {
            tipTitle = @"你".ntes_localized;
            break;
        }
        
        NIMSession *session = notification.session;
        NIMKitInfoFetchOption *option = [[NIMKitInfoFetchOption alloc] init];
        option.session = session;
        NIMKitInfo *info = [[NIMKit sharedKit] infoByUser:(revokeBySender ? fromUid : operatorUid) option:option];
        
        // 别人撤回自己的
        if (revokeBySender) {
            tipTitle = info.showName;
            break;
        }
        
        NIMTeamMember *member = nil;
        if (notification.session.sessionType == NIMSessionTypeTeam) {
            member = [[NIMSDK sharedSDK].teamManager teamMember:operatorUid inTeam:session.sessionId];
        } else if (notification.session.sessionType == NIMSessionTypeSuperTeam) {
            member = [[NIMSDK sharedSDK].superTeamManager teamMember:operatorUid inTeam:session.sessionId];
        }
        // 被群主/管理员撤回的
        if (member.type == NIMTeamMemberTypeOwner) {
            tipTitle = [@"群主".ntes_localized stringByAppendingString:info.showName];
        }
        else if (member.type == NIMTeamMemberTypeManager) {
            tipTitle = [@"管理员".ntes_localized stringByAppendingString:info.showName];
        }
    } while (false);
    
    return tipTitle;
}


+ (BOOL)canMessageBeForwarded:(NIMMessage *)message
{
    if (!message.isReceivedMsg && message.deliveryState == NIMMessageDeliveryStateFailed) {
        return NO;
    }
    id<NIMMessageObject> messageObject = message.messageObject;
    if ([messageObject isKindOfClass:[NIMCustomObject class]])
    {
        id<NTESCustomAttachmentInfo> attach = (id<NTESCustomAttachmentInfo>)[(NIMCustomObject *)message.messageObject attachment];
        return [attach canBeForwarded];
    }
    if ([messageObject isKindOfClass:[NIMNotificationObject class]]) {
        return NO;
    }
    if ([messageObject isKindOfClass:[NIMTipObject class]]) {
        return NO;
    }
    return YES;
}

+ (BOOL)canMessageBeRevoked:(NIMMessage *)message
{
    BOOL canRevokeMessageByRole  = [self canRevokeMessageByRole:message];
    BOOL isDeliverFailed = !message.isReceivedMsg && message.deliveryState == NIMMessageDeliveryStateFailed;
    if (!canRevokeMessageByRole || isDeliverFailed) {
        return NO;
    }
    id<NIMMessageObject> messageObject = message.messageObject;
    if ([messageObject isKindOfClass:[NIMTipObject class]]
        || [messageObject isKindOfClass:[NIMNotificationObject class]]) {
        return NO;
    }
    if ([messageObject isKindOfClass:[NIMCustomObject class]])
    {
        id<NTESCustomAttachmentInfo> attach = (id<NTESCustomAttachmentInfo>)[(NIMCustomObject *)message.messageObject attachment];
        return [attach canBeRevoked];
    }
    return YES;
}

+ (BOOL)canMessageBeCanceled:(NIMMessage *)message
{
    return [self canMessageBeRevoked:message] &&
    message.deliveryState == NIMMessageDeliveryStateDelivering;
}


+ (BOOL)canRevokeMessageByRole:(NIMMessage *)message
{
    BOOL isFromMe  = [message.from isEqualToString:[[NIMSDK sharedSDK].loginManager currentAccount]];
    BOOL isToMe        = [message.session.sessionId isEqualToString:[[NIMSDK sharedSDK].loginManager currentAccount]];
    BOOL isTeamManager = NO;
    if (message.session.sessionType == NIMSessionTypeTeam)
    {
        NIMTeamMember *member = [[NIMSDK sharedSDK].teamManager teamMember:[NIMSDK sharedSDK].loginManager.currentAccount inTeam:message.session.sessionId];
        isTeamManager = member.type == NIMTeamMemberTypeOwner || member.type == NIMTeamMemberTypeManager;
    } else if (message.session.sessionType == NIMSessionTypeSuperTeam) {
        NIMTeamMember *member = [[NIMSDK sharedSDK].superTeamManager teamMember:[[NIMSDK sharedSDK].loginManager currentAccount]
                                                                         inTeam:message.session.sessionId];
        isTeamManager = (member.type == NIMTeamMemberTypeOwner || member.type == NIMTeamMemberTypeManager);
    }

    //我发出去的消息并且不是发给我的电脑的消息，可以撤回
    //群消息里如果我是管理员可以撤回以上所有消息
    return (isFromMe && !isToMe) || isTeamManager;
}


+ (void)addRecentSessionMark:(NIMSession *)session type:(NTESRecentSessionMarkType)type
{
    NIMRecentSession *recent = [[NIMSDK sharedSDK].conversationManager recentSessionBySession:session];
    if (recent)
    {
        NSDictionary *localExt = recent.localExt?:@{};
        NSMutableDictionary *dict = [localExt mutableCopy];
        NSString *key = [NTESSessionUtil keyForMarkType:type];
        [dict setObject:@(YES) forKey:key];
        [[NIMSDK sharedSDK].conversationManager updateRecentLocalExt:dict recentSession:recent];
    }


}

+ (void)removeRecentSessionMark:(NIMSession *)session type:(NTESRecentSessionMarkType)type
{
    NIMRecentSession *recent = [[NIMSDK sharedSDK].conversationManager recentSessionBySession:session];
    if (recent) {
        NSMutableDictionary *localExt = [recent.localExt mutableCopy];
        NSString *key = [NTESSessionUtil keyForMarkType:type];
        [localExt removeObjectForKey:key];
        [[NIMSDK sharedSDK].conversationManager updateRecentLocalExt:localExt recentSession:recent];
    }
}

+ (BOOL)recentSessionIsMark:(NIMRecentSession *)recent type:(NTESRecentSessionMarkType)type
{
    NSDictionary *localExt = recent.localExt;
    NSString *key = [NTESSessionUtil keyForMarkType:type];
    if ([localExt[key] isKindOfClass:[NSNumber class]] || [localExt[key] isKindOfClass:[NSString class]]) {
        return [localExt[key] boolValue] == YES;
    }
    return NO;
}

+ (NSString *)keyForMarkType:(NTESRecentSessionMarkType)type
{
    static NSDictionary *keys;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        keys = @{
                 @(NTESRecentSessionMarkTypeAt)  : NTESRecentSessionAtMark,
                 @(NTESRecentSessionMarkTypeTop) : NTESRecentSessionTopMark
                 };
    });
    return [keys objectForKey:@(type)];
}

+ (NSString *)onlineState:(NSString *)userId detail:(BOOL)detail
{
    NSString *state = @"";
    if (![NTESSubscribeManager sharedManager] || [[NIMSDK sharedSDK].loginManager.currentAccount isEqualToString:userId])
    {
        //没有开启订阅服务或是自己  不显示在线状态
        return state;
    }
    
    NSDictionary *dict = [[NTESSubscribeManager sharedManager] eventsForType:NIMSubscribeSystemEventTypeOnline];
    NIMSubscribeEvent *event = [dict objectForKey:userId];
    NIMSubscribeOnlineInfo *info = event.subscribeInfo;
    if ([info isKindOfClass:[NIMSubscribeOnlineInfo class]] && info.senderClientTypes.count)
    {
        NIMLoginClientType client = [self resolveShowClientType:info.senderClientTypes];
        
        switch (event.value) {
            case NTESCustomStateValueOnlineExt:
            case NIMSubscribeEventOnlineValueLogin:
            case NIMSubscribeEventOnlineValueLogout:
            case NIMSubscribeEventOnlineValueDisconnected:
            {
                NSString *ext = [event ext:client];
                state = [self resolveOnlineState:ext client:client detail:detail];
            }
                break;
                
            default:
            {
                NSString *clientName = [self resolveOnlineClientName:client];
                state = [NSString stringWithFormat:@"%@ %@", clientName, @"在线".ntes_localized];
                break;
            }
        }
    }
    else
    {
        state = @"离线".ntes_localized;
    }
    return state;
}


+ (NIMLoginClientType)resolveShowClientType:(NSArray *)senderClientTypes
{
    NSArray *clients = @[@(NIMLoginClientTypePC),@(NIMLoginClientTypemacOS),@(NIMLoginClientTypeiOS),@(NIMLoginClientTypeAOS),@(NIMLoginClientTypeWeb),@(NIMLoginClientTypeWP)]; //显示优先级
    for (NSNumber *type in clients) {
        NIMLoginClientType client = type.integerValue;
        if ([senderClientTypes containsObject:@(client)]) {
            return client;
        }
    }
    return NIMLoginClientTypeUnknown;
}

+ (NSString *)resolveOnlineClientName:(NIMLoginClientType )client
{
    NSDictionary *formats  = @{
                              @(NIMLoginClientTypePC) : @"PC",
                              @(NIMLoginClientTypemacOS) : @"Mac",
                              @(NIMLoginClientTypeiOS): @"iOS",
                              @(NIMLoginClientTypeAOS): @"Android",
                              @(NIMLoginClientTypeWeb): @"Web",
                              @(NIMLoginClientTypeWP) : @"WP"
                             };

    NSString *format = [formats objectForKey:@(client)];
    return format? format : @"";
}

+ (NSString *)resolveOnlineState:(NSString *)ext client:(NIMLoginClientType)client detail:(BOOL)detail
{
    NSString *clientName = [self resolveOnlineClientName:client];
    NSString *state = [NSString stringWithFormat:@"%@ %@",clientName,@"在线".ntes_localized];
    NSDictionary *dict = [ext nimkit_jsonDict];
    if (dict) {
        
        NSString *netState =  [[NTESDevice currentDevice] networkStatus:[dict jsonInteger:NTESSubscribeNetState]];
        NTESOnlineState onlineState =  [dict jsonInteger:NTESSubscribeOnlineState];
        switch (onlineState) {
            case NTESOnlineStateNormal:
            {
                if (client == NIMLoginClientTypePC ||
                    client == NIMLoginClientTypeWeb ||
                    client == NIMLoginClientTypemacOS)
                {
                    //桌面端不显示网络状态，只显示端
                    return [NSString stringWithFormat:@"%@ %@",clientName,@"在线".ntes_localized];
                }
                else
                {
                    //移动端在会话列表显示网络状态，在会话内（detail）优先显示端+网络状态
                    if (detail)
                    {
                        return [NSString stringWithFormat:@"%@ - %@ %@",clientName,netState, @"在线".ntes_localized];
                    }
                    else
                    {
                        return [NSString stringWithFormat:@"%@ %@",netState,@"在线".ntes_localized];
                    }
                }
            }
            case NTESOnlineStateBusy:
                return @"忙碌".ntes_localized;
            case NTESOnlineStateLeave:
                return @"离开".ntes_localized;
            default:
                break;
        }
    }
    return state;
}

+ (NSString *)formatAutoLoginMessage:(NSError *)error
{
    NSString *message = [NSString stringWithFormat:@"%@ %@",@"自动登录失败".ntes_localized, error];
    NSString *domain = error.domain;
    NSInteger code = error.code;
    if ([domain isEqualToString:NIMLocalErrorDomain])
    {
        if (code == NIMLocalErrorCodeAutoLoginRetryLimit)
        {
            message = @"自动登录错误次数超限，请检查网络后重试".ntes_localized;
        }
    }
    else if([domain isEqualToString:NIMRemoteErrorDomain])
    {
        if (code == NIMRemoteErrorCodeInvalidPass)
        {
            message = @"密码错误".ntes_localized;
        }
        else if(code == NIMRemoteErrorCodeExist)
        {
            message = @"当前已经其他设备登录，请使用手动模式登录".ntes_localized;
        }
    }
    return message;
}

@end
