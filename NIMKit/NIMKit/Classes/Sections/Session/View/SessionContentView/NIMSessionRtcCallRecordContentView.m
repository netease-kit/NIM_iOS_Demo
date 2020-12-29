//
//  NIMSessionRtcCallRecordContentView.m
//  NIMKit
//
//  Created by Wenchao Ding on 2020/11/7.
//  Copyright © 2020 NetEase. All rights reserved.
//

#import "NIMSessionRtcCallRecordContentView.h"
#import "NIMKit.h"
#import "NSString+NIMKit.h"
#import "NIMKitUtil.h"
#import "UIImage+NIMKit.h"
#import "UIView+NIM.h"

@implementation NIMSessionRtcCallRecordContentView

- (instancetype)initSessionMessageContentView
{
    if (self = [super initSessionMessageContentView]) {
        _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _textLabel.numberOfLines = 1;
        _textLabel.backgroundColor = UIColor.clearColor;
        [self addSubview:_textLabel];
        
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_imageView];
    }
    return self;
}

- (void)refresh:(NIMMessageModel *)data {
    [super refresh:data];
    NIMKitSetting *setting = [[NIMKit sharedKit].config setting:data.message];
    self.textLabel.textColor = setting.textColor;
    self.textLabel.font = setting.font;
    self.textLabel.text = [NIMKitUtil messageTipContent:data.message];
    
    NIMRtcCallRecordObject *callRecord = data.message.messageObject;
    
    NSMutableString *mutableImageName = NSMutableString.string;
    [mutableImageName appendString:callRecord.callType == NIMRtcCallTypeVideo ? @"icon_video" : @"icon_audio"];
    if (data.message.isOutgoingMsg) {
        [mutableImageName appendString:@"_white"];
    }
    self.imageView.image = [UIImage nim_imageInKit:mutableImageName.copy];
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    UIEdgeInsets contentInsets = self.model.contentViewInsets;
    
    CGFloat tableViewWidth = self.superview.frame.size.width;
    CGSize contentsize         = [self.model contentSize:tableViewWidth];
    CGSize imageSize = CGSizeMake(contentsize.height, contentsize.height);
    CGFloat imageMargin = 14;

    if (self.model.shouldShowLeft) {
        self.imageView.frame = CGRectMake(contentInsets.left, contentInsets.top, imageSize.width, imageSize.height);
        self.imageView.layer.transform = CATransform3DIdentity;
        self.textLabel.frame = CGRectMake(self.imageView.nim_right+imageMargin-5, contentInsets.top, contentsize.width-imageSize.width-imageMargin, contentsize.height);
    } else {
        self.textLabel.frame = CGRectMake(contentInsets.left, contentInsets.top, contentsize.width-imageSize.width-imageMargin, contentsize.height);
        self.imageView.frame = CGRectMake(self.textLabel.nim_right+imageMargin-5, contentInsets.top, imageSize.width, contentsize.height);
        self.imageView.layer.transform = CATransform3DMakeRotation(M_PI, 0, 1, 0);
    }
    
}

- (void)onTouchUpInside:(id)sender {
    NIMKitEvent *event = [[NIMKitEvent alloc] init];
    event.eventName = NIMKitEventNameTapContent;
    event.messageModel = self.model;
    [self.delegate onCatchEvent:event];
}


@end
