//
//  NTESMessageUtil.h
//  NIM
//
//  Created by Netease on 2019/10/17.
//  Copyright © 2019 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTESSnapchatAttachment.h"
#import "NTESJanKenPonAttachment.h"
#import "NTESChartletAttachment.h"
#import "NTESWhiteboardAttachment.h"
#import "NTESRedPacketAttachment.h"
#import "NTESRedPacketTipAttachment.h"
#import "NTESMultiRetweetAttachment.h"

NS_ASSUME_NONNULL_BEGIN

@interface NTESMessageUtil : NSObject

+ (NSString *)messageContent:(NIMMessage *)message;

@end

NS_ASSUME_NONNULL_END
