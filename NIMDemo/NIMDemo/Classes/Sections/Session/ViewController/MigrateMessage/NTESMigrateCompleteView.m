//
//  NTESMigrateCompleteView.m
//  NIM
//
//  Created by Sampson on 2018/12/11.
//  Copyright © 2018 Netease. All rights reserved.
//

#import "NTESMigrateCompleteView.h"

@interface NTESMigrateCompleteView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;

@end

@implementation NTESMigrateCompleteView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.font = [UIFont systemFontOfSize:20];
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        self.titleLabel = label;
        
        label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.textAlignment = NSTextAlignmentCenter;
        label.minimumScaleFactor = 0.6;
        [self addSubview:label];
        self.messageLabel = label;
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [self addSubview:button];
        self.actionButton = button;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    const CGRect bounds = self.bounds;
    
    CGFloat y = CGRectGetMidY(bounds) - 80;
    CGFloat x = 12;
    CGFloat width = CGRectGetWidth(bounds) - x * 2;
    self.titleLabel.frame = CGRectMake(x, y, width, 40);
    
    y += 40;
    self.messageLabel.frame = CGRectMake(x, y, width, 30);
    
    y += 60;
    self.actionButton.frame = CGRectMake(x, y, width, 44);
}

- (void)setTitle:(NSString *)title {
    _title = [title copy];
    self.titleLabel.text = title;
}

- (void)setMessage:(NSString *)message {
    _message = [message copy];
    self.messageLabel.text = message;
}

@end
