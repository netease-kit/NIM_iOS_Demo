//
//  NTESCollectMessageListViewController.m
//  NIM
//
//  Created by 丁文超 on 2020/4/15.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NTESCollectMessageListViewController.h"
#import "NTESSnapchatAttachment.h"
#import "NTESJanKenPonAttachment.h"
#import "NTESFileTransSelectViewController.h"
#import "NTESChartletAttachment.h"
#import "NTESGalleryViewController.h"
#import "NTESVideoViewController.h"
#import "NTESFilePreViewController.h"
#import "NTESAudio2TextViewController.h"
#import "UIView+NIMToast.h"
#import "NTESGalleryViewController.h"
#import "NIMLocationViewController.h"
#import "NTESSessionMultiRetweetContentView.h"
#import "NTESMergeMessageViewController.h"
#import <NIMSDK/NIMSDK.h>

@interface NTESCollectMessageListViewController ()

@end

@implementation NTESCollectMessageListViewController

- (BOOL)onTapCell:(NIMKitEvent *)event
{
    BOOL handled = [super onTapCell:event];
    if (handled) {
        return YES;
    }
    NSString *eventName = event.eventName;
    if ([eventName isEqualToString:NIMKitEventNameTapContent])
    {
        NIMMessage *message = event.messageModel.message;
        NSDictionary *actions = [self cellActions];
        NSString *value = actions[@(message.messageType)];
        if (value) {
            SEL selector = NSSelectorFromString(value);
            if (selector && [self respondsToSelector:selector]) {
                SuppressPerformSelectorLeakWarning([self performSelector:selector withObject:message]);
                handled = YES;
            }
        }
    }
    else if([eventName isEqualToString:NIMKitEventNameTapLabelLink]) {
        NSString *link = event.data;
        [self openSafari:link];
        handled = YES;
    } else if ([eventName isEqualToString:NIMDemoEventNameOpenMergeMessage]) {
        NIMMessage *message = event.messageModel.message;
        NTESMergeMessageViewController *vc = [[NTESMergeMessageViewController alloc] initWithMessage:message];
        [self.navigationController pushViewController:vc animated:YES];
        handled = YES;
    }
    if (!handled) {
        NSAssert(0, @"invalid event");
    }
    return handled;
}


- (NSDictionary *)cellActions
{
    static NSDictionary *actions = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        actions = @{@(NIMMessageTypeImage) :    @"showImage:",
                    @(NIMMessageTypeVideo) :    @"showVideo:",
                    @(NIMMessageTypeLocation) : @"showLocation:",
                    @(NIMMessageTypeFile)  :    @"showFile:",
                    @(NIMMessageTypeCustom):    @"showCustom:"};
    });
    return actions;
}

- (void)showImage:(NIMMessage *)message
{
    NIMImageObject *object = message.messageObject;
    NTESGalleryItem *item = [[NTESGalleryItem alloc] init];
    item.thumbPath      = [object thumbPath];
    item.imageURL       = [object url];
    item.name           = [object displayName];
    item.itemId         = [message messageId];
    item.size           = [object size];
    item.imagePath      = [object path];

    NTESGalleryViewController *vc = [[NTESGalleryViewController alloc] initWithItem:item session:nil];
    [self.navigationController pushViewController:vc animated:YES];
    if(![[NSFileManager defaultManager] fileExistsAtPath:object.thumbPath]){
        //如果缩略图下跪了，点进看大图的时候再去下一把缩略图
        __weak typeof(self) wself = self;
        [[NIMSDK sharedSDK].resourceManager download:object.thumbUrl filepath:object.thumbPath progress:nil completion:^(NSError *error) {
            __weak typeof(self) sself = wself;
            if (!sself) return;
            if (!error) {
                [sself.tableView reloadData];
            }
        }];
    }
}

- (void)showVideo:(NIMMessage *)message
{
    NIMVideoObject *object = message.messageObject;

    NTESVideoViewItem *item = [[NTESVideoViewItem alloc] init];
    item.path = object.path;
    item.url  = object.url;
    item.itemId  = object.message.messageId;

    NTESVideoViewController *playerViewController = [[NTESVideoViewController alloc] initWithVideoViewItem:item];
    [self.navigationController pushViewController:playerViewController animated:YES];
    if(![[NSFileManager defaultManager] fileExistsAtPath:object.coverPath]){
        //如果封面图下跪了，点进视频的时候再去下一把封面图
        __weak typeof(self) wself = self;
        [[NIMSDK sharedSDK].resourceManager download:object.coverUrl filepath:object.coverPath progress:nil completion:^(NSError *error) {
            __weak typeof(self) sself = wself;
            if (!sself) return;
            if (!error) {
                [sself.tableView reloadData];
            }
        }];
    }
}

- (void)showLocation:(NIMMessage *)message
{
    NIMLocationObject *object = message.messageObject;
    NIMKitLocationPoint *locationPoint = [[NIMKitLocationPoint alloc] initWithLocationObject:object];
    NIMLocationViewController *vc = [[NIMLocationViewController alloc] initWithLocationPoint:locationPoint];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showFile:(NIMMessage *)message
{
    NIMFileObject *object = message.messageObject;
    NTESFilePreViewController *vc = [[NTESFilePreViewController alloc] initWithFileObject:object];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showCustom:(NIMMessage *)message
{
   //普通的自定义消息点击事件可以在这里做哦~
}

- (void)openSafari:(NSString *)link
{
    NSURLComponents *components = [[NSURLComponents alloc] initWithString:link];
    if (components)
    {
        if (!components.scheme)
        {
            //默认添加 http
            components.scheme = @"http";
        }
        [[UIApplication sharedApplication] openURL:[components URL]];
    }
}

@end
