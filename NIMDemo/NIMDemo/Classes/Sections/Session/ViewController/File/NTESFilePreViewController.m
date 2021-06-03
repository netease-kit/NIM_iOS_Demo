//
//  NTESFilePreViewController.m
//  NIM
//
//  Created by chris on 15/4/21.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NTESFilePreViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
@interface NTESFilePreViewController ()<NIMChatManagerDelegate>

@property(nonatomic,strong)NIMFileObject *fileObject;

@property(nonatomic,strong)UIDocumentInteractionController *interactionController;

@property(nonatomic,assign)BOOL isDownLoading;

@end

@implementation NTESFilePreViewController

- (instancetype)initWithFileObject:(NIMFileObject*)object{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _fileObject = object;
        [[NIMSDK sharedSDK].chatManager addDelegate:self];
    }
    return self;
}

- (void)dealloc{
    [[NIMSDK sharedSDK].chatManager cancelFetchingMessageAttachment:_fileObject.message];
    [[NIMSDK sharedSDK].chatManager removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = self.fileObject.displayName;
    self.fileNameLabel.text   = self.fileObject.displayName;
    NSString *filePath = self.fileObject.path;
    self.progressView.hidden = YES;
    [self.actionBtn addTarget:self action:@selector(touchUpBtn) forControlEvents:UIControlEventTouchUpInside];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [self.actionBtn setTitle:@"用其他应用程序打开".ntes_localized forState:UIControlStateNormal];
    }else{
        [self.actionBtn setTitle:@"下载文件".ntes_localized forState:UIControlStateNormal];
    }
}

- (void)touchUpBtn{
    NSString *filePath = self.fileObject.path;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [self openWithOtherApp];
    }else{
        if (self.isDownLoading) {
            [[NIMSDK sharedSDK].chatManager cancelFetchingMessageAttachment:self.fileObject.message];
            self.progressView.hidden   = YES;
            self.progressView.progress = 0.0;
            [self.actionBtn setTitle:@"下载文件".ntes_localized forState:UIControlStateNormal];
            self.isDownLoading         = NO;
        }else{
            [self downLoadFile];
        }
    }
}

#pragma mark - 文件下载

- (void)downLoadFile
{
    [[NIMSDK sharedSDK].chatManager fetchMessageAttachment:self.fileObject.message error:nil];
}

- (void)fetchMessageAttachment:(NIMMessage *)message
                      progress:(float)progress
{
    if ([message.messageId isEqualToString:self.fileObject.message.messageId])
    {
        self.isDownLoading = YES;
        self.progressView.hidden = NO;
        self.progressView.progress = progress;
        [self.actionBtn setTitle:@"取消下载".ntes_localized forState:UIControlStateNormal];
    }
}


- (void)fetchMessageAttachment:(NIMMessage *)message
          didCompleteWithError:(nullable NSError *)error
{
    if ([message.messageId isEqualToString:self.fileObject.message.messageId])
    {
        self.isDownLoading = NO;
        self.progressView.hidden = YES;
        if (!error)
        {
            [self.actionBtn setTitle:@"用其他应用程序打开".ntes_localized forState:UIControlStateNormal];
        }
        else
        {
            self.progressView.progress = 0.0f;
            [self.actionBtn setTitle:@"下载失败，点击重新下载".ntes_localized forState:UIControlStateNormal];
        }
    }
}


#pragma mark - 其他应用打开

- (void)openWithOtherApp{
    self.interactionController =
    [UIDocumentInteractionController
    interactionControllerWithURL:[NSURL fileURLWithPath:self.fileObject.path]];
    if (![self.interactionController presentOpenInMenuFromRect:self.view.frame inView:self.view animated:YES])
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"未找到打开该应用的程序".ntes_localized delegate:nil cancelButtonTitle:@"确定".ntes_localized otherButtonTitles: nil];
        [alert show];
    }
}

@end
