//
//  NTESTimestampCell.m
//  NIM
//
//  Created by zhanggenning on 2019/10/18.
//  Copyright © 2019 Netease. All rights reserved.
//

#import "NTESTimestampCell.h"
#import "UIView+NTES.h"
#import "NIMTimestampModel.h"

@interface NTESTimestampCell ()

@property (nonatomic, strong) UIView *lineLeft;
@property (nonatomic, strong) UIView *lineRight;

@end

@implementation NTESTimestampCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.timeBGView removeFromSuperview];
        self.timeLabel.textColor = [NIMKit sharedKit].config.nickColor;
        self.backgroundColor = UIColorFromRGB(0xfefefe);
        [self.contentView addSubview:self.lineLeft];
        [self.contentView addSubview:self.lineRight];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat padding = 8.0;
    self.timeLabel.centerY = self.height/2;
    _lineLeft.frame = CGRectMake(padding, 0.0, self.timeLabel.left - padding*2, 1.0);
    _lineLeft.centerY = self.timeLabel.centerY;
    _lineRight.frame = CGRectMake(self.timeLabel.right + padding, 0, self.width - self.timeLabel.right - 2*padding, 1.0);
    _lineRight.centerY = self.timeLabel.centerY;
}

- (void)refreshData:(NIMTimestampModel *)data {
    if ([data isKindOfClass:[NIMTimestampModel class]]) {
        self.timeLabel.text = [self timeFormatString:data.messageTime];
    }
}

- (NSString *)timeFormatString:(NSTimeInterval)timestamp {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    return [formatter stringFromDate: date];
}

#pragma mark - Getter
- (UIView *)lineLeft {
    if (!_lineLeft) {
        _lineLeft = [self setupLine];
    }
    return _lineLeft;
}

- (UIView *)lineRight {
    if (!_lineRight) {
        _lineRight = [self setupLine];
    }
    return _lineRight;
}

- (UIView *)setupLine {
    UIView *ret = [[UIView alloc] init];
    ret.backgroundColor = [UIColor groupTableViewBackgroundColor];
    return ret;
}

@end
