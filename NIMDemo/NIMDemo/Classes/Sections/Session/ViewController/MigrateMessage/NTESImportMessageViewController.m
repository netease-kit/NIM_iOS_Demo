//
//  NTESImportMessageViewController.m
//  NIM
//
//  Created by Sampson on 2018/12/10.
//  Copyright © 2018 Netease. All rights reserved.
//

#import "NTESImportMessageViewController.h"
#import "NTESMigrateProgressView.h"
#import "NTESMigrateCompleteView.h"
#import "NSData+NTES.h"
#import "NTESImportMessageDelegateImpl.h"
#import <SSZipArchive/SSZipArchive.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "NTESMainTabController.h"

static NSString * const aesVectorString = @"0123456789012345";

@interface NTESImportMessageViewController ()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, weak) UIAlertController *curAlertController;

@end

@implementation NTESImportMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.3 alpha:1];
    self.title = @"本地消息导入".ntes_localized;
    
    NTESMigrateProgressView *progressView = [[NTESMigrateProgressView alloc] initWithFrame:self.view.bounds];
    [progressView.stopButton addTarget:self action:@selector(onCancelButton:) forControlEvents:UIControlEventTouchUpInside];
    progressView.tip = @"导入本地消息需要较长时间，请耐心等待".ntes_localized;
    self.contentView = progressView;
    
    [self downloadRemoteFile];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    const CGRect bounds = self.view.bounds;
    self.contentView.frame = bounds;
}

- (void)setContentView:(UIView *)contentView {
    if (_contentView == contentView) {
        return;
    }
    if (contentView) {
        [self.view addSubview:contentView];
    }
    if (_contentView) {
        [_contentView removeFromSuperview];
    }
    _contentView = contentView;
}

#pragma mark -- action
- (void)onCancelButton:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"确定要取消导入？".ntes_localized message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    // 取消导入
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"取消导入".ntes_localized style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
        [[NIMSDK sharedSDK].conversationManager cancelMigrateMessages];
    }];
    [alertController addAction:actionCancel];
    
    // 继续导入
    UIAlertAction *actionGoon = [UIAlertAction actionWithTitle:@"继续导入".ntes_localized style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertController addAction:actionGoon];
    
    //
    [self presentViewController:alertController animated:YES completion:nil];
    self.curAlertController = alertController;
}

- (void)onReturnButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // 返回到会话页
    NTESMainTabController *tabController = [NTESMainTabController instance];
    UIViewController *selectedVC = tabController.selectedViewController;
    if ([selectedVC isKindOfClass:[UINavigationController class]]) {
        [((UINavigationController *)selectedVC) popToRootViewControllerAnimated:NO];
    }
    tabController.selectedIndex = 0;
}

#pragma mark -- private
- (void)onImportFailed:(NSError *)error description:(NSString *)description {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"导入失败！".ntes_localized message:description preferredStyle:UIAlertControllerStyleAlert];
    
    // 返回
    UIAlertAction *actionReturn = [UIAlertAction actionWithTitle:@"返回".ntes_localized style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
        // todo 导航
    }];
    [alertController addAction:actionReturn];
    
    // 重新导入
    UIAlertAction *actionRetry = [UIAlertAction actionWithTitle:@"重新导入".ntes_localized style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
        [self downloadRemoteFile];
    }];
    [alertController addAction:actionRetry];
    
    //
    [self presentViewController:alertController animated:YES completion:nil];
    self.curAlertController = alertController;
}

- (void)onImportSuccess {
    NTESMigrateCompleteView *completeView = [[NTESMigrateCompleteView alloc] initWithFrame:self.view.bounds];
    completeView.title = @"恭喜你".ntes_localized;
    completeView.message = @"消息导入成功".ntes_localized;
    [completeView.actionButton setTitle:@"返回会话列表".ntes_localized forState:UIControlStateNormal];
    [completeView.actionButton addTarget:self action:@selector(onReturnButton:) forControlEvents:UIControlEventTouchUpInside];
    self.contentView = completeView;
}

#pragma mark --
- (void)downloadRemoteFile {
    [self removeTempFiles];
    NSString *aesFilePath = [self aesFilePath];
    [[NIMSDK sharedSDK].resourceManager download:self.remoteFilePath
                                        filepath:aesFilePath
                                        progress:nil
                                      completion:^(NSError * _Nullable error)
     {
         if (error) {
             [self onImportFailed:error description:@"下载消息文件失败".ntes_localized];
             return;
         }

         NSString *decrypedPath = self.secureKey ? [self decryptMeessageFileAtPath:aesFilePath] : aesFilePath;
         dispatch_async(dispatch_get_main_queue(), ^{
             NSString *unzipPath = [self unzipMessageFileAtPath:decrypedPath];
             [self importMessageFileAtPath:unzipPath];
             
             // 删除中间文件
             [[NSFileManager defaultManager] removeItemAtPath:aesFilePath error:nil];
         });
     }];
}

// 如果上传时候有加密，需要先解密
- (NSString *)decryptMeessageFileAtPath:(NSString *)path {
    @autoreleasepool {
        NSData *data = [NSData dataWithContentsOfFile:path];
        NSString *aesKey = self.secureKey;
        NSData *decryptedData = [data aes256DecryptWithKey:aesKey vector:aesVectorString];
        NSString *directory = [path stringByDeletingPathExtension];
        directory = [directory stringByDeletingLastPathComponent];
        NSString *decryptedPath = [directory stringByAppendingPathComponent:@"decryped"];
        decryptedPath = [decryptedPath stringByAppendingPathExtension:@"zip"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:decryptedPath]) {
            [[NSFileManager defaultManager] removeItemAtPath:decryptedPath error:nil];
        }
        [decryptedData writeToFile:decryptedPath atomically:YES];
        return decryptedPath;
    }
}

// 如果上传时候有压缩，解密完了之后要解压缩
- (NSString *)unzipMessageFileAtPath:(NSString *)path {
    NSString *dstPath = [path stringByDeletingPathExtension];
    dstPath = [dstPath stringByAppendingString:@"unzip"];
    BOOL unzipResult = [SSZipArchive unzipFileAtPath:path toDestination:dstPath];
    if (!unzipResult) {
        return nil;
    }
    
    //
    NSString *unzipPath = nil;
    BOOL directory = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:dstPath isDirectory:&directory]) {
        if (directory) {
            NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dstPath error:nil];
            unzipPath = files.count > 0 ? files[0] : nil;
            unzipPath = [dstPath stringByAppendingPathComponent:unzipPath];
        }
        else {
            unzipPath = dstPath;
        }
    }
    
    // 删掉中间文件
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    });
    
    return unzipPath;
}

- (void)importMessageFileAtPath:(NSString *)path {
    if (!path) {
        [self onImportFailed:nil description:@"解压失败".ntes_localized];
        return;
    }
    
    // 用户自定义的导入过滤器，对于 custom 消息，需要用户自己处理
    NTESImportMessageDelegateImpl *importImpl = [[NTESImportMessageDelegateImpl alloc] init];
    
    [[NIMSDK sharedSDK].conversationManager importMessageInfosAtPath:path
                                                            delegate:importImpl
                                                            progress:^(float progress)
    {
        //NSLog(@"import progress %f", progress);
        NTESMigrateProgressView *progressView = (NTESMigrateProgressView *)self.contentView;
        if ([progressView isKindOfClass:[NTESMigrateProgressView class]]) {
            progressView.progress = progress;
        }
    } completion:^(NSError * _Nullable error) {
        if (error) {
            [self onImportFailed:error description:@"合并失败".ntes_localized];
        }
        else {
            [self onImportSuccess];
        }
    }];
}

#pragma mark -- temp
- (NSString *)aesFilePath {
    NSString *ret = [NSTemporaryDirectory() stringByAppendingPathComponent:@"NIM"];
    ret = [ret stringByAppendingPathComponent:@"iOS-zip-aes256"];
    return ret;
}

- (void)removeTempFiles {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:[self aesFilePath] error:nil];
}

@end
