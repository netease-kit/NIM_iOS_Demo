//
//  NotificationViewController.m
//  NTESNotificationContent
//
//  Created by emily on 2018/6/21.
//  Copyright © 2018 NIM. All rights reserved.
//

#import "NotificationViewController.h"
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>
#import <AVFoundation/AVFoundation.h>

@interface NotificationViewController () <UNNotificationContentExtension>

@property IBOutlet UIView *backView;
@property IBOutlet UIImageView *imgView;

@end

@implementation NotificationViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setPreferredContentSize:CGSizeMake(self.view.bounds.size.width, 300)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any required interface initialization here.
}

- (void)didReceiveNotification:(UNNotification *)notification {
    UNNotificationContent *content = notification.request.content;
    
    NSDictionary *dict = [content.userInfo mutableCopy];
    if (content.attachments.count > 0) {
        NSURL *fileURL = content.attachments[0].URL;
        //根据 type 定制布局
        NSString *type = dict[@"type"];
        if ([type isEqualToString:@"image"]) {
            self.backView.hidden = YES;
            self.imgView.hidden = NO;
            self.imgView.backgroundColor = [UIColor yellowColor];
            self.imgView.contentMode = UIViewContentModeScaleAspectFill;
            if (fileURL.startAccessingSecurityScopedResource) {
                UIImage *tmpImg = [[UIImage alloc] initWithContentsOfFile:fileURL.path];
                NSData *imgData = UIImageJPEGRepresentation(tmpImg, 1.0);
                UIImage *image = [[UIImage alloc] initWithData:imgData];
                self.imgView.image = image;
                [fileURL stopAccessingSecurityScopedResource];
            }
        }
        if ([type isEqualToString:@"video"]) {
            self.backView.hidden = NO;
            self.imgView.hidden = YES;
            if ([fileURL startAccessingSecurityScopedResource]) {
                AVAsset *asset = [AVURLAsset URLAssetWithURL:fileURL options:nil];
                AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
                AVPlayer *player = [AVPlayer playerWithPlayerItem:item];
                player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
                AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
                playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
                playerLayer.frame = self.backView.bounds;
                [self.backView.layer addSublayer:playerLayer];
                [player play];
                [fileURL stopAccessingSecurityScopedResource];
            }
        }
    }
    
}

@end

