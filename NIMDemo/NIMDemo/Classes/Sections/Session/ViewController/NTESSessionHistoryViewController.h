//
//  NTESSessionHistoryViewController.h
//  NIM
//
//  Created by emily on 30/01/2018.
//  Copyright © 2018 Netease. All rights reserved.
//

#import "NIMSessionViewController.h"
#import "NTESSessionConfig.h"
#import "NTESSessionViewController.h"

@interface NTESSessionHistoryConfig : NTESSessionConfig

- (instancetype)initWithSession:(NIMSession *)session firstMsg:(NIMMessage *)msg;

@end

@interface NTESSessionHistoryMessageDataProvider : NSObject<NIMKitMessageProvider>

@property(nonatomic, strong) NIMSession *session;

- (instancetype)initWithSession:(NIMSession *)session firstMsg:(NIMMessage *)msg;

@end


@interface NTESSessionHistoryViewController : NTESSessionViewController

- (instancetype)initWithSession:(NIMSession *)session andSearchMsg:(NIMMessage *)msg;

@end
