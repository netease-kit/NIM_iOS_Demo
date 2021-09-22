//
//  NEGroupCallView.m
//  NIM
//
//  Created by I am Groot on 2020/11/7.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NEGroupCallView.h"

@implementation NEGroupCallView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}
- (void)initUI {
    [self addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_centerY).offset(-50);
        make.centerX.mas_equalTo(self.mas_centerX);
        make.left.mas_equalTo(60);
        make.height.mas_equalTo(25);
    }];
    /// 接听和拒接按钮
    [self addSubview:self.rejectBtn];
    [self.rejectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX).offset(-80);
        make.bottom.mas_equalTo(self.mas_bottom).offset(-80);
        make.size.mas_equalTo(CGSizeMake(75, 103));
    }];
    [self addSubview:self.acceptBtn];
    [self.acceptBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX).offset(80);
        make.bottom.mas_equalTo(self.mas_bottom).offset(-80);
        make.size.mas_equalTo(CGSizeMake(75, 103));
    }];
    
}
- (void)rejectEvent:(NECustomButton *)button {
    self.acceptBtn.userInteractionEnabled = NO;
    if ([self.delegate respondsToSelector:@selector(reject:)]) {
        [self.delegate reject:button];
    }
}

- (void)acceptEvent:(NECustomButton *)button {
    self.rejectBtn.userInteractionEnabled = NO;
    self.acceptBtn.userInteractionEnabled = NO;
    if ([self.delegate respondsToSelector:@selector(accept:)]) {
        [self.delegate accept:button];
    }
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont boldSystemFontOfSize:18];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}
- (NECustomButton *)rejectBtn {
    if (!_rejectBtn) {
        _rejectBtn = [[NECustomButton alloc] init];
        _rejectBtn.titleLabel.text = @"拒绝";
        _rejectBtn.exclusiveTouch = YES;
        _rejectBtn.imageView.image = [UIImage imageNamed:@"call_cancel"];
        [_rejectBtn addTarget:self action:@selector(rejectEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rejectBtn;
}
- (NECustomButton *)acceptBtn {
    if (!_acceptBtn) {
        _acceptBtn = [[NECustomButton alloc] init];
        _acceptBtn.exclusiveTouch = YES;
        _acceptBtn.titleLabel.text = @"接听";
        _acceptBtn.imageView.image = [UIImage imageNamed:@"call_accept"];
        _acceptBtn.imageView.contentMode = UIViewContentModeCenter;
        [_acceptBtn addTarget:self action:@selector(acceptEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _acceptBtn;
}
@end
