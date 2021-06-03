//
//  NTESMigrateHeader.h
//  NIM
//
//  Created by Netease on 2019/10/16.
//  Copyright © 2019 Netease. All rights reserved.
//
//   内容为json格式字符串，保存记录导出的终端类型、sdk版本号、app版本号(由用户提供/自己获取)，头信息存储在文本文件的第一行 。
//   示例
//   {
//     "version":0，//必填,文件格式版本
//     "terminal": 1,//选填
//     "sdk_version": "7.0.0.1330",//选填
//     "app_version": "1.0.8.9",//选填
//     "message_count": 1234   //必填,最终写入文件中的消息数
//   }


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NTESMigrateHeader : NSObject

@property (nonatomic, assign) NSInteger version;

@property (nonatomic, assign) NIMLoginClientType clientType;

@property (nonatomic, copy) NSString *sdkVersion;

@property (nonatomic, copy) NSString *appVersion;

@property (nonatomic, assign) NSInteger totalInfoCount;

+ (instancetype)initWithDefaultConfig;

+ (nullable instancetype)initWithRawContent:(NSData *)data;

- (nullable NSData *)toRawContent;

@end

NS_ASSUME_NONNULL_END
