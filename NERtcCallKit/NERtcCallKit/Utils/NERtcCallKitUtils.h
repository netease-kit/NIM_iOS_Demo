//
//  NERtcCallKitUtils.h
//  NERtcCallKit
//
//  Created by Wenchao Ding on 2020/11/24.
//  Copyright © 2020 Wenchao Ding. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NERtcCallKitUtils : NSObject

/// 生成信令requestID
+ (NSString *)generateRequestID;

@end

NS_ASSUME_NONNULL_END
