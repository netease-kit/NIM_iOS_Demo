//
//  NTESThreadSessionConfig.h
//  NIM
//
//  Created by He on 2020/4/12.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NTESSessionConfig.h"

@class NIMMessage;
NS_ASSUME_NONNULL_BEGIN

@interface NTESThreadSessionConfig : NTESSessionConfig

- (instancetype)initWithMessage:(NIMMessage *)message;

@end

@interface NTESThreadDataSourceProvider : NSObject <NIMKitMessageProvider>

@property (nonatomic,strong) NIMMessage *threadMessage;

@end

NS_ASSUME_NONNULL_END
