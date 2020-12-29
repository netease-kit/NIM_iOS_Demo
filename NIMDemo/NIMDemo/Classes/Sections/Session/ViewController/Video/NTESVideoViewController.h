//
//  NTESVideoViewController.h
//  NIM
//
//  Created by chris on 15/4/12.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NTESAVMoivePlayerController.h"

@interface NTESVideoViewItem : NSObject

@property (nonatomic,copy) NSString *itemId;//message Id

@property (nonatomic,copy) NSString *path;

@property (nonatomic,copy) NSString *url;

@property (nonatomic,strong) NIMSession *session;

@end

@interface NTESVideoViewController : UIViewController

- (instancetype)initWithVideoViewItem:(NTESVideoViewItem *)item;

@property (nonatomic, readonly) NTESAVMoivePlayerController *avPlayer;

@end
