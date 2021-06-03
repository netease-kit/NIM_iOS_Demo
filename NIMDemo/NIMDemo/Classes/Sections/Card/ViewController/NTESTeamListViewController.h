//
//  NTESTeamListViewController.h
//  NIM
//
//  Created by Xuhui on 15/3/3.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NTESTeamListViewController : UITableViewController

@end

@interface NTESSuperTeamListViewController : NTESTeamListViewController<NIMTeamManagerDelegate>

@end

@interface NTESAdvancedTeamListViewController : NTESTeamListViewController<NIMTeamManagerDelegate>

@end

@interface NTESNormalTeamListViewController : NTESTeamListViewController<NIMTeamManagerDelegate>

@end
