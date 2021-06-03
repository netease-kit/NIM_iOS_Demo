//
//  NTESVideoChatViewController.m
//  NIM
//
//  Created by chris on 15/5/5.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NTESVideoChatViewController.h"
#import "UIView+Toast.h"
#import "NTESTimerHolder.h"
#import "NTESAudioChatViewController.h"
#import "NTESMainTabController.h"
#import "NTESNetCallChatInfo.h"
#import "NTESSessionUtil.h"
#import "NTESVideoChatNetStatusView.h"
#import "NTESBundleSetting.h"
#import "NTESRecordSelectView.h"
#import "UIView+NTES.h"
#import "NTESGLView.h"

@interface NTESVideoChatViewController ()

@property (nonatomic,assign) NIMNetCallCamera cameraType;

@property (nonatomic,strong) CALayer *localVideoLayer;

@property (nonatomic,weak) UIView   *localView;

@property (nonatomic,weak) UIView   *localPreView;

@property (nonatomic,weak) UIView   *remoteView;

@property (nonatomic, strong) NTESGLView *remoteGLView;

@property (nonatomic, assign) BOOL calleeBasy;

@property (nonatomic, copy) NSString *remoteUid;

@property (nonatomic, assign) BOOL oppositeCloseVideo;

@property (nonatomic, readonly) BOOL enableOpenGLView;

@end

@implementation NTESVideoChatViewController

- (instancetype)initWithCallInfo:(NTESNetCallChatInfo *)callInfo
{
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        self.callInfo = callInfo;
        self.callInfo.isMute = NO;
        self.callInfo.useSpeaker = NO;
        self.callInfo.disableCammera = NO;
        NSString *myUid = [NIMSDK sharedSDK].loginManager.currentAccount;
        if ([self.callInfo.caller isEqualToString:myUid]) {
            _remoteUid = self.callInfo.callee;
        } else {
            _remoteUid = self.callInfo.caller;
        }
        if (!self.localPreView) {
            //没有的话，尝试去取一把预览层（从视频切到语音再切回来的情况下是会有的）
            self.localPreView = [NIMAVChatSDK sharedSDK].netCallManager.localPreview;
        }
        [[NIMAVChatSDK sharedSDK].netCallManager switchType:NIMNetCallMediaTypeVideo];
    }
    return self;
}


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.callInfo.callType = NIMNetCallTypeVideo;
        _cameraType = [[NTESBundleSetting sharedConfig] startWithBackCamera] ? NIMNetCallCameraBack :NIMNetCallCameraFront;
    }
    return self;
}

- (void)viewDidLoad {
    self.localView = self.smallVideoView;
    [super viewDidLoad];
    
    if (self.localPreView) {
        self.localPreView.frame = self.localView.bounds;
        [self.localView addSubview:self.localPreView];
    }
    
    [self initUI];
}

- (void)initUI
{
    self.localRecordingView.layer.cornerRadius = 10.0;
    self.localRecordingRedPoint.layer.cornerRadius = 4.0;
    self.lowMemoryView.layer.cornerRadius = 10.0;
    self.lowMemoryRedPoint.layer.cornerRadius = 4.0;
    self.refuseBtn.exclusiveTouch = YES;
    self.acceptBtn.exclusiveTouch = YES;
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
        [self initRemoteGLView];
    }
}

- (void)initRemoteGLView {
    if (self.enableOpenGLView) {
        _remoteGLView = [[NTESGLView alloc] initWithFrame:_bigVideoView.bounds];
        [_remoteGLView setContentMode:[[NTESBundleSetting sharedConfig] videochatRemoteVideoContentMode]];
        [_remoteGLView setBackgroundColor:[UIColor clearColor]];
        _remoteGLView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_bigVideoView addSubview:_remoteGLView];
    } else {
        if(!_remoteView) {
            _remoteView = [[NIMAVChatSDK sharedSDK].netCallManager remoteDisplayViewWithUid:_remoteUid];
        }
        if (self.remoteView) {
            self.remoteView.frame = self.bigVideoView.bounds;
            if (self.remoteView.superview != self.bigVideoView) {
                [self.remoteView removeFromSuperview];
                [self.bigVideoView addSubview:self.remoteView];
            }
        }
    }
}

#pragma mark - Call Life
- (void)startByCaller{
    [super startByCaller];
    [self startInterface];
}

- (void)startByCallee{
    [super startByCallee];
    [self waitToCallInterface];
}
- (void)onCalling{
    [super onCalling];
    [self videoCallingInterface];
}

- (void)waitForConnectiong{
    [super waitForConnectiong];
    [self connectingInterface];
}

- (void)onCalleeBusy
{
    _calleeBasy = YES;
    if (_localPreView)
    {
        [_localPreView removeFromSuperview];
    }
}

#pragma mark - Interface
//正在接听中界面
- (void)startInterface{
    self.acceptBtn.hidden = YES;
    self.refuseBtn.hidden   = YES;
    self.hungUpBtn.hidden   = NO;
    self.connectingLabel.hidden = NO;
    self.connectingLabel.text = @"正在呼叫，请稍候...".ntes_localized;
    self.switchModelBtn.hidden = YES;
    self.switchCameraBtn.hidden = NO;
    self.muteBtn.hidden = NO;
    self.disableCameraBtn.hidden = NO;
    self.localRecordBtn.hidden = NO;
    self.muteBtn.enabled = NO;
    self.disableCameraBtn.enabled = NO;
    self.localRecordBtn.enabled = NO;
    
    self.localRecordingView.hidden = YES;
    self.lowMemoryView.hidden = YES;
    [self.hungUpBtn removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
    [self.hungUpBtn addTarget:self action:@selector(hangup) forControlEvents:UIControlEventTouchUpInside];
    self.localView = self.bigVideoView;
}

//选择是否接听界面
- (void)waitToCallInterface{
    self.acceptBtn.hidden = NO;
    self.refuseBtn.hidden   = NO;
    self.hungUpBtn.hidden   = YES;
    NSString *nick = [NTESSessionUtil showNick:self.callInfo.caller inSession:nil];
    self.connectingLabel.text = [nick stringByAppendingString:@"的来电".ntes_localized];
    self.muteBtn.hidden = YES;
    self.switchCameraBtn.hidden = YES;
    self.disableCameraBtn.hidden = YES;
    self.localRecordBtn.hidden = YES;
    self.localRecordingView.hidden = YES;
    self.lowMemoryView.hidden = YES;
    self.switchModelBtn.hidden = YES;
}

//连接对方界面
- (void)connectingInterface{
    self.acceptBtn.hidden = YES;
    self.refuseBtn.hidden   = YES;
    self.hungUpBtn.hidden   = NO;
    self.connectingLabel.hidden = NO;
    self.connectingLabel.text = @"正在连接对方...请稍后...".ntes_localized;
    self.switchModelBtn.hidden = YES;
    self.switchCameraBtn.hidden = YES;
    self.muteBtn.hidden = YES;
    self.disableCameraBtn.hidden = YES;
    self.localRecordBtn.hidden = YES;
    self.localRecordingView.hidden = YES;
    self.lowMemoryView.hidden = YES;
    [self.hungUpBtn removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
    [self.hungUpBtn addTarget:self action:@selector(hangup) forControlEvents:UIControlEventTouchUpInside];
}

//接听中界面(视频)
- (void)videoCallingInterface{
    
    NIMNetCallNetStatus status = [[NIMAVChatSDK sharedSDK].netCallManager netStatus:self.peerUid];
    [self.netStatusView refreshWithNetState:status];
    self.acceptBtn.hidden = YES;
    self.refuseBtn.hidden   = YES;
    self.hungUpBtn.hidden   = NO;
    self.connectingLabel.hidden = YES;
    self.muteBtn.hidden = NO;
    self.switchCameraBtn.hidden = NO;
    self.disableCameraBtn.hidden = NO;
    self.localRecordBtn.hidden = NO;
    self.switchModelBtn.hidden = NO;
    
    self.muteBtn.enabled = YES;
    self.disableCameraBtn.enabled = YES;
    self.localRecordBtn.enabled = YES;
    
    self.muteBtn.selected = self.callInfo.isMute;
    self.disableCameraBtn.selected = self.callInfo.disableCammera;
    self.localRecordBtn.selected = ![self allRecordsStopped];
;
    self.localRecordingView.hidden = [self allRecordsStopped];
;
    self.lowMemoryView.hidden = YES;
    [self.switchModelBtn setTitle:@"语音模式".ntes_localized forState:UIControlStateNormal];
    [self.hungUpBtn removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
    [self.hungUpBtn addTarget:self action:@selector(hangup) forControlEvents:UIControlEventTouchUpInside];
//    self.localVideoLayer.hidden = NO;
    self.localPreView.hidden = NO;
}

//切换接听中界面(语音)
- (void)audioCallingInterface{
    
    NTESAudioChatViewController *vc = [[NTESAudioChatViewController alloc] initWithCallInfo:self.callInfo];
    [UIView  beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.75];
    [self.navigationController pushViewController:vc animated:NO];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:NO];
    [UIView commitAnimations];
    NSMutableArray * vcs = [self.navigationController.viewControllers mutableCopy];
    [vcs removeObject:self];
    self.navigationController.viewControllers = vcs;
}

- (void)udpateLowSpaceWarning:(BOOL)show {
    self.lowMemoryView.hidden = !show;
    self.localRecordingView.hidden = show;
}


#pragma mark - IBAction

- (IBAction)acceptToCall:(id)sender{
    BOOL accept = (sender == self.acceptBtn);
    //防止用户在点了接收后又点拒绝的情况
    [self response:accept];
}

- (IBAction)mute:(BOOL)sender{
    self.callInfo.isMute = !self.callInfo.isMute;
    self.player.volume = !self.callInfo.isMute;
    [[NIMAVChatSDK sharedSDK].netCallManager setMute:self.callInfo.isMute];
    self.muteBtn.selected = self.callInfo.isMute;
}

- (IBAction)switchCamera:(id)sender{
    if (self.cameraType == NIMNetCallCameraFront) {
        self.cameraType = NIMNetCallCameraBack;
    }else{
        self.cameraType = NIMNetCallCameraFront;
    }
    [[NIMAVChatSDK sharedSDK].netCallManager switchCamera:self.cameraType];
    self.switchCameraBtn.selected = (self.cameraType == NIMNetCallCameraBack);
}


- (IBAction)disableCammera:(id)sender{
    self.callInfo.disableCammera = !self.callInfo.disableCammera;
    [[NIMAVChatSDK sharedSDK].netCallManager setCameraDisable:self.callInfo.disableCammera];
    self.disableCameraBtn.selected = self.callInfo.disableCammera;
    if (self.callInfo.disableCammera) {
        [self.localPreView removeFromSuperview];
        [[NIMAVChatSDK sharedSDK].netCallManager control:self.callInfo.callID type:NIMNetCallControlTypeCloseVideo];
    }else{
        [self.localView addSubview:self.localPreView];

        [[NIMAVChatSDK sharedSDK].netCallManager control:self.callInfo.callID type:NIMNetCallControlTypeOpenVideo];
    }
}

- (IBAction)localRecord:(id)sender {
    //出现录制选择框
    if ([self allRecordsStopped]) {
        [self showRecordSelectView:YES];
    }
    //同时停止所有录制
    else
    {
        //结束语音对话
        if (self.callInfo.audioConversation) {
            [self stopAudioRecording];
            if([self allRecordsStopped])
            {
                self.localRecordBtn.selected = NO;
                self.localRecordingView.hidden = YES;
                self.lowMemoryView.hidden = YES;
            }
        }
        [self stopRecordTaskWithVideo:YES];
    }

}


- (IBAction)switchCallingModel:(id)sender{
    [[NIMAVChatSDK sharedSDK].netCallManager control:self.callInfo.callID type:NIMNetCallControlTypeToAudio];
    [self switchToAudio];
}


#pragma mark - NTESRecordSelectViewDelegate

-(void)onRecordWithAudioConversation:(BOOL)audioConversationOn myMedia:(BOOL)myMediaOn otherSideMedia:(BOOL)otherSideMediaOn
{
    if (audioConversationOn) {
        //开始语音对话
        if ([self startAudioRecording]) {
            self.callInfo.audioConversation = YES;
            self.localRecordBtn.selected = YES;
            self.localRecordingView.hidden = NO;
            self.lowMemoryView.hidden = YES;
        }
    }
    [self recordWithAudioConversation:audioConversationOn myMedia:myMediaOn otherSideMedia:otherSideMediaOn video:YES];
}


#pragma mark - NIMNetCallManagerDelegate
- (void)onLocalDisplayviewReady:(UIView *)displayView
{
    if (_calleeBasy) {
        return;
    }
    
    if (self.localPreView) {
        [self.localPreView removeFromSuperview];
    }
    
    self.localPreView = displayView;
    displayView.frame = self.localView.bounds;

    [self.localView addSubview:displayView];
}

- (void)onRemoteDisplayviewReady:(UIView *)displayView user:(NSString *)user {
    
    if (self.enableOpenGLView) {
        return;
    }
    
    if (_remoteView != displayView) {
        if (displayView.superview) {
            [displayView removeFromSuperview];
        }
        [_remoteView removeFromSuperview];
        _remoteView = displayView;
        _remoteView.frame = _bigVideoView.bounds;
        _remoteView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [_bigVideoView addSubview:displayView];
    }
}

- (void)onRemoteYUVReady:(NSData *)yuvData
                   width:(NSUInteger)width
                  height:(NSUInteger)height
                    from:(NSString *)user
{
    if (!self.enableOpenGLView) {
        return;
    }
    
    if (([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) && !self.oppositeCloseVideo) {
        
        if (!_remoteGLView) {
            [self initRemoteGLView];
        }
        [_remoteGLView render:yuvData width:width height:height];
    }
}

- (void)onControl:(UInt64)callID
             from:(NSString *)user
             type:(NIMNetCallControlType)control{
    [super onControl:callID from:user type:control];
    switch (control) {
        case NIMNetCallControlTypeToAudio:
            [self switchToAudio];
            break;
        case NIMNetCallControlTypeCloseVideo:
            [self resetRemoteImage];
            self.oppositeCloseVideo = YES;
            _remoteView.hidden = YES;
            [self.view makeToast:@"对方关闭了摄像头".ntes_localized
                        duration:2
                        position:CSToastPositionCenter];
            break;
        case NIMNetCallControlTypeOpenVideo:
            self.oppositeCloseVideo = NO;
            _remoteView.hidden = NO;
            [self.view makeToast:@"对方开启了摄像头".ntes_localized
                        duration:2
                        position:CSToastPositionCenter];
            break;
        default:
            break;
    }
}


-(void)onCallEstablished:(UInt64)callID
{
    if (self.callInfo.callID == callID) {
        [super onCallEstablished:callID];
        
        self.durationLabel.hidden = NO;
        self.durationLabel.text = self.durationDesc;
        
        if (self.localView == self.bigVideoView) {
            self.localView = self.smallVideoView;
            
            if (self.localPreView) {
                [self onLocalDisplayviewReady:self.localPreView];
            }
        }
    }
}

- (void)onNetStatus:(NIMNetCallNetStatus)status user:(NSString *)user
{
    if ([user isEqualToString:self.peerUid]) {
        [self.netStatusView refreshWithNetState:status];
    }
}


- (void)onRecordStarted:(UInt64)callID fileURL:(NSURL *)fileURL uid:(NSString *)userId
{
    [super onRecordStarted:callID fileURL:fileURL uid:userId];
    if (self.callInfo.callID == callID) {
        self.localRecordBtn.selected = YES;
        self.localRecordingView.hidden = NO;
        self.lowMemoryView.hidden = YES;
    }
}


- (void)onRecordError:(NSError *)error
                    callID:(UInt64)callID
                       uid:(NSString *)userId;

{
    [super onRecordError:error callID:callID uid:userId];
    if (self.callInfo.callID == callID) {
        //判断是否全部结束
        if([self allRecordsStopped])
        {
            self.localRecordBtn.selected = NO;
            self.localRecordingView.hidden = YES;
            self.lowMemoryView.hidden = YES;
        }
    }
}

- (void) onRecordStopped:(UInt64)callID
                      fileURL:(NSURL *)fileURL
                          uid:(NSString *)userId;

{
    [super onRecordStopped:callID fileURL:fileURL uid:userId];
    if (self.callInfo.callID == callID) {
        if([self allRecordsStopped])
        {
            self.localRecordBtn.selected = NO;
            self.localRecordingView.hidden = YES;
            self.lowMemoryView.hidden = YES;
        }
    }
}

#pragma mark - M80TimerHolderDelegate

- (void)onNTESTimerFired:(NTESTimerHolder *)holder{
    [super onNTESTimerFired:holder];
    self.durationLabel.text = self.durationDesc;
}

#pragma mark - Misc
- (void)switchToAudio{
    [self audioCallingInterface];
}

- (NSString*)durationDesc{
    if (!self.callInfo.startTime) {
        return @"";
    }
    NSTimeInterval time = [NSDate date].timeIntervalSince1970;
    NSTimeInterval duration = time - self.callInfo.startTime;
    return [NSString stringWithFormat:@"%02d:%02d",(int)duration/60,(int)duration%60];
}

- (void)resetRemoteImage{
    [self.remoteGLView render:nil width:0 height:0];
    self.bigVideoView.image = [UIImage imageNamed:@"netcall_bkg.png"];
}

- (BOOL)enableOpenGLView {
    return ![NTESBundleSetting sharedConfig].enableSdkRemoteRender;
}

@end
