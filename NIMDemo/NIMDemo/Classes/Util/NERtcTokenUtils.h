//
//  NTESRtcTokenUtils.h
//  NERtcDemo
//
//  Created by Sampson on 2019/4/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^NTESDemoRequestHandler)(NSString * _Nullable channelName, NSError * _Nullable error, NSString * _Nullable token);

@interface NTESRtcTokenUtils : NSObject

+ (void)requestTokenWithChannelName:(NSString *)channelName
                              myUid:(uint64_t)myUid
                             appKey:(NSString *)appKey
                         completion:(NTESDemoRequestHandler)completion;

@end

NS_ASSUME_NONNULL_END
