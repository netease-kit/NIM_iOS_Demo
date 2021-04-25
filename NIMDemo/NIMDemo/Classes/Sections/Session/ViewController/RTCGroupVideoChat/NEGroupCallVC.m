//
//  NEGroupCallVC.m
//  NIM
//
//  Created by I am Groot on 2020/11/6.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NEGroupCallVC.h"
#import "NEGroupCallCollectionCell.h"
#import "NEGroupCallView.h"
#import "NEVideoOperationView.h"
#import "NECustomNavigationBar.h"
#import "NIMContactSelectViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface NEGroupCallVC ()<UICollectionViewDelegate,UICollectionViewDataSource,NERtcCallKitDelegate,NEGroupCallViewDelegate>

@property(strong,nonatomic)UICollectionView *collectionView;
@property(strong,nonatomic)NEGroupCallView *callView;
@property(strong,nonatomic)NEVideoOperationView *operationView;
@property(strong,nonatomic)UIButton *switchCameraBtn;
@property(strong,nonatomic)NECustomNavigationBar *topBar;

/// 取消呼叫
@property(strong,nonatomic)NECustomButton *cancelBtn;

@property(strong,nonatomic)NSMutableOrderedSet<NSString *> *otherMembers;
@property(strong,nonatomic)NSString *caller;
// key:userID value:cell
@property(strong,nonatomic)NSMutableSet<NSString *> *muteUsers;
@property(nonatomic,readonly)NSString *myselfID;

@property (nonatomic,strong) AVAudioPlayer *player; //播放提示音

@end


@implementation NEGroupCallVC

- (instancetype)initWithCaller:(NSString *)caller otherMembers:(NSArray *)members isCalled:(BOOL)isCalled {
    self = [super init];
    if (self) {
        self.caller = caller;
        self.otherMembers = [NSMutableOrderedSet orderedSetWithArray:members];
        self.muteUsers = NSMutableSet.set;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self setupSDK];
    [self.player play];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.player stop];
}

- (void)setupUI {
    [self.view addSubview:self.topBar];
    [self.topBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view.mas_leading);
        make.trailing.equalTo(self.view.mas_trailing);
        make.top.equalTo(self.view.mas_top);
        make.height.equalTo(@64);
    }];
    [self.view addSubview:self.callView];
    [self.callView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view.mas_leading);
        make.trailing.equalTo(self.view.mas_trailing);
        make.top.equalTo(self.topBar.mas_bottom);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    [self updateUIWithStatus:NERtcCallKit.sharedInstance.callStatus];
    
    /// 取消按钮
    [self.view addSubview:self.cancelBtn];
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-80);
        make.size.mas_equalTo(CGSizeMake(75, 103));
    }];
    
    [self.view addSubview:self.switchCameraBtn];
    [self.view addSubview:self.operationView];
    [self.switchCameraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.operationView.mas_top).offset(-50);
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    [self.operationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(224, 60));
        make.bottom.mas_equalTo(-50);
    }];

}
- (void)updateUIWithStatus:(NERtcCallStatus)status {
    switch (status) {
        case NERtcCallStatusIdle:
        case NERtcCallStatusCalling:
        {
            self.callView.hidden = YES;
            self.collectionView.hidden = NO;
            self.switchCameraBtn.hidden = YES;
            self.operationView.hidden = YES;
            self.cancelBtn.hidden = NO;
        }
            break;
        case NERtcCallStatusCalled:
        {
            self.callView.hidden = NO;
            self.collectionView.hidden = YES;
            self.switchCameraBtn.hidden = YES;
            self.operationView.hidden = YES;
            self.cancelBtn.hidden = YES;
            self.callView.titleLabel.text = [NSString stringWithFormat:@"%@发起多人视频通话",self.caller];
        }
            break;
        case NERtcCallStatusInCall:
        {
            self.callView.hidden = YES;
            self.collectionView.hidden = NO;
            self.switchCameraBtn.hidden = NO;
            self.operationView.hidden = NO;
            self.operationView.switchAudio.hidden = YES;
            self.cancelBtn.hidden = YES;
        }
            break;

        default:
            break;
    }
}

- (void)uiAddMembers:(NSArray<NSString *> *)newMembers {
    NSMutableArray<NSIndexPath *> *newIndexPaths = NSMutableArray.array;
    for (int i = 0; i < newMembers.count; i++) {
        [newIndexPaths addObject:[NSIndexPath indexPathForItem:self.otherMembers.count+1+i inSection:0]];
    }
    [self.otherMembers addObjectsFromArray:newMembers];
    [self.collectionView insertItemsAtIndexPaths:newIndexPaths];
}

#pragma mark - SDK
- (void)setupSDK {
    [[NERtcCallKit sharedInstance] addDelegate:self];
    [NERtcCallKit sharedInstance].timeOutSeconds = 30;
    if (NERtcCallKit.sharedInstance.callStatus != NERtcCallStatusCalled) {
        WEAK_SELF(weakSelf);
        [[NERtcCallKit sharedInstance] groupCall:self.otherMembers.array groupID:self.teamId type:NERtcCallTypeVideo completion:^(NSError * _Nullable error) {
            NSLog(@"groupCall:error::%@",error);
            STRONG_SELF(strongSelf);
            NEGroupCallCollectionCell *cell = [strongSelf cellForUser:strongSelf.caller];
            [[NERtcCallKit sharedInstance] setupLocalView:cell.videoView];
            cell.cameraTip.hidden = YES;
            if (error) {
                /// 对方离线时 通过APNS推送 UI不弹框提示
                [strongSelf.view.window makeToast:error.localizedDescription];
                [strongSelf dismissViewControllerAnimated:YES completion:nil];
            }
        }];
    }
}
- (void)updateVideoViewForJoinedMembers:(NSArray *)joinedMembers {
    for (NSString *userID in joinedMembers) {
        [self updateVideoViewForJoinedUser:userID];
    }
}

- (void)updateVideoViewForJoinedUser:(NSString *)userID {
    NEGroupCallCollectionCell *cell = [self cellForUser:userID];
    cell.cameraTip.hidden = YES;
    cell.muteImageView.hidden = NO;
    if ([userID isEqualToString:self.myselfID]) {
        [[NERtcCallKit sharedInstance] setupLocalView:cell.videoView];
    }else {
        [[NERtcCallKit sharedInstance] setupRemoteView:cell.videoView forUser:userID];
    }
}

#pragma mark - NERtcCallKitDelegate
- (void)onUserCancel:(NSString *)userID {
    [[NERtcCallKit sharedInstance] hangup:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)onUserAccept:(NSString *)userID {
    [self.player stop];
    [self updateUIWithStatus:NERtcCallStatusInCall];
}
- (void)onUserEnter:(NSString *)userID {
    if (![self.otherMembers containsObject:userID] && ![userID isEqualToString:self.caller]) {
        [self uiAddMembers:@[userID]];
    }
    [self updateVideoViewForJoinedUser:userID];
}
- (void)onCameraAvailable:(BOOL)available userID:(NSString *)userID {
    if (userID.length) {
        NEGroupCallCollectionCell *cell = [self cellForUser:userID];
        cell.cameraTip.text = [NSString stringWithFormat:@"%@关闭了摄像头",userID];
        cell.cameraTip.hidden = available;
    }
}
- (void)onUserBusy:(NSString *)userID {
    if (userID.length) {
        NEGroupCallCollectionCell *cell = [self cellForUser:userID];
        cell.cameraTip.text = [NSString stringWithFormat:@"%@对方正忙",userID];
        cell.cameraTip.hidden = NO;
    }
}
- (void)onUserReject:(NSString *)userID {
    if (userID.length) {
        NEGroupCallCollectionCell *cell = [self cellForUser:userID];
        cell.cameraTip.text = [NSString stringWithFormat:@"%@拒绝了您的邀请",userID];
        cell.cameraTip.hidden = NO;
    }
}
- (void)onUserLeave:(NSString *)userID {
    if (userID.length) {
        NEGroupCallCollectionCell *cell = [self cellForUser:userID];
        cell.cameraTip.text = [NSString stringWithFormat:@"%@离开了房间",userID];
        cell.cameraTip.hidden = NO;
        cell.muteImageView.hidden = YES;
    }
}

- (void)onUserDisconnect:(NSString *)userID {
    [self onUserLeave:userID];
}

- (void)onOtherClientAccept {
    [self.view.window makeToast:@"已在其他设备接听"];
    [self dismissViewControllerAnimated:YES completion:nil]; // 已被其他端处理
}

- (void)onOtherClientReject {
    [self dismissViewControllerAnimated:YES completion:nil]; // 已被其他端处理
}

- (void)onCallEnd {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onCallingTimeOut {
    WEAK_SELF(weakSelf);
    if (NERtcCallKit.sharedInstance.callStatus != NERtcCallStatusInCall) {
        [[NERtcCallKit sharedInstance] cancel:^(NSError * _Nullable error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                STRONG_SELF(strongSelf);
                [strongSelf dismissViewControllerAnimated:YES completion:nil];
            });
        }];
    }
}
#pragma mark - NEGroupCallViewDelegate
- (void)accept:(NECustomButton *)button {
    WEAK_SELF(weakSelf);
    [[NERtcCallKit sharedInstance] accept:^(NSError * _Nullable error) {
        STRONG_SELF(strongSelf);
        if (error) {
            NSString *desc = error.code == kNERtcErrInvalidState ? @"您的操作太过频繁，请稍后再试" : [NSString stringWithFormat:@"接听失败：%@", error.localizedDescription];
            [strongSelf.view.window makeToast:desc];
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            // 接听成功 更新UI
            [strongSelf updateUIWithStatus:NERtcCallKit.sharedInstance.callStatus];
            [strongSelf.player stop];
            NEGroupCallCollectionCell *cell = [strongSelf cellForUser:strongSelf.myselfID];
            [[NERtcCallKit sharedInstance] setupLocalView:cell.videoView];
            cell.cameraTip.hidden = YES;
        }
    }];
}
- (void)reject:(NECustomButton *)button {
    WEAK_SELF(weakSelf);
    [[NERtcCallKit sharedInstance] reject:^(NSError * _Nullable error) {
        STRONG_SELF(strongSelf);
        [strongSelf dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)cancelEvent:(NECustomButton *)button {
    WEAK_SELF(weakSelf);
    [[NERtcCallKit sharedInstance] cancel:^(NSError * _Nullable error) {
        STRONG_SELF(strongSelf);
        if (error) {
            // 邀请已接受 取消失败 不销毁VC
            [strongSelf.view.window makeToast:error.localizedDescription];
        } else {
            [strongSelf dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

#pragma mark - event
- (void)microPhoneClick:(UIButton *)button {
    button.selected = !button.selected;
    [[NERtcCallKit sharedInstance] muteLocalAudio:button.selected];
}
- (void)cameraBtnClick:(UIButton *)button {
    button.selected = !button.selected;
    [[NERtcCallKit sharedInstance] enableLocalVideo:!button.selected];
}
- (void)switchCameraBtn:(UIButton *)button {
    [[NERtcCallKit sharedInstance] switchCamera];
}
- (void)hangupBtnClick:(UIButton *)button {
    button.enabled = NO;
    [[NERtcCallKit sharedInstance] leave:^(NSError * _Nullable error) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

#pragma mark - get
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat padding = 2;
        CGFloat numPerRow = 3;
        CGFloat width = ([UIScreen mainScreen].bounds.size.width - ((numPerRow + 1) * padding))/numPerRow;
        CGFloat height = width/9*16;
        layout.itemSize = CGSizeMake(width, height);
        layout.minimumLineSpacing = padding;
        layout.minimumInteritemSpacing = padding;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor lightGrayColor];
        _collectionView.contentInset = UIEdgeInsetsMake(0, padding, 0, padding);
        [_collectionView registerClass:[NEGroupCallCollectionCell class] forCellWithReuseIdentifier:@"NEGroupCallCollectionCellID"];
    }
    return _collectionView;
    
}
- (NEGroupCallView *)callView {
    if (!_callView) {
        _callView = [[NEGroupCallView alloc] init];
        _callView.backgroundColor = UIColor.darkGrayColor;
        _callView.delegate = self;
    }
    return _callView;
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
- (NEVideoOperationView *)operationView {
    if (!_operationView) {
        _operationView = [[NEVideoOperationView alloc] init];
        _operationView.layer.cornerRadius = 30;
        [_operationView.microPhone addTarget:self action:@selector(microPhoneClick:) forControlEvents:UIControlEventTouchUpInside];
        [_operationView.cameraBtn addTarget:self action:@selector(cameraBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_operationView.hangupBtn addTarget:self action:@selector(hangupBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _operationView;
}
- (AVAudioPlayer *)player {
    if (!_player) {
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"video_chat_tip_receiver" withExtension:@"aac"];
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        _player.numberOfLoops = 30;
    }
    return _player;
}
- (UIButton *)switchCameraBtn {
    if (!_switchCameraBtn) {
        _switchCameraBtn = [[UIButton alloc] init];
        [_switchCameraBtn setImage:[UIImage imageNamed:@"call_switch_camera"] forState:UIControlStateNormal];
        [_switchCameraBtn addTarget:self action:@selector(switchCameraBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switchCameraBtn;
}

- (NECustomNavigationBar *)topBar {
    if (!_topBar) {
        _topBar = [[NECustomNavigationBar alloc] initWithFrame:CGRectZero];
        UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:@"视频通话"];
        item.hidesBackButton = YES;
        item.prompt = nil;
        _topBar.items = @[item];
        [_topBar setValue:@(UIBarPositionBottom) forKey:@"barPosition"];
    }
    return _topBar;
}

- (NEGroupCallCollectionCell *)cellForUser:(NSString *)user {
    NSInteger index = [user isEqualToString:self.caller] ? 0 : [self.otherMembers indexOfObject:user] + 1;
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    return (NEGroupCallCollectionCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
}

- (NSString *)myselfID {
    return NIMSDK.sharedSDK.loginManager.currentAccount;
}

#pragma mark - UICollectionViewDataSource && UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.otherMembers.count + 1;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NEGroupCallCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NEGroupCallCollectionCellID" forIndexPath:indexPath];
    NSString *userID = indexPath.item == 0 ? self.caller : self.otherMembers[indexPath.item-1];
    cell.muteImageView.image = [self.muteUsers containsObject:userID]?[UIImage imageNamed:@"call_disable_listen"]:[UIImage imageNamed:@"call_listen"];
    cell.muteImageView.hidden = [userID isEqualToString:self.myselfID];
    if (userID.length && !cell.nameLabel.text) {
        NIMTeamMember *member = [NIMSDK.sharedSDK.teamManager teamMember:userID inTeam:self.teamId];
        if (member.nickname.length) {
            cell.nameLabel.text = member.nickname;
        } else {
            NIMUser *info = [NIMSDK.sharedSDK.userManager userInfo:userID];
            cell.nameLabel.text = info.alias ?: userID;
        }
    }
    return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *userID = indexPath.item == 0 ? self.caller : self.otherMembers[indexPath.item-1];
    return ![userID isEqualToString:self.myselfID]; // 点击自己无效
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *userID = indexPath.item == 0 ? self.caller : self.otherMembers[indexPath.item-1];
    BOOL isMuted = [self.muteUsers containsObject:userID];
    NSError *error;
    [NERtcCallKit.sharedInstance setAudioMute:!isMuted forUser:userID error:&error];
    if (!error) {
        if (isMuted) {
            [self.muteUsers removeObject:userID];
        } else {
            [self.muteUsers addObject:userID];
        }
        NEGroupCallCollectionCell *cell = (NEGroupCallCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
        cell.muteImageView.image = !isMuted?[UIImage imageNamed:@"call_disable_listen"]:[UIImage imageNamed:@"call_listen"];
    }
}


- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *userID = indexPath.item == 0 ? self.caller : self.otherMembers[indexPath.item-1];
    [NERtcCallKit.sharedInstance setupRemoteView:nil forUser:userID];
}

#pragma mark - destroy

- (void)dealloc {
    if (self.player) {
        [self.player stop];
        self.player = nil;
    }
    [[NERtcCallKit sharedInstance] removeDelegate:self];
    [[NERtcCallKit sharedInstance] setupLocalView:nil];
}

@end
