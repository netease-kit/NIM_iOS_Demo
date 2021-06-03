//
//  NTESThreadSessionConfig.m
//  NIM
//
//  Created by He on 2020/4/12.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NTESThreadSessionConfig.h"
#import "NTESBundleSetting.h"

@interface NTESThreadSessionConfig ()

@property (nonatomic,strong) NTESThreadDataSourceProvider *provider;

@property (nonatomic,strong) NIMMessage *threadMessage;

@end

@implementation NTESThreadSessionConfig

- (instancetype)initWithMessage:(NIMMessage *)message
{
    self = [super init];
    if (self)
    {
        _threadMessage = message;
        _provider = [[NTESThreadDataSourceProvider alloc] init];
        _provider.threadMessage = message;
    }
    return self;
}

- (id<NIMKitMessageProvider>)messageDataProvider
{
    return self.provider;
}

- (BOOL)needShowReplyContent
{
    return NO;
}

- (BOOL)shouldShowPinContent
{
    return NO;
}

- (BOOL)needShowQuickComments
{
    return NO;
}

- (void)cleanThreadMessage
{
    _threadMessage = nil;
}

- (NIMMessage *)threadMessage
{
    return _threadMessage;
}

- (BOOL)clearThreadMessageAfterSent
{
    return NO;
}

@end

@interface NTESThreadDataSourceProvider ()

@property (nonatomic,assign) BOOL didInsertThreadMessage;

@end

@implementation NTESThreadDataSourceProvider

- (void)pullDown:(NIMMessage *)firstMessage handler:(NIMKitDataProvideHandler)handler
{
    BOOL enablePullCloudMessages = [[NTESBundleSetting sharedConfig] enablePullSubMessagesFromServer];
    if (!enablePullCloudMessages)
    {
        NSArray *array = [[NIMSDK sharedSDK].chatExtendManager subMessages:self.threadMessage];
        if (!self.didInsertThreadMessage && self.threadMessage)
        {
            NSMutableArray *tmp = [NSMutableArray arrayWithArray:array];
            [tmp insertObject:self.threadMessage atIndex:0];
            array = tmp;
            self.didInsertThreadMessage = YES;
        }
        
        if (handler)
        {
            handler(nil, array);
        }
    }
    else
    {
        NIMThreadTalkFetchOption *option = [[NIMThreadTalkFetchOption alloc] init];
        option.limit = 100;
        option.excludeMessage = firstMessage;
        option.end = firstMessage.timestamp;
        option.sync = YES;
        option.reverse = NO;
         
         [[NIMSDK sharedSDK].chatExtendManager fetchSubMessagesFrom:self.threadMessage option:option completion:^(NSError * error, NIMThreadTalkFetchResult * result)
         {
             if (!self.didInsertThreadMessage && self.threadMessage)
             {
                 NSMutableArray *tmp = [NSMutableArray arrayWithArray:result.subMessages];
                 [tmp insertObject:self.threadMessage atIndex:0];
                 result.subMessages = tmp;
                 self.didInsertThreadMessage = YES;
             }
             
            result.subMessages = [result.subMessages sortedArrayUsingComparator:^NSComparisonResult(NIMMessage  * obj1, NIMMessage  * obj2) {
                return obj1.timestamp < obj2.timestamp ? NSOrderedAscending : NSOrderedDescending;

             }];
             
             if (handler)
             {
                 handler(error, result.subMessages);
             }
         }];
    }
}

@end
