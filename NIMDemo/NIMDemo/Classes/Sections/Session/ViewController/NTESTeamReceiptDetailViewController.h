//
//  NTESTeamReceiptDetailViewController.h
//  NIM
//
//  Created by chris on 2018/3/14.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NTESTeamReceiptDetailViewController : UIViewController

@property(nonatomic, strong) IBOutlet UISegmentedControl *segmentControl;

@property(nonatomic, strong) IBOutlet UICollectionView *unreadUsers;

@property(nonatomic, strong) IBOutlet UICollectionView *readUsers;

- (instancetype)initWithMessage:(NIMMessage *)message;

@end
