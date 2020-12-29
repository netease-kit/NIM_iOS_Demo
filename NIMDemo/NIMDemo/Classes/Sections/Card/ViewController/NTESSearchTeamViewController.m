//
//  NTESSearchTeamViewController.m
//  NIM
//
//  Created by Xuhui on 15/3/19.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NTESSearchTeamViewController.h"
#import "SVProgressHUD.h"
#import "UIView+Toast.h"
#import "NTESJionTeamViewController.h"


@interface NTESSearchTeamViewController () <UITextFieldDelegate>
@property (nonatomic, assign) NIMTeamType teamType;
@property (strong, nonatomic) IBOutlet UITextField *textField;

@end

@implementation NTESSearchTeamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"搜索加入群组".ntes_localized;
    self.textField.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (instancetype)initWithTeamType:(NIMTeamType)teamType {
    if (self = [super init]) {
        _teamType = teamType;
    }
    return self;
}

#pragma mark - UITextFieldDelegate
- (void)hanldFetchTeamInfo:(NSError *)error team:(NIMTeam *)team {
    if(!error) {
        NTESJionTeamViewController *vc = [[NTESJionTeamViewController alloc] initWithNibName:nil bundle:nil];
        vc.joinTeam = team;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        [self.view makeToast:error.localizedDescription.ntes_localized
                    duration:2
                    position:CSToastPositionCenter];
        DDLogDebug(@"Fetch team info failed: %@", error.localizedDescription);
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.textField endEditing:YES];
    [SVProgressHUD show];
    __weak typeof(self) weakSelf = self;
    if (_teamType == NIMTeamTypeSuper) {
        [[NIMSDK sharedSDK].superTeamManager fetchTeamInfo:textField.text
                                                completion:^(NSError * _Nullable error, NIMTeam * _Nullable team) {
            [SVProgressHUD dismiss];
            [weakSelf hanldFetchTeamInfo:error team:team];
        }];
    } else {
        [[NIMSDK sharedSDK].teamManager fetchTeamInfo:textField.text
                                           completion:^(NSError *error, NIMTeam *team) {
            [SVProgressHUD dismiss];
            [weakSelf hanldFetchTeamInfo:error team:team];

        }];
    }
    return YES;
}

@end
