//
//  NTESSessionListViewController.m
//  NIMDemo
//
//  Created by chris on 15/2/2.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NTESSessionListViewController.h"
#import "NTESSessionViewController.h"
#import "NTESSessionPeekViewController.h"
#import "UIView+NTES.h"
#import "NTESBundleSetting.h"
#import "NTESListHeader.h"
#import "NTESClientsTableViewController.h"
#import "NTESSessionUtil.h"
#import "NTESPersonalCardViewController.h"
#import "NTESMessageUtil.h"
#import "NTESSessionServiceListVC.h"
#import "NTESSessionSearchViewController.h"
#import "NSString+NTES.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <Toast/UIView+Toast.h>

#define SessionListTitle @"云信 Demo".ntes_localized

@interface NTESSessionListViewController ()<NIMLoginManagerDelegate,NTESListHeaderDelegate,NIMEventSubscribeManagerDelegate,UIViewControllerPreviewingDelegate,NIMChatExtendManagerDelegate, NIMConversationManagerDelegate>

@property (nonatomic,strong) NTESListHeader *header;

@property (nonatomic,assign) BOOL supportsForceTouch;

@property (nonatomic,strong) NSMutableDictionary *previews;

@property (nonatomic,strong) NSMutableDictionary<NIMSession *,NIMStickTopSessionInfo *> *stickTopInfos;


@end

@implementation NTESSessionListViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _previews = [[NSMutableDictionary alloc] init];
        self.stickTopInfos = NSMutableDictionary.dictionary;
        self.autoRemoveRemoteSession = [[NTESBundleSetting sharedConfig] autoRemoveRemoteSession];
    }
    return self;
}

- (void)dealloc{
    [[NIMSDK sharedSDK].loginManager removeDelegate:self];
    [[NIMSDK sharedSDK].chatExtendManager removeDelegate:self];
    [[NIMSDK sharedSDK].conversationManager removeDelegate:self];
}


- (void)viewDidLoad{
    [super viewDidLoad];
    self.supportsForceTouch = [self.traitCollection respondsToSelector:@selector(forceTouchCapability)] && self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable;
    
    [[NIMSDK sharedSDK].loginManager addDelegate:self];
    [[NIMSDK sharedSDK].subscribeManager addDelegate:self];
    [[NIMSDK sharedSDK].chatExtendManager addDelegate:self];
    [[NIMSDK sharedSDK].conversationManager addDelegate:self];

    self.header = [[NTESListHeader alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 0)];
    self.header.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.header.delegate = self;
    [self.view addSubview:self.header];

    self.emptyTipLabel = [[UILabel alloc] init];
    self.emptyTipLabel.text = @"还没有会话，在通讯录中找个人聊聊吧".ntes_localized;
    [self.emptyTipLabel sizeToFit];
    self.emptyTipLabel.hidden = self.recentSessions.count;
    self.emptyTipLabel.numberOfLines = 0;
    [self.view addSubview:self.emptyTipLabel];
    
    NSString *userID = [[[NIMSDK sharedSDK] loginManager] currentAccount];
    self.navigationItem.titleView  = [self titleView:userID];
    self.definesPresentationContext = YES;
    [self setUpNavItem];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadStickTopSessions];
}

- (void)setUpNavItem{
    UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreBtn addTarget:self action:@selector(more:) forControlEvents:UIControlEventTouchUpInside];
    [moreBtn setImage:[UIImage imageNamed:@"icon_sessionlist_more_normal"] forState:UIControlStateNormal];
    [moreBtn setImage:[UIImage imageNamed:@"icon_sessionlist_more_pressed"] forState:UIControlStateHighlighted];
    [moreBtn sizeToFit];
    moreBtn.size = CGSizeMake(moreBtn.width + 4.0, 40.0);
    UIBarButtonItem *moreItem = [[UIBarButtonItem alloc] initWithCustomView:moreBtn];
    
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [searchBtn addTarget:self action:@selector(searchAction:) forControlEvents:UIControlEventTouchUpInside];
    [searchBtn setImage:[UIImage imageNamed:@"btn_search"] forState:UIControlStateNormal];
    [searchBtn sizeToFit];
    searchBtn.size = CGSizeMake(searchBtn.width + 4.0, 40.0);
    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithCustomView:searchBtn];
    self.navigationItem.rightBarButtonItems = @[moreItem, searchItem];
}

- (void)refresh{
    [super refresh];
    self.emptyTipLabel.hidden = self.recentSessions.count;
}

- (NSMutableArray *)setupAlertActions {
    UIAlertAction *markAllMessagesReadAction = [UIAlertAction actionWithTitle:@"标记所有消息为已读".ntes_localized
                                                                        style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * _Nonnull action) {
          [[NIMSDK sharedSDK].conversationManager markAllMessagesRead];
    }];
    
    UIAlertAction *cleanAllMessagesAction = [UIAlertAction actionWithTitle:@"清理所有消息".ntes_localized
                                                                     style:UIAlertActionStyleDefault
                                                                   handler:^(UIAlertAction * _Nonnull action) {
           BOOL removeRecentSessions = [NTESBundleSetting sharedConfig].removeSessionWhenDeleteMessages;
           BOOL removeTables = [NTESBundleSetting sharedConfig].dropTableWhenDeleteMessages;
           
           NIMDeleteMessagesOption *option = [[NIMDeleteMessagesOption alloc] init];
           option.removeSession = removeRecentSessions;
           option.removeTable = removeTables;
           
           [[NIMSDK sharedSDK].conversationManager deleteAllMessages:option];
    }];
    

    UIAlertAction *allServerSessions = [UIAlertAction actionWithTitle:@"查看云端会话".ntes_localized
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * _Nonnull action) {
        NTESSessionServiceListVC * vc = [[NTESSessionServiceListVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消".ntes_localized
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    return @[markAllMessagesReadAction, cleanAllMessagesAction, allServerSessions, cancel].mutableCopy;
}

- (void)more:(id)sender
{
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil
                                                                message:nil
                                                         preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSArray *actions = [self setupAlertActions];
    for (UIAlertAction *action in actions) {
        [vc addAction:action];
    }
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)searchAction:(id)sender {
    NTESSessionSearchViewController *searchVC = [[NTESSessionSearchViewController alloc] init];
    searchVC.recentSessions = self.recentSessions;
    [self.navigationController pushViewController:searchVC animated:YES];
}

- (void)onSelectedRecent:(NIMRecentSession *)recent atIndexPath:(NSIndexPath *)indexPath{
    NTESSessionViewController *vc = [[NTESSessionViewController alloc] initWithSession:recent.session];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onSelectedAvatar:(NIMRecentSession *)recent
             atIndexPath:(NSIndexPath *)indexPath{
    if (recent.session.sessionType == NIMSessionTypeP2P) {
        UIViewController *vc;
        vc = [[NTESPersonalCardViewController alloc] initWithUserId:recent.session.sessionId];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)onDeleteRecentAtIndexPath:(NIMRecentSession *)recent atIndexPath:(NSIndexPath *)indexPath
{
    id<NIMConversationManager> manager = [[NIMSDK sharedSDK] conversationManager];
    [manager deleteRecentSession:recent];
}

- (void)onTopRecentAtIndexPath:(NIMRecentSession *)recent
                   atIndexPath:(NSIndexPath *)indexPath
                         isTop:(BOOL)isTop
{
    if (isTop)
    {
        __weak typeof(self) wself = self;
        [NIMSDK.sharedSDK.chatExtendManager removeStickTopSession:self.stickTopInfos[recent.session] completion:^(NSError * _Nullable error, NIMStickTopSessionInfo * _Nullable removedInfo) {
            __weak typeof(self) sself = wself;
            if (!sself) return;
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                return;
            }
            self.stickTopInfos[recent.session] = nil;
            [self refresh];
        }];
    } else {
        __weak typeof(self) wself = self;
        NIMAddStickTopSessionParams *params = [[NIMAddStickTopSessionParams alloc] initWithSession:recent.session];
        [NIMSDK.sharedSDK.chatExtendManager addStickTopSession:params completion:^(NSError * _Nullable error, NIMStickTopSessionInfo * _Nullable newInfo) {
            __weak typeof(self) sself = wself;
            if (!sself) return;
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                return;
            }
            self.stickTopInfos[newInfo.session] = newInfo;
            [self refresh];
        }];
    }
}


- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self refreshSubview];
}


- (NSString *)nameForRecentSession:(NIMRecentSession *)recent{
    if ([recent.session.sessionId isEqualToString:[[NIMSDK sharedSDK].loginManager currentAccount]]) {
        return @"我的电脑".ntes_localized;
    }
    return [super nameForRecentSession:recent];
}

- (NSMutableArray *)customSortRecents:(NSMutableArray *)recentSessions
{
    [NIMSDK.sharedSDK.chatExtendManager sortRecentSessions:recentSessions withStickTopInfos:self.stickTopInfos];
    return recentSessions;
}

#pragma mark - SessionListHeaderDelegate

- (void)didSelectRowType:(NTESListHeaderType)type{
    //多人登录
    switch (type) {
        case ListHeaderTypeLoginClients:{
            NTESClientsTableViewController *vc = [[NTESClientsTableViewController alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        default:
            break;
    }
}


#pragma mark - NIMLoginManagerDelegate
- (void)onLogin:(NIMLoginStep)step{
    [super onLogin:step];
    switch (step) {
        case NIMLoginStepLinkFailed:
            self.titleLabel.text = [SessionListTitle stringByAppendingString:@"(未连接)".ntes_localized];
            break;
        case NIMLoginStepLinking:
            self.titleLabel.text = [SessionListTitle stringByAppendingString:@"(连接中)".ntes_localized];
            break;
        case NIMLoginStepLinkOK:
        case NIMLoginStepSyncOK:
            self.titleLabel.text = SessionListTitle;
            break;
        case NIMLoginStepSyncing:
            self.titleLabel.text = [SessionListTitle stringByAppendingString:@"(同步数据)".ntes_localized];
            break;
        default:
            break;
    }
    [self.titleLabel sizeToFit];
    self.titleLabel.centerX   = self.navigationItem.titleView.width * .5f;
    [self.header refreshWithType:ListHeaderTypeNetStauts value:@(step)];
    [self refreshSubview];
}

- (void)onMultiLoginClientsChanged
{
    [self.header refreshWithType:ListHeaderTypeLoginClients value:[NIMSDK sharedSDK].loginManager.currentLoginClients];
    [self refreshSubview];
}

- (void)onTeamUsersSyncFinished:(BOOL)success
{
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.supportsForceTouch) {
        id<UIViewControllerPreviewing> preview = [self registerForPreviewingWithDelegate:self sourceView:cell];
        [self.previews setObject:preview forKey:@(indexPath.row)];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.supportsForceTouch) {
        id<UIViewControllerPreviewing> preview = [self.previews objectForKey:@(indexPath.row)];
        [self unregisterForPreviewingWithContext:preview];
        [self.previews removeObjectForKey:@(indexPath.row)];
    }
}


- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)context viewControllerForLocation:(CGPoint)point {
    UITableViewCell *touchCell = (UITableViewCell *)context.sourceView;
    if ([touchCell isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:touchCell];
        NIMRecentSession *recent = self.recentSessions[indexPath.row];
        NTESSessionPeekNavigationViewController *nav = [NTESSessionPeekNavigationViewController instance:recent.session];
        return nav;
    }
    return nil;
}

- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    UITableViewCell *touchCell = (UITableViewCell *)previewingContext.sourceView;
    if ([touchCell isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:touchCell];
        NIMRecentSession *recent = self.recentSessions[indexPath.row];
        NTESSessionViewController *vc = [[NTESSessionViewController alloc] initWithSession:recent.session];
        [self.navigationController showViewController:vc sender:nil];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 偶现侧滑数组越界，但并没有发现并发问题，暂且防护
    return indexPath.row < self.recentSessions.count;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    __weak typeof(self) weakSelf = self;
    UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除".ntes_localized handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        NIMRecentSession *recentSession = weakSelf.recentSessions[indexPath.row];
        [weakSelf onDeleteRecentAtIndexPath:recentSession atIndexPath:indexPath];
        [tableView setEditing:NO animated:YES];
        
        // 删除置顶
        NIMStickTopSessionInfo *stickTopInfo = [NIMSDK.sharedSDK.chatExtendManager stickTopInfoForSession:recentSession.session];
        if (stickTopInfo) {
            [NIMSDK.sharedSDK.chatExtendManager removeStickTopSession:stickTopInfo completion:^(NSError * _Nullable error, NIMStickTopSessionInfo * _Nullable removedInfo) {
                __strong typeof(self) sself = weakSelf;
                if (!sself) return;
                if (!error) {
                    self.stickTopInfos[recentSession.session] = nil;
                }
            }];
        }
    }];
    
    
    NIMRecentSession *recentSession = weakSelf.recentSessions[indexPath.row];
    BOOL isTop = self.stickTopInfos[recentSession.session] != nil;
    UITableViewRowAction *top = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:isTop?@"取消置顶".ntes_localized:@"置顶".ntes_localized handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [weakSelf onTopRecentAtIndexPath:recentSession atIndexPath:indexPath isTop:isTop];
        [tableView setEditing:NO animated:YES];
    }];
    
    return @[delete,top];
}

#pragma mark - NIMEventSubscribeManagerDelegate

- (void)onRecvSubscribeEvents:(NSArray *)events
{
    NSMutableSet *ids = [[NSMutableSet alloc] init];
    for (NIMSubscribeEvent *event in events) {
        [ids addObject:event.from];
    }
    
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    for (NSIndexPath *indexPath in self.tableView.indexPathsForVisibleRows) {
        NIMRecentSession *recent = self.recentSessions[indexPath.row];
        if (recent.session.sessionType == NIMSessionTypeP2P) {
            NSString *from = recent.session.sessionId;
            if ([ids containsObject:from]) {
                [indexPaths addObject:indexPath];
            }
        }
    }
    
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
}

- (void)onNotifyAddStickTopSession:(NIMStickTopSessionInfo *)newInfo
{
    self.stickTopInfos[newInfo.session] = newInfo;
    [self refresh];
}

- (void)onNotifyRemoveStickTopSession:(NIMStickTopSessionInfo *)removedInfo
{
    self.stickTopInfos[removedInfo.session] = nil;
    [self refresh];
}

- (void)onNotifySyncStickTopSessions:(NIMSyncStickTopSessionResponse *)response
{
    if (response.hasChange) {
        [self.stickTopInfos removeAllObjects];
        [response.allInfos enumerateObjectsUsingBlock:^(NIMStickTopSessionInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            self.stickTopInfos[obj.session] = obj;
        }];
        [self refresh];
    }
}

#pragma mark - NIMConversationManagerDelegate
- (void)onMarkMessageReadCompleteInSession:(NIMSession *)session error:(NSError *)error {
    if (error) {
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        NSString *msg = [NSString stringWithFormat:@"session %@ type %@ mark fail.code:%@",
                         session.sessionId, @(session.sessionType), @(error.code)];
        [keyWindow makeToast:msg duration:2 position:CSToastPositionCenter];
    }
}

#pragma mark - Private

- (void)refreshSubview{
    [self.titleLabel sizeToFit];
    self.titleLabel.centerX   = self.navigationItem.titleView.width * .5f;
    if (@available(iOS 11.0, *))
    {
        self.header.top = self.view.safeAreaInsets.top;
        self.tableView.top = self.header.bottom;
        CGFloat offset = self.view.safeAreaInsets.bottom;
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, offset, 0);
    }
    else
    {
        self.tableView.top = self.header.height;
        self.header.bottom    = self.tableView.top + self.tableView.contentInset.top;
    }
    self.tableView.height = self.view.height - self.tableView.top;
    
    self.emptyTipLabel.centerX = self.view.width * .5f;
    self.emptyTipLabel.centerY = self.tableView.height * .5f;
    self.emptyTipLabel.width = self.emptyTipLabel.width < self.view.width ? self.emptyTipLabel.width : self.view.width - 5;
    CGSize size = [self.emptyTipLabel sizeThatFits:CGSizeMake(self.emptyTipLabel.width, CGFLOAT_MAX)];
    self.emptyTipLabel.height = size.height;
}

- (UIView*)titleView:(NSString*)userID{
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.text =  SessionListTitle;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:15.f];
    [self.titleLabel sizeToFit];
    UILabel *subLabel  = [[UILabel alloc] initWithFrame:CGRectZero];
    subLabel.textColor = [UIColor grayColor];
    subLabel.font = [UIFont systemFontOfSize:12.f];
    subLabel.text = userID;
    subLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [subLabel sizeToFit];
    
    UIView *titleView = [[UIView alloc] init];
    titleView.width  = subLabel.width;
    titleView.height = self.titleLabel.height + subLabel.height;
    
    subLabel.bottom = titleView.height;
    [titleView addSubview:self.titleLabel];
    [titleView addSubview:subLabel];
    return titleView;
}


- (NSAttributedString *)contentForRecentSession:(NIMRecentSession *)recent{
    NSAttributedString *content;
    if (recent.lastMessage.messageType == NIMMessageTypeCustom)
    {
        NSString *text = [NTESMessageUtil messageContent:recent.lastMessage];
        if (recent.session.sessionType != NIMSessionTypeP2P)
        {
            NSString *nickName = [NTESSessionUtil showNick:recent.lastMessage.from inSession:recent.lastMessage.session];
            text =  nickName.length ? [nickName stringByAppendingFormat:@" : %@",text] : @"";
        }
        content = [[NSAttributedString alloc] initWithString:text];
    }
    else
    {
        content = [super contentForRecentSession:recent];
    }
    NSMutableAttributedString *attContent = [[NSMutableAttributedString alloc] initWithAttributedString:content];
    [self checkNeedAtTip:recent content:attContent];
    [self checkOnlineState:recent content:attContent];
    return attContent;
}


- (void)checkNeedAtTip:(NIMRecentSession *)recent content:(NSMutableAttributedString *)content
{
    if ([NTESSessionUtil recentSessionIsMark:recent type:NTESRecentSessionMarkTypeAt]) {
        NSAttributedString *atTip = [[NSAttributedString alloc] initWithString:@"[有人@你]".ntes_localized attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}];
        [content insertAttributedString:atTip atIndex:0];
    }
}

- (void)checkOnlineState:(NIMRecentSession *)recent content:(NSMutableAttributedString *)content
{
    if (recent.session.sessionType == NIMSessionTypeP2P) {
        NSString *state  = [NTESSessionUtil onlineState:recent.session.sessionId detail:NO];
        if (state.length) {
            NSString *format = [NSString stringWithFormat:@"[%@] ",state];
            NSAttributedString *atTip = [[NSAttributedString alloc] initWithString:format attributes:nil];
            [content insertAttributedString:atTip atIndex:0];
        }
    }
}

- (void)loadStickTopSessions
{
    __weak typeof(self) wself = self;
    [NIMSDK.sharedSDK.chatExtendManager loadStickTopSessionInfos:^(NSError * _Nullable error, NSDictionary<NIMSession *,NIMStickTopSessionInfo *> * _Nullable infos) {
        __strong typeof(self) sself = wself;
        if (!sself) return;
        sself.stickTopInfos = [NSMutableDictionary dictionaryWithDictionary:infos];
        [sself refresh];
    }];
}

@end
