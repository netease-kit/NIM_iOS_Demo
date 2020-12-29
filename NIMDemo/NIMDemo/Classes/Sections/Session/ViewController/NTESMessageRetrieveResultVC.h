//
//  NTESMessageRetrieveResultVC.h
//  NIM
//
//  Created by He on 2019/12/18.
//  Copyright © 2019 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NIMCommonTableData;

NS_ASSUME_NONNULL_BEGIN

@interface NTESMessageRetrieveResultVC : UIViewController <UISearchResultsUpdating>

@property (nonatomic,strong) UITableView * tableView;

@property (nonatomic,strong) NSArray<NIMCommonTableData *> * datas;

@property (nonatomic,weak) UISearchBar * searchBar;

@end

NS_ASSUME_NONNULL_END
