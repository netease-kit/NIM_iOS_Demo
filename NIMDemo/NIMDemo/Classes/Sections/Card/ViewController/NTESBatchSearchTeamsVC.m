//
//  NTESBatchSearchTeamsVCViewController.m
//  NIM
//
//  Created by I am Groot on 2020/12/14.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NTESBatchSearchTeamsVC.h"
#import "SVProgressHUD.h"
#import "UIView+Toast.h"

@interface NTESBatchSearchTeamsVC ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (nonatomic, assign) NIMTeamType teamType;

@end

@implementation NTESBatchSearchTeamsVC

- (instancetype)initWithTeamType:(NIMTeamType)teamType {
    if (self = [super init]) {
        _teamType = teamType;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.textField endEditing:YES];
    [SVProgressHUD show];
    if (_teamType == NIMTeamTypeSuper) {

    } else {
        NSArray *teamIds = [textField.text componentsSeparatedByString:@"+"];
        if (!teamIds.count) {
            NSLog(@"fetchTeamInfoList teamIds.count:%ld",teamIds.count);
            return YES;
        }
        [[NIMSDK sharedSDK].teamManager fetchTeamInfoList:teamIds completion:^(NSError * _Nullable error, NSArray<NIMTeam *> * _Nullable teams, NSArray<NSString *> * _Nullable failedTeamIds) {
            [SVProgressHUD dismiss];
            NSLog(@"fetchTeamInfoList error:%@ failedTeamIds:%@",error,failedTeamIds);
            for (NIMTeam *team in teams) {
                NSLog(@"fetchTeamInfoList team:%@",team);
                
            }
        }];
    }
    return YES;
}

@end
