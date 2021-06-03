//
//  NTESMultiRetweetAttachment.h
//  NIM
//
//  Created by Netease on 2019/10/16.
//  Copyright © 2019 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTESCustomAttachmentDefines.h"

NS_ASSUME_NONNULL_BEGIN

@class NTESMessageAbstract;

@interface NTESMultiRetweetAttachment : NSObject<NIMCustomAttachment,NTESCustomAttachmentInfo>

@property (nonatomic,copy) NSString *md5;

@property (nonatomic,copy) NSString *url;

@property (nonatomic,assign) BOOL compressed;

@property (nonatomic,assign) BOOL encrypted;

@property (nonatomic,copy) NSString *password;

@property (nonatomic,copy) NSString *sessionName;

@property (nonatomic,copy) NSString *sessionId;

@property (nonatomic,copy) NSArray *messageAbstract;

@property (nonatomic,strong) NSMutableArray <NTESMessageAbstract *> *abstracts;

@property (nonatomic,copy) NSString *fileName;

@property (nonatomic,readonly) NSString * _Nullable filePath;

- (NSString *)formatTitleMessage;

- (NSString *)formatAbstractMessage:(NTESMessageAbstract *)abstract;

@end

@interface NTESMessageAbstract : NSObject

@property (nonatomic, copy) NSString *sender;

@property (nonatomic, copy) NSString *message;

+ (instancetype)abstractWithMessage:(NIMMessage *)message;

+ (instancetype)abstractWithDictionary:(NSDictionary *)content;

- (nullable NSDictionary *)abstractDictionary;

@end

NS_ASSUME_NONNULL_END
