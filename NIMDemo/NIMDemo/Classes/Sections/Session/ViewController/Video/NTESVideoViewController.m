//
//  NTESVideoViewController.m
//  NIM
//
//  Created by chris on 15/4/12.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NTESVideoViewController.h"
#import "UIView+Toast.h"
#import "Reachability.h"
#import "UIAlertView+NTESBlock.h"
#import "SVProgressHUD.h"
#import "NTESNavigationHandler.h"
#import "NTESMediaPreviewViewController.h"

@interface NTESVideoViewController ()

@property (nonatomic,strong) NTESVideoViewItem *item;

@property (nonatomic,strong) NTESAVMoivePlayerController *avPlayer;

@end

@implementation NTESVideoViewController

- (instancetype)initWithVideoViewItem:(NTESVideoViewItem *)item
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        _item = item;
    }
    return self;
}

- (void)dealloc{
    [_avPlayer stop];
    [SVProgressHUD dismiss];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NIMSDK sharedSDK].resourceManager cancelTask:_item.path];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.navigationItem.title = @"视频短片".ntes_localized;
    if (self.item.session)
    {
        [self setupRightNavItem];
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.item.path]) {
        [self startPlay];
    }else{
        __weak typeof(self) wself = self;
        [self downLoadVideo:^(NSError *error) {
            if (!error) {
                [wself startPlay];
            }else{
                [wself.view makeToast:@"下载失败，请检查网络".ntes_localized
                             duration:2
                             position:CSToastPositionCenter];
            }
        }];
    }
}

- (void)setupRightNavItem
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(onMore:) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:[UIImage imageNamed:@"icon_gallery_more_normal"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"icon_gallery_more_pressed"] forState:UIControlStateHighlighted];
    [button sizeToFit];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = buttonItem;
}


- (void)onMore:(id)sender
{
    NIMMessageSearchOption *option = [[NIMMessageSearchOption alloc] init];
    option.limit = 0;
    option.messageTypes = @[@(NIMMessageTypeImage),@(NIMMessageTypeVideo)];
    
    __weak typeof(self) weakSelf = self;
    [[NIMSDK sharedSDK].conversationManager searchMessages:self.item.session option:option result:^(NSError * _Nullable error, NSArray<NIMMessage *> * _Nullable messages) {
        if (weakSelf)
        {
            NSMutableArray *objects = [[NSMutableArray alloc] init];
            NTESMediaPreviewObject *focusObject;
            
            //显示的时候新的在前老的在后，逆序排列
            //如果需要微信的显示顺序，则直接将这段代码去掉即可
            NSArray *array = messages.reverseObjectEnumerator.allObjects;
            
            
            for (NIMMessage *message in array)
            {
                switch (message.messageType) {
                    case NIMMessageTypeVideo:{
                        NTESMediaPreviewObject *object = [weakSelf previewObjectByVideo:message.messageObject];
                        [objects addObject:object];
                        if ([message.messageId isEqualToString:weakSelf.item.itemId])
                        {
                            focusObject = object;
                        }
                        break;
                    }
                    case NIMMessageTypeImage:{
                        NTESMediaPreviewObject *object = [weakSelf previewObjectByImage:message.messageObject];
                        [objects addObject:object];
                        break;
                    }
                    default:
                        break;
                }
            }
            NTESMediaPreviewViewController *vc = [[NTESMediaPreviewViewController alloc] initWithPriviewObjects:objects focusObject:focusObject];
            [weakSelf.navigationController pushViewController:vc animated:YES];
        }
    }];
}

- (NTESMediaPreviewObject *)previewObjectByVideo:(NIMVideoObject *)object
{
    NTESMediaPreviewObject *previewObject = [[NTESMediaPreviewObject alloc] init];
    previewObject.objectId  = object.message.messageId;
    previewObject.thumbPath = object.coverPath;
    previewObject.thumbUrl  = object.coverUrl;
    previewObject.path      = object.path;
    previewObject.url       = object.url;
    previewObject.type      = NTESMediaPreviewTypeVideo;
    previewObject.timestamp = object.message.timestamp;
    previewObject.displayName = object.displayName;
    previewObject.duration  = object.duration;
    previewObject.imageSize = object.coverSize;
    return previewObject;
}

- (NTESMediaPreviewObject *)previewObjectByImage:(NIMImageObject *)object
{
    NTESMediaPreviewObject *previewObject = [[NTESMediaPreviewObject alloc] init];
    previewObject.objectId  = object.message.messageId;
    previewObject.thumbPath = object.thumbPath;
    previewObject.thumbUrl  = object.thumbUrl;
    previewObject.path      = object.path;
    previewObject.url       = object.url;
    previewObject.type      = NTESMediaPreviewTypeImage;
    previewObject.timestamp = object.message.timestamp;
    previewObject.displayName = object.displayName;
    previewObject.imageSize = object.size;
    return previewObject;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear: animated];
    if (![[self.navigationController viewControllers] containsObject: self])
    {
        [self topStatusUIHidden:NO];
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.avPlayer pause];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear: animated];
    if (_avPlayer.playbackState == NTESAVMoviePlaybackStatePlaying) {//不要调用.get方法，会过早的初始化播放器
        [self topStatusUIHidden:YES];
    }else{
        [self topStatusUIHidden:NO];
    }
}



- (void)downLoadVideo:(void(^)(NSError *error))handler{
    [SVProgressHUD show];
    __weak typeof(self) wself = self;
    [[NIMSDK sharedSDK].resourceManager download:self.item.url filepath:self.item.path progress:^(float progress) {
        if (wself)
        {
            [SVProgressHUD showProgress:progress];
        }
    } completion:^(NSError *error) {
        if (wself) {
            [SVProgressHUD dismiss];
            if (handler) {
                handler(error);
            }
        }
    }];
}




- (void)startPlay{
    self.avPlayer.view.frame = self.view.bounds;
    self.avPlayer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.avPlayer prepareToPlay];
    [self.view addSubview:self.avPlayer.view];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlaybackComplete:)
                                                 name:NTESAVMoviePlayerPlaybackDidFinishNotification
                                               object:self.avPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayStateChanged:)
                                                 name:NTESAVMoviePlayerPlaybackStateDidChangeNotification
                                               object:self.avPlayer];
    
    
    CGRect bounds = self.avPlayer.view.bounds;
    CGRect tapViewFrame = CGRectMake(0, 0, bounds.size.width, bounds.size.height);
    UIView *tapView = [[UIView alloc]initWithFrame:tapViewFrame];
    [tapView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    tapView.backgroundColor = [UIColor clearColor];
    [self.avPlayer.view addSubview:tapView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTap:)];
    [tapView  addGestureRecognizer:tap];
}

- (void)moviePlaybackComplete: (NSNotification *)aNotification
{
    if (self.avPlayer == aNotification.object)
    {
        [self topStatusUIHidden:NO];
        NSDictionary *notificationUserInfo = [aNotification userInfo];
        NSNumber *resultValue = [notificationUserInfo objectForKey:NTESAVMoviePlayerPlaybackDidFinishReasonUserInfoKey];
        NTESAVMovieFinishReason reason = [resultValue intValue];
        if (reason == NTESAVMovieFinishReasonPlaybackError)
        {
            NSError *mediaPlayerError = [notificationUserInfo objectForKey:@"error"];
            NSString *errorTip = [NSString stringWithFormat:@"%@: %@", @"播放失败".ntes_localized, [mediaPlayerError localizedDescription]];
            [self.view makeToast:errorTip
                        duration:2
                        position:CSToastPositionCenter];
        }
    }
    
}

- (void)moviePlayStateChanged: (NSNotification *)aNotification
{
    if (self.avPlayer == aNotification.object)
    {
        switch (self.avPlayer.playbackState)
        {
            case NTESAVMoviePlaybackStatePlaying:
                [self topStatusUIHidden:YES];
                break;
            case NTESAVMoviePlaybackStatePaused:
            case NTESAVMoviePlaybackStateStopped:
            case NTESAVMoviePlaybackStateInterrupted:
                [self topStatusUIHidden:NO];
            case NTESAVPMoviePlaybackStateSeekingBackward:
            case NTESAVPMoviePlaybackStateSeekingForward:
                break;
        }
        
    }
}

- (void)topStatusUIHidden:(BOOL)isHidden
{
    [[UIApplication sharedApplication] setStatusBarHidden:isHidden];
    self.navigationController.navigationBar.hidden = isHidden;
    NTESNavigationHandler *handler = (NTESNavigationHandler *)self.navigationController.delegate;
    handler.recognizer.enabled = !isHidden;
}

- (void)onTap: (UIGestureRecognizer *)recognizer
{
    switch (self.avPlayer.playbackState)
    {
        case NTESAVMoviePlaybackStatePlaying:
            [self.avPlayer pause];
            break;
        case NTESAVMoviePlaybackStatePaused:
        case NTESAVMoviePlaybackStateStopped:
        case NTESAVMoviePlaybackStateInterrupted:
            [self.avPlayer play];
            break;
        default:
            break;
    }
}

- (NTESAVMoivePlayerController *)avPlayer {
    if (!_avPlayer) {
        _avPlayer = [[NTESAVMoivePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:self.item.path]];
        _avPlayer.scalingMode = NTESAVMovieScalingModeAspectFill;
    }
    return _avPlayer;
}


@end


@implementation NTESVideoViewItem
@end

