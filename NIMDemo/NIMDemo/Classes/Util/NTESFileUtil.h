//
//  NTESFileUtil.h
//  NIM
//
//  Created by Netease on 2019/10/17.
//  Copyright © 2019 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NTESFileUtil : NSObject

+ (nullable NSString *)fileMD5:(NSString *)filepath;

+ (void)fileMD5:(NSString *)filepath completion:(void(^)(NSString *MD5))completion;

@end

NS_ASSUME_NONNULL_END
