//
//  NTESThreadTalkSessionViewController.m
//  NIM
//
//  Created by He on 2020/4/12.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NTESThreadTalkSessionViewController.h"
#import "NTESThreadSessionConfig.h"

@interface NTESThreadTalkSessionViewController ()
@property (nonatomic,strong) NIMMessage *threadMesssage;
@property (nonatomic,strong) NTESThreadSessionConfig *sessionConfig;
@end

@implementation NTESThreadTalkSessionViewController

- (instancetype)initWithThreadMessage:(NIMMessage *)message
{
    self = [super initWithSession:message.session];
    if (self)
    {
        _threadMesssage = message;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setupNormalNav
{
}

- (NSString *)sessionTitle
{
    return @"回复详情".ntes_localized;
}

//接收消息

- (void)willSendMessage:(NIMMessage *)message
{
    if (![self shouldReceive:message])
    {
        return;
    }
    [super willSendMessage:message];
}

//发送结果
- (void)sendMessage:(NIMMessage *)message didCompleteWithError:(NSError *)error
{
    if (![self shouldReceive:message])
    {
       return;
    }
    
    [super sendMessage:message didCompleteWithError:error];
}


//发送进度
-(void)sendMessage:(NIMMessage *)message progress:(float)progress
{
     if (![self shouldReceive:message])
     {
         return;
     }
    
    [super sendMessage:message progress:progress];
}

- (void)onRecvMessages:(NSArray *)messages
{
    NSMutableArray *subMessages = [NSMutableArray array];
    for (NIMMessage *message in messages)
    {
        if ([self shouldReceive:message])
        {
            [subMessages addObject:message];
        }
    }
    if (subMessages.count == 0)
    {
        return;
    }
    [super onRecvMessages:messages];
}

- (void)fetchMessageAttachment:(NIMMessage *)message progress:(float)progress
{
    if (![self shouldReceive:message])
    {
        return;
    }
    
    [super fetchMessageAttachment:message progress:progress];
}

- (void)fetchMessageAttachment:(NIMMessage *)message didCompleteWithError:(NSError *)error
{
    if (![self shouldReceive:message])
    {
        return;
    }
    
    [super fetchMessageAttachment:message didCompleteWithError:error];
}

- (void)onRecvMessageReceipts:(NSArray<NIMMessageReceipt *> *)receipts
{
}


- (BOOL)shouldReceive:(NIMMessage *)message
{
    BOOL should = [message.session isEqual:self.session] &&
    [message.threadMessageId isEqualToString:self.threadMesssage.messageId];
    should = should || [message.messageId isEqualToString:self.threadMesssage.messageId];

    return should;
}

- (id<NIMSessionConfig>)sessionConfig
{
    if (_sessionConfig == nil) {
        _sessionConfig = [[NTESThreadSessionConfig alloc] initWithMessage:self.threadMesssage];
        _sessionConfig.session = self.session;
    }
    return _sessionConfig;
}

#pragma mark - Override
- (void)onClickReplyButton:(NIMMessage *)message
{
    
}

- (BOOL)onLongPressCell:(NIMMessage *)message
                 inView:(UIView *)view
{
    return YES;
}

@end
