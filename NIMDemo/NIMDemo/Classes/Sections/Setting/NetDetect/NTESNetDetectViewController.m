//
//  NTESNetDetectViewController.m
//  NIM
//
//  Created by fenric on 16/12/20.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "NTESNetDetectViewController.h"

@interface NTESNetDetectViewController ()

@property (strong, nonatomic) UITextView *netDetectResultTextView;

@property (assign, nonatomic) UInt64 taskId;

@end

@implementation NTESNetDetectViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"音视频网络探测".ntes_localized;
    
    [self.view addSubview:self.netDetectResultTextView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"退出".ntes_localized style:UIBarButtonItemStyleDone target:self action:@selector(onDismiss:)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"探测".ntes_localized style:UIBarButtonItemStyleDone target:self action:@selector(onDetect:)];


}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.netDetectResultTextView.frame = self.view.bounds;
}

- (void)onDismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onDetect:(id)sender {
    
    if (self.taskId == 0) {
        static BOOL videoDetect = YES;
        __weak typeof (self) wself = self;
        self.taskId = [[NIMAVChatSDK sharedSDK].avchatNetDetectManager startDetectTaskForDetectType:NIMAVChatNetDetectType480P 
                                                                                    completion:^(NIMAVChatNetDetectResult * _Nonnull result) {
            wself.netDetectResultTextView.text = [NSString stringWithFormat:@"%@net detect result:\n%@\n------------\n", wself.netDetectResultTextView.text, result];
            wself.taskId = 0;
            [wself updateDetectButton];
        }];
        self.netDetectResultTextView.text = [self.netDetectResultTextView.text stringByAppendingString:[NSString stringWithFormat:@"start %@ net detect task id %llu \n------------\n", videoDetect ? @"video" : @"audio", self.taskId]];
        videoDetect = !videoDetect;
    }
    else {
        self.netDetectResultTextView.text = [self.netDetectResultTextView.text stringByAppendingString:[NSString stringWithFormat:@"stop net detect task id %llu \n------------\n", self.taskId]];
        [[NIMAVChatSDK sharedSDK].avchatNetDetectManager stopDetectTask:self.taskId];
        self.taskId = 0;
    }
    
    [self updateDetectButton];
}

- (void)updateDetectButton
{
    self.navigationItem.leftBarButtonItem.title = (self.taskId == 0) ? @"探测".ntes_localized : @"停止".ntes_localized;
}

- (UITextView *)netDetectResultTextView {
    if (!_netDetectResultTextView) {
        _netDetectResultTextView = [[UITextView alloc] initWithFrame:self.view.bounds];
        _netDetectResultTextView.font = [UIFont systemFontOfSize:14.0];
    }
    return _netDetectResultTextView;
}


@end
