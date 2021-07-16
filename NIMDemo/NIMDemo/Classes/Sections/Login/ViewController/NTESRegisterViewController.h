//
//  NTESRegisterViewController.h
//  NIM
//
//  Created by amao on 8/10/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NTESRegisterViewControllerDelegate <NSObject>

@optional
- (void)registerDidComplete:(NSString *)account password:(NSString *)password;

@end

@interface NTESRegisterViewController : UIViewController

/// 手机号
@property (nonatomic, copy) NSString *phone;

/// 代理对象
@property (nonatomic, weak) id<NTESRegisterViewControllerDelegate> delegate;

/// 手机号
@property (strong, nonatomic) IBOutlet UITextField *phoneTextField;

/// 验证码
@property (strong, nonatomic) IBOutlet UITextField *authCodeTextField;

/// 昵称
@property (strong, nonatomic) IBOutlet UITextField *nicknameTextField;

/// 获取验证码
@property (strong, nonatomic) IBOutlet UIButton *authCodeButton;

/// 获取验证码
- (IBAction)authCodeClicked:(id)sender;

/// 手机号输入
- (IBAction)phoneValueChanged:(id)sender;

/// 验证码输入
- (IBAction)authCodeValueChanged:(id)sender;

@end
