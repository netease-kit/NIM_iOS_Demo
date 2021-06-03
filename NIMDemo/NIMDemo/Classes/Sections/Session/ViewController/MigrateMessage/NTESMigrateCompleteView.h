//
//  NTESMigrateCompleteView.h
//  NIM
//
//  Created by Sampson on 2018/12/11.
//  Copyright © 2018 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NTESMigrateCompleteView : UIView

@property (nonatomic, nullable, copy) NSString *title;
@property (nonatomic, nullable, copy) NSString *message;
@property (nonatomic, strong) UIButton *actionButton;

@end

NS_ASSUME_NONNULL_END
