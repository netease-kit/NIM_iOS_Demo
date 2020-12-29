//
//  NTESSessionMultiRetweetContentView.m
//  NIM
//
//  Created by Netease on 2019/10/17.
//  Copyright © 2019 Netease. All rights reserved.
//

#import "NTESSessionMultiRetweetContentView.h"
#import "NTESMultiRetweetAttachment.h"
#import "UIView+NTES.h"
#import "M80AttributedLabel+NIMKit.h"

NSString *const NIMDemoEventNameOpenMergeMessage = @"NIMDemoEventNameOpenMergeMessage";

@interface NTESSessionMultiRetweetContentView ()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) NSMutableArray <M80AttributedLabel *> *messageLabs;

@property (nonatomic, strong) UIView *line;

@property (nonatomic, strong) UILabel *subTitleLabel;

@property (nonatomic, strong) UIImage *bkNormalImage;

@property (nonatomic, strong) UIButton *touchBtn;

@end

@implementation NTESSessionMultiRetweetContentView

- (instancetype)initSessionMessageContentView{
    self = [super initSessionMessageContentView];
    if (self) {
        static UIImage *bkNormalImage = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            bkNormalImage = [[UIImage imageNamed:@"SendTextViewBkg"] resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{18,25,17,25}")        resizingMode:UIImageResizingModeStretch];
        });
        _bkNormalImage = bkNormalImage;
        _messageLabs = [NSMutableArray array];
        [self addSubview:self.titleLabel];
        [self addSubview:self.line];
        [self addSubview:self.subTitleLabel];
        [self addSubview:self.touchBtn];
    }
    return self;
}

- (void)refresh:(NIMMessageModel *)data{
    [super refresh:data];
    
    NIMCustomObject *object = data.message.messageObject;
    NTESMultiRetweetAttachment *attachment = (NTESMultiRetweetAttachment *)object.attachment;
    
    [_messageLabs makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_messageLabs removeAllObjects];
    
    _titleLabel.text = [attachment formatTitleMessage];
    
    for (NTESMessageAbstract *abstract in attachment.abstracts) {
        M80AttributedLabel *lab = [self setupMessageLabel];
        [lab nim_setText:[attachment formatAbstractMessage:abstract]];
        [_messageLabs addObject:lab];
        [self addSubview:lab];
    }
    [self layoutIfNeeded];
}

- (UIImage *)chatBubbleImageForState:(UIControlState)state outgoing:(BOOL)outgoing {
    return _bkNormalImage;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat padding = 4.0;
    CGFloat inset = 12.0;
    _titleLabel.frame = CGRectMake(inset, inset, self.width - 2*inset, _titleLabel.height);
    if (_messageLabs.count != 0) {
        __weak typeof(self) weakSelf = self;
        __block CGFloat yOffset = 0;
        [_messageLabs enumerateObjectsUsingBlock:^(M80AttributedLabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CGSize size = [obj sizeThatFits:CGSizeMake(weakSelf.titleLabel.width, CGFLOAT_MAX)];
            obj.frame = CGRectMake(_titleLabel.left, _titleLabel.bottom + 4.0 + yOffset, size.width, size.height);
            yOffset += (obj.height + padding);
        }];
        M80AttributedLabel *lastLab = [_messageLabs lastObject];
        _line.frame = CGRectMake(_titleLabel.left, lastLab.bottom + padding, _titleLabel.width, 1.0);
    } else {
        _line.frame = CGRectMake(_titleLabel.left, _titleLabel.bottom + padding, _titleLabel.width, 1.0);
    }
    _subTitleLabel.origin = CGPointMake(_titleLabel.left, _line.bottom + padding);
    _touchBtn.frame = self.bounds;
}

#pragma mark - Action
- (void)touchAction:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(onCatchEvent:)]) {
        NIMKitEvent *event = [[NIMKitEvent alloc] init];
        event.eventName = NIMDemoEventNameOpenMergeMessage;
        event.messageModel = self.model;
        event.data = self;
        [self.delegate onCatchEvent:event];
    }
}

#pragma mark - Getter
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:Message_Font_Size];
        _titleLabel.text = @"null";
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        [_titleLabel sizeToFit];
    }
    return _titleLabel;
}

- (UILabel *)subTitleLabel {
    if (!_subTitleLabel) {
        _subTitleLabel = [self setupContentLabel];
        _subTitleLabel.text = @"聊天记录".ntes_localized;
        [_subTitleLabel sizeToFit];
    }
    return _subTitleLabel;
}

- (UIButton *)touchBtn {
    if (!_touchBtn) {
        _touchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_touchBtn addTarget:self action:@selector(touchAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _touchBtn;
}


- (UILabel *)setupContentLabel {
    UILabel *ret = [[UILabel alloc] init];
    ret.textColor = [UIColor lightGrayColor];
    ret.font = [UIFont systemFontOfSize:Message_Detail_Font_Size];
    ret.textAlignment = NSTextAlignmentLeft;
    ret.text = @"null";
    ret.backgroundColor = [UIColor clearColor];
    [ret sizeToFit];
    return ret;
}

- (M80AttributedLabel *)setupMessageLabel {
    M80AttributedLabel *ret = [[M80AttributedLabel alloc] initWithFrame:CGRectZero];
    ret.textColor = [UIColor lightGrayColor];
    ret.font = [UIFont systemFontOfSize:Message_Detail_Font_Size];
    ret.numberOfLines = 1;
    ret.backgroundColor = [UIColor clearColor];
    return ret;
}

- (UIView *)line {
    if (!_line) {
        _line = [[UIView alloc] init];
        _line.backgroundColor = [UIColor lightGrayColor];
    }
    return _line;
}
@end
