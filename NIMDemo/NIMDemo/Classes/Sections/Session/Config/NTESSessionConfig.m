//
//  NTESSessionConfig.m
//  NIM
//
//  Created by amao on 8/11/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NTESSessionConfig.h"
#import "NIMMediaItem.h"
#import "NTESBundleSetting.h"
#import "NTESSnapchatAttachment.h"
#import "NTESWhiteboardAttachment.h"
#import "NTESBundleSetting.h"
#import "NSString+NTES.h"
#import "NIMSessionConfig.h"
#import "NTESSessionUtil.h"
#import "NIMInputEmoticonManager.h"
#import "NIMKitUtil.h"

@interface NTESSessionConfig()
@property (nonatomic,strong) NIMMessage *threadMessage;
@end

@implementation NTESSessionConfig

- (NSArray *)mediaItems
{
    NSArray *defaultMediaItems = [NIMKit sharedKit].config.defaultMediaItems;
    
    NIMMediaItem *janKenPon = [NIMMediaItem item:@"onTapMediaItemJanKenPon:"
                                     normalImage:[UIImage imageNamed:@"icon_jankenpon_normal"]
                                   selectedImage:[UIImage imageNamed:@"icon_jankenpon_pressed"]
                                           title:@"石头剪刀布".ntes_localized];
    
    NIMMediaItem *fileTrans = [NIMMediaItem item:@"onTapMediaItemFileTrans:"
                                                normalImage:[UIImage imageNamed:@"icon_file_trans_normal"]
                                              selectedImage:[UIImage imageNamed:@"icon_file_trans_pressed"]
                                           title:@"文件传输".ntes_localized];
    
    NIMMediaItem *tip       = [NIMMediaItem item:@"onTapMediaItemTip:"
                                     normalImage:[UIImage imageNamed:@"bk_media_tip_normal"]
                                   selectedImage:[UIImage imageNamed:@"bk_media_tip_pressed"]
                                           title:@"提示消息".ntes_localized];
    
    NIMMediaItem *audioChat =  [NIMMediaItem item:@"onTapMediaItemAudioChat:"
                                      normalImage:[UIImage imageNamed:@"btn_media_telphone_message_normal"]
                                    selectedImage:[UIImage imageNamed:@"btn_media_telphone_message_pressed"]
                                           title:@"实时语音".ntes_localized];
    
    NIMMediaItem *videoChat =  [NIMMediaItem item:@"onTapMediaItemVideoChat:"
                                      normalImage:[UIImage imageNamed:@"btn_bk_media_video_chat_normal"]
                                    selectedImage:[UIImage imageNamed:@"btn_bk_media_video_chat_pressed"]
                                            title:@"视频聊天".ntes_localized];
    
    NIMMediaItem *teamMeeting =  [NIMMediaItem item:@"onTapMediaItemTeamMeeting:"
                                      normalImage:[UIImage imageNamed:@"btn_media_telphone_message_normal"]
                                    selectedImage:[UIImage imageNamed:@"btn_media_telphone_message_pressed"]
                                            title:@"视频通话".ntes_localized];
    
    NIMMediaItem *snapChat =   [NIMMediaItem item:@"onTapMediaItemSnapChat:"
                                      normalImage:[UIImage imageNamed:@"bk_media_snap_normal"]
                                    selectedImage:[UIImage imageNamed:@"bk_media_snap_pressed"]
                                            title:@"阅后即焚".ntes_localized];

//    NIMMediaItem *whiteBoard = [NIMMediaItem item:@"onTapMediaItemWhiteBoard:"
//                                      normalImage:[UIImage imageNamed:@"btn_whiteboard_invite_normal"]
//                                    selectedImage:[UIImage imageNamed:@"btn_whiteboard_invite_pressed"]
//
//                                            title:@"白板".ntes_localized];
    //红包功能因合作终止，暂时关闭
//    NIMMediaItem *redPacket  = [NIMMediaItem item:@"onTapMediaItemRedPacket:"
//                                      normalImage:[UIImage imageNamed:@"icon_redpacket_normal"]
//                                    selectedImage:[UIImage imageNamed:@"icon_redpacket_pressed"]
//                                            title:@"红包"];
    
    NIMMediaItem *teamReceipt  = [NIMMediaItem item:@"onTapMediaItemTeamReceipt:"
                                      normalImage:[UIImage imageNamed:@"icon_team_receipt_normal"]
                                    selectedImage:[UIImage imageNamed:@"icon_team_receipt_pressed"]
                                            title:@"已读回执".ntes_localized];
    
    
    
    BOOL isMe   = _session.sessionType == NIMSessionTypeP2P
    && [_session.sessionId isEqualToString:[[NIMSDK sharedSDK].loginManager currentAccount]];
    NSArray *items = nil;
    
    if (isMe)
    {
        items = @[janKenPon,fileTrans,tip];
    }
    else if(_session.sessionType == NIMSessionTypeTeam || _session.sessionType == NIMSessionTypeSuperTeam)
    {
        items = @[janKenPon,teamMeeting,fileTrans,tip,teamReceipt];
    }
    else
    {
        items = @[janKenPon,audioChat,videoChat,fileTrans,snapChat,tip];
    }
    

    return [defaultMediaItems arrayByAddingObjectsFromArray:items];
    
}


- (NSArray<NIMMediaItem *> *)menuItemsWithMessage:(NIMMessage *)message {
    NSMutableArray *items = [NSMutableArray array];

    NIMMediaItem *reply = [NIMMediaItem item:@"onTapMenuItemReply:"
                                 normalImage:[UIImage imageNamed:@"menu_reply"]
                               selectedImage:nil
                                       title:@"回复".ntes_localized];
    
    NIMMediaItem *copy = [NIMMediaItem item:@"onTapMenuItemCopy:"
                                normalImage:[UIImage imageNamed:@"menu_copy"]
                              selectedImage:nil
                                      title:@"复制".ntes_localized];
    
    NIMMediaItem *forword = [NIMMediaItem item:@"onTapMenuItemForword:"
                                   normalImage:[UIImage imageNamed:@"menu_forword"]
                                 selectedImage:nil
                                         title:@"转发".ntes_localized];
    
    NIMMediaItem *mark = [NIMMediaItem item:@"onTapMenuItemMark:"
                                normalImage:[UIImage imageNamed:@"menu_collect"]
                              selectedImage:nil
                                      title:@"收藏".ntes_localized];
    
    BOOL isMessagePined = [NIMSDK.sharedSDK.chatExtendManager pinItemForMessage:message] != nil;
    NSString *pinTitle = isMessagePined ? @"Un-pin": @"Pin";
    NSString *pinAction = isMessagePined ? @"onTapMenuItemUnpin:" : @"onTapMenuItemPin:";
    NIMMediaItem *pin = [NIMMediaItem item:pinAction
                               normalImage:[UIImage imageNamed:@"menu_pin"]
                             selectedImage:nil
                                     title:pinTitle];
    
    NIMMediaItem *revoke = [NIMMediaItem item:@"onTapMenuItemRevoke:"
                                  normalImage:[UIImage imageNamed:@"menu_revoke"]
                                selectedImage:nil
                                        title:@"撤回".ntes_localized];
    
    NIMMediaItem *delete = [NIMMediaItem item:@"onTapMenuItemDelete:"
                                  normalImage:[UIImage imageNamed:@"menu_del"]
                                selectedImage:nil
                                        title:@"删除".ntes_localized];
    
    NIMMediaItem *mutiSelect = [NIMMediaItem item:@"onTapMenuItemMutiSelect:"
                                      normalImage:[UIImage imageNamed:@"menu_choose"]
                                    selectedImage:nil
                                            title:@"多选".ntes_localized];
    if ([NTESSessionUtil canMessageBeForwarded:message])
    {
        [items addObject:reply];
    }
    
    if (message.messageType == NIMMessageTypeText)
    {
        [items addObject:copy];
    }
    
    if ([NTESSessionUtil canMessageBeForwarded:message]) {
        [items addObject:forword];
    }
    if ([NTESSessionUtil canMessageBeForwarded:message]) {
        [items addObject:mark];
        [items addObject:pin];
    }
    if ([NTESSessionUtil canMessageBeRevoked:message]) {
        [items addObject:revoke];
    }
    [items addObject:delete];
    if ([NTESSessionUtil canMessageBeForwarded:message])
    {
        [items addObject:mutiSelect];
    }
    
    if (message.messageType == NIMMessageTypeAudio)
    {
        NIMMediaItem *audio2text = [NIMMediaItem item:@"onTapMenuItemAudio2Text:"
          normalImage:[UIImage imageNamed:@"menu_audio2text"]
        selectedImage:nil
                title:@"转文字".ntes_localized];
        
        [items addObject:audio2text];
    }
    return items;
}

- (NSArray *)emotionItems
{
    NSArray *indexs = @[@(1),@(145),@(12),@(15),@(10),@(18),@(19)];
    NSMutableArray *items = [NSMutableArray array];
    for (NSNumber *index in indexs)
    {
        NSString * ID = [NSString stringWithFormat:NIMKitQuickCommentFormat, [index integerValue]];
        NIMInputEmoticon *item = [[NIMInputEmoticonManager sharedManager] emoticonByID:ID];
        if (item)
        {
            [items addObject:item];
        }
    }
    
    return [items copy];
}

- (BOOL)shouldHandleReceipt{
    return YES;
}

- (NSArray<NSNumber *> *)inputBarItemTypes{
    return @[
             @(NIMInputBarItemTypeVoice),
             @(NIMInputBarItemTypeTextAndRecord),
             @(NIMInputBarItemTypeEmoticon),
             @(NIMInputBarItemTypeMore)
            ];
}

- (BOOL)shouldHandleReceiptForMessage:(NIMMessage *)message
{
    //文字，语音，图片，视频，文件，地址位置和自定义消息都支持已读回执，其他的不支持
    NIMMessageType type = message.messageType;
    if (type == NIMMessageTypeCustom) {
        NIMCustomObject *object = (NIMCustomObject *)message.messageObject;
        id attachment = object.attachment;
        
        if ([attachment isKindOfClass:[NTESWhiteboardAttachment class]]) {
            return NO;
        }
    }
    
    
    
    return type == NIMMessageTypeText ||
    type == NIMMessageTypeAudio ||
    type == NIMMessageTypeImage ||
    type == NIMMessageTypeVideo ||
    type == NIMMessageTypeFile ||
    type == NIMMessageTypeLocation ||
    type == NIMMessageTypeCustom;
}

- (NSArray<NIMInputEmoticonCatalog *> *)charlets
{
    return [self loadChartletEmoticonCatalog];
}

- (BOOL)disableProximityMonitor{
    return [[NTESBundleSetting sharedConfig] disableProximityMonitor];
}

- (BOOL)autoFetchAttachment {
    return [[NTESBundleSetting sharedConfig] autoFetchAttachment];
}

- (NIMAudioType)recordType
{
    return [[NTESBundleSetting sharedConfig] usingAmr] ? NIMAudioTypeAMR : NIMAudioTypeAAC;
}


- (NSArray *)loadChartletEmoticonCatalog{
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"NIMDemoChartlet.bundle"
                                         withExtension:nil];
    NSBundle *bundle = [NSBundle bundleWithURL:url];
    NSArray  *paths   = [bundle pathsForResourcesOfType:nil inDirectory:@""];
    NSMutableArray *res = [[NSMutableArray alloc] init];
    for (NSString *path in paths) {
        BOOL isDirectory = NO;
        if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory] && isDirectory) {
            NIMInputEmoticonCatalog *catalog = [[NIMInputEmoticonCatalog alloc]init];
            catalog.catalogID = path.lastPathComponent;
            NSArray *resources = [NSBundle pathsForResourcesOfType:nil inDirectory:[path stringByAppendingPathComponent:@"content"]];
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (NSString *path in resources) {
                NSString *name  = path.lastPathComponent.stringByDeletingPathExtension;
                NIMInputEmoticon *icon  = [[NIMInputEmoticon alloc] init];
                icon.emoticonID = name.stringByDeletingPictureResolution;
                icon.filename   = path;
                [array addObject:icon];
            }
            catalog.emoticons = array;
            
            NSArray *icons     = [NSBundle pathsForResourcesOfType:nil inDirectory:[path stringByAppendingPathComponent:@"icon"]];
            for (NSString *path in icons) {
                NSString *name  = path.lastPathComponent.stringByDeletingPathExtension.stringByDeletingPictureResolution;
                if ([name hasSuffix:@"normal"]) {
                    catalog.icon = path;
                }else if([name hasSuffix:@"highlighted"]){
                    catalog.iconPressed = path;
                }
            }
            [res addObject:catalog];
        }
    }
    return res;
}

- (BOOL)disableSelectedForMessage:(NIMMessage *)message {
    return ![NTESSessionUtil canMessageBeForwarded:message];
}

- (void)setThreadMessage:(NIMMessage *)message
{
    _threadMessage = message;
}

- (void)cleanThreadMessage
{
    _threadMessage = nil;
}

- (BOOL)clearThreadMessageAfterSent
{
    return YES;
}

@end
