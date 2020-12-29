//
//  NTESMergeMessageViewController.h
//  NIM
//
//  Created by zhanggenning on 2019/10/18.
//  Copyright © 2019 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NTESMultiRetweetAttachment.h"


NS_ASSUME_NONNULL_BEGIN

@interface NTESMergeMessageViewController : UIViewController

- (instancetype)initWithMessage:(NIMMessage *)message;

@end

NS_ASSUME_NONNULL_END
