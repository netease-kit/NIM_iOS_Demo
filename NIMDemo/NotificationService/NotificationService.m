//
//  NotificationService.m
//  NTESNotificationService
//
//  Created by emily on 2018/6/21.
//  Copyright © 2018 NIM. All rights reserved.
//

#import "NotificationService.h"
#import <CommonCrypto/CommonDigest.h>

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    //修改 attachment
    NSDictionary *dict = [request.content.userInfo mutableCopy];
    NSString *mediaAttachUrl = [dict valueForKey:@"media"];
    if (mediaAttachUrl.length) {
        NSString *type = [dict valueForKey:@"type"];
        [self loadAttachmentForUrlString:mediaAttachUrl withType:type completionHandler:^(UNNotificationAttachment *attach) {
            if (attach) {
                self.bestAttemptContent.attachments = @[attach];
            }
            self.contentHandler(self.bestAttemptContent);
        }];
    }
    else {
        self.contentHandler(self.bestAttemptContent);
    }
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

#pragma mark - Private

- (void)loadAttachmentForUrlString:(NSString *)urlStr withType:(NSString *)type completionHandler:(void(^)(UNNotificationAttachment *attach))completionHandler {
    __block UNNotificationAttachment *attachment = nil;
    NSURL *attachmentURL = [NSURL URLWithString:urlStr];
    NSString *fileExt = [self fileExtensionForMediaType:type];
    [[[NSURLSession sharedSession] dataTaskWithURL:attachmentURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            NSString *cachepath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
            if (![[NSFileManager defaultManager] fileExistsAtPath:cachepath]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:cachepath withIntermediateDirectories:YES attributes:nil error:nil];
            }
            
            NSString *localPath = [cachepath stringByAppendingPathComponent:[[self md5Str:urlStr] stringByAppendingString:fileExt]];
            NSURL *localURL = [NSURL fileURLWithPath:localPath];
            
            if ([data writeToFile:localPath atomically:NO]) {
                NSError *attachmentError = nil;
                attachment = [UNNotificationAttachment attachmentWithIdentifier:urlStr URL:localURL options:nil error:&attachmentError];
                completionHandler(attachment);
            }
            else {
                completionHandler(attachment);
            }
        }
        else {
            completionHandler(attachment);
        }
    }] resume];
    
}

- (NSString *)fileExtensionForMediaType:(NSString *)type {
    NSString *ext = type;
    if ([type isEqualToString:@"image"]) {
        ext = @"jpg";
    }
    else if ([type isEqualToString:@"video"]) {
        ext = @"mp4";
    }
    else if ([type isEqualToString:@"audio"]) {
        ext = @"mp3";
    }
    return [@"." stringByAppendingString:ext];
}

- (NSString *)md5Str:(NSString *)str {
    const char *cstr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cstr, (CC_LONG)strlen(cstr), result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

@end
