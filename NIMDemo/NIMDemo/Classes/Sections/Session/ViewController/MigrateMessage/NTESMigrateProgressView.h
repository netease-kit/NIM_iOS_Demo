//
//  NTESMigrateProgressView.h
//  NIM
//
//  Created by Sampson on 2018/12/11.
//  Copyright © 2018 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NTESMigrateProgressView : UIView

@property (nonatomic, copy) NSString *tip;
@property (nonatomic, assign) float progress;
@property (nonatomic, strong) UIButton *stopButton;

@end

NS_ASSUME_NONNULL_END
