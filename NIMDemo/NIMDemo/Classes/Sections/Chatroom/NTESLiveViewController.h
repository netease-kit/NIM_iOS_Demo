//
//  NTESLiveViewController.h
//  NIM
//
//  Created by chris on 15/12/16.
//  Copyright © 2015年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NTESLiveViewController : UIViewController

@property (nonatomic, readonly)   NIMChatroom *chatroom;

- (instancetype)initWithChatroom:(NIMChatroom *)chatroom;

@end
