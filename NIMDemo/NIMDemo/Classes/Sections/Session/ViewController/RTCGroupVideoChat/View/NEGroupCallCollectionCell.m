//
//  NEGroupCallCollectionCell.m
//  NIM
//
//  Created by I am Groot on 2020/11/7.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NEGroupCallCollectionCell.h"

@interface NEGroupCallCollectionCell ()
//是否点选禁听，默认不禁听
@property(assign,nonatomic)BOOL isSelected;
@end

@implementation NEGroupCallCollectionCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
//        [self addGestureRecognizer];
    }
    return self;
}
- (void)initUI {
    [self.contentView addSubview:self.videoView];
    [self.contentView addSubview:self.cameraTip];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.muteImageView];
    [self.videoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView.mas_leading);
        make.trailing.equalTo(self.contentView.mas_trailing);
        make.top.equalTo(self.contentView.mas_top);
        make.bottom.equalTo(self.contentView.mas_bottom);
    }];
    [self.cameraTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.centerY.mas_equalTo(0);
        make.height.mas_equalTo(40);
    }];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(40);
    }];
    [self.muteImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self.contentView).offset(5);
        make.size.width.equalTo(@(20));
        make.size.height.equalTo(@(20));
    }];
}

//添加点击手势
-(void)onPressUtilImage {
    self.isSelected = !self.isSelected;
    self.muteImageView.image = self.isSelected?[UIImage imageNamed:@"call_disable_listen"]:[UIImage imageNamed:@"call_listen"];
}
- (UIView *)videoView {
    if (!_videoView) {
        _videoView = [[UIView alloc] init];
        _videoView.backgroundColor = [UIColor grayColor];
    }
    return _videoView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _nameLabel;
}
- (UILabel *)cameraTip {
    if (!_cameraTip) {
        _cameraTip = [[UILabel alloc] init];
        _cameraTip.textAlignment = NSTextAlignmentCenter;
        _cameraTip.textColor = [UIColor whiteColor];
        _cameraTip.text = @"等待接听";
        _cameraTip.font = [UIFont systemFontOfSize:14.0];
        _cameraTip.adjustsFontSizeToFitWidth = YES;
        _cameraTip.numberOfLines = 0;
    }
    return _cameraTip;
}

- (UIImageView *)muteImageView {
    if (!_muteImageView) {
        _muteImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _muteImageView.image = [UIImage imageNamed:@"call_listen"];
//        _muteImageView.hidden = YES;

    }
    return _muteImageView;
}

@end
