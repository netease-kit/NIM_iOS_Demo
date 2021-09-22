//
//  NTESRtcTokenUtils.h
//  NERtcDemo
//
//  Created by Sampson on 2019/4/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^NTESRtcTokenRequestHandler)(NSError * _Nullable error, NSString * _Nullable token);

@interface NTESRtcTokenUtils : NSObject

+ (instancetype)sharedInstance;

- (void)requestTokenWithUid:(uint64_t)myUid
                     appKey:(NSString *)appKey
                 completion:(NTESRtcTokenRequestHandler)completion;

@end

NS_ASSUME_NONNULL_END
