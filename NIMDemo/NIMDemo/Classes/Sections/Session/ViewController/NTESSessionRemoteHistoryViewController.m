//
//  NTESSessionHistoryViewController.m
//  NIM
//
//  Created by chris on 15/4/22.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NTESSessionRemoteHistoryViewController.h"
#import "UIView+Toast.h"
#import "SVProgressHUD.h"
#import "NIMCellLayoutConfig.h"
#import "NTESBundleSetting.h"
#import "NTESCellLayoutConfig.h"
#import "NTESSessionUtil.h"

#pragma mark - Remote View Controller
@interface NTESSessionRemoteHistoryViewController ()<NTESRemoteSessionDelegate>


@end

@implementation NTESSessionRemoteHistoryViewController

- (instancetype) initWithSession:(NIMSession *)session{
    NTESRemoteSessionConfig *config = [[NTESRemoteSessionConfig alloc] initWithSession:session];

    return [self initWithSession:session config:config];
}

- (instancetype)initWithSession:(NIMSession *)session config:(NTESRemoteSessionConfig *)config
{
    self = [super initWithSession:session];
    if (self) {
        self.config = config;
        self.config.delegate = self;
        self.disableCommandTyping = YES;
        self.disableOnlineState = YES;
    }
    return self;
}

- (void)dealloc{
    [SVProgressHUD dismiss];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = UIColorFromRGB(0xe4e7ec);
    self.navigationItem.rightBarButtonItems = @[];
    self.navigationItem.leftBarButtonItems = @[];
    [SVProgressHUD show];
}


- (NSString *)sessionTitle{
    return @"云消息记录".ntes_localized;
}

- (NSString *)sessionSubTitle
{
    return @"";
}

- (BOOL)disableAudioPlayedStatusIcon:(NIMMessage *)message
{
    return YES;
}

- (void)sendMessage:(NIMMessage *)message{};

- (id<NIMSessionConfig>)sessionConfig{
    return self.config;
}

- (NSArray *)menusItems:(NIMMessage *)message{
    return nil;
}

- (void)doRevokeMessage:(NIMMessage *)message postscript:(NSString *)postscript{
    __weak typeof(self) weakSelf = self;
    NSString *collapseId = message.apnsPayload[@"apns-collapse-id"];
    NSDictionary *payload = @{
        @"apns-collapse-id": collapseId ? : @"",
    };
    NIMRevokeMessageOption *option = [[NIMRevokeMessageOption alloc] init];
    option.apnsContent = @"撤回一条消息";
    option.apnsPayload = payload;
    option.shouldBeCounted = ![[NTESBundleSetting sharedConfig] isIgnoreRevokeMessageCount];
    option.postscript = postscript;
    [[NIMSDK sharedSDK].chatManager revokeMessage:message option:option completion:^(NSError * _Nullable error) {
        if (error) {
            if (error.code == NIMRemoteErrorCodeDomainExpireOld) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"发送时间超过2分钟的消息，不能被撤回".ntes_localized delegate:nil cancelButtonTitle:@"确定".ntes_localized otherButtonTitles:nil, nil];
                [alert show];
            } else {
                DDLogError(@"revoke message eror code %zd",error.code);
                [weakSelf.view makeToast:@"消息撤回失败，请重试".ntes_localized duration:2.0 position:CSToastPositionCenter];
            }
        } else {
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            userInfo[@"msg"] = message;
            userInfo[@"postscript"] = postscript;
            [[NSNotificationCenter defaultCenter] postNotificationName:kNTESDemoRevokeMessageFromMeNotication
                                                                object:nil
                                                              userInfo:userInfo];
        }
    }];
}

- (void)onRevokeMessageFromMe:(NSNotification *)note {
    NIMMessage *message = note.userInfo[@"msg"];
    if (message) {
        [self uiDeleteMessage:message];
    }
}

#pragma mark - NIMMessageCellDelegate

//- (BOOL)onLongPressCell:(NIMMessage *)message
//                 inView:(UIView *)view
//{
//    return YES;
//}

- (void)onClickEmoticon:(NIMMessage *)message
                comment:(NIMQuickComment *)comment
               selected:(BOOL)isSelected
{
    
}


- (void)uiAddMessages:(NSArray *)messages{}

#pragma mark - NTESRemoteSessionDelegate
- (void)fetchRemoteDataError:(NSError *)error{
    if (error) {
        [self.view makeToast:@"获取消息失败".ntes_localized duration:2.0 position:CSToastPositionCenter];
    }
}

#pragma mark - NIMSessionConfiguratorDelegate
- (void)didFetchMessageData{
    [super didFetchMessageData];
    [SVProgressHUD dismiss];
}

@end



#pragma mark - Remote Session Config
@interface NTESRemoteSessionConfig()

@property (nonatomic,strong) NIMRemoteMessageDataProvider *provider;



@end

@implementation NTESRemoteSessionConfig

- (instancetype)initWithSession:(NIMSession *)session{
    self = [super init];
    if (self) {
        NSInteger limit = 20;
        self.provider = [[NIMRemoteMessageDataProvider alloc] initWithSession:session limit:limit];
    }
    return self;
}

- (void)setDelegate:(id<NTESRemoteSessionDelegate>)delegate{
    self.provider.delegate = delegate;
}

- (id<NIMKitMessageProvider>)messageDataProvider{
    return self.provider;
}

- (BOOL)disableProximityMonitor{
    return [[NTESBundleSetting sharedConfig] disableProximityMonitor];
}

- (BOOL)autoFetchAttachment {
    return [[NTESBundleSetting sharedConfig] autoFetchAttachment];
}

- (BOOL)disableInputView{
    return YES;
}

//云消息不支持音频轮播
- (BOOL)disableAutoPlayAudio
{
    return YES;
}

//云消息不显示已读
- (BOOL)shouldHandleReceipt{
    return NO;
}

- (BOOL)disableReceiveNewMessages
{
    return YES;
}

- (NSArray<NIMMediaItem *> *)mediaItems
{
    return nil;
}

- (NSArray<NIMMediaItem *> *)menuItemsWithMessage:(NIMMessage *)message
{
    NSMutableArray *items = [NSMutableArray array];
    
    NIMMediaItem *revoke = [NIMMediaItem item:@"onTapMenuItemRevoke:"
                                  normalImage:[UIImage imageNamed:@"menu_revoke"]
                                selectedImage:nil
                                        title:@"撤回".ntes_localized];
    if ([NTESSessionUtil canMessageBeRevoked:message]) {
        [items addObject:revoke];
    }
    return items;
}


- (NSArray*)emotionItems
{
    return nil;
}

@end




#pragma mark - Provider
@interface NIMRemoteMessageDataProvider(){
    NSMutableArray *_msgArray; //消息数组
    NSTimeInterval _lastTime;
}
@end


@implementation NIMRemoteMessageDataProvider

- (instancetype)initWithSession:(NIMSession *)session limit:(NSInteger)limit{
    self = [super init];
    if (self) {
        _limit = limit;
        _session = session;
    }
    return self;
}

- (void)pullDown:(NIMMessage *)firstMessage handler:(NIMKitDataProvideHandler)handler{
    [self remoteFetchMessage:firstMessage handler:handler];
}


- (void)remoteFetchMessage:(NIMMessage *)message
                   handler:(NIMKitDataProvideHandler)handler
{
    NIMHistoryMessageSearchOption *searchOpt = [[NIMHistoryMessageSearchOption alloc] init];
    searchOpt.startTime  = 0;
    searchOpt.endTime    = message.timestamp;
    searchOpt.currentMessage = message;
    searchOpt.limit      = self.limit;
    searchOpt.sync       =  [NTESBundleSetting sharedConfig].enableSyncWhenFetchRemoteMessages;
    searchOpt.createRecentSessionIfNotExists = NTESBundleSetting.sharedConfig.enableCreateRecentSessionsWhenSyncRemoteMessages;
    [[NIMSDK sharedSDK].conversationManager fetchMessageHistory:self.session option:searchOpt result:^(NSError *error, NSArray *messages) {
        if (handler) {
            handler(error,messages.reverseObjectEnumerator.allObjects);
            if ([self.delegate respondsToSelector:@selector(fetchRemoteDataError:)]) {
                [self.delegate fetchRemoteDataError:error];
            }
        };
    }];
}

@end
