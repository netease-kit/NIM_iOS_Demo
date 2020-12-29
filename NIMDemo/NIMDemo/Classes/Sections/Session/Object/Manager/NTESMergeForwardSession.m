//
//  NTESMergeForwardSession.m
//  NIM
//
//  Created by Netease on 2019/10/16.
//  Copyright © 2019 Netease. All rights reserved.
//

#import "NTESMergeForwardSession.h"
#import "NTESMessageSerialization.h"
#import "NTESMultiRetweetAttachment.h"
#import "NTESSessionMsgConverter.h"
#import "NIMKitInfoFetchOption.h"

#define NTES_Message_Abstract_Count  (2)

typedef void(^NTESMergeForwardTaskResult)(uint64_t identifier, NSError * _Nonnull error, NIMMessage * _Nonnull message);

@interface NTESMergeForwardSession ()

@property (nonatomic, strong) NSMutableDictionary <NSNumber *, NTESMergeForwardTask *> *tasks;

@end

@interface NTESMergeForwardTask ()

@property (nonatomic, assign) uint64_t identifier;
@property (nonatomic, strong) NSMutableArray <NIMMessage *> *messages;
@property (nonatomic, strong) NTESMergeForwardProcess process;
@property (nonatomic, strong) NTESMergeForwardTaskResult completion;
@property (nonatomic, strong) NTESMessageSerialization *serialize;

@end

@implementation NTESMergeForwardSession
- (instancetype)init {
    if (self = [super init]) {
        _tasks = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NTESMergeForwardTask *)forwardTaskWithMessages:(NSMutableArray <NIMMessage *> *)messages
                                          process:(NTESMergeForwardProcess)process
                                       completion:(NTESMergeForwardResult)completion {
    NTESMergeForwardTask *task = [[NTESMergeForwardTask alloc] init];
    task.messages = messages;
    task.process = process;

    __weak typeof(self) weakSelf = self;
    task.completion = ^(uint64_t identifier, NSError *error, NIMMessage *message) {
        if (completion) {
            completion(error, message);
        }
        weakSelf.tasks[@(identifier)] = nil;
    };
    _tasks[@(task.identifier)] = task;
    return task;
}

@end


@implementation NTESMergeForwardTask

- (instancetype)init {
    if (self = [super init]) {
        _identifier = (uint64_t)self;
        _serialize = [[NTESMessageSerialization alloc] init];
    }
    return self;
}

- (void)resume {
    NSError *error = nil;
    __block NIMMessage *message = nil;
    if (_messages.count == 0) {
        error = [NSError errorWithDomain:@"nim.demo.mergeforward.task" code:1000 userInfo:nil];
        if (_completion) {
            _completion(_identifier, error, message);
        }
        return;
    }
    
    //时间戳排序
    [_messages sortUsingComparator:^NSComparisonResult(NIMMessage *_Nonnull obj1, NIMMessage * _Nonnull obj2) {
        if (obj1.timestamp < obj2.timestamp) {
            return NSOrderedAscending;
        } else {
            return NSOrderedDescending;
        }
    }];
    
    //序列化
    __weak typeof(self) weakSelf = self;
    NSString *password = [self getRandomRCKey];
    [_serialize encode:_messages encrypt:YES password:password completion:^(NSError * _Nullable error, NTESMessageSerializationInfo * _Nullable info) {
        if (error) {
            if (weakSelf.completion) {
                weakSelf.completion(weakSelf.identifier, error, message);
            }
        } else {
            NTESMultiRetweetAttachment *attach = [[NTESMultiRetweetAttachment alloc] init];
            attach.fileName = info.filePath.lastPathComponent;
            attach.md5 = info.md5;
            attach.compressed = info.compressed;
            attach.encrypted = info.encrypted;
            attach.password = info.password;
            attach.abstracts = [weakSelf messageAbstract:weakSelf.messages];
            if (attach.messageAbstract.count == 0) {
                error = [NSError errorWithDomain:@"nim.demo.mergeforward.task" code:1001 userInfo:nil];
            } else {;
                //show name
                NIMSession *fromSession = [weakSelf.messages firstObject].session;
                NIMKitInfoFetchOption *option = [[NIMKitInfoFetchOption alloc] init];
                option.session = fromSession;
                NIMKitInfo *info = nil;
                if (fromSession.sessionType == NIMSessionTypeP2P) {
                    NSString *userId = [[NIMSDK sharedSDK].loginManager currentAccount];
                    info = [[NIMKit sharedKit].provider infoByUser:userId option:option];
                } else if (fromSession.sessionType == NIMSessionTypeTeam){
                    info = [[NIMKit sharedKit].provider infoByTeam:fromSession.sessionId option:option];
                } else if (fromSession.sessionType == NIMSessionTypeSuperTeam) {
                    info = [[NIMKit sharedKit].provider infoBySuperTeam:fromSession.sessionId option:option];
                }
                attach.sessionName = info.showName ?: @"null";
                attach.sessionId = fromSession.sessionId;
                
                //message
                message = [NTESSessionMsgConverter msgWithMultiRetweetAttachment:attach];
            }
            if (weakSelf.completion) {
                weakSelf.completion(weakSelf.identifier, error, message);
            }
        }
    }];
}

- (NSMutableArray <NTESMessageAbstract *> *)messageAbstract:(NSArray <NIMMessage *> *)messages {
    NSMutableArray <NTESMessageAbstract *> *abstracts = [NSMutableArray array];
    for (NIMMessage *message in _messages) {
        if (abstracts.count == NTES_Message_Abstract_Count) {
            break;
        }
        NTESMessageAbstract *abstract = [NTESMessageAbstract abstractWithMessage:message];
        
        
        
        if (abstract) {
            [abstracts addObject:abstract];
        }
    }
    return abstracts;
}

-(NSString *)getRandomRCKey
{
    char data[16] = {0};
    for (int x=0; x < sizeof(data); data[x++] = (char)('a' + (arc4random_uniform(26))));
    NSString *randomStr = [[NSString alloc] initWithBytes:data length:sizeof(data) encoding:NSUTF8StringEncoding];
    NSString *string = [NSString stringWithFormat:@"%@",randomStr];
    return string;
}



@end

