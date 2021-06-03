//
//  NTESMessageCellFactory.m
//  NIM
//
//  Created by zhanggenning on 2019/10/18.
//  Copyright © 2019 Netease. All rights reserved.
//

#import "NTESMessageCellFactory.h"

@implementation NTESMessageCellFactory

- (NTESMergeMessageCell *)ntesCellInTable:(UITableView*)tableView
                         forMessageMode:(NIMMessageModel *)model {
    id<NIMCellLayoutConfig> layoutConfig = [[NIMKit sharedKit] layoutConfig];
    NSString *identity = [[layoutConfig cellContent:model] stringByAppendingString:@"_ntes"];
    NIMMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:identity];
    if (!cell) {
        NSString *clz = @"NTESMergeMessageCell";
        [tableView registerClass:NSClassFromString(clz) forCellReuseIdentifier:identity];
        cell = [tableView dequeueReusableCellWithIdentifier:identity];
    }
    return (NTESMergeMessageCell *)cell;
}

- (NTESTimestampCell *)ntesCellInTable:(UITableView *)tableView
                            forTimeModel:(NIMTimestampModel *)model {
    NSString *identity = @"time_ntes";
    NTESTimestampCell *cell = [tableView dequeueReusableCellWithIdentifier:identity];
    if (!cell) {
        NSString *clz = @"NTESTimestampCell";
        [tableView registerClass:NSClassFromString(clz) forCellReuseIdentifier:identity];
        cell = [tableView dequeueReusableCellWithIdentifier:identity];
    }
    [cell refreshData:model];
    return (NTESTimestampCell *)cell;
}

@end
