//
//  JrmfGetCustomerInfo.h
//  JrmfPacketKit
//
//  Created by Criss on 2017/12/13.
//  Copyright © 2017年 JYang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


/**
 用户部分信息

 @param uImageStr 用户头像地址 支持网络链接或本地链接
 */
typedef void(^GetUserInfo)(NSString * uImageStr);

@protocol JrmfGetCustomerInfo <NSObject>

@required
/**
 外部获取用户信息

 @param cId 用户id
 @param block 用户信息回调 包含用户
 */
+ (void)getCustomerInfoWith:(NSString *)cId complate:(GetUserInfo)block;

@end
