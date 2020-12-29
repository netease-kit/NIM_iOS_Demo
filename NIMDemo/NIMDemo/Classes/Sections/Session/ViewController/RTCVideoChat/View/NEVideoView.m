//
//  NEVideoView.m
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/8/26.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NEVideoView.h"

@implementation NEVideoView
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        [self addSubview:self.videoView];
        [self.videoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
        [self addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
        [self addTapGesture];
    }
    return self;
}
- (void)addTapGesture {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEvent:)];
    [self addGestureRecognizer:tap];
}
- (void)tapEvent:(UITapGestureRecognizer *)tap {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapVideoView:)]) {
        [self.delegate didTapVideoView:self];
    }
}
- (void)becomeBig {
    self.isSmall = NO;
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.right.mas_equalTo(0);
        make.size.mas_equalTo([UIScreen mainScreen].bounds.size);
    }];
}

- (void)becomeSmall {
    self.isSmall = YES;
    CGFloat statusHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(statusHeight + 20);
        make.right.mas_equalTo(-20);
        make.size.mas_equalTo(CGSizeMake(90, 160));
    }];
}
- (UIView *)videoView {
    if (!_videoView) {
        _videoView = [[UIView alloc] init];
    }
    return _videoView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:20];
        _titleLabel.numberOfLines = 0;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.backgroundColor = [UIColor blackColor];
        _titleLabel.hidden = YES;
    }
    return _titleLabel;
}
@end
