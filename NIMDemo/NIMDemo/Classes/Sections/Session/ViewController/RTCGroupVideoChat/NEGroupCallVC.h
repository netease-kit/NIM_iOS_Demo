//
//  NEGroupCallVC.h
//  NIM
//
//  Created by I am Groot on 2020/11/6.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NERtcCallKit/NERtcCallKit.h>
#import "NTESTeamMeetingCallerInfo.h"
#import "NTESTeamMeetingCalleeInfo.h"
#import <Toast/UIView+Toast.h>

NS_ASSUME_NONNULL_BEGIN

@interface NEGroupCallVC : UIViewController
@property(strong,nonatomic)NSString *teamId;

/// NEGroupCallVC初始化
/// @param caller 呼叫发起者
/// @param members 群聊起他成员（不包含呼叫者）
/// @param isCalled 是否是被呼叫者
- (instancetype)initWithCaller:(NSString *)caller
                  otherMembers:(NSArray<NSString *> *)otherMembers
                      isCalled:(BOOL)isCalled;
@end

NS_ASSUME_NONNULL_END
