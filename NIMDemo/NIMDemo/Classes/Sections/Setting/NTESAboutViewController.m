//
//  NTESAboutViewController.m
//  NIM
//
//  Created by chris on 15/7/30.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NTESAboutViewController.h"
#import <UIView+Toast.h>

@interface NTESAboutViewController ()

@end

@implementation NTESAboutViewController

- (void)viewDidLoad {
   [super viewDidLoad];
    self.navigationItem.title = @"关于".ntes_localized;
    NSString *version = [NIMSDK sharedSDK].sdkVersion;
    self.versionLabel.text = [NSString stringWithFormat:@"%@：%@",@"版本号".ntes_localized, version];
    
    [self loadServerTime];
}


- (void)loadServerTime {
    __weak typeof(self) weakSelf = self;
    [[NIMSDK sharedSDK].loginManager queryServerTimeCompletion:^(NSError * _Nullable error, NIMServerTime * _Nonnull time) {
        if (error) {
            NSString *msg = [NSString stringWithFormat:@"%@：%zd",@"服务端时间查询失败".ntes_localized, error.code];
            [weakSelf.view makeToast:msg duration:2 position:CSToastPositionCenter];
        }
        weakSelf.serverTimeLabel.text = @(time.timestamp).stringValue;
    }];
}

@end
