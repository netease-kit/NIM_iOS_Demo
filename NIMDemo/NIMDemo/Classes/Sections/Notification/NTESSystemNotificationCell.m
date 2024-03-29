//
//  NTESSystemNotificationCell.m
//  NIM
//
//  Created by amao on 3/17/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NTESSystemNotificationCell.h"
#import "NTESSessionUtil.h"
#import "UIView+NTES.h"
#import "NIMAvatarImageView.h"

@interface NTESSystemNotificationCell ()
@property (nonatomic,strong) IBOutlet UILabel *messageLabel;
@property (nonatomic,strong) NIMSystemNotification *notification;
@property (nonatomic,strong) IBOutlet NIMAvatarImageView *avatarImageView;
@end

@implementation NTESSystemNotificationCell

- (void)awakeFromNib{
    [super awakeFromNib];
    self.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    self.detailTextLabel.backgroundColor = [UIColor clearColor];
    self.detailTextLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    self.avatarImageView = [[NIMAvatarImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [self.contentView addSubview:self.avatarImageView];
}

- (void)update:(NIMSystemNotification *)notification{
    self.notification = notification;
    [self updateUI];
}

- (void)updateUI{
    BOOL hideActionButton = [self shouldHideActionButton];

    [self.acceptButton setHidden:hideActionButton];
    [self.refuseButton setHidden:hideActionButton];
    if(hideActionButton) {
        self.handleInfoLabel.hidden = NO;
        switch (self.notification.handleStatus) {
            case NotificationHandleTypeOk:
                 self.handleInfoLabel.text = @"已同意".ntes_localized;
                break;
            case NotificationHandleTypeNo:
                self.handleInfoLabel.text = @"已拒绝".ntes_localized;
                break;
            case NotificationHandleTypeOutOfDate:
                self.handleInfoLabel.text = @"已过期".ntes_localized;
                break;
            default:
                self.handleInfoLabel.text = nil;
                break;
        }
    } else {
        self.handleInfoLabel.hidden = YES;
    }


    NSString *sourceID = self.notification.sourceID;
    NIMKitInfo *sourceMember = [[NIMKit sharedKit] infoByUser:sourceID option:nil];
    [self updateSourceMember:sourceMember];
}

- (void)updateSourceMember:(NIMKitInfo *)sourceMember{
    NIMSystemNotificationType type = self.notification.type;
    NSString *avatarUrlString = sourceMember.avatarUrlString;
    NSURL *url;
    if (avatarUrlString.length) {
        url = [NSURL URLWithString:avatarUrlString];
    }
    [self.avatarImageView nim_setImageWithURL:url placeholderImage:sourceMember.avatarImage options:SDWebImageRetryFailed];
    self.textLabel.text        = sourceMember.showName;
    [self.textLabel sizeToFit];
    switch (type) {
        case NIMSystemNotificationTypeTeamApply:
        {
            NIMTeam *team = [[NIMSDK sharedSDK].teamManager teamById:self.notification.targetID];
            self.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@",@"申请加入群".ntes_localized, team.teamName];
        }
            break;
        case NIMSystemNotificationTypeTeamApplyReject:
        {
            NIMTeam *team = [[NIMSDK sharedSDK].teamManager teamById:self.notification.targetID];
            self.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@ %@",
                                         @"群".ntes_localized,
                                         team.teamName,
                                         @"拒绝你加入".ntes_localized];
        }
            break;
        case NIMSystemNotificationTypeTeamInvite:
        {
            NIMTeam *team = [[NIMSDK sharedSDK].teamManager teamById:self.notification.targetID];
            
            self.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@ %@ attach:%@",
                                         @"群".ntes_localized,
                                         team.teamName,
                                         @"邀请你加入".ntes_localized,
                                         self.notification.notifyExt ? : @""];
        }
            break;
        case NIMSystemNotificationTypeTeamIviteReject:
        {
            NIMTeam *team = [[NIMSDK sharedSDK].teamManager teamById:self.notification.targetID];
            self.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@ %@",
                                         @"拒绝了群".ntes_localized,
                                         team.teamName,
                                         @"邀请".ntes_localized];
        }
            break;
        case NIMSystemNotificationTypeSuperTeamApply:
        {
            NIMTeam *team = [[NIMSDK sharedSDK].superTeamManager teamById:self.notification.targetID];
            self.detailTextLabel.text = [NSString stringWithFormat:@"申请加入超大群 %@".ntes_localized, team.teamName];
            break;
        }
        case NIMSystemNotificationTypeSuperTeamApplyReject:
        {
            NIMTeam *team = [[NIMSDK sharedSDK].superTeamManager teamById:self.notification.targetID];
            self.detailTextLabel.text = [NSString stringWithFormat:@"超大群 %@ 拒绝你加入".ntes_localized, team.teamName];
            break;
        }
        case NIMSystemNotificationTypeSuperTeamInvite:
        {
            NIMTeam *team = [[NIMSDK sharedSDK].superTeamManager teamById:self.notification.targetID];
            self.detailTextLabel.text = [NSString stringWithFormat:@"超大群 %@ 邀请你加入 attach:%@".ntes_localized, team.teamName, self.notification.notifyExt ? : @""];
            break;
        }
        case NIMSystemNotificationTypeSuperTeamIviteReject:
        {
            NIMTeam *team = [[NIMSDK sharedSDK].superTeamManager teamById:self.notification.targetID];
            self.detailTextLabel.text = [NSString stringWithFormat:@"拒绝了超大群 %@ 邀请".ntes_localized, team.teamName];
            break;
        }
        case NIMSystemNotificationTypeFriendAdd:
        {
            NSString *text = @"未知请求".ntes_localized;
            id object = self.notification.attachment;
            if ([object isKindOfClass:[NIMUserAddAttachment class]]) {
                NIMUserOperation operation = [(NIMUserAddAttachment *)object operationType];
                switch (operation) {
                    case NIMUserOperationAdd:
                        text = @"已添加你为好友".ntes_localized;
                        break;
                    case NIMUserOperationRequest:
                        text = @"请求添加你为好友".ntes_localized;
                        break;
                    case NIMUserOperationVerify:
                        text = @"通过了你的好友请求".ntes_localized;
                        break;
                    case NIMUserOperationReject:
                        text = @"拒绝了你的好友请求".ntes_localized;
                        break;
                    default:
                        break;
                }
            }
            self.detailTextLabel.text = text;
        }
            break;
        default:
            break;
    }
    [self.detailTextLabel sizeToFit];
    self.messageLabel.text = self.notification.postscript;
    [self.messageLabel sizeToFit];
    [self setNeedsLayout];
}

- (IBAction)onAccept:(id)sender {
    if (_actionDelegate && [_actionDelegate respondsToSelector:@selector(onAccept:)]){
        [_actionDelegate onAccept:self.notification];
    }
}
- (IBAction)onRefuse:(id)sender {
    if (_actionDelegate && [_actionDelegate respondsToSelector:@selector(onRefuse:)]){
        [_actionDelegate onRefuse:self.notification];
    }
}

- (BOOL)shouldHideActionButton
{
    NIMSystemNotificationType type = self.notification.type;
    BOOL handled = self.notification.handleStatus != 0;
    BOOL needHandle = NO;
    if (type == NIMSystemNotificationTypeTeamApply ||
        type == NIMSystemNotificationTypeTeamInvite ||
        type == NIMSystemNotificationTypeSuperTeamApply ||
        type == NIMSystemNotificationTypeSuperTeamInvite) {
        needHandle = YES;
    }
    if (type == NIMSystemNotificationTypeFriendAdd) {
        id object = self.notification.attachment;
        if ([object isKindOfClass:[NIMUserAddAttachment class]]) {
            NIMUserOperation operation = [(NIMUserAddAttachment *)object operationType];
            needHandle = operation == NIMUserOperationRequest;
        }
    }
    return !(!handled && needHandle);
    
}

#define MaxTextLabelWidth 120.0 * UISreenWidthScale
#define MaxDetailLabelWidth 160.0 * UISreenWidthScale
#define MaxMessageLabelWidth 150.0 * UISreenWidthScale
#define TextLabelAndMessageLabelSpacing 20.f
#define AvatarImageViewLeft 15.f
#define MessageAndAvatarSpacing 15.f
- (void)layoutSubviews{
    [super layoutSubviews];
    self.avatarImageView.centerY = self.height * .5f;
    self.avatarImageView.left = AvatarImageViewLeft;
    if (self.textLabel.width > MaxTextLabelWidth) {
        self.textLabel.width = MaxTextLabelWidth;
    }
    if (self.detailTextLabel.width > MaxDetailLabelWidth) {
        self.detailTextLabel.width = MaxDetailLabelWidth;
    }
    self.textLabel.left = self.avatarImageView.right + MessageAndAvatarSpacing;
    self.detailTextLabel.left = self.textLabel.left;
    self.detailTextLabel.bottom = self.avatarImageView.bottom;
    
    if (self.messageLabel.width > MaxMessageLabelWidth) {
        self.messageLabel.width = MaxMessageLabelWidth;
    }
    self.messageLabel.left = self.textLabel.right + TextLabelAndMessageLabelSpacing;

}

@end
