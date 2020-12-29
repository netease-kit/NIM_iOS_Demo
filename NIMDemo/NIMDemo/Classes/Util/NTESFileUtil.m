//
//  NTESFileUtil.m
//  NIM
//
//  Created by Netease on 2019/10/17.
//  Copyright © 2019 Netease. All rights reserved.
//

#import "NTESFileUtil.h"
#import <CommonCrypto/CommonDigest.h>
#import "NSData+NTES.h"

@implementation NTESFileUtil

+ (NSString *)fileMD5:(NSString *)filepath
{
    NSString *md5 = nil;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filepath])
    {
        unsigned long long fileSize = [self fileSize:filepath];
        if(fileSize > 200 * 1024 * 1024) {
            md5 = [self bigFileMD5:filepath];
        }else {
            NSData *data = [NSData dataWithContentsOfFile:filepath];
            md5 =  [data MD5String];
        }
    }
    return md5;
}

+ (void)fileMD5:(NSString *)filepath completion:(void(^)(NSString *MD5))completion;
{
    dispatch_block_t block = ^(){
        NSString *md5 = [self fileMD5:filepath];
        if(completion) {
            completion(md5);
        }
    };
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(queue,block);
}

+ (NSString *)bigFileMD5:(NSString *)filePath
{
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    if(!fileHandle) {
        return nil;
    }
    
    CC_MD5_CTX ctx;
    CC_MD5_Init(&ctx);
    
    BOOL done = NO;
    NSData *data = nil;
    while (!done) {
        @autoreleasepool {
            data = [fileHandle readDataOfLength:256];
            if([data length]) {
                CC_MD5_Update(&ctx, [data bytes], (CC_LONG)[data length]);
            }else {
                done = YES;
            }
        }
    };
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &ctx);
    NSString *result = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                        digest[0],digest[1],
                        digest[2],digest[3],
                        digest[4],digest[5],
                        digest[6],digest[7],
                        digest[8],digest[9],
                        digest[10],digest[11],
                        digest[12],digest[13],
                        digest[14],digest[15]
                        ];
    return result;
}

+ (unsigned long long)fileSize:(NSString *)filepath
{
    unsigned long long fileSize = 0;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filepath])
    {
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filepath
                                                                                    error:nil];
        id item = [attributes objectForKey:NSFileSize];
        fileSize = [item isKindOfClass:[NSNumber class]] ? [item unsignedLongLongValue] : 0;
    }
    return fileSize;

}

@end
