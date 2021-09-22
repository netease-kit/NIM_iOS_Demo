//
//  NTESCountDownManager.m
//  NIM
//
//  Created by Wenchao Ding on 2021/7/5.
//  Copyright © 2021 Netease. All rights reserved.
//

#import "NTESCountDownManager.h"

NSString * const NTESCountDownTickNotification = @"NTESCountDownTickNotification";
NSString * const NTESCountDownCounterUserInfoKey = @"counter";

@interface NTESCountDownManager ()

@property (nonatomic, weak) NSTimer *timer;
@property (nonatomic, assign) NSInteger counter;

@end

@implementation NTESCountDownManager

+ (instancetype)sharedInstance {
    static NTESCountDownManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = self.new;
    });
    return instance;
}

- (void)dealloc {
    [self stop];
}

- (void)start:(NSInteger)seconds {
    if (self.isCounting) {
        return;
    }
    self.counter = seconds;
    [NSNotificationCenter.defaultCenter postNotificationName:NTESCountDownTickNotification object:nil userInfo:@{NTESCountDownCounterUserInfoKey: @(self.counter--)}];
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [NSNotificationCenter.defaultCenter postNotificationName:NTESCountDownTickNotification object:nil userInfo:@{NTESCountDownCounterUserInfoKey: @(self.counter--)}];
        if (self.counter <= -1) {
            [self.timer invalidate];
            self.timer = nil;
        }
    }];
    self.timer = timer;
}

- (void)stop {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
        self.counter = 0;
    }
}

- (BOOL)isCounting {
    return self.timer != nil;
}

@end

