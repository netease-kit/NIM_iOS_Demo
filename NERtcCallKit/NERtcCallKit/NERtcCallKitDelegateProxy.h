//
//  NERtcCallKitDelegateProxy.h
//  NLiteAVDemo
//
//  Created by Wenchao Ding on 2020/10/28.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NERtcCallKit.h"

NS_ASSUME_NONNULL_BEGIN

@interface NERtcCallKitDelegateProxy : NSProxy<NERtcCallKitDelegate>

@property (nonatomic, strong) NSHashTable<id<NERtcCallKitDelegate>> *weakDelegates;

- (instancetype)init;

- (void)addDelegate:(id<NERtcCallKitDelegate>)delegate;

- (void)removeDelegate:(id<NERtcCallKitDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
