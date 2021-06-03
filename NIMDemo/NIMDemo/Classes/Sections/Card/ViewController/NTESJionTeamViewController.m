//
//  NTESJionTeamViewController.m
//  NIM
//
//  Created by Xuhui on 15/3/19.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NTESJionTeamViewController.h"
#import "SVProgressHUD.h"
#import "UIView+Toast.h"
#import "NTESSessionViewController.h"
#import "UIAlertView+NTESBlock.h"

@interface NTESJionTeamViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *teamNameLabel;
@property (strong, nonatomic) IBOutlet UIButton *jionTeamBtn;
@property (strong, nonatomic) IBOutlet UILabel *teamIdLabel;

@end

@implementation NTESJionTeamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"加入群组".ntes_localized;
    self.teamNameLabel.text = self.joinTeam.teamName;
    self.teamIdLabel.text = [NSString stringWithFormat:@"%@：%@",@"群号".ntes_localized, self.joinTeam.teamId];
    if(self.joinTeam.joinMode == NIMTeamJoinModeRejectAll) {
        [self.jionTeamBtn setTitle:@"该群无法申请加入".ntes_localized forState:UIControlStateNormal];
        self.jionTeamBtn.userInteractionEnabled = NO;
    }
}

- (IBAction)onJionTeamBtnClick:(id)sender {
    __weak typeof(self) wself = self;
    if(self.joinTeam.joinMode == NIMTeamJoinModeNoAuth) {
        [self didApplyToTeamWithMessage:@""];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"输入验证信息".ntes_localized delegate:nil cancelButtonTitle:@"确定".ntes_localized otherButtonTitles:nil, nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert showAlertWithCompletionHandler:^(NSInteger index) {
            NSString *message = [alert textFieldAtIndex:0].text ? : @"";
            [wself didApplyToTeamWithMessage:message];
        }];
    }
    
}

- (void)handleApplyToTeam:(NSError *)error status:(NIMTeamApplyStatus)status {
    if (!error) {
        switch (status) {
            case NIMTeamApplyStatusAlreadyInTeam:{
                NIMSession *session = nil;
                if (_joinTeam.type == NIMTeamTypeSuper) {
                    session = [NIMSession session:self.joinTeam.teamId type:NIMSessionTypeSuperTeam];
                } else {
                    session = [NIMSession session:self.joinTeam.teamId type:NIMSessionTypeTeam];
                }

                NTESSessionViewController * vc = [[NTESSessionViewController alloc] initWithSession:session];
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            case NIMTeamApplyStatusWaitForPass:
                [self.view makeToast:@"申请成功，等待验证" duration:2.0 position:CSToastPositionCenter];
            default:
                break;
        }
    }else{
        DDLogDebug(@"Jion team failed: %@", error.localizedDescription);
        switch (error.code) {
            case NIMRemoteErrorCodeTeamAlreadyIn:
                [self.view makeToast:@"已经在群里" duration:2.0 position:CSToastPositionCenter];
                break;
            default:
                [self.view makeToast:@"群申请失败" duration:2.0 position:CSToastPositionCenter];
                break;
        }
    }
    DDLogDebug(@"Jion team status: %zd", status);
}

- (void)didApplyToTeamWithMessage:(NSString *)message {
    [SVProgressHUD show];
    __weak typeof(self) weakSelf = self;
    if (_joinTeam.type == NIMTeamTypeSuper) {
        [[NIMSDK sharedSDK].superTeamManager applyToTeam:self.joinTeam.teamId
                                                 message:message
                                              completion:^(NSError *error,NIMTeamApplyStatus applyStatus) {
            [SVProgressHUD dismiss];
            [weakSelf handleApplyToTeam:error status:applyStatus];
        }];
    } else {
        [[NIMSDK sharedSDK].teamManager applyToTeam:self.joinTeam.teamId
                                            message:message
                                         completion:^(NSError *error,NIMTeamApplyStatus applyStatus) {
            [SVProgressHUD dismiss];
            [weakSelf handleApplyToTeam:error status:applyStatus];
        }];
    }
}

@end
