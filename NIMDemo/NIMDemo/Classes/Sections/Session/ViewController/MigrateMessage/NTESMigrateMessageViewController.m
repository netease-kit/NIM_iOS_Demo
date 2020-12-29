//
//  NTESMigrateMessageViewController.m
//  NIM
//
//  Created by Sampson on 2018/12/10.
//  Copyright © 2018 Netease. All rights reserved.
//

#import "NTESMigrateMessageViewController.h"
#import "NIMCommonTableData.h"
#import "NIMCommonTableDelegate.h"
#import "SVProgressHUD.h"
#import "NTESExportMessageViewController.h"
#import "NTESImportMessageViewController.h"
#import "UIView+Toast.h"

@interface NTESMigrateMessageViewController ()

@property (nonatomic,copy) NSArray *data;
@property (nonatomic,strong) NIMCommonTableDelegate *delegator;

@end

@implementation NTESMigrateMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"本地消息迁移".ntes_localized;
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self buildData];
    __weak typeof(self) wself = self;
    self.delegator = [[NIMCommonTableDelegate alloc] initWithTableData:^NSArray *{
        return wself.data;
    }];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [self.view addSubview:self.tableView];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tableView.delegate   = self.delegator;
    self.tableView.dataSource = self.delegator;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (@available(iOS 11.0, *)) {
        CGFloat heightAdjust = self.view.safeAreaInsets.bottom;
        const CGRect frame = self.view.frame;
        self.tableView.frame = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame) - heightAdjust);
    }
}

#pragma mark --
- (void)buildData {
    NSArray *data = @[
                      @{
                          HeaderTitle : @"",
                          RowContent : @[
                                  @{
                                      Title : @"本地消息导出".ntes_localized,
                                      CellAction : @"onTouchExportLocalMessages:",
                                      },
                                  @{
                                      Title : @"本地消息导入".ntes_localized,
                                      CellAction : @"onTouchImportLocalMessages:",
                                      },
                                  ]
                          }
                      ];
    self.data = [NIMCommonTableSection sectionsWithData:data];
}

#pragma mark -- cellAction
- (void)onTouchExportLocalMessages:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"确定导出本地消息？".ntes_localized message:@"本地消息将存至云端，会耗费较长时间".ntes_localized preferredStyle:UIAlertControllerStyleAlert];
    
    // 返回
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"返回".ntes_localized style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertController addAction:actionCancel];
    
    // 导出
    UIAlertAction *actionExport = [UIAlertAction actionWithTitle:@"继续导出".ntes_localized style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NTESExportMessageViewController *exportController = [[NTESExportMessageViewController alloc] init];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:exportController];
        [self presentViewController:navController animated:YES completion:nil];
    }];
    [alertController addAction:actionExport];
    
    //
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)onTouchImportLocalMessages:(id)sender {
    // check message
    [SVProgressHUD show];
    
    [[NIMSDK sharedSDK].conversationManager fetchMigrateMessageInfo:^(NSError * _Nullable error, NSString * _Nullable remoteFilePath, NSString * _Nullable secureKey)
    {
        [SVProgressHUD dismiss];
        
        if (error) {
            [self onGetRemoteHistoryFailed:@"发生了错误".ntes_localized];
            return;
        }
        if (remoteFilePath.length == 0) {
            [self onGetRemoteHistoryFailed:@"未找到消息备份。请先在旧设备上导出消息记录".ntes_localized];
            return;
        }
        
        [self onGetHistorySuccessWithRemotePath:remoteFilePath secureKey:secureKey];
    }];
}

#pragma mark -- private
- (void)onGetHistorySuccessWithRemotePath:(NSString *)remotePath secureKey:(NSString *)secureKey {
    NTESImportMessageViewController *importController = [[NTESImportMessageViewController alloc] init];
    importController.remoteFilePath = remotePath;
    importController.secureKey = secureKey;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:importController];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)onGetRemoteHistoryFailed:(NSString *)errorDescription {
    [self.view makeToast:errorDescription duration:3.0 position:CSToastPositionCenter];
}

@end
