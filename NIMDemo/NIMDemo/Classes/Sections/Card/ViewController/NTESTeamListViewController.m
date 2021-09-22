//
//  NTESTeamListViewController.m
//  NIM
//
//  Created by Xuhui on 15/3/3.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NTESTeamListViewController.h"
#import "NTESSessionViewController.h"


@interface NTESTeamListViewController () <UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *myTeams;

- (NSMutableArray *)didFetchTeams;
- (NIMSession *)didGetSessionWithTeam:(NIMTeam *)team;
@end

@implementation NTESTeamListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.myTeams = [self didFetchTeams];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc]init];
    self.tableView.rowHeight = 55.f;
}

- (void)setMyTeams:(NSMutableArray *)myTeams {
    _myTeams = myTeams;
    [self.tableView reloadData];
}

//MARK: Subclass reload
- (NSMutableArray *)didFetchTeams {return nil;}

- (NIMSession *)didGetSessionWithTeam:(NIMTeam *)team {return nil;}

//MARK: <UITableViewDelegate,UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _myTeams.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TeamListCell"];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TeamListCell"];
    }
    NIMTeam *team = _myTeams[indexPath.row];
    cell.textLabel.text = team.teamName;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NIMTeam *team = _myTeams[indexPath.row];
    NIMSession *session = [self didGetSessionWithTeam:team];
    if (session) {
        NTESSessionViewController *vc = [[NTESSessionViewController alloc] initWithSession:session];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end

#pragma mark -
@implementation NTESSuperTeamListViewController

- (void)dealloc {
    [[NIMSDK sharedSDK].superTeamManager removeDelegate:self];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.navigationItem.title = @"超大群组".ntes_localized;
    [[NIMSDK sharedSDK].superTeamManager addDelegate:self];
}

//MARK:Reload
- (NIMSession *)didGetSessionWithTeam:(id)team {
    NIMTeam *teamItem = (NIMTeam *)team;
    NIMSession *session = [NIMSession session:teamItem.teamId type:NIMSessionTypeSuperTeam];
    return session;
}

- (NSMutableArray *)didFetchTeams {
    NSMutableArray *myTeams = [[NSMutableArray alloc]init];
    for (NIMTeam *team in [NIMSDK sharedSDK].superTeamManager.allMyTeams) {
        [myTeams addObject:team];
    }
    return myTeams;
}

//MARK:<NIMTeamManagerDelegate>
- (void)onTeamAdded:(NIMTeam *)team {
    self.myTeams = [self didFetchTeams];
}

- (void)onTeamUpdated:(NIMTeam *)team {
    self.myTeams = [self didFetchTeams];
}

- (void)onTeamRemoved:(NIMTeam *)team {
    self.myTeams = [self didFetchTeams];
}

- (void)onTeamMemberChanged:(NIMTeam *)team {
    self.myTeams = [self didFetchTeams];
}

@end

#pragma mark -
@implementation NTESAdvancedTeamListViewController

- (void)dealloc{
    [[NIMSDK sharedSDK].teamManager removeDelegate:self];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.navigationItem.title = @"高级群组".ntes_localized;
    [[NIMSDK sharedSDK].teamManager addDelegate:self];
}

//MARK:Reload
- (NIMSession *)didGetSessionWithTeam:(id)team {
    NIMTeam *teamItem = (NIMTeam *)team;
    NIMSession *session = [NIMSession session:teamItem.teamId type:NIMSessionTypeTeam];
    return session;
}

- (NSMutableArray *)didFetchTeams {
    NSMutableArray *myTeams = [[NSMutableArray alloc]init];
    for (NIMTeam *team in [NIMSDK sharedSDK].teamManager.allMyTeams) {
        if (team.type == NIMTeamTypeAdvanced) {
            [myTeams addObject:team];
        }
    }
    return myTeams;
}

//MARK:NIMTeamManagerDelegate
- (void)onTeamAdded:(NIMTeam *)team{
    if (team.type == NIMTeamTypeAdvanced) {
        self.myTeams = [self didFetchTeams];
    }
}

- (void)onTeamUpdated:(NIMTeam *)team{
    if (team.type == NIMTeamTypeAdvanced) {
        self.myTeams = [self didFetchTeams];
    }
}

- (void)onTeamRemoved:(NIMTeam *)team{
    if (team.type == NIMTeamTypeAdvanced) {
        self.myTeams = [self didFetchTeams];
    }
}

@end


#pragma mark -
@implementation NTESNormalTeamListViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.navigationItem.title = @"讨论组".ntes_localized;
}

//MARK:Reload
- (NIMSession *)didGetSessionWithTeam:(NIMTeam *)team {
    NIMSession *session = [NIMSession session:team.teamId type:NIMSessionTypeTeam];
    return session;
}

- (NSMutableArray *)didFetchTeams{
    NSMutableArray *myTeams = [[NSMutableArray alloc]init];
    for (NIMTeam *team in [NIMSDK sharedSDK].teamManager.allMyTeams) {
        if (team.type == NIMTeamTypeNormal) {
            [myTeams addObject:team];
        }
    }
    return myTeams;
}

//MARK:NIMTeamManagerDelegate
- (void)onTeamUpdated:(NIMTeam *)team{
    if (team.type == NIMTeamTypeNormal) {
        self.myTeams = [self didFetchTeams];
    }
}

- (void)onTeamRemoved:(NIMTeam *)team{
    if (team.type == NIMTeamTypeNormal) {
        self.myTeams = [self didFetchTeams];
    }
    [self.tableView reloadData];
}

- (void)onTeamAdded:(NIMTeam *)team{
    if (team.type == NIMTeamTypeNormal) {
        self.myTeams = [self didFetchTeams];
    }
    [self.tableView reloadData];
}
@end

