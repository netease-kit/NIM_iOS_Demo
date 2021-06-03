//
//  NTESThreadTalkSessionViewController.h
//  NIM
//
//  Created by He on 2020/4/12.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NTESSessionViewController.h"

@class NIMMessage;
NS_ASSUME_NONNULL_BEGIN

@interface NTESThreadTalkSessionViewController : NTESSessionViewController

- (instancetype)initWithThreadMessage:(NIMMessage *)message;

@end

NS_ASSUME_NONNULL_END
