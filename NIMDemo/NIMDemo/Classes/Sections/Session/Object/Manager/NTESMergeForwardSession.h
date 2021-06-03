//
//  NTESMergeForwardSession.h
//  NIM
//
//  Created by Netease on 2019/10/16.
//  Copyright © 2019 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^NTESMergeForwardProcess)(CGFloat process);
typedef void(^NTESMergeForwardResult)(NSError * _Nonnull error, NIMMessage * _Nonnull message);


@interface NTESMergeForwardTask : NSObject

- (void)resume;

@end

@interface NTESMergeForwardSession : NSObject

- (NTESMergeForwardTask *)forwardTaskWithMessages:(NSMutableArray <NIMMessage *> *)messages
                                          process:(_Nullable NTESMergeForwardProcess)process
                                       completion:(_Nullable NTESMergeForwardResult)completion;

@end

NS_ASSUME_NONNULL_END
