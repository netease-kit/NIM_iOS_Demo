//
//  NERtcCallKitUtils.m
//  NERtcCallKit
//
//  Created by Wenchao Ding on 2020/11/24.
//  Copyright © 2020 Wenchao Ding. All rights reserved.
//

#import "NERtcCallKitUtils.h"

@implementation NERtcCallKitUtils

+ (NSString *)generateRequestID {
    NSInteger random = arc4random() % 1000;
    NSString *requestID = [NSString stringWithFormat:@"%.f%zd",[NSDate timeIntervalSinceReferenceDate],random];
    return requestID;
}


@end
