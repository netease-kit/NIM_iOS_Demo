//
//  NTESRegisterViewController.m
//  NIM
//
//  Created by amao on 8/10/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NTESRegisterViewController.h"
#import "NTESDemoService.h"
#import "NSString+NTES.h"
#import "UIView+Toast.h"
#import "UIView+NTES.h"
#import "SVProgressHUD.h"
#import "NTESLoginManager.h"
#import "NTESCountDownManager.h"
#import "NTESLoginViewController.h"
#import "NSString+NTES.h"

@interface NTESRegisterViewController ()<UITextFieldDelegate>

@end

@implementation NTESRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self setupNotifications];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:UIImage.new
                             forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.tintColor = UIColor.whiteColor;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (textField == self.phoneTextField) {
        return newString.length <= 11;
    }
    if (textField == self.nicknameTextField) {
        return newString.length <= 10;
    }
    if (textField == self.authCodeTextField) {
        return newString.length <= 6;
    }
    return NO;
}

#pragma mark - Actions

- (IBAction)phoneValueChanged:(id)sender {
    self.authCodeButton.enabled = self.phoneTextField.text.length > 0;
    self.navigationItem.rightBarButtonItem.enabled = self.phoneTextField.text.length > 0 && self.authCodeTextField.text.length > 0;
}

- (IBAction)authCodeValueChanged:(id)sender {
    self.navigationItem.rightBarButtonItem.enabled = self.phoneTextField.text.length > 0 && self.authCodeTextField.text.length > 0;
}

- (IBAction)authCodeClicked:(id)sender {
    __weak typeof(self) wself = self;
    [NTESLoginManager.sharedManager sendSmsCode:self.phoneTextField.text completion:^(NSError *error) {
        __strong typeof(wself) sself = wself;
        if (!sself) return;
        if (error) {
            [sself.view makeToast:error.localizedDescription];
            return;
        }
        [sself startCountDown];
    }];
}

- (void)doneItemClicked:(id)sender {
    if (self.phoneTextField.text.length < 11) {
        [self.view makeToast:@"手机号格式错误"];
        return;
    }
    NTESSmsRegisterParams *params = [[NTESSmsRegisterParams alloc] init];
    params.mobile = self.phoneTextField.text;
    params.smsCode = self.authCodeTextField.text;
    params.nickname = self.nicknameTextField.text;
    __weak typeof(self) wself = self;
    [NTESLoginManager.sharedManager smsRegister:params completion:^(NTESSmsLoginResult *result, NSError *error) {
        __strong typeof(wself) sself = wself;
        if (!sself) return;
        if (error) {
            [sself.view makeToast:error.localizedDescription];
            return;
        }
        [NTESCountDownManager.sharedInstance stop];
        NSString *accid = result.imAccid;
        NSString *token = result.imToken;
        // IM Login
        [NIMSDK.sharedSDK.loginManager login:accid
                                       token:token
                                  completion:^(NSError * _Nullable error) {
            [SVProgressHUD dismiss];
            if (error) {
                NSString *toast = [NSString stringWithFormat:@"%@ code: %zd",@"登录失败".ntes_localized, error.code];
                [self.view makeToast:toast duration:2.0 position:CSToastPositionCenter];
                return;
            }
            [self finishIMLogin:accid token:token];
        }];
    }];
}

- (void)onCountDownNotification:(NSNotification *)notification {
    NSInteger counter = [notification.userInfo[NTESCountDownCounterUserInfoKey] integerValue];
    if (counter > 0) {
        [self.authCodeButton setTitle:[NSString stringWithFormat:@"%lds后可重发",counter] forState:UIControlStateDisabled];
    } else {
        self.authCodeButton.enabled = YES;
    }
}

#pragma mark - Private

- (void)setupUI {
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(doneItemClicked:)];
    [doneItem setBackgroundImage:[UIImage imageNamed:@"login_btn_done_normal"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [doneItem setTitleTextAttributes:@{
        NSFontAttributeName: [UIFont systemFontOfSize:15],
        NSForegroundColorAttributeName: UIColor.systemBlueColor
    } forState:UIControlStateNormal];
    [doneItem setTitleTextAttributes:@{
        NSFontAttributeName: [UIFont systemFontOfSize:15],
        NSForegroundColorAttributeName: [UIColor.systemBlueColor colorWithAlphaComponent:0.5]
    } forState:UIControlStateDisabled];
    [doneItem setTitleTextAttributes:@{
        NSFontAttributeName: [UIFont systemFontOfSize:15]
    } forState:UIControlStateHighlighted];
    doneItem.enabled = NO;
    self.navigationItem.rightBarButtonItem = doneItem;
    
    UIImage *image = [UIImage imageNamed:@"icon_back_normal.png"];
    [self.navigationController.navigationBar setBackIndicatorImage:image];
    [self.navigationController.navigationBar setBackIndicatorTransitionMaskImage:image];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backItem;
    
    self.phoneTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.phoneTextField.placeholder attributes:@{NSForegroundColorAttributeName: UIColor.whiteColor}];
    self.authCodeTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.authCodeTextField.placeholder attributes:@{NSForegroundColorAttributeName: UIColor.whiteColor}];
    self.nicknameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.nicknameTextField.placeholder attributes:@{NSForegroundColorAttributeName: UIColor.whiteColor}];
    
    if (self.phone.length) {
        self.phoneTextField.text = self.phone;
        [self.phoneTextField sendActionsForControlEvents:UIControlEventEditingChanged];
    }
    
}

- (void)setupNotifications {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onCountDownNotification:) name:NTESCountDownTickNotification object:nil];
}

- (void)startCountDown {
    self.authCodeButton.enabled = NO;
    if (!NTESCountDownManager.sharedInstance.isCounting) {
        [NTESCountDownManager.sharedInstance start:60];
    }
}

- (void)finishIMLogin:(NSString *)accid token:(NSString *)token {
    if (self.delegate && [self.delegate respondsToSelector:@selector(registerDidComplete:password:)]) {
        [self.delegate registerDidComplete:accid password:token];
    }
}

@end
