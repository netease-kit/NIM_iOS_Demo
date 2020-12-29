//
//  NTESSettingViewController.m
//  NIM
//
//  Created by chris on 15/6/25.
//  Copyright © 2015年 Netease. All rights reserved.
//

#import "NTESSettingViewController.h"
#import "NIMCommonTableData.h"
#import "NIMCommonTableDelegate.h"
#import "SVProgressHUD.h"
#import "UIView+Toast.h"
#import "UIView+NTES.h"
#import "NTESBundleSetting.h"
#import "UIActionSheet+NTESBlock.h"
#import "UIAlertView+NTESBlock.h"
#import "NTESNotificationCenter.h"
#import "NTESCustomNotificationDB.h"
#import "NTESCustomSysNotificationViewController.h"
#import "NTESNoDisturbSettingViewController.h"
#import "NTESLogManager.h"
#import "NTESColorButtonCell.h"
#import "NTESAboutViewController.h"
#import "NTESUserInfoSettingViewController.h"
#import "NTESBlackListViewController.h"
#import "NTESUserUtil.h"
#import "NTESLogUploader.h"
#import "NTESSessionUtil.h"
#import "JRMFHeader.h"
#import "NTESMigrateMessageViewController.h"
#import "NTESCollectMessageListViewController.h"
#import <NIMSDK/NIMSDK.h>

@interface NTESSettingViewController ()<NIMUserManagerDelegate>

@property (nonatomic,strong) NSArray *data;
@property (nonatomic,strong) NTESLogUploader *logUploader;
@property (nonatomic,strong) NIMCommonTableDelegate *delegator;

@end

@implementation NTESSettingViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLayoutSubviews {
    if (@available(iOS 11.0, *)) {
        CGFloat height = self.view.safeAreaInsets.bottom;
        self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - height);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"设置".ntes_localized;
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
    
    extern NSString *NTESCustomNotificationCountChanged;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCustomNotifyChanged:) name:NTESCustomNotificationCountChanged object:nil];
    [[NIMSDK sharedSDK].userManager addDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NIMSDK sharedSDK].userManager removeDelegate:self];
}

- (void)buildData{
    BOOL disableRemoteNotification = [UIApplication sharedApplication].currentUserNotificationSettings.types == UIUserNotificationTypeNone;
    
    NIMPushNotificationSetting *setting = [[NIMSDK sharedSDK].apnsManager currentSetting];
    BOOL enableNoDisturbing     = setting.noDisturbing;
    NSString *noDisturbingStart = [NSString stringWithFormat:@"%02zd:%02zd",setting.noDisturbingStartH,setting.noDisturbingStartM];
    NSString *noDisturbingEnd   = [NSString stringWithFormat:@"%02zd:%02zd",setting.noDisturbingEndH,setting.noDisturbingEndM];
    
    NSInteger customNotifyCount = [[NTESCustomNotificationDB sharedInstance] unreadCount];
    NSString *customNotifyText  = [NSString stringWithFormat:@"%@ (%zd)",@"自定义系统通知".ntes_localized,customNotifyCount];

    NSString *uid = [[NIMSDK sharedSDK].loginManager currentAccount];
    NSArray *data = @[
                      @{
                          HeaderTitle:@"",
                          RowContent :@[
                                        @{
                                            ExtraInfo     : uid.length ? uid : [NSNull null],
                                            CellClass     : @"NTESSettingPortraitCell",
                                            RowHeight     : @(100),
                                            CellAction    : @"onActionTouchPortrait:",
                                            ShowAccessory : @(YES)
                                         },
                                       ],
                          FooterTitle:@""
                       },
                      @{
                          HeaderTitle:@"",
                          RowContent :@[
                                  @{
                                      Title         : @"我的收藏".ntes_localized,
                                      CellAction    : @"onTouchMyCollection:",
                                      ShowAccessory : @(YES),
                                   },
                                  @{
                                      Title         : @"我的钱包".ntes_localized,
                                      CellAction    : @"onTouchMyWallet:",
                                      ShowAccessory : @(YES),
                                      },
                                  ],
                          },
                       @{
                          HeaderTitle:@"",
                          RowContent :@[
                                           @{
                                              Title      :@"消息提醒".ntes_localized,
                                              DetailTitle:disableRemoteNotification ? @"未开启".ntes_localized : @"已开启".ntes_localized,
                                            },
                                        ],
                          FooterTitle:@"在iPhone的“设置- 通知中心”功能，找到应用程序“云信”，可以更改云信新消息提醒设置".ntes_localized
                        },
                        @{
                          HeaderTitle:@"",
                          RowContent :@[
                                          @{
                                              Title        : @"通知显示详情".ntes_localized,
                                              CellClass    : @"NTESSettingSwitcherCell",
                                              ExtraInfo    : @(setting.type == NIMPushNotificationDisplayTypeDetail? YES : NO),
                                              CellAction   : @"onActionShowPushDetailSetting:",
                                              ForbidSelect : @(YES)
                                           },
                                      ],
                          FooterTitle:@""
                          },
                       @{
                          HeaderTitle:@"",
                          RowContent :@[
                                       @{
                                          Title      :@"免打扰".ntes_localized,
                                          DetailTitle:enableNoDisturbing ? [NSString stringWithFormat:@"%@%@%@",noDisturbingStart,@"到".ntes_localized,noDisturbingEnd] : @"未开启".ntes_localized,
                                          CellAction :@"onActionNoDisturbingSetting:",
                                          ShowAccessory : @(YES)
                                        },
                                  ],
                          FooterTitle:@""
                        },
                       @{
                          HeaderTitle:@"",
                          RowContent :@[
                                        @{
                                          Title      :@"查看日志".ntes_localized,
                                          CellAction :@"onTouchShowLog:",
                                          },
                                        @{
                                            Title      :@"上传日志".ntes_localized,
                                            CellAction :@"onTouchUploadLog:",
                                            },
                                        @{
                                            Title      :@"清理缓存".ntes_localized,
                                            CellAction :@"onTouchCleanCache:",
                                            },
                                        @{
                                            Title      :customNotifyText,
                                            CellAction :@"onTouchCustomNotify:",
                                          },
                                        @{
                                            Title      :@"本地消息迁移".ntes_localized,
                                            CellAction :@"onTouchMigrateMessages:",
                                            ShowAccessory : @(YES),
                                            
                                            },
                                        @{
                                            Title      :@"关于".ntes_localized,
                                            CellAction :@"onTouchAbout:",
                                          },
                                      ],
                          FooterTitle:@""
                        },
                      @{
                          HeaderTitle:@"",
                          RowContent :@[
                                          @{
                                              Title        : @"注销".ntes_localized,
                                              CellClass    : @"NTESColorButtonCell",
                                              CellAction   : @"logoutCurrentAccount:",
                                              ExtraInfo    : @(ColorButtonCellStyleRed),
                                              ForbidSelect : @(YES)
                                            },
                                       ],
                          FooterTitle:@"",
                          },
                    ];
    self.data = [NIMCommonTableSection sectionsWithData:data];
}

- (void)refreshData{
    [self buildData];
    [self.tableView reloadData];
}


#pragma mark - Action

- (void)onActionTouchPortrait:(id)sender{
    NTESUserInfoSettingViewController *vc = [[NTESUserInfoSettingViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onActionNoDisturbingSetting:(id)sender {
    NTESNoDisturbSettingViewController *vc = [[NTESNoDisturbSettingViewController alloc] initWithNibName:nil bundle:nil];
    __weak typeof(self) wself = self;
    vc.handler = ^(){
        [wself refreshData];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onActionShowPushDetailSetting:(UISwitch *)switcher
{
    NIMPushNotificationSetting *setting = [NIMSDK sharedSDK].apnsManager.currentSetting;
    setting.type = switcher.on? NIMPushNotificationDisplayTypeDetail : NIMPushNotificationDisplayTypeNoDetail;
    __weak typeof(self) wself = self;
    [[NIMSDK sharedSDK].apnsManager updateApnsSetting:setting completion:^(NSError * _Nullable error) {
        if (error)
        {
            [wself.view makeToast:@"更新失败".ntes_localized duration:2.0 position:CSToastPositionCenter];
            switcher.on = !switcher.on;
        }
    }];
}


- (void)onTouchShowLog:(id)sender{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"查看日志".ntes_localized delegate:nil cancelButtonTitle:@"取消".ntes_localized destructiveButtonTitle:nil otherButtonTitles:@"查看 DEMO 配置".ntes_localized,@"查看 SDK 日志".ntes_localized,@"查看 Demo 日志".ntes_localized, nil];
    [actionSheet showInView:self.view completionHandler:^(NSInteger index) {
        switch (index) {
            case 0:
                [self showDemoConfig];
                break;
            case 1:
                [self showSDKLog];
                break;
            case 2:
                [self showDemoLog];
                break;
            default:
                break;
        }
    }];
}

- (void)onTouchUploadLog:(id)sender{
    if (_logUploader == nil) {
        _logUploader = [[NTESLogUploader alloc] init];
    }
    
    [SVProgressHUD show];
    
    __weak typeof(self) weakSelf = self;
    [[NIMSDK sharedSDK] uploadLogsWithAttach:@"attach"
                                      roomId:nil
                                  completion:^(NSError * error, NSString * logUrl)
     {
        __strong typeof(weakSelf) strongSelf = weakSelf;

        if (error || !logUrl)
        {
            [strongSelf.view makeToast:@"上传日志失败".ntes_localized duration:3.0 position:CSToastPositionCenter];
            [SVProgressHUD dismiss];
            return;
        }
        
        [[NIMSDK sharedSDK].resourceManager fetchNOSURLWithURL:logUrl completion:^(NSError * _Nullable error, NSString * _Nullable urlString)
        {
            [SVProgressHUD dismiss];
            if (error || !urlString)
            {
                [strongSelf.view makeToast:@"上传日志失败".ntes_localized duration:3.0 position:CSToastPositionCenter];
                return;
            }
            [UIPasteboard generalPasteboard].string = urlString;
            [strongSelf.view makeToast:@"上传日志成功,URL已复制到剪切板中".ntes_localized duration:3.0 position:CSToastPositionCenter];
        }];
    }];
}


- (void)onTouchCleanCache:(id)sender
{
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"" message:@"清除后，图片、视频等多媒体消息需要重新下载查看。确定清除？".ntes_localized preferredStyle:UIAlertControllerStyleActionSheet];
    [[vc addAction:@"清除".ntes_localized style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        NIMResourceQueryOption *option = [[NIMResourceQueryOption alloc] init];
        option.timeInterval = 0;
        [SVProgressHUD show];
        [[NIMSDK sharedSDK].resourceManager removeResourceFiles:option completion:^(NSError * _Nullable error, long long freeBytes) {
            [SVProgressHUD dismiss];
            if (error)
            {
                UIAlertController *result = [UIAlertController alertControllerWithTitle:@"" message:@"清除失败！".ntes_localized preferredStyle:UIAlertControllerStyleAlert];
                [result addAction:@"确定".ntes_localized style:UIAlertActionStyleCancel handler:nil];
                [result show];
            }
            else
            {
                CGFloat freeMB = (CGFloat)freeBytes / 1000 / 1000;
                UIAlertController *result = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"%@%.2fMB%@",@"成功清理了".ntes_localized, freeMB, @"磁盘空间".ntes_localized] preferredStyle:UIAlertControllerStyleAlert];
                [result addAction:@"确定".ntes_localized style:UIAlertActionStyleCancel handler:nil];
                [result show];
            }
        }];
    }]
     addAction:@"取消".ntes_localized style:UIAlertActionStyleCancel handler:nil];
    
    [vc show];
}

- (void)onTouchMyCollection:(id)sender
{
    NTESCollectMessageListViewController *vc = [[NTESCollectMessageListViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onTouchMyWallet:(id)sender
{
    JrmfWalletSDK * jrmf = [[JrmfWalletSDK alloc] init];
    NSString *userId = [[NIMSDK sharedSDK].loginManager currentAccount];
    NIMKitInfo *userInfo = [[NIMKit sharedKit] infoByUser:userId option:nil];
    [jrmf doPresentJrmfWalletPageWithBaseViewController:self userId:userId userName:userInfo.showName userHeadLink:userInfo.avatarUrlString thirdToken:[JRMFSington GetPacketSington].JrmfThirdToken];
}

- (void)onTouchCustomNotify:(id)sender{
    NTESCustomSysNotificationViewController *vc = [[NTESCustomSysNotificationViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onTouchAbout:(id)sender{
    NTESAboutViewController *about = [[NTESAboutViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:about animated:YES];
}

- (void)logoutCurrentAccount:(id)sender{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"退出当前帐号？".ntes_localized message:nil delegate:nil cancelButtonTitle:@"取消".ntes_localized otherButtonTitles:@"确定".ntes_localized, nil];
    [alert showAlertWithCompletionHandler:^(NSInteger alertIndex) {
        switch (alertIndex) {
            case 1:
                [[[NIMSDK sharedSDK] loginManager] logout:^(NSError *error)
                 {
                     extern NSString *NTESNotificationLogout;
                     [[NSNotificationCenter defaultCenter] postNotificationName:NTESNotificationLogout object:nil];
                 }];
                break;
            default:
                break;
        }
    }];
}

- (void)onTouchMigrateMessages:(id)sender {
    NTESMigrateMessageViewController *migrateMessageController = [[NTESMigrateMessageViewController alloc] init];
    [self.navigationController pushViewController:migrateMessageController animated:YES];
}

#pragma mark - Notification
- (void)onCustomNotifyChanged:(NSNotification *)notification
{
    [self buildData];
    [self.tableView reloadData];
}


#pragma mark - NIMUserManagerDelegate
- (void)onUserInfoChanged:(NIMUser *)user
{
    if ([user.userId isEqualToString:[[NIMSDK sharedSDK].loginManager currentAccount]]) {
        [self buildData];
        [self.tableView reloadData];
    }
}


#pragma mark - Private

- (void)showSDKLog{
    UIViewController *vc = [[NTESLogManager sharedManager] sdkLogViewController];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav
                       animated:YES
                     completion:nil];
}

- (void)showDemoLog{
    UIViewController *logViewController = [[NTESLogManager sharedManager] demoLogViewController];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:logViewController];
    [self presentViewController:nav
                       animated:YES
                     completion:nil];
}

- (void)showDemoConfig {
    UIViewController *logViewController = [[NTESLogManager sharedManager] demoConfigViewController];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:logViewController];
    [self presentViewController:nav
                       animated:YES
                     completion:nil];
}

#pragma mark - 旋转处理 (iOS7)
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.tableView reloadData];
}


@end
