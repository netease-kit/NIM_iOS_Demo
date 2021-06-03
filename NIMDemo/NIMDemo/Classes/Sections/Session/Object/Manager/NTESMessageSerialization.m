//
//  NTESMessageSerialization.m
//  NIM
//
//  Created by Netease on 2019/10/16.
//  Copyright © 2019 Netease. All rights reserved.
//

#import "NTESMessageSerialization.h"
#import "NTESFileLocationHelper.h"
#import "NTESFileUtil.h"
#import "NTESMigrateHeader.h"
#import "NSData+NTES.h"

static dispatch_queue_t NTESMessageSerializationQueue()
{
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("nim.demo.message.serialization.queue", 0);
    });
    return queue;
}

@interface NTESMessageSerialization ()

@property (nonatomic, copy) NSString *targetFile;

@end


@implementation NTESMessageSerialization

- (void)encode:(NSArray <NIMMessage *>*)messages
       encrypt:(BOOL)encrypt
      password:(NSString *)password
    completion:(NTESMessageEncodeResult)completion {
    
    dispatch_async(NTESMessageSerializationQueue(), ^{
        NSMutableArray *datas = [NSMutableArray array];
        __block NSError *error = nil;
        
        //header
        NSData *headerRowData = [self fileHeaderWithCount:messages.count];
        
        if (!headerRowData) {
            dispatch_async(dispatch_get_main_queue(), ^{
                error = [NSError errorWithDomain:@"ntes.message.serialization" code:1000 userInfo:nil];
                if (completion) {
                    completion(error, nil);
                }
            });
            return;
        }
        [datas addObject:headerRowData];
        
        //message
        NSArray *messageRowData = [self messageRowData:messages];
        if (messageRowData.count == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                error = [NSError errorWithDomain:@"ntes.message.serialization" code:1001 userInfo:nil];
                if (completion) {
                    completion(error, nil);
                }
            });
            return;
        }
        [datas addObjectsFromArray:messageRowData];
        
        //write
        NSString *file = [self writeRowDatasToFile:datas encrypt:encrypt password:password];
        if (file == nil) {
            error = [NSError errorWithDomain:@"ntes.message.serialization" code:1002 userInfo:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(error, nil);
                }
            });
            return;
        }
        
        //md5
        NSString *md5 = [NTESFileUtil fileMD5:file];
        if (!md5) {
            //delete
            [[NSFileManager defaultManager] removeItemAtPath:file error:nil];
            
            //error
            error = [NSError errorWithDomain:@"ntes.message.serialization" code:1003 userInfo:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(error, nil);
                }
            });
            return;
        }
        
        //callback
        NTESMessageSerializationInfo *info = [[NTESMessageSerializationInfo alloc] init];
        info.filePath = file;
        info.md5 = md5;
        info.encrypted = YES;
        info.password = password;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(error, info);
            }
        });
    });
    
}

- (void)decode:(NSString *)filePath
       encrypt:(BOOL)encrypt
      password:(NSString *)password
    completion:(NTESMessageDecodeResult)completion {
    dispatch_async(NTESMessageSerializationQueue(), ^{
        NSError *error = nil;

        NSMutableArray *ret = [self readRowDatasFromFile:filePath encrypt:encrypt password:password];
        if (!ret) {
            error = [NSError errorWithDomain:@"ntes.message.serialization" code:1003 userInfo:nil];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(error, ret);
            }
        });
    });
}

#pragma mark - Export
- (NSString *)targetFile {
    NSDate * date = [[NSDate alloc] init];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"YYYYMMddhhmmssSSS";
    NSString *fileName = [[formatter stringFromDate:date] stringByAppendingString:@".txt"];
    return [NTESFileLocationHelper filepathForMergeForwardFile:fileName];
}

- (NSData *)fileHeaderWithCount:(NSInteger)count {
    NTESMigrateHeader *header = [NTESMigrateHeader initWithDefaultConfig];
    header.totalInfoCount = count;
    return [header toRawContent];
}

- (NSMutableArray <NSData *>*)messageRowData:(NSArray <NIMMessage *>*)messages {
    NSMutableArray *ret = [NSMutableArray array];
    [messages enumerateObjectsUsingBlock:^(NIMMessage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSData *data = [[NIMSDK sharedSDK].conversationManager encodeMessageToData:obj];
        if (data) {
            [ret addObject:data];
        }
    }];
    return ret;
}

- (NSString *)writeRowDatasToFile:(NSMutableArray *)datas
                          encrypt:(BOOL)encrypt
                         password:(NSString *)password {
    NSString *filePath = [self targetFile];
    FILE *fp = fopen([filePath UTF8String], "wb");
    if (!fp) {
        return nil;
    }
    NSMutableData *temp = [NSMutableData data];
    NSString *newlineStr = @"\n";
    NSData *newline = [newlineStr dataUsingEncoding:NSUTF8StringEncoding];
    [datas enumerateObjectsUsingBlock:^(NSData *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [temp appendData:obj];
        [temp appendData:newline];
    }];
    
    if (temp.length != 0) {
        if (encrypt) {
            NSData *encryptData = [temp rc4EncryptWithKey:password];
            fwrite(encryptData.bytes, 1, encryptData.length, fp);
        } else {
            fwrite(temp.bytes, 1, temp.length, fp);
        }
        [temp resetBytesInRange:NSMakeRange(0, temp.length)];
        [temp setLength:0];
    }

    fclose(fp);
    return filePath;
}

#pragma mark - Import
- (NSString *)readFileString:(NSString *)file
                     encrypt:(BOOL)encrypt
                    password:(NSString *)password{
    FILE *fp = NULL;
    char szBlock[1024*100] = {0};
    size_t len = 0;
    NSMutableString *ret = [NSMutableString string];
    
    fp = fopen(file.UTF8String, "r");
    if (fp == NULL) {
        return nil;
    }
    
    while (!feof(fp)) {
        len = fread(szBlock, 1, sizeof(szBlock), fp);
        NSData *fileData = [NSData dataWithBytes:szBlock length:len];
        if (encrypt) {
            NSData *decryptData = [fileData rc4DecryptWithKey:password];
            NSString *decryptStr = [[NSString alloc] initWithData:decryptData encoding:NSUTF8StringEncoding];
            if (decryptStr) {
                [ret appendString:decryptStr];
            }
        } else {
            NSString *fileStr = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
            if (fileStr) {
                [ret appendString:fileStr];
            }
        }
    }
    
    fclose(fp);
    return ret;
}


- (NSMutableArray <NIMMessage *>*)readRowDatasFromFile:(NSString *)file
                                               encrypt:(BOOL)encrypt
                                              password:(NSString *)password {
    
    NSMutableArray *ret = nil;
    NSString *fileString = [self readFileString:file encrypt:encrypt password:password];
    NSArray *subStrings = [fileString componentsSeparatedByString:@"\n"];
    NTESMigrateHeader *header = nil;
    NSInteger count = 0;
    if (subStrings.count == 0) {
        return ret;
    }
    
    for (int i = 0; i < subStrings.count; i++) {
        NSString *jsonString = subStrings[i];
        if (i == 0) {
            NSData *headerData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            header = [NTESMigrateHeader initWithRawContent:headerData];
            if (header == nil) {
                break;
            }
        } else {
            if (count++ == header.totalInfoCount) {
                break;
            }
            if (!ret) {
                ret = [NSMutableArray array];
            }
            NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            NIMMessage *message = [[NIMSDK sharedSDK].conversationManager decodeMessageFromData:data];
            if (message) {
                [ret addObject:message];
            }
        }
    }
    return ret;
}

@end


@implementation NTESMessageSerializationInfo

@end
