//
//  NTESMessageRetrieveResultVC.m
//  NIM
//
//  Created by He on 2019/12/18.
//  Copyright © 2019 Netease. All rights reserved.
//

#import "NTESMessageRetrieveResultVC.h"
#import "NIMCommonTableData.h"
#import "NIMCommonTableDelegate.h"
#import "UIView+NTES.h"

@interface NTESMessageRetrieveResultVC ()
@property (nonatomic,strong) NSMutableArray * msgs;
@property (nonatomic,strong) NIMCommonTableDelegate * delegater;
@end

@implementation NTESMessageRetrieveResultVC

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self setupTableView];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)setupTableView
{
    self.delegater = [[NIMCommonTableDelegate alloc] initWithTableData:^NSArray *{
        return self.datas;
    }];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self.delegater;
    self.tableView.dataSource = self.delegater;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
    self.tableView.tableFooterView = [[UIView alloc] init];
    if (@available(iOS 11, *))
    {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self.view addSubview:self.tableView];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if (self.searchBar)
    {
        CGFloat top = self.searchBar.bottom - 25;
        self.tableView.contentInset = UIEdgeInsetsMake(top, 0, 0, 0);
        self.tableView.contentOffset = CGPointMake(0, -top);
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

#pragma mark - UISearchResultsUpdating
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    // 谓词筛选
    
}



@end
