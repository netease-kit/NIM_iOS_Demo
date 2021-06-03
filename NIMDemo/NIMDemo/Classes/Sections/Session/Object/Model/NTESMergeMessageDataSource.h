//
//  NTESMergeMessageDataSource.h
//  NIM
//
//  Created by zhanggenning on 2019/10/18.
//  Copyright © 2019 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NTESMessageModel;
@class NTESMultiRetweetAttachment;

NS_ASSUME_NONNULL_BEGIN

@interface NTESMergeMessageDataSource : NSObject

@property (nonatomic, strong) NSMutableArray<NTESMessageModel *> *items;

- (void)pullDataWithAttachment:(NTESMultiRetweetAttachment *)attachment
                    completion:(void (^)(NSString *msg))complete;

- (NSIndexPath * _Nullable)updateMessage:(NIMMessage *)message;

- (NTESMessageModel *)setupMessageModel:(NIMMessage *)message;

- (NSMutableArray<NTESMessageModel *> *)itemsWithMessages:(NSMutableArray <NIMMessage *> *)messages;

@end

NS_ASSUME_NONNULL_END
