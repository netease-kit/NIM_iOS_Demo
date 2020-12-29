//
//  NTESSessionSearchViewController.m
//  NIM
//
//  Created by Genning-Work on 2020/1/2.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NTESSessionSearchViewController.h"
#import "NIMSessionListCell.h"
#import "UIView+NTES.h"
#import "NIMKitUtil.h"
#import "NTESMessageUtil.h"
#import "NIMAvatarImageView.h"
#import "NTESSessionViewController.h"
#import <SVProgressHUD.h>
#import <UIView+Toast.h>

@interface NTESSessionSearchViewController ()<UISearchResultsUpdating, UISearchControllerDelegate>

@property (nonatomic, assign) BOOL endSearch;

@property (nonatomic, copy) NSString *searchText;

@property (nonatomic, strong) UISearchController *searchVC;

@property (nonatomic, strong) UITableViewController *searchResultVC;

@property (nonatomic, strong) NSMutableArray <NIMRecentSession *>* resultSessions;

@property (nonatomic, strong) NSMutableDictionary <NSString *, NIMUser *> *userResultDictionary;

@property (nonatomic, strong) NSMutableDictionary <NSString *, NIMTeam *> *teamResultDictionary;

@end

@implementation NTESSessionSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"搜索最近会话".ntes_localized;
    _userResultDictionary = [NSMutableDictionary dictionary];
    _teamResultDictionary = [NSMutableDictionary dictionary];
    UIEdgeInsets separatorInset   = self.tableView.separatorInset;
    separatorInset.right          = 0;
    self.tableView.separatorInset = separatorInset;
    self.tableView.sectionHeaderHeight = 0.0;
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = [UIView new];
    self.automaticallyAdjustsScrollViewInsets = NO;
    if (!IOS11) {
        CGFloat insetTop = self.searchVC.searchBar.height + [UIApplication sharedApplication].statusBarFrame.size.height;
        UIEdgeInsets insets = {insetTop, 0, 0, 0};
        self.tableView.contentInset = insets;
    }
    self.tableView.tableHeaderView = self.searchVC.searchBar;
    [self.tableView registerClass:[NIMSessionListCell class] forCellReuseIdentifier:@"content"];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        return _resultSessions.count;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tableView) {
        NIMSessionListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"content"
                                                                   forIndexPath:indexPath];
        NIMRecentSession *recent = self.resultSessions[indexPath.row];
        cell.nameLabel.attributedText = [self nameForRecentSession:recent];
        [cell.avatarImageView setAvatarBySession:recent.session];
        [cell.nameLabel sizeToFit];
        cell.messageLabel.attributedText  = [self contentForRecentSession:recent];
        [cell.messageLabel sizeToFit];
        cell.timeLabel.text = [self timestampDescriptionForRecentSession:recent];
        [cell.timeLabel sizeToFit];
        [cell refresh:recent];
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"entrance"
                                                                forIndexPath:indexPath];
        cell.textLabel.textColor = [UIColor blueColor];
        cell.textLabel.text = [NSString stringWithFormat:@"搜索关键字:\"%@\"".ntes_localized, _searchText];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == self.searchResultVC.tableView) {
        [self doSearch:_searchText];
    } else if (tableView == self.tableView) {
        NIMRecentSession *recent = _resultSessions[indexPath.row];
        NTESSessionViewController *vc = [[NTESSessionViewController alloc] initWithSession:recent.session];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - <UISearchResultsUpdating>
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    if (!_endSearch) {
        _searchText = searchController.searchBar.text;
        [self.searchResultVC.tableView reloadData];
    }
}

- (void)willPresentSearchController:(UISearchController *)searchController {
    _endSearch = NO;
}

#pragma mark - Session Search
- (void)doSearch:(NSString *)text {
    //查找user
    __weak typeof(self) weakSelf = self;
    [SVProgressHUD show];
    [self searchSessionIdWithText:text completion:^(NSError *error, NSMutableArray<NSMutableArray *> *sessionIds) {
        if (error) {
            [SVProgressHUD dismiss];
            [weakSelf.view makeToast:@"搜索失败" duration:2 position:CSToastPositionCenter];
        } else {
            //反查recentsession
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSMutableArray *resultSessions = [NSMutableArray array];
                __block NIMRecentSession *recentSession = nil;
                 [sessionIds enumerateObjectsUsingBlock:^(NSMutableArray * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                     if (idx == 0) { //user
                         for (NSString *userId in obj) {
                             recentSession = [self recentSessionWithId:userId type:NIMSessionTypeP2P];
                             if (recentSession) {
                                 [resultSessions addObject:recentSession];
                             }
                         }
                     } else if (idx == 1) { //team
                         for (NSString *teamId in obj) {
                             recentSession = [self recentSessionWithId:teamId type:NIMSessionTypeTeam];
                             if (recentSession) {
                                 [resultSessions addObject:recentSession];
                             }
                         }
                     }
                 }];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    weakSelf.resultSessions = resultSessions;
                });
            });
        }
    }];
}

- (void)searchSessionIdWithText:(NSString *)text
                     completion:(void (^)(NSError *error, NSMutableArray <NSMutableArray *> *sessionIds))completion {
    NSMutableArray *ret = [NSMutableArray array];
    //查找user
    [_userResultDictionary removeAllObjects];
    [_teamResultDictionary removeAllObjects];
    NIMUserSearchOption *option = [[NIMUserSearchOption alloc] init];
    option.searchRange = NIMUserSearchRangeOptionAll;
    option.searchContent = text;
    option.ignoreingCase = YES;
    __weak typeof(self) weakSelf= self;
    [[NIMSDK sharedSDK].userManager searchUserWithOption:option completion:^(NSArray<NIMUser *> * _Nullable users, NSError * _Nullable error) {
        if (!error) {
            NSMutableArray *userResults = [NSMutableArray array];
            for (NIMUser *user in users) {
                [userResults addObject:user.userId];
                weakSelf.userResultDictionary[user.userId] = user;
            }
            [ret addObject:userResults];
            
            NIMTeamSearchOption *teamSeacheOption = [[NIMTeamSearchOption alloc] init];
            teamSeacheOption.searchContent = text;
            teamSeacheOption.ignoreingCase = YES;
            [[NIMSDK sharedSDK].teamManager searchTeamWithOption:teamSeacheOption completion:^(NSError * _Nullable error, NSArray<NIMTeam *> * _Nullable teams) {
                if (!error) {
                    NSMutableArray *teamResults = [NSMutableArray array];
                    for (NIMTeam *team in teams) {
                        [teamResults addObject:team.teamId];
                        weakSelf.teamResultDictionary[team.teamId] = team;
                    }
                    [ret addObject:teamResults];
                }
                if (completion) {
                    completion(error, ret);
                }
            }];
        } else {
            if (completion) {
                completion(error, nil);
            }
        }
    }];
}

#pragma mark - Helper
- (void)setResultSessions:(NSMutableArray<NIMRecentSession *> *)resultSessions {
    _resultSessions = resultSessions;
    _endSearch = YES;
    [self.searchVC setActive:NO];
    [self.tableView reloadData];
}

- (NIMRecentSession *)recentSessionWithId:(NSString *)sessionId type:(NIMSessionType)type{
    __block NIMRecentSession *ret = nil;
    [self.recentSessions enumerateObjectsUsingBlock:^(NIMRecentSession * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.session.sessionId isEqualToString:sessionId]
            && obj.session.sessionType == type) {
            ret = obj;
            *stop = YES;
        }
    }];
    return ret;
}

- (NSMutableAttributedString *)nameForRecentSession:(NIMRecentSession *)recent {
    if (recent.session.sessionType == NIMSessionTypeP2P) {
        NIMUser *user = _userResultDictionary[recent.session.sessionId];
        return [self showNameWithUser:user];
    } else if (recent.session.sessionType == NIMSessionTypeTeam) {
        NIMTeam *team = _teamResultDictionary[recent.session.sessionId];
        return [self showNameWithTeam:team];
    } else {
        return [[NSMutableAttributedString alloc] initWithString:@""];
    }
}

- (NSString *)messageContent:(NIMMessage*)lastMessage{
    NSString *text = [NTESMessageUtil messageContent:lastMessage];
    if (lastMessage.session.sessionType == NIMSessionTypeP2P || lastMessage.messageType == NIMMessageTypeTip)
    {
        return text;
    }
    else
    {
        NSString *from = lastMessage.from;
        NSString *nickName = [NIMKitUtil showNick:from inSession:lastMessage.session];
        return nickName.length ? [nickName stringByAppendingFormat:@" : %@",text] : @"";
    }
}

- (NSAttributedString *)contentForRecentSession:(NIMRecentSession *)recent{
    NSString *content = [self messageContent:recent.lastMessage];
    return [[NSAttributedString alloc] initWithString:content ?: @""];
}

- (NSString *)timestampDescriptionForRecentSession:(NIMRecentSession *)recent{
    return [NIMKitUtil showTime:recent.lastMessage.timestamp showDetail:NO];
}

#pragma mark - Hight
- (NSMutableAttributedString *)showNameWithTeam:(NIMTeam *)team {
    NSString *src = team.teamName ?: @"null";
    NSString *searchText = _searchText;
    if ([self ignoreCase]) {
        src = [src lowercaseString];
        searchText = [searchText lowercaseString];
    }
    NSRange local = [src rangeOfString:searchText];
    NSMutableAttributedString *show = [[NSMutableAttributedString alloc] initWithString:(team.teamName ?: @"null")];
    [show setAttributes:@{NSForegroundColorAttributeName:[UIColor redColor]} range:local];
    return show;
}

- (NSMutableAttributedString *)showNameWithUser:(NIMUser *)user {
    NIMKitInfo *info = [[NIMKit sharedKit] infoByUser:user.userId option:nil];
    NSMutableAttributedString *ret = [[NSMutableAttributedString alloc] init];
    
    NSString *src = info.showName;
    NSString *searchText = _searchText;
    if ([self ignoreCase]) {
        src = [src lowercaseString];
        searchText = [searchText lowercaseString];
    }
    NSRange local = [src rangeOfString:searchText];
    if (local.location != NSNotFound) {
        NSMutableAttributedString *show = [[NSMutableAttributedString alloc] initWithString:(info.showName ?: @"null")];
        [show setAttributes:@{NSForegroundColorAttributeName:[UIColor redColor]} range:local];
        [ret appendAttributedString:show];
    } else {
        src = user.userId;
        if ([self ignoreCase]) {
            src = [src lowercaseString];
        }
        local = [src rangeOfString:searchText];  //userId
        if (local.location != NSNotFound) {
            NSMutableAttributedString *mainShow = [[NSMutableAttributedString alloc] initWithString:(info.showName ?: @"null")];
            [ret appendAttributedString:mainShow];
            NSMutableAttributedString *show = [self otherShowName:user.userId];
            [ret appendAttributedString:show];
        } else {
            src = user.alias;
            if ([self ignoreCase]) {
                src = [src lowercaseString];
            }
            local = [src rangeOfString:searchText]; //nickName
            if (local.location != NSNotFound) {
                NSMutableAttributedString *mainShow = [[NSMutableAttributedString alloc] initWithString:(info.showName ?: @"null")];
                [ret appendAttributedString:mainShow];
                NSMutableAttributedString *show = [self otherShowName:user.alias];
                [ret appendAttributedString:show];
            } else {
                src = user.userInfo.nickName;
                if ([self ignoreCase]) {
                    src = [src lowercaseString];
                }
                local = [src rangeOfString:searchText]; //nickName
                if (local.location != NSNotFound) {
                    NSMutableAttributedString *mainShow = [[NSMutableAttributedString alloc] initWithString:(info.showName ?: @"null")];
                    [ret appendAttributedString:mainShow];
                    NSMutableAttributedString *show = [self otherShowName:user.userInfo.nickName];
                    [ret appendAttributedString:show];
                }
            }
        }
    }
    return ret;
}

- (NSMutableAttributedString *)otherShowName:(NSString *)string {
    NSString *otherShow = [NSString stringWithFormat:@" [%@]", string];
    NSMutableAttributedString *show = [[NSMutableAttributedString alloc] initWithString:otherShow];
    NSString *searchText = _searchText;
    if ([self ignoreCase]) {
        searchText = [searchText lowercaseString];
    }
    NSRange local = [[otherShow lowercaseString] rangeOfString:searchText];
    [show setAttributes:@{NSForegroundColorAttributeName:[UIColor redColor]} range:local];
    return show;
}

- (BOOL)ignoreCase {
    BOOL ret = YES;
    return ret;
}

#pragma mark - Getter
- (UITableViewController *)searchResultVC {
    if (!_searchResultVC) {
        _searchResultVC = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
        _searchResultVC.automaticallyAdjustsScrollViewInsets = NO;
        CGFloat resultInsetTop = self.searchVC.searchBar.height + [UIApplication sharedApplication].statusBarFrame.size.height;
        UIEdgeInsets resultInsets = {resultInsetTop, 0, 0, 0};
        _searchResultVC.tableView.contentInset = resultInsets;
        [_searchResultVC.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier: @"entrance"];
        _searchResultVC.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _searchResultVC.tableView.delegate = self;
        _searchResultVC.tableView.dataSource = self;
        _searchResultVC.tableView.separatorInset  = UIEdgeInsetsZero;
        _searchResultVC.tableView.tableFooterView = [UIView new];
    }
    return _searchResultVC;
}

- (UISearchController *)searchVC {
    if (!_searchVC) {
        _searchVC = [[UISearchController alloc] initWithSearchResultsController:self.searchResultVC];
        _searchVC.searchResultsUpdater = self;
        _searchVC.delegate = self;
        _searchVC.dimsBackgroundDuringPresentation = YES;
        _searchVC.obscuresBackgroundDuringPresentation = YES;
        _searchVC.hidesNavigationBarDuringPresentation = YES;
        _searchVC.searchBar.height = 44.f;
    }
    return _searchVC;
}

@end
