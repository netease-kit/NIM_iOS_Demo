//
//  UITextView+NTES.h
//  NIM
//
//  Created by chris on 2018/3/20.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextView (NTES)

@property (nonatomic, strong) NSString* placeholder;
@property (nonatomic, strong) UILabel * placeholderLabel;
@property (nonatomic, strong) NSString* textValue;

@end
