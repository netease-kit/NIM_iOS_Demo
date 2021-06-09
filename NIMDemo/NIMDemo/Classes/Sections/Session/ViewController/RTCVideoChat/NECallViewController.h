//
//  NECallViewController.h
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/8/21.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NERtcCallKit/NERtcCallKit.h>
#import "NEVideoView.h"

NS_ASSUME_NONNULL_BEGIN

@interface NECallViewController : UIViewController<NERtcCallKitDelegate,NEVideoViewDelegate>

/// 如果正在dismiss，提供dismiss完成的回调
@property (nonatomic, copy) void(^dismissCompletion)(void);

/// 初始化ViewController
/// @param member 对方IM账号
/// @param isCalled 是否是被呼叫
/// @param type 语音或视频
- (instancetype)initWithOtherMember:(NSString *)member isCalled:(BOOL)isCalled type:(NERtcCallType)type;

@end

NS_ASSUME_NONNULL_END
