//
//  NTESCustomSysNotiSender.m
//  NIM
//
//  Created by chris on 15/5/26.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NTESCustomSysNotificationSender.h"
#import "NIMKitInfoFetchOption.h"
#import "NTESBundleSetting.h"

@interface NTESCustomSysNotificationSender ()
@property (nonatomic,strong)    NSDate *lastTime;
@end

@implementation NTESCustomSysNotificationSender

- (void)sendCustomContent:(NSString *)content toSession:(NIMSession *)session{
    if (!content) {
        return;
    }
    NSDictionary *dict = @{
                           NTESNotifyID : @(NTESCustom),
                           NTESCustomContent : content,
                           };
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict
                                                   options:0
                                                     error:nil];
    NSString *json = [[NSString alloc] initWithData:data
                                              encoding:NSUTF8StringEncoding];
    
    NIMCustomSystemNotification *notification = [[NIMCustomSystemNotification alloc] initWithContent:json];
    notification.apnsContent = content;
    notification.sendToOnlineUsersOnly = NO;
    notification.env = [[NTESBundleSetting sharedConfig] messageEnv];
    NIMCustomSystemNotificationSetting *setting = [[NIMCustomSystemNotificationSetting alloc] init];
    setting.apnsEnabled = YES;
    notification.setting = setting;
    [[[NIMSDK sharedSDK] systemNotificationManager] sendCustomNotification:notification
                                                                 toSession:session
                                                                completion:nil];
}


- (void)sendTypingState:(NIMSession *)session
{
    NSString *currentAccount = [[[NIMSDK sharedSDK] loginManager] currentAccount];
    if (session.sessionType != NIMSessionTypeP2P ||
        [session.sessionId isEqualToString:currentAccount])
    {
        return;
    }
    
    NSDate *now = [NSDate date];
    if (_lastTime == nil ||
        [now timeIntervalSinceDate:_lastTime] > 3)
    {
        _lastTime = now;
        
        NSDictionary *dict = @{NTESNotifyID : @(NTESCommandTyping)};
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:0
                                                         error:nil];
        NSString *content = [[NSString alloc] initWithData:data
                                                  encoding:NSUTF8StringEncoding];
        
        NIMCustomSystemNotification *notification = [[NIMCustomSystemNotification alloc] initWithContent:content];
        notification.sendToOnlineUsersOnly = YES;
        notification.env = [[NTESBundleSetting sharedConfig] messageEnv];
        NIMCustomSystemNotificationSetting *setting = [[NIMCustomSystemNotificationSetting alloc] init];
        setting.apnsEnabled  = NO;
        notification.setting = setting;
        [[[NIMSDK sharedSDK] systemNotificationManager] sendCustomNotification:notification
                                                                     toSession:session
                                                                    completion:nil];
    }

}


- (void)sendCallNotification:(NIMTeam *)team
                    roomName:(NSString *)roomName
                     members:(NSArray *)members
{
    if (!team || !team.teamId || !members) {
        return;
    }
    
    NSString *teamId = team.teamId;
    NIMKitTeamType teamType = NIMKitTeamTypeNomal;
    if (team.type == NIMTeamTypeSuper) {
        teamType = NIMKitTeamTypeSuper;
    }
    NSDictionary *dict = @{
                           NTESNotifyID : @(NTESTeamMeetingCall),
                           NTESTeamMeetingMembers : members,
                           NTESTeamMeetingTeamId  : teamId,
                           NTESTeamMeetingTeamName  : team.teamName? team.teamName : @"群组".ntes_localized,
                           NTESTeamMeetingName    : roomName,
                           NTESTeamMeetingType    : @(teamType)
                          };
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict
                                                   options:0
                                                     error:nil];
    NSString *content = [[NSString alloc] initWithData:data
                                           encoding:NSUTF8StringEncoding];
    NIMCustomSystemNotification *notification = [[NIMCustomSystemNotification alloc] initWithContent:content];
    notification.sendToOnlineUsersOnly = NO;
    notification.env = [[NTESBundleSetting sharedConfig] messageEnv];
    NIMKitInfoFetchOption *option = [[NIMKitInfoFetchOption alloc] init];
    option.session = [NIMSession session:teamId type:NIMSessionTypeTeam];
    NIMKitInfo *me = [[NIMKit sharedKit] infoByUser:[NIMSDK sharedSDK].loginManager.currentAccount option:option];
    
    notification.apnsContent = [NSString stringWithFormat:@"%@%@",me.showName,@"正在呼叫您".ntes_localized];
    NIMCustomSystemNotificationSetting *setting = [[NIMCustomSystemNotificationSetting alloc] init];
    setting.apnsEnabled  = YES;
    notification.setting = setting;
    

    for (NSString *userId in members) {
        if ([userId isEqualToString:[NIMSDK sharedSDK].loginManager.currentAccount])
        {
            continue;
        }
        NIMSession *session = [NIMSession session:userId type:NIMSessionTypeP2P];
        [[NIMSDK sharedSDK].systemNotificationManager sendCustomNotification:notification toSession:session completion:nil];
    }

}




@end
