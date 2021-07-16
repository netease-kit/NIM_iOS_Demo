//
//  NTESSmsLoginViewController.h
//  NIM
//
//  Created by Wenchao Ding on 2021/7/2.
//  Copyright © 2021 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NTESSmsLoginViewController : UIViewController

/// 手机号
@property (strong, nonatomic) IBOutlet UITextField *phoneTextField;

/// 验证码
@property (strong, nonatomic) IBOutlet UITextField *authCodeTextField;

/// 注册
@property (strong, nonatomic) IBOutlet UIButton *registerButton;

/// 获取验证码
@property (strong, nonatomic) IBOutlet UIButton *authCodeButton;

/// 账号密码登录
@property (strong, nonatomic) IBOutlet UIButton *pwdLoginButton;

/// 注册
- (IBAction)registerClicked:(id)sender;

/// 账号密码登录
- (IBAction)pwdLoginClicked:(id)sender;

/// 获取验证码
- (IBAction)authCodeClicked:(id)sender;

/// 手机号输入
- (IBAction)phoneValueChanged:(id)sender;

/// 验证码输入
- (IBAction)authCodeValueChanged:(id)sender;

@end

NS_ASSUME_NONNULL_END
