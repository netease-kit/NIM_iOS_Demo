//
//  NERoomLog.m
//  NERoomKit
//
//  Created by 周晓路 on 2022/1/24.
//

#import "QChatLog.h"
#import <YXAlog_iOS/YXAlog.h>


@implementation QChatLog
+ (void)setUp {
    YXAlogOptions *opt = [[YXAlogOptions alloc] init];
    opt.path = [self getDirectoryForDocuments:@"IMDemo"];
    opt.level = YXAlogLevelInfo;
    opt.filePrefix = @"qchatLog";
    opt.moduleName = @"IMDemo";
    [[YXAlog shared] setupWithOptions:opt];
}

+ (void)infoLog:(NSString *)className desc:(NSString *)desc {
    [YXAlog.shared logWithLevel:YXAlogLevelInfo
                            tag:className
                           type:YXAlogTypeNormal
                           line:0
                           desc:desc];
}

+ (void)warnLog:(NSString *)className desc:(NSString *)desc {
    [YXAlog.shared logWithLevel:YXAlogLevelWarn
                            tag:className
                           type:YXAlogTypeNormal
                           line:0
                           desc:desc];
}

+ (void)errorLog:(NSString *)className desc:(NSString *)desc {
    [YXAlog.shared logWithLevel:YXAlogLevelError
                            tag:className
                           type:YXAlogTypeNormal
                           line:0
                           desc:desc];
}

+ (NSString *)getDocumentPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

+ (NSString *)getDirectoryForDocuments:(NSString *)dir {
    NSString* dirPath = [[self getDocumentPath] stringByAppendingPathComponent:dir];
    BOOL isDir = NO;
    BOOL isCreated = [[NSFileManager defaultManager] fileExistsAtPath:dirPath isDirectory:&isDir];
    if ( !isCreated || !isDir) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES
                                                   attributes:nil error:nil];
    }
    return dirPath;
}
@end
