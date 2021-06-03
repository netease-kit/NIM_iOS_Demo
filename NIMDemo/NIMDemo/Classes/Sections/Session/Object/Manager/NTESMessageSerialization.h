//
//  NTESMessageSerialization.h
//  NIM
//
//  Created by Netease on 2019/10/16.
//  Copyright © 2019 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class NTESMessageSerializationInfo;

typedef void(^NTESMessageEncodeResult)(NSError * _Nullable error, NTESMessageSerializationInfo * _Nullable info);
typedef void(^NTESMessageDecodeResult)(NSError * _Nullable error, NSMutableArray<NIMMessage *> * _Nullable messages);

@interface NTESMessageSerialization : NSObject

- (void)encode:(NSArray <NIMMessage *>*)messages
       encrypt:(BOOL)encrypt
      password:(NSString *)password
    completion:(NTESMessageEncodeResult)completion;

- (void)decode:(NSString *)filePath
       encrypt:(BOOL)encrypt
      password:(NSString *)password
    completion:(NTESMessageDecodeResult)completion;

@end

@interface NTESMessageSerializationInfo : NSObject

@property (nonatomic, copy) NSString *filePath;

@property (nonatomic, copy) NSString *md5;

@property (nonatomic, assign) BOOL encrypted;

@property (nonatomic, copy) NSString *password;

@property (nonatomic, assign) BOOL compressed;

@end

NS_ASSUME_NONNULL_END
