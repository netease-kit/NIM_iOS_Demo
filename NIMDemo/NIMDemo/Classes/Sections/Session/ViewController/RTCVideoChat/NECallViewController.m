//
//  NECallViewController.m
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/8/21.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NECallViewController.h"
#import "NECustomButton.h"
#import "NEVideoOperationView.h"
#import <Toast/UIView+Toast.h>
#import <UIImageView+WebCache.h>
#import <AVFoundation/AVFoundation.h>

@interface NECallViewController ()
@property(strong,nonatomic)NEVideoView *smallVideoView;
@property(strong,nonatomic)NEVideoView *bigVideoView;
@property(strong,nonatomic)UIImageView *remoteAvatorView;
@property(strong,nonatomic)UILabel *titleLabel;
@property(strong,nonatomic)UILabel *subTitleLabel;
@property(strong,nonatomic)UIButton *switchCameraBtn;
//@property(strong,nonatomic)UIButton *callTypeBtn;
/// 取消呼叫
@property(strong,nonatomic)NECustomButton *cancelBtn;
/// 拒绝接听
@property(strong,nonatomic)NECustomButton *rejectBtn;
/// 接听
@property(strong,nonatomic)NECustomButton *acceptBtn;
@property(strong,nonatomic)NEVideoOperationView *operationView;
@property(assign,nonatomic)NERtcCallType type;
@property(assign,nonatomic)NERtcCallStatus status;
/// 对方账号
@property(strong,nonatomic)NSString *otherUserID;
/// 自己账号
@property(strong,nonatomic)NSString *myselfID;

@property (nonatomic,strong) AVAudioPlayer *player; //播放提示音

@property (nonatomic,assign) NSInteger statsCount; // 计算网络统计次数，前3次产生误差，忽略
@property (nonatomic,strong) UILabel *statsLabel; // 显示网络异常状态
@property (nonatomic,strong) UILabel *connectingLabel; // 显示正在接通
@property (nonatomic,assign) BOOL isCalled;

@end

@implementation NECallViewController
- (instancetype)initWithOtherMember:(NSString *)member isCalled:(BOOL)isCalled type:(NERtcCallType)type {
    self = [super init];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationFullScreen;
        self.isCalled = isCalled;
        if (isCalled) {
            self.status = NERtcCallStatusCalled;
        }else {
            self.status = NERtcCallStatusCalling;
        }
        self.type = type;
        self.otherUserID = member;
        self.myselfID = [NIMSDK sharedSDK].loginManager.currentAccount;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self setupSDK];
    [self updateUIStatus:self.status];
    [self.player play];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.player stop];
}
#pragma mark - SDK
- (void)setupSDK {
    [[NERtcCallKit sharedInstance] addDelegate:self];
    [NERtcCallKit sharedInstance].timeOutSeconds = 30;
    if (self.status == NERtcCallStatusCalling) {
        WEAK_SELF(weakSelf);
        NSLog(@"CallVC: Start call: %@", self.otherUserID);
        [[NERtcCallKit sharedInstance] call:self.otherUserID type:self.type completion:^(NSError * _Nullable error) {
            STRONG_SELF(strongSelf);
            [self setupLocalView];
            if (error) {
                [strongSelf.view makeToast:error.localizedDescription];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [strongSelf destroy];
                });
            }
        }];
    }
}

#pragma mark - UI
- (void)setupUI {
    [self.view addSubview:self.bigVideoView];
    CGFloat statusHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    [self.bigVideoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.mas_equalTo(0);
        make.size.mas_equalTo([UIScreen mainScreen].bounds.size);
    }];
    [self.view addSubview:self.switchCameraBtn];
    [self.switchCameraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(statusHeight + 20);
        make.left.mas_equalTo(20);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
//    [self.view addSubview:self.callTypeBtn];
//    [self.callTypeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(self.switchCameraBtn.mas_top);
//        make.leading.mas_equalTo(self.switchCameraBtn.mas_trailing).offset(10);
//        make.size.mas_equalTo(CGSizeMake(30, 30));
//    }];
    [self.view addSubview:self.smallVideoView];
    [self.smallVideoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(statusHeight + 20);
        make.right.mas_equalTo(-20);
        make.size.mas_equalTo(CGSizeMake(90, 160));
    }];
    [self.view addSubview:self.remoteAvatorView];
    [self.remoteAvatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(statusHeight + 20);
        make.right.mas_equalTo(self.view.mas_right).offset(-20);
        make.size.mas_equalTo(CGSizeMake(60, 60));
    }];
    [self.view addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.remoteAvatorView.mas_top).offset(5);
        make.right.mas_equalTo(self.remoteAvatorView.mas_left).offset(-8);
        make.left.mas_equalTo(60);
        make.height.mas_equalTo(25);
    }];
    [self.view addSubview:self.subTitleLabel];
    [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom);
        make.right.mas_equalTo(self.titleLabel.mas_right);
        make.left.mas_equalTo(self.titleLabel.mas_left);
        make.height.mas_equalTo(20);
    }];
    
    /// 取消按钮
    [self.view addSubview:self.cancelBtn];
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-80);
        make.size.mas_equalTo(CGSizeMake(75, 103));
    }];
    // 正在接通
    [self.view addSubview:self.connectingLabel];
    [self.connectingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.view.mas_leading);
        make.trailing.mas_equalTo(self.view.mas_trailing);
        make.bottom.mas_equalTo(self.cancelBtn.mas_top).mas_offset(-20);
    }];
    /// 接听和拒接按钮
    [self.view addSubview:self.rejectBtn];
    [self.rejectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(- self.view.frame.size.width/4.0);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-80);
        make.size.mas_equalTo(CGSizeMake(75, 103));
    }];
    [self.view addSubview:self.acceptBtn];
    [self.acceptBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.frame.size.width/4.0);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-80);
        make.size.mas_equalTo(CGSizeMake(75, 103));
    }];
    [self.view addSubview:self.operationView];
    [self.operationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(44 + 3 * 60, 60));
        make.bottom.mas_equalTo(-50);
    }];
    [self.view addSubview:self.statsLabel];
    [self.statsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.view.mas_leading);
        make.trailing.mas_equalTo(self.view.mas_trailing);
        make.bottom.mas_equalTo(self.operationView.mas_top).mas_offset(-20);
    }];
}

- (void)updateUIStatus:(NERtcCallStatus)status {
    switch (status) {
        case NERtcCallStatusCalling:
        {
            self.titleLabel.text = [NSString stringWithFormat:@"正在呼叫 %@",self.otherUserID];
            self.subTitleLabel.text = @"等待对方接听……";
            self.remoteAvatorView.hidden = NO;
            self.smallVideoView.hidden = YES;
            self.cancelBtn.hidden = NO;
            self.rejectBtn.hidden = YES;
            self.acceptBtn.hidden = YES;
            self.switchCameraBtn.hidden = YES;
            self.operationView.hidden = YES;
//            self.callTypeBtn.hidden = YES;
        }
            break;
        case NERtcCallStatusCalled:
        {
            self.titleLabel.text = [NSString stringWithFormat:@"%@",self.otherUserID];
            self.remoteAvatorView.hidden = NO;
            self.subTitleLabel.text = self.type == NERtcCallTypeVideo? @"邀请您视频通话":@"邀请您语音通话";
            self.smallVideoView.hidden = YES;
            self.cancelBtn.hidden = YES;
            self.rejectBtn.hidden = NO;
            self.acceptBtn.hidden = NO;
            self.switchCameraBtn.hidden = YES;
            self.operationView.hidden = YES;
//            self.callTypeBtn.hidden = YES;
        }
            break;
        case NERtcCallStatusInCall:
        {
            self.operationView.hidden = NO;
            if (self.type == NERtcCallTypeVideo) {
                self.titleLabel.hidden = YES;
                self.subTitleLabel.hidden = YES;
                self.switchCameraBtn.hidden = NO;
                
                self.operationView.cameraBtn.hidden = NO;
                self.operationView.switchAudio.hidden = NO;
                [self.operationView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.centerX.mas_equalTo(self.view.mas_centerX);
                    make.size.mas_equalTo(CGSizeMake(44 + 60 * 4, 60));
                    make.bottom.mas_equalTo(-50);
                }];
                
            }else {
                self.titleLabel.text = [NSString stringWithFormat:@"%@",self.otherUserID];
                self.subTitleLabel.text = @"正在语音通话";
                self.titleLabel.hidden = NO;
                self.subTitleLabel.hidden = NO;
                self.operationView.cameraBtn.hidden = YES;
                self.operationView.switchAudio.hidden = YES;
                [self.operationView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.centerX.mas_equalTo(self.view.mas_centerX);
                    make.size.mas_equalTo(CGSizeMake(44 + 60 * 2, 60));
                    make.bottom.mas_equalTo(-50);
                }];
                self.switchCameraBtn.hidden = YES;
            }
            self.smallVideoView.hidden = NO;
            self.remoteAvatorView.hidden = YES;
            self.cancelBtn.hidden = YES;
            self.rejectBtn.hidden = YES;
            self.acceptBtn.hidden = YES;
        }
            break;
        default:
            break;
    }
}

#pragma mark - event
- (void)cancelEvent:(NECustomButton *)button {
    WEAK_SELF(weakSelf);
    [[NERtcCallKit sharedInstance] hangup:^(NSError * _Nullable error) {
        STRONG_SELF(strongSelf);
        [strongSelf.view makeToast:error.localizedDescription];
    }];
    [self destroy];
}

- (void)rejectEvent:(NECustomButton *)button {
    self.acceptBtn.enabled = NO;
    WEAK_SELF(weakSelf);
    switch (button.tag) {
        case 0: { // 拒绝
            [[NERtcCallKit sharedInstance] reject:^(NSError * _Nullable error) {
                STRONG_SELF(strongSelf);
                strongSelf.acceptBtn.enabled = YES;
                [strongSelf destroy];
            }];
            break;
        }
        case 1: { // 挂断
            [[NERtcCallKit sharedInstance] hangup:^(NSError * _Nullable error) {
                STRONG_SELF(strongSelf);
                strongSelf.acceptBtn.enabled = YES;
                [strongSelf destroy];
            }];
        }
        default:
            break;
    }
}

- (void)acceptEvent:(NECustomButton *)button {
    self.acceptBtn.enabled = NO;
    self.connectingLabel.hidden = NO;
    self.rejectBtn.tag = 1; // 给拒绝按钮打个标签，再点击拒绝等同于挂断
    WEAK_SELF(weakSelf);
    [[NERtcCallKit sharedInstance] accept:^(NSError * _Nullable error) {
        STRONG_SELF(strongSelf);
        if (error) {
            strongSelf.connectingLabel.hidden = YES;
            strongSelf.acceptBtn.enabled = YES;
            NSString *errorToast = [NSString stringWithFormat:@"接听失败%@",error.localizedDescription];
            [strongSelf.view.window makeToast:errorToast];
            [strongSelf destroy];
        } else {
            [strongSelf.player stop];
        }
    }];
}

- (void)switchCallTypeEvent:(UIButton *)button {
//    button.enabled = NO;
    NERtcCallType newType = self.type == NERtcCallTypeVideo ? NERtcCallTypeAudio : NERtcCallTypeVideo;
    __weak typeof(self) wself = self;
    [NERtcCallKit.sharedInstance switchCallType:newType completion:^(NSError * _Nullable error) {
        __strong typeof(wself) sself = wself;
        if (!sself) return;
        if (error) {
            [sself.view makeToast:error.localizedDescription];
            return;
        }
        [sself handleCallTypeChange:newType];
    }];
}

- (void)switchCameraBtn:(UIButton *)button {
    [[NERtcCallKit sharedInstance] switchCamera];
}

- (void)microPhoneClick:(UIButton *)button {
    button.selected = !button.selected;
    [[NERtcCallKit sharedInstance] muteLocalAudio:button.selected];
}

- (void)cameraBtnClick:(UIButton *)button {
    button.selected = !button.selected;
    
    BOOL enable = !button.selected;
    [[NERtcCallKit sharedInstance] enableLocalVideo:enable];
    [self cameraAvailble:enable userId:self.myselfID];
    if (enable) {
        self.statsCount = 0; // 打开摄像头后会有正常的统计数据波动，同样忽略前3次统计
    }
}

- (void)hangupBtnClick:(UIButton *)button {
    [[NERtcCallKit sharedInstance] hangup:^(NSError * _Nullable error) {
        [self destroy];
    }];
}

#pragma mark - NERtcCallKitDelegate

- (void)onUserEnter:(NSString *)userID {
    self.otherUserID = userID;
    self.statsCount = 0;
    if (self.type == NERtcCallTypeAudio) {
        self.connectingLabel.hidden = YES;
        [self updateUIStatus:NERtcCallStatusInCall];
    }
}

- (void)onFirstVideoFrameDecoded:(NSString *)userID width:(uint32_t)width height:(uint32_t)height {
    self.connectingLabel.hidden = YES;
    if (self.isCalled) {
        [self setupLocalView];
    }
    [self setupRemoteView];
    [self updateUIStatus:NERtcCallStatusInCall];
    [self becomeBigVideoView:self.smallVideoView];
}

- (void)onUserAccept:(NSString *)userID {
    NSLog(@"CallVC: User %@ accept", userID);
    [self.player stop];
    self.connectingLabel.hidden = NO;
    self.cancelBtn.enabled = NO;
}
- (void)onUserCancel:(NSString *)userID {
    [[NERtcCallKit sharedInstance] hangup:nil];
    [self destroy];
}
- (void)onCameraAvailable:(BOOL)available userID:(NSString *)userID {
    [self cameraAvailble:available userId:userID];
}
- (void)onCallingTimeOut {
    [self.view.window makeToast:@"对方无响应"];
    [self destroy];
}

- (void)onUserBusy:(NSString *)userID {
    [self.view.window makeToast:@"对方正在通话中"];
    [self destroy];

}
- (void)onCallEnd {
    [self destroy];
}
- (void)onUserReject:(NSString *)userID {
    [self.view.window makeToast:@"对方拒绝了您的邀请"];
    [self destroy];
}

- (void)onUserLeave:(NSString *)userID {
    [self.view.window makeToast:@"对方已离开"];
    [NERtcCallKit.sharedInstance hangup:^(NSError * _Nullable error) {
        [self destroy];
    }];
}

- (void)onUserDisconnect:(NSString *)userID {
    [self.view.window makeToast:@"对方已断开"];
    [NERtcCallKit.sharedInstance hangup:^(NSError * _Nullable error) {
        [self destroy];
    }];
}

- (void)onCallTypeChange:(NERtcCallType)callType {
    [self handleCallTypeChange:callType];
}

- (void)onUserNetworkQuality:(NSDictionary<NSString *,NERtcNetworkQualityStats *> *)stats {
    NERtcNetworkQualityStats *otherUserStat = stats[self.otherUserID?:@""];
    if (!otherUserStat) {
        return;
    }
    if (self.statsCount++ < 3) { // 忽略前3次统计
        return;
    }
//    NSLog(@"%@", @(otherUserStat.txQuality));
    switch (otherUserStat.txQuality) {
        case kNERtcNetworkQualityUnknown: {
            self.statsLabel.text = @"对方网络状态可能较差";
            self.statsLabel.hidden = NO;
            break;
        }
        case kNERtcNetworkQualityBad:
        case kNERtcNetworkQualityVeryBad: {
            self.statsLabel.text = @"对方可能网络状态不佳";
            self.statsLabel.hidden = NO;
            break;
        }
        case kNERtcNetworkQualityDown: {
            self.statsLabel.text = @"对方可能网络状态非常差";
            self.statsLabel.hidden = NO;
            break;
        }
        default:
            self.statsLabel.hidden = YES;
            break;
    }
}

- (void)onDisconnect:(NSError *)reason {
    [self.view.window makeToast:@"您已断开连接"];
    [self destroy];
}

- (void)onOtherClientAccept {
    [self.view.window makeToast:@"已在其他设备接听"];
    [self destroy]; // 已被其他端处理
}

- (void)onOtherClientReject {
    [self destroy]; // 已被其他端处理
}

#pragma mark - NEVideoViewDelegate
- (void)didTapVideoView:(NEVideoView *)videoView {
    if (videoView.isSmall) {
        [self becomeBigVideoView:videoView];
    }
}

#pragma mark - private mothed
- (void)becomeBigVideoView:(NEVideoView *)videoView {
    [videoView becomeBig];
    
    NSInteger frontIndex = 0;
    NSInteger backIndex = 0;
    NEVideoView *forwardView = [videoView isEqual:self.bigVideoView]?self.smallVideoView:self.bigVideoView;
    for (int i = 0; i < self.view.subviews.count; i ++) {
        UIView *view = self.view.subviews[i];
        if ([view isEqual:videoView]) {
            backIndex = i;
        }
        if ([view isEqual:forwardView]) {
            frontIndex = i;
        }
    }
    [self.view exchangeSubviewAtIndex:frontIndex withSubviewAtIndex:backIndex];
    
    [forwardView becomeSmall];
}
//铃声 - 接收方铃声
- (void)ring
{
    [self.player stop];
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"video_chat_tip_receiver" withExtension:@"aac"];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    NSError *error;
    [AVAudioSession.sharedInstance setCategory:AVAudioSessionCategorySoloAmbient withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:&error];
    if (error) {
        NSLog(@"Error changing audio session category: %@", error.localizedDescription);
    }
    self.player.numberOfLoops = 30;
    [self.player play];
}
- (void)cameraAvailble:(BOOL)available userId:(NSString *)userId {
    NSLog(@"CallVC: User %@ camera did %@", userId, available ? @"Start" : @"Stop");
    NSString *tips = [self.myselfID isEqualToString:userId]?@"关闭了摄像头":@"对方关闭了摄像头";
    BOOL tipForceHidden = self.type == NERtcCallTypeAudio;
    if ([self.bigVideoView.userID isEqualToString:userId]) {
        self.bigVideoView.titleLabel.hidden = available || tipForceHidden;
        self.bigVideoView.titleLabel.text = tips;
    }
    if ([self.smallVideoView.userID isEqualToString:userId]) {
        self.smallVideoView.titleLabel.hidden = available || tipForceHidden;
        self.smallVideoView.titleLabel.text = tips;
    }
}

- (void)setupLocalView {
    if (self.type == NERtcCallTypeVideo) {
       [[NERtcCallKit sharedInstance] setupLocalView:self.bigVideoView.videoView];
       self.bigVideoView.userID = self.myselfID;
    }
}
- (void)setupRemoteView {
    if (self.type == NERtcCallTypeVideo) {
       [[NERtcCallKit sharedInstance] setupRemoteView:self.smallVideoView.videoView forUser:self.otherUserID];
       self.smallVideoView.userID = self.otherUserID;
    }
}
- (void)handleCallTypeChange:(NERtcCallType)type {
    self.type = type;
    BOOL isAudioType = type == NERtcCallTypeAudio; // 音频类型不提示关闭摄像头
    self.bigVideoView.titleLabel.hidden = isAudioType;
    self.smallVideoView.titleLabel.hidden = isAudioType;
//    [self.callTypeBtn setImage:[UIImage imageNamed:isAudioType?@"call_switch_video":@"call_switch_audio"] forState:UIControlStateNormal];
    NSString *toast = [NSString stringWithFormat:@"已切换为%@", type==NERtcCallTypeAudio?@"音频通话":@"视频通话"];
    [self.view makeToast:toast];
    [self updateUIStatus:NERtcCallStatusInCall];
    if (isAudioType) {
        [self.smallVideoView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.bigVideoView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    } else {
        self.statsCount = 0;
        [NERtcCallKit.sharedInstance setupLocalView:self.smallVideoView];
        [NERtcCallKit.sharedInstance setupRemoteView:self.bigVideoView forUser:self.otherUserID];
    }
}

#pragma mark - destroy
- (void)destroy {
    if (self.player) {
        [self.player stop];
        self.player = nil;
    }
    if (self && [self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
        [self dismissViewControllerAnimated:YES completion:^{
            if (self.dismissCompletion) {
                self.dismissCompletion();
            }
        }];
    }
    [[NERtcCallKit sharedInstance] setupLocalView:nil];
    [[NERtcCallKit sharedInstance] removeDelegate:self];
}
#pragma mark - property
- (NEVideoView *)bigVideoView {
    if (!_bigVideoView) {
        _bigVideoView = [[NEVideoView alloc] init];
        _bigVideoView.isSmall = NO;
        _bigVideoView.delegate = self;
    }
    return _bigVideoView;
}
- (NEVideoView *)smallVideoView {
    if (!_smallVideoView) {
        _smallVideoView = [[NEVideoView alloc] init];
        _smallVideoView.isSmall = YES;
        _smallVideoView.delegate = self;
    }
    return _smallVideoView;
}
- (UIImageView *)remoteAvatorView {
    if (!_remoteAvatorView) {
        _remoteAvatorView = [[UIImageView alloc] init];
        _remoteAvatorView.image = [UIImage imageNamed:@"avator"];
    }
    return _remoteAvatorView;
}
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont boldSystemFontOfSize:18];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentRight;
    }
    return _titleLabel;
}
- (UILabel *)subTitleLabel {
    if (!_subTitleLabel) {
        _subTitleLabel = [[UILabel alloc] init];
        _subTitleLabel.font = [UIFont boldSystemFontOfSize:14];
        _subTitleLabel.textColor = [UIColor whiteColor];
        _subTitleLabel.text = @"等待对方接听……";
        _subTitleLabel.textAlignment = NSTextAlignmentRight;
    }
    return _subTitleLabel;
}

- (UILabel *)statsLabel {
    if (!_statsLabel) {
        _statsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _statsLabel.font = [UIFont systemFontOfSize:14];
        _statsLabel.textColor = [UIColor whiteColor];
        _statsLabel.textAlignment = NSTextAlignmentCenter;
        _statsLabel.hidden = YES;
    }
    return _statsLabel;
}

- (NECustomButton *)cancelBtn {
    if (!_cancelBtn) {
        _cancelBtn = [[NECustomButton alloc] init];
        _cancelBtn.titleLabel.text = @"取消";
        _cancelBtn.imageView.image = [UIImage imageNamed:@"call_cancel"];
        [_cancelBtn addTarget:self action:@selector(cancelEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

//- (UIButton *)callTypeBtn {
//    if (!_callTypeBtn) {
//        _callTypeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        _callTypeBtn.titleLabel.numberOfLines = 2;
//        _callTypeBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
//        [_callTypeBtn setImage:[UIImage imageNamed:self.type == NERtcCallTypeAudio ? @"call_switch_video" : @"call_switch_audio"] forState:UIControlStateNormal];
//        [_callTypeBtn addTarget:self action:@selector(switchCallTypeEvent:) forControlEvents:UIControlEventTouchUpInside];
//    }
//    return _callTypeBtn;
//}

- (NECustomButton *)rejectBtn {
    if (!_rejectBtn) {
        _rejectBtn = [[NECustomButton alloc] init];
        _rejectBtn.titleLabel.text = @"拒绝";
        _rejectBtn.imageView.image = [UIImage imageNamed:@"call_cancel"];
        _rejectBtn.exclusiveTouch = YES;
        [_rejectBtn addTarget:self action:@selector(rejectEvent:) forControlEvents:UIControlEventTouchUpInside];

    }
    return _rejectBtn;
}
- (NECustomButton *)acceptBtn {
    if (!_acceptBtn) {
        _acceptBtn = [[NECustomButton alloc] init];
        _acceptBtn.titleLabel.text = @"接听";
        _acceptBtn.exclusiveTouch = YES;
        _acceptBtn.imageView.image = [UIImage imageNamed:@"call_accept"];
        _acceptBtn.imageView.contentMode = UIViewContentModeCenter;
        [_acceptBtn addTarget:self action:@selector(acceptEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _acceptBtn;
}
- (UIButton *)switchCameraBtn {
    if (!_switchCameraBtn) {
        _switchCameraBtn = [[UIButton alloc] init];
        [_switchCameraBtn setImage:[UIImage imageNamed:@"call_switch_camera"] forState:UIControlStateNormal];
        [_switchCameraBtn addTarget:self action:@selector(switchCameraBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switchCameraBtn;
}
- (NEVideoOperationView *)operationView {
    if (!_operationView) {
        _operationView = [[NEVideoOperationView alloc] init];
        _operationView.layer.cornerRadius = 30;
        [_operationView.switchAudio addTarget:self action:@selector(switchCallTypeEvent:) forControlEvents:UIControlEventTouchUpInside];
        [_operationView.microPhone addTarget:self action:@selector(microPhoneClick:) forControlEvents:UIControlEventTouchUpInside];
        [_operationView.cameraBtn addTarget:self action:@selector(cameraBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_operationView.hangupBtn addTarget:self action:@selector(hangupBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _operationView;
}

- (UILabel *)connectingLabel {
    if (!_connectingLabel) {
        _connectingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _connectingLabel.font = [UIFont systemFontOfSize:15];
        _connectingLabel.textColor = [UIColor whiteColor];
        _connectingLabel.textAlignment = NSTextAlignmentCenter;
        _connectingLabel.hidden = YES;
        _connectingLabel.text = @"正在接通...";
    }
    return _connectingLabel;
}

- (AVAudioPlayer *)player {
    if (!_player) {
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"video_chat_tip_receiver" withExtension:@"aac"];
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        _player.numberOfLoops = 30;
    }
    return _player;
}
- (void)dealloc {
    NSLog(@"%@ dealloc%@",[self class],self);
}
@end
