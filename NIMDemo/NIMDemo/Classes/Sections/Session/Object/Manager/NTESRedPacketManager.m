//
//  NTESRedPacketManager.m
//  NIM
//
//  Created by chris on 2017/7/17.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESRedPacketManager.h"
#import "JRMFHeader.h"
#import "NTESSessionUtil.h"
#import "NTESMainTabController.h"
#import "UIView+Toast.h"
#import "NTESRedPacketAttachment.h"
#import "NTESRedPacketTipAttachment.h"
#import "NTESSessionMsgConverter.h"
#import "NTESDemoConfig.h"

@interface NTESRedPacketManager()<NIMLoginManagerDelegate,jrmfManagerDelegate>
{
    NIMSession *_currentSession;
    NSString *_currentRedpacketId;
    NSString *_currentRedpacketFrom;
    
    BOOL _onceToken;
}

@end

@implementation NTESRedPacketManager

+ (instancetype)sharedManager
{
    static NTESRedPacketManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NTESRedPacketManager alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [[NIMSDK sharedSDK].loginManager addDelegate:self];
        extern NSString *NTESNotificationLogout;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLogout:) name:NTESNotificationLogout object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NIMSDK sharedSDK].loginManager removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)start
{
    DDLogInfo(@"RedPacketManager setup");
    DDLogInfo(@"start jrmf packet, current version: %@",[JrmfPacket getCurrentVersion]);
}

- (void)updateUserInfo
{
    NSString *me = [[NIMSDK sharedSDK].loginManager currentAccount];
    NSString *nickName = [NTESSessionUtil showNick:me inSession:nil];
    NSString *headUrl = [[NIMKit sharedKit] infoByUser:me option:nil].avatarUrlString;

    [JrmfPacket updateUserMsgWithUserId:me userName:nickName userHead:headUrl thirdToken:[JRMFSington GetPacketSington].JrmfThirdToken completion:^(NSError *error, NSDictionary *resultDic) {
        DDLogInfo(@"red packet update user info complete, error : %@",error);
    }];
}

- (void)sendRedPacket:(NIMSession *)session
{
    JrmfPacket *jrmf = [[JrmfPacket alloc] init];
    jrmf.delegate = self;
    NSString *me = [[NIMSDK sharedSDK].loginManager currentAccount];
    NSString *nickName = [NTESSessionUtil showNick:me inSession:session];
    NSString *headUrl = [[NIMKit sharedKit] infoByUser:me option:nil].avatarUrlString;
    
    NIMTeam *team = nil;
    if (session.sessionType == NIMSessionTypeTeam)
    {
        if ([[NIMSDK sharedSDK].teamManager isMyTeam:session.sessionId])
        {
            team = [[NIMSDK sharedSDK].teamManager teamById:session.sessionId];
        }
        else
        {
            [self.currentTopViewController.view makeToast:@"不在群中，无法发送红包".ntes_localized duration:2.0 position:CSToastPositionCenter];
        }
    }
    _currentSession = session;
    [jrmf doActionPresentSendRedEnvelopeViewController:self.currentTopViewController
                                            thirdToken:[JRMFSington GetPacketSington].JrmfThirdToken
                                             withGroup:(team != nil)
                                             receiveID:session.sessionId
                                          sendUserName:nickName
                                          sendUserHead:headUrl
                                            sendUserID:me
                                           groupNumber:@(team.memberNumber).description];
}

- (void)openRedPacket:(NSString *)redpacketId
                 from:(NSString *)from
              session:(NIMSession *)session
{
    JrmfPacket *jrmf = [[JrmfPacket alloc] init];
    jrmf.delegate = self;
    NSString *me = [[NIMSDK sharedSDK].loginManager currentAccount];
    NSString *nickName = [NTESSessionUtil showNick:me inSession:session];
    NSString *headUrl = [[NIMKit sharedKit] infoByUser:me option:nil].avatarUrlString;
    BOOL isGroup = session.sessionType == NIMSessionTypeTeam;
    
    [jrmf doActionPresentOpenViewController:self.currentTopViewController thirdToken:[JRMFSington GetPacketSington].JrmfThirdToken withUserName:nickName userHead:headUrl userID:me envelopeID:redpacketId isGroup:isGroup];
    
    _currentSession = session;
    _currentRedpacketId   = redpacketId;
    _currentRedpacketFrom = from;
}

- (void)showRedPacketDetail:(NSString *)redPacketId
{
    JrmfPacket *jrmf = [[JrmfPacket alloc] init];
    jrmf.delegate = self;
    NSString *me = [[NIMSDK sharedSDK].loginManager currentAccount];
    [jrmf doActionPresentPacketDetailInViewWithUserID:me packetID:redPacketId thirdToken:[JRMFSington GetPacketSington].JrmfThirdToken];
}


#pragma mark - jrmfManagerDelegate
- (void)dojrmfActionDidSendEnvelopedWithID:(NSString *)envId Name:(NSString *)envName Message:(NSString *)envMsg Stat:(jrmfSendStatus)jrmfStat
{
    switch (jrmfStat) {
        case kjrmfStatUnknow:
            break;
        case kjrmfStatSucess:
        {
            NTESRedPacketAttachment *attachment = [[NTESRedPacketAttachment alloc] init];
            attachment.title = envName;
            attachment.redPacketId = envId;
            attachment.content = envMsg;
            NIMMessage *message = [NTESSessionMsgConverter msgWithRedPacket:attachment];
            [[NIMSDK sharedSDK].chatManager sendMessage:message toSession:_currentSession error:nil];

        }
        case kjrmfStatCancel:
            //取消成功都重置会话
            _currentSession = nil;
        default:
            break;
    }
}

- (void)dojrmfActionOpenPacketSuccessWithGetDone:(BOOL)isDone
{    
    NTESRedPacketTipAttachment *attachment = [[NTESRedPacketTipAttachment alloc] init];
    attachment.isGetDone = @(isDone).description;
    attachment.openPacketId = [[NIMSDK sharedSDK].loginManager currentAccount];
    attachment.packetId = _currentRedpacketId;
    attachment.sendPacketId = _currentRedpacketFrom;
    
    [[NIMSDK sharedSDK].chatManager sendMessage:[NTESSessionMsgConverter msgWithRedPacketTip:attachment] toSession:_currentSession error:nil];
    
    _currentSession = nil;
    _currentRedpacketId   = nil;
    _currentRedpacketFrom = nil;
}

- (void)dojrmfActionDidSendEnvelopedWithID:(NSString *)envId Name:(NSString *)envName Message:(NSString *)envMsg Stat:(jrmfSendStatus)jrmfStat packType:(JrmfRedPacketType)type {}


#pragma mark - NIMLoginManagerDelegate

- (void)onLogin:(NIMLoginStep)step
{
    switch (step)
    {
        case NIMLoginStepSyncOK:
        {
            if (!_onceToken)
            {
                NIMRedPacketTokenRequest *request = [[NIMRedPacketTokenRequest alloc] init];
                request.type = NIMRedPacketServiceTypeJRMF;
                NSString *envelopeName = @"云信红包".ntes_localized;
                BOOL isOnLine = [NTESDemoConfig sharedConfig].redPacketConfig.useOnlineEnv;
                NSString *aliPaySchemeUrl = [NTESDemoConfig sharedConfig].redPacketConfig.aliPaySchemeUrl;
                NSString *weChatSchemeUrl = [NTESDemoConfig sharedConfig].redPacketConfig.weChatSchemeUrl;
                [[NIMSDK sharedSDK].redPacketManager fetchTokenWithRedPacketRequest:request completion:^(NSError * _Nullable error, NSString * _Nullable token) {
                    if (!error)
                    {
                        [JRMFSington GetPacketSington].JrmfThirdToken = token;
                        
                        [JrmfPacket instanceJrmfPacketWithPartnerId:[JRMFSington GetPacketSington].JrmfPartnerId EnvelopeName:envelopeName aliPaySchemeUrl:aliPaySchemeUrl weChatSchemeUrl:weChatSchemeUrl appMothod:isOnLine];
                        [JrmfWalletSDK instanceJrmfWalletSDKWithPartnerId:[JRMFSington GetPacketSington].JrmfPartnerId AppMethod:isOnLine];
                    }
                    else
                    {
                        DDLogError(@"fetch red packet token error : %@",error);
                    }
                }];
                _onceToken = YES;
            }
        }
            break;
        default:
            break;
    }
}

- (void)onLogout:(id)sender
{
    _onceToken = NO;
}


#pragma mark - open url

- (void)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    if ([url.host isEqualToString:@"safepay"]) {
        //跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            if ([[resultDic objectForKey:@"resultStatus"] isEqualToString:@"9000"]) {
                [JrmfPacket doActionAlipayDone];
            }
        }];
    }
    
}

- (void)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<NSString*, id> *)options
{
    if ([url.host isEqualToString:@"safepay"]) {
        //跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            if ([[resultDic objectForKey:@"resultStatus"] isEqualToString:@"9000"]) {
                [JrmfPacket doActionAlipayDone];
            }
        }];
    }
    
}

- (void)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

}

#pragma mark - Private
- (UIViewController *)currentTopViewController
{
    UINavigationController *nav = [NTESMainTabController instance].selectedViewController;
    UIViewController *vc = [nav isKindOfClass:[UINavigationController class]]? nav.topViewController : nav;
    return vc;
}

@end
