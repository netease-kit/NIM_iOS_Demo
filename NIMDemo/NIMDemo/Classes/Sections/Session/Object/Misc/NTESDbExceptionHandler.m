//
//  NTESDbExceptionHandler.m
//  NIM
//
//  Created by He on 2019/10/29.
//  Copyright © 2019 Netease. All rights reserved.
//

#import "NTESDbExceptionHandler.h"
#import <Toast/UIView+Toast.h>

@interface NTESDbExceptionHandler ()

@property (nonatomic,assign) NSUInteger count;

@end

@implementation NTESDbExceptionHandler

- (void)handleException:(NIMDatabaseException *)exception
{
    self.count ++;
    
    NSString * codeType = nil;
    switch (exception.exception) {

        case NIMDatabaseExceptionTypeBadDb:
            codeType = @"数据库损坏";
            break;
        default:
            break;
        }

    
    NSString * msg = [NSString stringWithFormat:@"总次数%zu\n错误:%@\n信息:%@\n路径:%@\n",self.count, codeType,exception.message, exception.databasePath];
    NSLog(@"handleException: %@",msg);
    [[UIApplication sharedApplication].keyWindow hideToasts];
    [[UIApplication sharedApplication].keyWindow makeToast:msg
                                                  duration:3
                                                  position:CSToastPositionCenter];
}

@end
