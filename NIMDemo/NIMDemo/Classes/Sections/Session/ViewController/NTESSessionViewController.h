//
//  NTESSessionViewController.h
//  NIM
//
//  Created by amao on 8/11/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMSessionViewController.h"

extern NSString *kNTESDemoRevokeMessageFromMeNotication;

@interface NTESSessionViewController : NIMSessionViewController

@property (nonatomic,assign) BOOL disableCommandTyping;  //需要在导航条上显示“正在输入”

@property (nonatomic,assign) BOOL disableOnlineState;  //需要在导航条上显示在线状态

@property (nonatomic,copy) NSString *revokeAttach;     //撤回附带内容
/// 是否正在查看阅后即焚
@property(assign,nonatomic)BOOL isPreviewSnappicture;

@end
