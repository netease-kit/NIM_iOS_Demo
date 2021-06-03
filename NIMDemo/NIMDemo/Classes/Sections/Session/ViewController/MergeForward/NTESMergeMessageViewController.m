//
//  NTESMergeMessageViewController.m
//  NIM
//
//  Created by zhanggenning on 2019/10/18.
//  Copyright © 2019 Netease. All rights reserved.
//

#import "NTESMergeMessageViewController.h"
#import "NTESMultiRetweetAttachment.h"
#import "NTESMessageCellFactory.h"
#import "UIView+NTES.h"
#import <UIView+Toast.h>
#import <SVProgressHUD.h>
#import "NIMKitAudioCenter.h"
#import "NTESGalleryViewController.h"
#import "NTESMergeMessageViewController.h"
#import "NTESSessionMultiRetweetContentView.h"
#import "NTESVideoViewController.h"
#import "NIMLocationViewController.h"
#import "NTESFilePreViewController.h"
#import "NTESMergeMessageDataSource.h"
#import "NIMContactSelectViewController.h"
#import "UIActionSheet+NTESBlock.h"
#import "UIAlertView+NTESBlock.h"
#import "NIMKitInfoFetchOption.h"
#import "NTESMessageModel.h"

@interface NTESMergeMessageViewController ()<UITableViewDelegate,
                                                   UITableViewDataSource,
                                                   NIMMessageCellDelegate, NIMChatManagerDelegate>
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NIMMessage *message;
@property (nonatomic, strong) NTESMultiRetweetAttachment *attachment;
@property (nonatomic, readonly) NSMutableArray<NTESMessageModel *> *items;
@property (nonatomic, strong) NTESMessageCellFactory *cellFactory;
@property (nonatomic, strong) NTESMergeMessageDataSource *dataSource;
@end

@implementation NTESMergeMessageViewController

- (void)dealloc {
    if ([[NIMSDK sharedSDK].mediaManager isPlaying]) {
        [[NIMSDK sharedSDK].mediaManager stopPlay];
    }
}

- (instancetype)initWithMessage:(NIMMessage *)message {
    if (self = [super init]) {
        _message = message;
        if ([message.messageObject isKindOfClass:[NIMCustomObject class]]) {
            NIMCustomObject *customObj = (NIMCustomObject *)message.messageObject;
            if ([customObj.attachment isKindOfClass:[NTESMultiRetweetAttachment class]]) {
                _attachment = (NTESMultiRetweetAttachment *)customObj.attachment;
            }
        }
        _cellFactory = [[NTESMessageCellFactory alloc] init];
        _dataSource = [[NTESMergeMessageDataSource alloc] init];
        [[NIMSDK sharedSDK].chatManager addDelegate:self];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNav];
    [self setupComponent];
    [self setupDataSource];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _tableView.frame = self.view.bounds;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UIImageView *navBarHairlineImageView = [self findLineImageViewUnder:self.navigationController.navigationBar];
    navBarHairlineImageView.hidden = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    UIImageView *navBarHairlineImageView = [self findLineImageViewUnder:self.navigationController.navigationBar];
    navBarHairlineImageView.hidden = NO;
}

- (void)setupNav {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.titleLabel.font = [UIFont systemFontOfSize:13.0];
    btn.frame = CGRectMake(0, 0, 40, 60);
    [btn setTitle:@"转发".ntes_localized forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(forwardAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = rightItem;
    self.title = self.attachment.sessionName;

}

- (void)setupComponent {
    [self.view addSubview:self.tableView];
}

- (UIImageView *)findLineImageViewUnder:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0)
     {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findLineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

- (void)setupDataSource {
    __weak typeof(self) weakSelf = self;
    [SVProgressHUD show];
    [_dataSource pullDataWithAttachment:self.attachment completion:^(NSString * _Nonnull msg) {
        [SVProgressHUD dismiss];
        if (msg) {
            [weakSelf.view makeToast:msg duration:2 position:CSToastPositionCenter];
        } else {
            [weakSelf.tableView reloadData];
        }
    }];
}

- (void)updateMessage:(NIMMessage *)message
{
    NSIndexPath *indexPath = [_dataSource updateMessage:message];
    if (indexPath) {
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark - <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    id model = [self.items objectAtIndex:indexPath.row];
    if ([model isKindOfClass:[NTESMessageModel class]]) {
        cell = [self.cellFactory ntesCellInTable:tableView forMessageMode:model];
        [(NTESMergeMessageCell *)cell setDelegate:self];
        [(NTESMergeMessageCell *)cell refreshData:model];
    }
    else if ([model isKindOfClass:[NIMTimestampModel class]])
    {
        cell = [self.cellFactory ntesCellInTable:tableView
                                    forTimeModel:model];
    }
    else
    {
        NSAssert(0, @"not support model");
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat cellHeight = 0;
    id modelInArray = [self.items objectAtIndex:indexPath.row];
    if ([modelInArray isKindOfClass:[NTESMessageModel class]])
    {
        NTESMessageModel *model = (NTESMessageModel *)modelInArray;
        
        CGSize size = [model contentSize:tableView.width];
        CGFloat avatarMarginY = [model avatarMargin].y;
        UIEdgeInsets contentViewInsets = model.contentViewInsets;
        UIEdgeInsets bubbleViewInsets  = model.bubbleViewInsets;
        cellHeight = size.height + contentViewInsets.top + contentViewInsets.bottom + bubbleViewInsets.top + bubbleViewInsets.bottom ;
        cellHeight = cellHeight - contentViewInsets.bottom + 16.0 * 2; //二次调整
        cellHeight = cellHeight > (model.avatarSize.height + avatarMarginY) ? cellHeight : model.avatarSize.height + avatarMarginY;
    }
    else if ([modelInArray isKindOfClass:[NIMTimestampModel class]])
    {
        cellHeight = [(NIMTimestampModel *)modelInArray height];
    }
    else
    {
        NSAssert(0, @"not support model");
    }
    return cellHeight;
}

#pragma mark - Forward
- (void)forwardAction:(UIButton *)sender {
    __weak typeof(self) weakSelf = self;
    [self selectForwardSessionCompletion:^(NIMSession *targetSession) {
        [weakSelf forwardMessage:weakSelf.message toSession:targetSession];
    }];
}

- (void)selectForwardSessionCompletion:(void (^)(NIMSession *targetSession))completion {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"选择会话类型".ntes_localized delegate:nil cancelButtonTitle:@"取消".ntes_localized destructiveButtonTitle:nil otherButtonTitles:@"个人".ntes_localized, @"群组".ntes_localized, @"超大群组".ntes_localized, nil];
    [sheet showInView:self.view completionHandler:^(NSInteger index) {
        switch (index) {
            case 0:{
                NIMContactFriendSelectConfig *config = [[NIMContactFriendSelectConfig alloc] init];
                config.needMutiSelected = NO;
                NIMContactSelectViewController *vc = [[NIMContactSelectViewController alloc] initWithConfig:config];
                vc.finshBlock = ^(NSArray *array){
                    NSString *userId = array.firstObject;
                    NIMSession *session = [NIMSession session:userId type:NIMSessionTypeP2P];
                    if (completion) {
                        completion(session);
                    }
                };
                [vc show];
            }
                break;
            case 1:{
                NIMContactTeamSelectConfig *config = [[NIMContactTeamSelectConfig alloc] init];
                config.teamType = NIMKitTeamTypeNomal;
                NIMContactSelectViewController *vc = [[NIMContactSelectViewController alloc] initWithConfig:config];
                vc.finshBlock = ^(NSArray *array){
                    NSString *teamId = array.firstObject;
                    NIMSession *session = [NIMSession session:teamId type:NIMSessionTypeTeam];
                    if (completion) {
                        completion(session);
                    }
                };
                [vc show];
            }
                break;
            case 2: {
                NIMContactTeamSelectConfig *config = [[NIMContactTeamSelectConfig alloc] init];
                config.teamType = NIMKitTeamTypeSuper;
                NIMContactSelectViewController *vc = [[NIMContactSelectViewController alloc] initWithConfig:config];
                vc.finshBlock = ^(NSArray *array){
                    NSString *teamId = array.firstObject;
                    NIMSession *session = [NIMSession session:teamId type:NIMSessionTypeSuperTeam];
                    if (completion) {
                        completion(session);
                    }
                };
                [vc show];
            }
                break;
            default:
                break;
        }
    }];
}

 - (void)forwardMessage:(NIMMessage *)message toSession:(NIMSession *)session
{
    NSString *name;
    if (session.sessionType == NIMSessionTypeP2P) {
        NIMKitInfoFetchOption *option = [[NIMKitInfoFetchOption alloc] init];
        option.session = session;
        name = [[NIMKit sharedKit] infoByUser:session.sessionId option:option].showName;
    }
    else if (session.sessionType == NIMSessionTypeTeam) {
        name = [[NIMKit sharedKit] infoByTeam:session.sessionId option:nil].showName;
    }
    else if (session.sessionType == NIMSessionTypeSuperTeam) {
        name = [[NIMKit sharedKit] infoBySuperTeam:session.sessionId option:nil].showName;
    }
    else {
        DDLogWarn(@"unknown session type %zd", session.sessionType);
    }
    NSString *tip = [NSString stringWithFormat:@"%@ %@ ?",@"确认转发给".ntes_localized,name];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确认转发".ntes_localized message:tip delegate:nil cancelButtonTitle:@"取消".ntes_localized otherButtonTitles:@"确认".ntes_localized, nil];
    
    __weak typeof(self) weakSelf = self;
    [alert showAlertWithCompletionHandler:^(NSInteger index) {
        if(index == 1)
        {
            NSError *error = nil;
            if (message.session) {
                [[NIMSDK sharedSDK].chatManager forwardMessage:message toSession:session error:&error];
            } else {
                [[NIMSDK sharedSDK].chatManager sendMessage:message toSession:session error:&error];
            }
            
            if (error) {
                NSString *msg = [NSString stringWithFormat:@"%@.code:%zd",@"转发失败".ntes_localized, error.code];
                [weakSelf.view makeToast:msg duration:2.0 position:CSToastPositionCenter];
            } else {
                [weakSelf.view makeToast:@"已发送".ntes_localized duration:2.0 position:CSToastPositionCenter];
            }
        }
    }];
}

#pragma mark - NIMMessageCellDelegate
- (BOOL)onTapCell:(NIMKitEvent *)event {
    BOOL handled = NO;
    NSString *eventName = event.eventName;
    if ([eventName isEqualToString:NIMKitEventNameTapAudio])
    {
        [self mediaAudioPressed:event.messageModel];
        handled = YES;
    }
    else if ([eventName isEqualToString:NIMKitEventNameTapContent])
    {
        NIMMessage *message = event.messageModel.message;
        NSDictionary *actions = [self cellActions];
        NSString *value = actions[@(message.messageType)];
        if (value) {
            SEL selector = NSSelectorFromString(value);
            if (selector && [self respondsToSelector:selector]) {
                SuppressPerformSelectorLeakWarning([self performSelector:selector withObject:message]);
                handled = YES;
            }
        }
    }
    else if ([eventName isEqualToString:NIMDemoEventNameOpenMergeMessage])
    {
        NIMMessage *message = event.messageModel.message;
        NTESMergeMessageViewController *vc = [[NTESMergeMessageViewController alloc] initWithMessage:message];
        [self.navigationController pushViewController:vc animated:YES];
        handled = YES;
    }
    if (!handled) {
        NSAssert(0, @"invalid event");
    }
    return handled;
}


#pragma mark - Cell Actions
- (NSDictionary *)cellActions
{
    static NSDictionary *actions = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        actions = @{@(NIMMessageTypeImage) :    @"showImage:",
                    @(NIMMessageTypeVideo) :    @"showVideo:",
                    @(NIMMessageTypeLocation) : @"showLocation:",
                    @(NIMMessageTypeFile)  :    @"showFile:",
                    @(NIMMessageTypeCustom):    @"showCustom:"};
    });
    return actions;
}

- (void)mediaAudioPressed:(NIMMessageModel *)messageModel
{
    if (![[NIMSDK sharedSDK].mediaManager isPlaying]) {
        [[NIMSDK sharedSDK].mediaManager switchAudioOutputDevice:NIMAudioOutputDeviceSpeaker];
        [[NIMKitAudioCenter instance] play:messageModel.message];
    } else {
        [[NIMSDK sharedSDK].mediaManager stopPlay];
    }
}

- (void)showImage:(NIMMessage *)message
{
    NIMImageObject *object = message.messageObject;
    NTESGalleryItem *item = [[NTESGalleryItem alloc] init];
    item.thumbPath      = [object thumbPath];
    item.imageURL       = [object url];
    item.name           = [object displayName];
    item.itemId         = [message messageId];
    item.size           = [object size];
    item.imagePath      = [object path];
    
    NIMSession *session = message.session;
    
    NTESGalleryViewController *vc = [[NTESGalleryViewController alloc] initWithItem:item session:session];
    [self.navigationController pushViewController:vc animated:YES];
    if(![[NSFileManager defaultManager] fileExistsAtPath:object.thumbPath]){
        //如果缩略图下跪了，点进看大图的时候再去下一把缩略图
        __weak typeof(self) wself = self;
        [[NIMSDK sharedSDK].resourceManager download:object.thumbUrl filepath:object.thumbPath progress:nil completion:^(NSError *error) {
            if (!error) {
                [wself updateMessage:message];
            }
        }];
    }
}

- (void)showVideo:(NIMMessage *)message
{
    NIMVideoObject *object = message.messageObject;
    NIMSession *session = message.session;
    
    NTESVideoViewItem *item = [[NTESVideoViewItem alloc] init];
    item.path = object.path;
    item.url  = object.url;
    item.session = session;
    item.itemId  = object.message.messageId;
    
    NTESVideoViewController *playerViewController = [[NTESVideoViewController alloc] initWithVideoViewItem:item];
    [self.navigationController pushViewController:playerViewController animated:YES];
    if(![[NSFileManager defaultManager] fileExistsAtPath:object.coverPath]){
        //如果封面图下跪了，点进视频的时候再去下一把封面图
        __weak typeof(self) wself = self;
        [[NIMSDK sharedSDK].resourceManager download:object.coverUrl filepath:object.coverPath progress:nil completion:^(NSError *error) {
            if (!error) {
                [wself updateMessage:message];
            }
        }];
    }
}

- (void)showLocation:(NIMMessage *)message
{
    NIMLocationObject *object = message.messageObject;
    NIMKitLocationPoint *locationPoint = [[NIMKitLocationPoint alloc] initWithLocationObject:object];
    NIMLocationViewController *vc = [[NIMLocationViewController alloc] initWithLocationPoint:locationPoint];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showFile:(NIMMessage *)message
{
    NIMFileObject *object = message.messageObject;
    NTESFilePreViewController *vc = [[NTESFilePreViewController alloc] initWithFileObject:object];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showCustom:(NIMMessage *)message
{
   //普通的自定义消息点击事件可以在这里做哦~
}



#pragma mark - Getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 100, 100) style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _tableView;
}

- (NSMutableArray<NTESMessageModel *> *)items {
    return _dataSource.items;
}

#pragma mark - <NIMChatManagerDelegate>
- (void)fetchMessageAttachment:(NIMMessage *)message progress:(float)progress
{
    [self updateMessage:message];
}

- (void)fetchMessageAttachment:(NIMMessage *)message didCompleteWithError:(NSError *)error
{
    NIMMessageModel *model = nil;
    
    for (id obj in _dataSource.items) {
        
        if (![obj isKindOfClass:[NIMMessageModel class]]) {
            continue;
        }
        model = (NIMMessageModel *)obj;
        if ([model.message.messageId isEqualToString:message.messageId]) {
            model = obj;
            break;
        }
    }
    
    //下完缩略图之后，因为比例有变化，重新刷下宽高。
    [model cleanCache];
    [self updateMessage:message];
}

@end
