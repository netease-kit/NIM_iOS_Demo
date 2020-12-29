//
//  NTESSessionServiceListVC.m
//  NIM
//
//  Created by He on 2019/10/21.
//  Copyright © 2019 Netease. All rights reserved.
//

#import "NTESSessionServiceListVC.h"
#import "NTESSessionUtil.h"
#import "UIView+NTES.h"
#import <UIView+Toast.h>
#import "NTESSessionViewController.h"
#import "NIMSessionListCell.h"
#import "NTESNoticationUtil.h"
#import "NIMKitUtil.h"

@interface NTESSessionServiceListVC () <NIMConversationManagerDelegate>
@property (nonatomic,strong) UIButton * moreButton;
@property (nonatomic,strong) NIMFetchServerSessionOption * option;
@property (nonatomic,assign) BOOL hasMore;

@end

@implementation NTESSessionServiceListVC

- (void)dealloc {
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.hasMore = YES;
    self.tableView.backgroundColor = [UIColor colorWithRed:243.f/255 green:244.f/255 blue:245.f/255 alpha:1];
    [[NIMSDK sharedSDK].loginManager removeDelegate:self];
    [[NIMSDK sharedSDK].conversationManager removeDelegate:self];
}

- (void)setUpNavItem
{
    [super setUpNavItem];
    self.titleLabel.text = @"云端会话列表".ntes_localized;
    self.navigationItem.rightBarButtonItems = nil;
}

- (void)refreshFooterWithMore:(BOOL)more {
    self.moreButton.selected = !more;
    self.tableView.tableFooterView = self.moreButton;
}

- (void)onLoadMore
{
    if (!self.hasMore) {
        return;
    }
    
    [[NIMSDK sharedSDK].conversationManager fetchServerSessions:self.option completion:^(NSError * _Nullable error, NSArray<NIMRecentSession *> * _Nullable recentSessions, BOOL hasMore) {
        if (!error) {
            self.hasMore = hasMore;
            NSMutableArray * tmps = recentSessions.mutableCopy;
            for (NIMRecentSession * recentSession in recentSessions)
            {
                if ([self.recentSessions containsObject:recentSession]) {
                    [tmps removeObject:recentSession];
                }
            }
            [self.recentSessions addObjectsFromArray:tmps];
            [self refresh];
            [self refreshFooterWithMore:hasMore];
            NIMRecentSession * recentSession = self.recentSessions.lastObject;
            self.option.maxTimestamp = recentSession.updateTime;
        }
    }];
}

- (void)onSelectedRecent:(NIMRecentSession *)recent atIndexPath:(NSIndexPath *)indexPath{
    NTESSessionViewController *vc = [[NTESSessionViewController alloc] initWithSession:recent.session];
    [self.navigationController pushViewController:vc animated:YES];
    NSMutableArray *vcs = [self.navigationController.viewControllers mutableCopy];
    [vcs removeObject:self];
    self.navigationController.viewControllers = vcs;
}

- (void)refresh{
    [super refresh];
}

- (UIButton *)moreButton {
    if (!_moreButton) {
        _moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_moreButton setTitleColor:self.view.tintColor forState:UIControlStateNormal];
        [_moreButton setTitle:@"加载更多".ntes_localized forState:UIControlStateNormal];
        [_moreButton setTitle:@"没有更多会话了".ntes_localized forState:UIControlStateSelected];
        _moreButton.frame = CGRectMake(0, 0, self.view.frame.size.width, 50);
        _moreButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_moreButton addTarget:self
                        action:@selector(onLoadMore)
              forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreButton;
}

- (NSMutableArray *)getRecentSessions {
    self.option = [[NIMFetchServerSessionOption alloc] init];
    self.option.limit = 20;
    [[NIMSDK sharedSDK].conversationManager fetchServerSessions:self.option completion:^(NSError * _Nullable error, NSArray<NIMRecentSession *> * _Nullable recentSessions, BOOL hasMore) {
        if (!error) {
            self.hasMore = hasMore;
            [self.recentSessions addObjectsFromArray:recentSessions];
            [self.tableView reloadData];
            [self refreshFooterWithMore:hasMore];
            NIMRecentSession * recentSession = self.recentSessions.lastObject;
            self.option.maxTimestamp = recentSession.updateTime;
            [self refresh];
        }
    }];
    return nil;
}

- (NSAttributedString *)contentForRecentSession:(NIMRecentSession *)recent{
    if (recent.lastMessageType == NIMLastMsgTypeRevokeNotication) {
        NSString *content = [self messageContentWithRevokeNote:recent.lastRevokeNotification];
        return [[NSAttributedString alloc] initWithString:content ?: @""];
    } else {
        return [super contentForRecentSession:recent];;
    }
}

- (NSString *)messageContentWithRevokeNote:(NIMRevokeMessageNotification *)revokeNote {
    NSString *text = [NTESNoticationUtil revokeNoticationContent:revokeNote];
    if (revokeNote.session.sessionType == NIMSessionTypeP2P)
    {
        return text;
    }
    else
    {
        NSString *from = revokeNote.fromUserId;
        NSString *nickName = [NIMKitUtil showNick:from inSession:revokeNote.session];
        return nickName.length ? [nickName stringByAppendingFormat:@" : %@",text] : @"";
    }
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    __weak typeof(self) weakSelf = self;
    UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        NIMRecentSession *recentSession = weakSelf.recentSessions[indexPath.row];
        [[NIMSDK sharedSDK].conversationManager deleteServerSessions:@[recentSession.session] completion:^(NSError * _Nullable error) {
            if (!error) {
                [weakSelf.recentSessions removeObject:recentSession];
                [weakSelf.tableView reloadData];
            } else {
                [weakSelf.view makeToast:@"删除失败" duration:1 position:CSToastPositionCenter];
            }
        }];
        [tableView setEditing:NO animated:YES];
    }];
    
    NIMRecentSession *recentSession = weakSelf.recentSessions[indexPath.row];
    UITableViewRowAction *update = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"更新" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        NSDictionary * localExt = recentSession.localExt;
        NSMutableDictionary * newExt = [NSMutableDictionary dictionaryWithDictionary:localExt];
        newExt[@"number"] = @(arc4random());

        NSData * data = [NSJSONSerialization dataWithJSONObject:newExt options:NSJSONWritingPrettyPrinted error:nil];
        NSString * newServerExt = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
        [[NIMSDK sharedSDK].conversationManager updateServerSessionExt:newServerExt session:recentSession.session completion:^(NSError * _Nullable error) {
            if (error) {
                [weakSelf.view makeToast:@"更新失败" duration:1 position:CSToastPositionCenter];
                return;
            } else {
                [weakSelf.view makeToast:recentSession.serverExt duration:3 position:CSToastPositionCenter];
            }
            recentSession.serverExt = newServerExt;
            [weakSelf.tableView reloadData];
        }];
        
        [tableView setEditing:NO animated:YES];
    }];
    

    UITableViewRowAction *show = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"详情" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        NIMRecentSession *recentSession = weakSelf.recentSessions[indexPath.row];
        NSString *content = [NSString stringWithFormat:@"%@", recentSession];
        [weakSelf showInfo:content];
        [tableView setEditing:NO animated:YES];
    }];
    
    return @[delete,update, show];
}

- (void)showInfo:(NSString *)info {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    NSDictionary * attributes = @{NSFontAttributeName : [UIFont systemFontOfSize:14.0],
                                  NSParagraphStyleAttributeName : paragraphStyle};
    NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:info];
    [attributedTitle addAttributes:attributes range:NSMakeRange(0, info.length)];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"详情" message:info preferredStyle:UIAlertControllerStyleAlert];
    [alert setValue:attributedTitle forKey:@"attributedMessage"];
    UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:sure];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)onTouchAvatar:(id)sender{
    UIView *view = [sender superview];
    while (![view isKindOfClass:[UITableViewCell class]]) {
        view = view.superview;
    }
    UITableViewCell *cell  = (UITableViewCell *)view;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NIMRecentSession *recent = self.recentSessions[indexPath.row];
    [[NIMSDK sharedSDK].conversationManager fetchServerSessionBySession:recent.session completion:^(NSError * _Nullable error, NIMRecentSession * _Nullable recentSession) {
        if (!error && recentSession) {
            [self.recentSessions removeObject:recent];
            [self.recentSessions addObject:recentSession];
            self.recentSessions = [self customSortRecents:self.recentSessions];
            [self.tableView reloadData];
        }
        
    }];
}

- (void)didServerSessionUpdated:(nullable NIMRecentSession *)recentSession {
    NSArray * recents = [self.recentSessions copy];
    [recents enumerateObjectsUsingBlock:^(NIMRecentSession  * recent, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([recentSession.session isEqual:recent.session]) {
            [self.recentSessions replaceObjectAtIndex:idx withObject:recentSession];
            * stop = YES;
        }
    }];
    [self refresh];
}

@end
