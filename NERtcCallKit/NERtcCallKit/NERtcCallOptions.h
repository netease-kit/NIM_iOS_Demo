//
//  NERtcCallOptions.h
//  NLiteAVDemo
//
//  Created by Wenchao Ding on 2020/10/28.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NERtcCallOptions : NSObject

/// 推送证书名称
@property (nonatomic, copy) NSString *APNSCerName;

/// 呼叫推送证书名称
@property (nonatomic, copy) NSString *VoIPCerName;

@end

NS_ASSUME_NONNULL_END
