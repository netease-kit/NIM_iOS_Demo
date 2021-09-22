//
//  NEGroupCallView.h
//  NIM
//
//  Created by I am Groot on 2020/11/7.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NECustomButton.h"

NS_ASSUME_NONNULL_BEGIN

@protocol NEGroupCallViewDelegate <NSObject>

- (void)accept:(NECustomButton *)button;
- (void)reject:(NECustomButton *)button;

@end

@interface NEGroupCallView : UIView
@property(weak,nonatomic)id <NEGroupCallViewDelegate>delegate;

@property(strong,nonatomic)UILabel *titleLabel;
/// 拒绝接听
@property(strong,nonatomic)NECustomButton *rejectBtn;
/// 接听
@property(strong,nonatomic)NECustomButton *acceptBtn;
@end

NS_ASSUME_NONNULL_END
