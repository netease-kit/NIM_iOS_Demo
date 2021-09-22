//
//  NECustomNavigationBar.m
//  NIM
//
//  Created by Wenchao Ding on 2021/3/30.
//  Copyright © 2021 Netease. All rights reserved.
//

#import "NECustomNavigationBar.h"

@implementation NECustomNavigationBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.barTintColor = UIColor.whiteColor;
        self.backgroundColor = UIColor.whiteColor;
        self.tintColor = UIColor.darkGrayColor;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.frame = CGRectOffset(obj.frame, 0, 20);
    }];
}

@end
