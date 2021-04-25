//
//  NERtcCallKitCompatFactory.h
//  NERtcCallKit
//
//  Created by Wenchao Ding on 2021/4/12.
//  Copyright © 2021 Wenchao Ding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <INERtcCallKitCompat.h>

NS_ASSUME_NONNULL_BEGIN

@interface NERtcCallKitCompatFactory : NSObject

/// 获取默认实例
+ (instancetype)defaultFactory;

/// 根据版本号获取对应的版本兼容
- (id<INERtcCallKitCompat>)compatWithVersion:(NSString *)version;

@end

NS_ASSUME_NONNULL_END
