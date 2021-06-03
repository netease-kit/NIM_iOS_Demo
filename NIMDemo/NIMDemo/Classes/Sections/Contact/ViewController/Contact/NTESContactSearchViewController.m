//
//  NTESContactSearchViewController.m
//  NIM
//
//  Created by Genning-Work on 2020/1/2.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NTESContactSearchViewController.h"
#import "NTESGroupedContacts.h"
#import "NTESContactUtilItem.h"
#import "NTESPersonalCardViewController.h"
#import "NTESContactDataCell.h"
#import "UIView+Toast.h"
#import "UIView+NTES.h"
#import "NIMAvatarImageView.h"
#import "NTESSessionViewController.h"
#import <SVProgressHUD.h>

@interface NTESContactSearchViewController ()<UISearchResultsUpdating, UISearchControllerDelegate>

/*
 0 : 联系人
 1 : 群组
*/

@property (nonatomic, copy) NSString *searchText;

@property (nonatomic, strong) NSMutableArray <NSArray *>*sections;

@property (nonatomic, strong) UISearchController *searchVC;

@property (nonatomic, strong) UITableViewController *searchResultVC;

@property (nonatomic, assign) BOOL endSearch;

@end

@implementation NTESContactSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIEdgeInsets separatorInset   = self.tableView.separatorInset;
    separatorInset.right          = 0;
    self.tableView.separatorInset = separatorInset;
    self.tableView.sectionHeaderHeight = 0.0;
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = [UIView new];
    self.automaticallyAdjustsScrollViewInsets = NO;
    if (IOS10Lower) {
        CGFloat insetTop = self.searchVC.searchBar.height + [UIApplication sharedApplication].statusBarFrame.size.height;
        UIEdgeInsets insets = {insetTop, 0, 0, 0};
        self.tableView.contentInset = insets;
    }
    self.tableView.tableHeaderView = self.searchVC.searchBar;
    self.definesPresentationContext = YES;
    self.title = @"搜索联系人".ntes_localized;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.tableView) {
        return _sections.count;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        return [_sections objectAtIndex:section].count;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tableView) {
        NSArray *datas = _sections[indexPath.section];
        if (indexPath.section == 0) {
            NIMUser *user = datas[indexPath.row];
            NTESContactDataCell * cell = [tableView dequeueReusableCellWithIdentifier:@"userList"];
            if (!cell) {
                cell = [[NTESContactDataCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"userList"];
            }
            UIImage *placeholderImage = [UIImage imageNamed:@"avatar_user"];
            NSURL *avatarUrl = [NSURL URLWithString:user.userInfo.avatarUrl];
            [cell.avatarImageView nim_setImageWithURL:avatarUrl placeholderImage:placeholderImage];
            cell.textLabel.attributedText = [self showNameWithUser:user];
            return cell;
        } else if (indexPath.section == 1) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"teamList"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"teamList"];
            }
            NIMTeam *team = datas[indexPath.row];
            cell.textLabel.attributedText = [self showNameWithTeam:team];
            return cell;
        } else {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"defaultCell"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"defaultCell"];
            }
            return cell;
        }
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
            cell.textLabel.textColor = [UIColor blueColor];
        }
        cell.textLabel.text = [NSString stringWithFormat:@"搜索关键字:\"%@\"".ntes_localized, _searchText];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView == self.tableView) {
        if (indexPath.section == 0) {
            NIMUser *user = [_sections[indexPath.section] objectAtIndex:indexPath.row];
            NTESPersonalCardViewController *vc = [[NTESPersonalCardViewController alloc] initWithUserId:user.userId];
            [self showVC:vc];
        } else if (indexPath.section == 1) {
            NIMTeam *team = [_sections[indexPath.section] objectAtIndex:indexPath.row];
            NIMSession *session = [NIMSession session:team.teamId type:NIMSessionTypeTeam];
            NTESSessionViewController *vc = [[NTESSessionViewController alloc] initWithSession:session];
            [self showVC:vc];
        }
    } else {
        [self doSearch];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        if (section == 0) {
            return _sections[section].count != 0 ? @"联系人" : @"";
        } else if (section == 1) {
            return _sections[section].count != 0 ? @"群组" : @"";
        } else {
            return @"";
        }
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 24.0;
}

- (void)showVC:(UIViewController *)vc {
    self.sections = _sections;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController pushViewController:vc animated:YES];
    });
}

#pragma mark - UISearchResultsUpdating
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    if (!_endSearch) {
        _searchText = searchController.searchBar.text;
        [self.searchResultVC.tableView reloadData];
    }
}

- (void)willPresentSearchController:(UISearchController *)searchController {
    _endSearch = NO;
}

#pragma mark - Search
- (void)doSearch {
    [SVProgressHUD show];
    NIMUserSearchOption *option = [[NIMUserSearchOption alloc] init];
    option.searchContent = _searchText;
    option.ignoreingCase = [self ignoreCase];
    __weak typeof(self) weakSelf = self;
    [[NIMSDK sharedSDK].userManager searchUserWithOption:option completion:^(NSArray<NIMUser *> * _Nullable users, NSError * _Nullable error) {
        if (!error) {
            NSMutableArray *sections = [NSMutableArray array];
            NSMutableArray *ret = [NSMutableArray arrayWithArray:users];
            [sections addObject:ret];
            if (![weakSelf disableSearchTeam]) {//查找team
                NIMTeamSearchOption *teamSeacheOption = [[NIMTeamSearchOption alloc] init];
                teamSeacheOption.searchContent = weakSelf.searchText;
                teamSeacheOption.ignoreingCase = [weakSelf ignoreCase];
                [[NIMSDK sharedSDK].teamManager searchTeamWithOption:teamSeacheOption completion:^(NSError * _Nullable error, NSArray<NIMTeam *> * _Nullable teams) {
                    if (!error) {
                        [sections addObject:teams];
                    }
                    [SVProgressHUD dismiss];
                    weakSelf.sections = sections;
                }];
            } else {
                [SVProgressHUD dismiss];
                weakSelf.sections = sections;
            }
        } else {
            [SVProgressHUD dismiss];
        }
    }];
}

#pragma mark - Helper
- (NSMutableAttributedString *)showNameWithTeam:(NIMTeam *)team {
    NSString *src = team.teamName;
    NSString *searchText = _searchText;
    if ([self ignoreCase]) {
        src = [src lowercaseString];
        searchText = [searchText lowercaseString];
    }
    NSRange local = [src rangeOfString:searchText];
    NSMutableAttributedString *show = [[NSMutableAttributedString alloc] initWithString:team.teamName];
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
        NSMutableAttributedString *show = [[NSMutableAttributedString alloc] initWithString:info.showName];
        [show setAttributes:@{NSForegroundColorAttributeName:[UIColor redColor]} range:local];
        [ret appendAttributedString:show];
    } else {
        src = user.userId;
        if ([self ignoreCase]) {
            src = [src lowercaseString];
        }
        local = [src rangeOfString:searchText];  //userId
        if (local.location != NSNotFound) {
            NSMutableAttributedString *mainShow = [[NSMutableAttributedString alloc] initWithString:info.showName];
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
                NSMutableAttributedString *mainShow = [[NSMutableAttributedString alloc] initWithString:info.showName];
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
                    NSMutableAttributedString *mainShow = [[NSMutableAttributedString alloc] initWithString:info.showName];
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

- (BOOL)disableSearchTeam {
    BOOL ret = NO;
    if (_delegate && [_delegate respondsToSelector:@selector(disableSearchTeam)]) {
        ret = [_delegate disableSearchTeam];
    }
    return ret;
}

- (BOOL)ignoreCase {
    BOOL ret = YES;
    if (_delegate && [_delegate respondsToSelector:@selector(ignoreCase)]) {
        ret = [_delegate ignoreCase];
    }
    return ret;
}

#pragma mark - Getter
- (void)setSections:(NSMutableArray<NSArray *> *)sections {
    _sections = sections;
    _endSearch = YES;
    [self.searchVC setActive:NO];
    [self.tableView reloadData];
}

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
