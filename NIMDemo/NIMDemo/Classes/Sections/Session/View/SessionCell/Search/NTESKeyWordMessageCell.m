//
//  NTESKeyWordMessageCell.m
//  NIM
//
//  Created by He on 2019/12/18.
//  Copyright © 2019 Netease. All rights reserved.
//

#import "NTESKeyWordMessageCell.h"
#import "NIMAvatarImageView.h"
#import "NIMCommonTableData.h"
#import "UIView+NTES.h"

@interface NTESKeyWordMessageCell ()

@property (nonatomic,strong) NIMAvatarImageView * avatar;

@property (nonatomic,strong) UILabel * nickL;

@property (nonatomic,strong) UILabel * timeL;

@end

@implementation NTESKeyWordMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self.contentView addSubview:self.avatar];
        [self.contentView addSubview:self.nickL];
        [self.contentView addSubview:self.timeL];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.avatar.size = CGSizeMake(40, 40);
    self.avatar.centerY = self.contentView.height * .5f;
    self.avatar.left = 15.f;
    
    [self.textLabel sizeToFit];
    self.textLabel.left = self.avatar.right + 15;
    self.detailTextLabel.left = self.textLabel.left;
    
    [self.nickL sizeToFit];
    self.nickL.left = self.textLabel.right + 2;
    self.nickL.centerY = self.textLabel.centerY;
    
    [self.timeL sizeToFit];
    self.timeL.width = MIN(self.timeL.width, self.width - self.textLabel.right - 4 - 15);
    self.timeL.top = self.textLabel.top;
    self.timeL.right = self.contentView.width - 15;
    
    self.nickL.width = MAX(0,self.timeL.left - self.nickL.left - 5);
}

- (void)refreshData:(NIMCommonTableRow *)rowData tableView:(UITableView *)tableView
{
    NSString * keyWord = rowData.title;
    NIMMessage * message = rowData.extraInfo;
    if ([message isKindOfClass:[NIMMessage class]])
    {
        NIMKitInfo * info = nil;
        NIMSession * session = message.session;
        if (session.sessionType == NIMSessionTypeP2P)
        {
           info = [[NIMKit sharedKit] infoByUser:session.sessionId option:nil];
        }
        else
        {
            info = [[NIMKit sharedKit] infoByTeam:session.sessionId option:nil];
        }
        
        if (info.avatarUrlString.length)
        {
            [self.avatar nim_setImageWithURL:[NSURL URLWithString:info.avatarUrlString]
                            placeholderImage:info.avatarImage];
        }
        else
        {
            [self.avatar setImage:info.avatarImage];
        }
        
        self.textLabel.attributedText = [self coloredTextWithSource:info.showName keyword:keyWord];
        [self.textLabel sizeToFit];
        
        self.nickL.attributedText = [self coloredTextWithSource:[NSString stringWithFormat:@"(%@)", session.sessionId] keyword:keyWord];
//        [self.nickL sizeToFit];
        
        self.detailTextLabel.attributedText = [self coloredTextWithSource:message.text keyword:keyWord];
        [self.detailTextLabel sizeToFit];
        
        self.timeL.text = [self timeWithTimestamp:message.timestamp];
        [self.timeL sizeToFit];
    }
}

- (NSAttributedString *)coloredTextWithSource:(NSString *)source
                                      keyword:(NSString *)keyword
{
    if (!source)
    {
        return nil;
    }
    
    NSMutableAttributedString * accidString = [[NSMutableAttributedString alloc] initWithString:source];
    NSString * lowercaseSource = [source lowercaseString];
    NSString * lowercaseKeyword = [keyword lowercaseString];
    if ([lowercaseSource containsString:lowercaseKeyword])
    {
        NSRange range = [source rangeOfString:keyword];
        [accidString addAttributes:@{
            NSForegroundColorAttributeName : [UIColor redColor],
        }
                             range:range];
    }
    return accidString;
}



- (NIMAvatarImageView *)avatar
{
    if (!_avatar)
    {
        _avatar = [[NIMAvatarImageView alloc] init];
    }
    return _avatar;
}

- (UILabel *)nickL
{
    if (!_nickL)
    {
        _nickL = [[UILabel alloc] init];
        _nickL.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _nickL;
}

- (UILabel *)timeL
{
    if (!_timeL)
    {
        _timeL = [[UILabel alloc] init];
    }
    return _timeL;
}

- (NSString *)timeWithTimestamp:(NSTimeInterval)ts
{
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:ts];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    NSTimeZone* timeZone = [NSTimeZone timeZoneForSecondsFromGMT:8 * 60 * 60];
    [formatter setTimeZone:timeZone];
    formatter.dateFormat = @"MM-dd hh:mm:ss";
    NSString * time = [formatter stringFromDate:date];
    return time;
}

@end
