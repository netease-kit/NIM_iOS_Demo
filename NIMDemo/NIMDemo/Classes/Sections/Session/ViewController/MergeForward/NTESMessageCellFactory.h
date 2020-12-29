//
//  NTESMessageCellFactory.h
//  NIM
//
//  Created by zhanggenning on 2019/10/18.
//  Copyright © 2019 Netease. All rights reserved.
//

#import "NIMMessageCellFactory.h"
#import "NTESTimestampCell.h"
#import "NTESMergeMessageCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface NTESMessageCellFactory : NIMMessageCellFactory

- (NTESMergeMessageCell *)ntesCellInTable:(UITableView*)tableView
                           forMessageMode:(NIMMessageModel *)model;

- (NTESTimestampCell *)ntesCellInTable:(UITableView *)tableView
                          forTimeModel:(NIMTimestampModel *)model;

@end

NS_ASSUME_NONNULL_END
