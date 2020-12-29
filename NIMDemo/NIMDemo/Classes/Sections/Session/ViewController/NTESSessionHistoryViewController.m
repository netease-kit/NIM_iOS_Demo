//
//  NTESSessionHistoryViewController.m
//  NIM
//
//  Created by emily on 30/01/2018.
//  Copyright © 2018 Netease. All rights reserved.
//

#define PULLUPCOUNT 20
#define PULLDOWNCOUNT 40

#import "NTESSessionHistoryViewController.h"
#import "NTESFileTransSelectViewController.h"
#import "NTESSessionMsgConverter.h"
#import "NIMNormalTeamCardViewController.h"
#import "NIMAdvancedTeamCardViewController.h"
#import "NIMSuperTeamCardViewController.h"
#import "NTESSessionCardViewController.h"
#import "UIScrollView+NTESDirection.h"

#pragma mark - sessionConfig

@interface NTESSessionHistoryConfig()

@property(nonatomic, strong) NIMMessage *firstMsg;

@property(nonatomic, strong) NTESSessionHistoryMessageDataProvider *dataProvider;

@end

@implementation NTESSessionHistoryConfig

- (instancetype)initWithSession:(NIMSession *)session firstMsg:(NIMMessage *)msg {
    if (self = [super init]) {
        self.session = session;
        _firstMsg = msg;
        _dataProvider = [[NTESSessionHistoryMessageDataProvider alloc] initWithSession:session firstMsg:self.firstMsg];
    }
    return self;
}

- (NSArray *)mediaItems {
    NSMutableArray *items = [super mediaItems].mutableCopy;
    for (NIMMediaItem *item in items) {
        if ([item.title isEqualToString:@"已读回执".ntes_localized]) {
            [items removeObject:item];
            break;
        }
    }
    return items.copy;
}

- (id<NIMKitMessageProvider>)messageDataProvider {
    return self.dataProvider;
}

- (BOOL)disableReceiveNewMessages {
    return YES;
}

- (BOOL)shouldHandleReceipt {
    return NO;
}

- (BOOL)autoFetchWhenOpenSession {
    return YES;
}

@end

#pragma mark - 获取消息源

@interface NTESSessionHistoryMessageDataProvider()

@property(nonatomic, strong) NIMMessage *firstMsg;

@end

@implementation NTESSessionHistoryMessageDataProvider

- (instancetype)initWithSession:(NIMSession *)session firstMsg:(NIMMessage *)msg {
    if (self = [super init]) {
        _session = session;
        _firstMsg = msg;
    }
    return self;
}

- (void)pullDown:(NIMMessage *)firstMessage handler:(NIMKitDataProvideHandler)handler {
    __block NSMutableArray *tmp = @[].mutableCopy;
    dispatch_group_t messageFetchServiceGroup = dispatch_group_create();
    if (self.firstMsg) {
        dispatch_group_enter(messageFetchServiceGroup);
        NIMMessageSearchOption *option1 = [NIMMessageSearchOption new];
        option1.limit = PULLUPCOUNT;
        option1.endTime = self.firstMsg.timestamp;
        option1.allMessageTypes = YES;
        option1.order = NIMMessageSearchOrderDesc;
        [[NIMSDK sharedSDK].conversationManager searchMessages:self.session option:option1 result:^(NSError * _Nullable error, NSArray<NIMMessage *> * _Nullable messages) {
            [tmp addObjectsFromArray:messages];
            [tmp addObject:self.firstMsg];
            dispatch_group_leave(messageFetchServiceGroup);
        }];
        dispatch_group_enter(messageFetchServiceGroup);
        NIMMessageSearchOption *option2 = [NIMMessageSearchOption new];
        option2.limit = PULLDOWNCOUNT;
        option2.startTime = self.firstMsg.timestamp;
        option2.allMessageTypes = YES;
        option2.order = NIMMessageSearchOrderAsc;
        [[NIMSDK sharedSDK].conversationManager searchMessages:self.session option:option2 result:^(NSError * _Nullable error, NSArray<NIMMessage *> * _Nullable messages) {
            [tmp addObjectsFromArray:messages];
            dispatch_group_leave(messageFetchServiceGroup);
        }];
        dispatch_group_notify(messageFetchServiceGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (handler) {
                self.firstMsg = nil;
                handler(nil, tmp);
            }
        });
    }
    else {
        NIMMessageSearchOption *upOption = [NIMMessageSearchOption new];
        if (firstMessage) {
            upOption.endTime = firstMessage.timestamp;
        }
        upOption.limit = PULLUPCOUNT;
        upOption.order = NIMMessageSearchOrderDesc;
        upOption.allMessageTypes = YES;
        [[NIMSDK sharedSDK].conversationManager searchMessages:self.session option:upOption result:^(NSError * _Nullable error, NSArray<NIMMessage *> * _Nullable messages) {
            tmp = messages.mutableCopy;
            if (handler) {
                handler(nil, tmp);
            }
        }];
    }
}

- (BOOL)needTimetag {
    return YES;
}

@end


@interface NTESSessionHistoryViewController () <NIMInputToolBarDelegate, NIMInputActionDelegate>

@property(nonatomic, strong) NTESSessionHistoryConfig *sessionConfig;
@property(nonatomic, strong) NIMMessage *firstMsg;
@property(nonatomic, assign) BOOL shouldResetMsg;

@end

@implementation NTESSessionHistoryViewController

- (instancetype)initWithSession:(NIMSession *)session andSearchMsg:(NIMMessage *)msg {
    if (self = [super initWithSession:session]) {
        _firstMsg = msg;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.shouldResetMsg = YES;
    [self setUpNav];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)setUpNav{
    self.navigationItem.leftBarButtonItem = nil;

    UIButton *enterTeamCard = [UIButton buttonWithType:UIButtonTypeCustom];
    [enterTeamCard addTarget:self action:@selector(enterTeamCard:) forControlEvents:UIControlEventTouchUpInside];
    [enterTeamCard setImage:[UIImage imageNamed:@"icon_session_info_normal"] forState:UIControlStateNormal];
    [enterTeamCard setImage:[UIImage imageNamed:@"icon_session_info_pressed"] forState:UIControlStateHighlighted];
    [enterTeamCard sizeToFit];
    UIBarButtonItem *enterTeamCardItem = [[UIBarButtonItem alloc] initWithCustomView:enterTeamCard];
    
    UIButton *infoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [infoBtn addTarget:self action:@selector(enterPersonInfoCard:) forControlEvents:UIControlEventTouchUpInside];
    [infoBtn setImage:[UIImage imageNamed:@"icon_session_info_normal"] forState:UIControlStateNormal];
    [infoBtn setImage:[UIImage imageNamed:@"icon_session_info_pressed"] forState:UIControlStateHighlighted];
    [infoBtn sizeToFit];
    UIBarButtonItem *enterUInfoItem = [[UIBarButtonItem alloc] initWithCustomView:infoBtn];
    
    if (self.session.sessionType == NIMSessionTypeTeam)
    {
        self.navigationItem.rightBarButtonItems  = @[enterTeamCardItem];
    }
    else if(self.session.sessionType == NIMSessionTypeP2P)
    {
        if ([self.session.sessionId isEqualToString:[[NIMSDK sharedSDK].loginManager currentAccount]])
        {
            self.navigationItem.rightBarButtonItems = nil;
        }
        else
        {
            self.navigationItem.rightBarButtonItems = @[enterUInfoItem];
        }
    }
}

- (void)enterTeamCard:(id)sender{
    NIMTeam *team = nil;
    if (self.session.sessionType == NIMSessionTypeSuperTeam) {
        team = [[NIMSDK sharedSDK].superTeamManager teamById:self.session.sessionId];
    } else {
        team = [[NIMSDK sharedSDK].teamManager teamById:self.session.sessionId];
    }
    if (!team) {
        return;
    }
    UIViewController *vc;
    if (team.type == NIMTeamTypeNormal) {
        vc = [[NIMNormalTeamCardViewController alloc] initWithTeam:team session:self.session option:nil];
    } else if(team.type == NIMTeamTypeAdvanced){
        vc = [[NIMAdvancedTeamCardViewController alloc] initWithTeam:team session:self.session option:nil];
    } else if(team.type == NIMTeamTypeAdvanced){
        vc = [[NIMSuperTeamCardViewController alloc] initWithTeam:team session:self.session option:nil];
    }
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)enterPersonInfoCard:(id)sender{
    NTESSessionCardViewController *vc = [[NTESSessionCardViewController alloc] initWithSession:self.session];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)keyboardWillChange:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    CGRect endFrame   = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    BOOL visible = endFrame.origin.y != [UIApplication sharedApplication].keyWindow.frame.size.height;
    if (visible && self.shouldResetMsg) {
        self.shouldResetMsg = NO;
        [self refetchMessages];
    }
}

#pragma mark - 消息收发接口
- (void)sendMessage:(NIMMessage *)message {
    if (self.shouldResetMsg) {
        self.shouldResetMsg = NO;
        [self.interactor resetMessages:^(NSError *error) {
            [self.interactor sendMessage:message];
        }];
    }
    else {
        [self.interactor sendMessage:message];
    }
}

#pragma mark - Getter

- (id<NIMSessionConfig>)sessionConfig {
    if (!_sessionConfig) {
        _sessionConfig = [[NTESSessionHistoryConfig alloc] initWithSession:self.session firstMsg:self.firstMsg];
    }
    return _sessionConfig;
}

- (void)didPullUpMessageData {
    [self.interactor pullUpMessages:^(NSArray *messages, NSError *error) {
        [self.tableView reloadData];
    }];
}

#pragma mark - NIMInputActionProtocol

- (void)onTapEmoticonBtn:(id)sender {
    if (self.shouldResetMsg) {
        self.shouldResetMsg = NO;
        [self refetchMessages];
    }
}

- (void)onTapMoreBtn:(id)sender {
    if (self.shouldResetMsg) {
        self.shouldResetMsg = NO;
        [self refetchMessages];
    }
}

- (void)onTapVoiceBtn:(id)sender {
    if (self.shouldResetMsg) {
        self.shouldResetMsg = NO;
        [self refetchMessages];
    }
}

- (void)refetchMessages {
    [self.interactor resetMessages:^(NSError *error) {
        [self.tableView reloadData];
    }];
}

#pragma mark - NIMSessionConfiguratorDelegate

- (void)didFetchMessageData
{
    [self.tableView reloadData];
    if (self.shouldResetMsg) {
        [self scrollToFirstMsg];
    }
}

- (void)scrollToFirstMsg {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSInteger row = [self.interactor findMessageIndex:self.firstMsg];
        if (row > 0) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
    });
}

@end
