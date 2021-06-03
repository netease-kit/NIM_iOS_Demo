//
//  NTESAudio2TextViewController.m
//  NIM
//
//  Created by amao on 7/10/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NTESAudio2TextViewController.h"
#import "UIView+Toast.h"
#import "SVProgressHUD.h"
#import "UIView+NTES.h"
#import "NTESSessionViewController.h"
#import "NTESMainTabController.h"
#import "UIView+NTES.h"

@interface NTESAudio2TextViewController ()
@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) NIMAudioToTextOption *option;
@property (strong, nonatomic) NIMMessage *message;

@end

@implementation NTESAudio2TextViewController

- (instancetype)initWithMessage:(NIMMessage *)message
{
    if (self = [super initWithNibName:@"NTESAudio2TextViewController"
                               bundle:nil])
    {
        NIMAudioToTextOption *option = [[NIMAudioToTextOption alloc] init];
        option.url                   = [(NIMAudioObject *)message.messageObject url];
        option.filepath              = [(NIMAudioObject *)message.messageObject path];
        _option = option;
        _message = message;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [SVProgressHUD showWithStatus:@"正在转换".ntes_localized];
    [self.view addSubview:self.textView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    [self.textView addGestureRecognizer:tap];
    __weak typeof(self) weakSelf = self;
    
    if (_option.url.length == 0) { //上传一把
        [self doUploadWithCompletion:^(NSError *error) {
            if (error) {
                [weakSelf switchEndUI:error text:@"转换文件上传失败".ntes_localized];
                DDLogError(@"upload audio error, %@",error);
            } else {
                [self doTransAudioToTextWithCompletion:^(NSError *error, NSString *text) {
                      [weakSelf switchEndUI:error text:text];
                      if (!error) {
                          weakSelf.message.isPlayed = YES;
                      }else{
                          DDLogError(@"audio 2 text error, %@",error);
                      }
                }];
            }
        }];
    } else { //直接转
        [self doTransAudioToTextWithCompletion:^(NSError *error, NSString *text) {
            [weakSelf switchEndUI:error text:text];
            if (!error) {
                weakSelf.message.isPlayed = YES;
            } else {
                DDLogError(@"audio 2 text error, %@",error);
            }
        }];
    }
}

- (void)switchEndUI:(NSError *)error text:(NSString *)text {
    [SVProgressHUD dismiss];
    self.cancelBtn.hidden = YES;
    [self show:error text:text];
    if (error) {
        [self.textView removeFromSuperview];
        [self.view addSubview:self.errorTipView];
    }
}

- (void)doTransAudioToTextWithCompletion:(void (^)(NSError *error, NSString *text))completion {
    [[[NIMSDK sharedSDK] mediaManager] transAudioToText:_option
                                                 result:^(NSError *error, NSString *text) {
        if (completion) {
            completion(error, text);
        }
    }];
}

- (void)doUploadWithCompletion:(void (^)(NSError *error))completion {
    
    NSError *locError = [NSError errorWithDomain:@"nim.demo.auido2Text" code:1000 userInfo:nil];
    
    if (_option.filepath.length == 0 ||
        ![[NSFileManager defaultManager] fileExistsAtPath:_option.filepath] ) {
        if (completion) {
            completion(locError);
        }
        return;
    }
    
    if (_option.url.length != 0) {
        if (completion) {
            completion(nil);
        }
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [[[NIMSDK sharedSDK] resourceManager] upload:_option.filepath
                                        progress:nil
                                      completion:^(NSString * _Nullable urlString, NSError * _Nullable error) {
        if (!error) {
            weakSelf.option.url = urlString;
        }
        if (completion) {
            completion(error);
        }
    }];
}


- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    CGFloat top = [UIApplication sharedApplication].statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height;
    self.textView.top = top;
    CGRect rect = CGRectApplyAffineTransform(self.view.frame, self.view.transform);
    self.errorTipView.top = rect.size.height * .33f;
    self.errorTipView.centerX = rect.size.width * .5f;
}


- (void)show:(NSError *)error
        text:(NSString *)text
{
    if (error) {
        [self.view makeToast:NSLocalizedString(@"转换失败", nil)
                    duration:2
                    position:CSToastPositionCenter];
    }
    else
    {
        _textView.text = text;
        [_textView sizeToFit];
        if (self.textView.height + self.textView.top > self.view.height) {
            self.textView.height = self.view.height - self.textView.top;
            self.textView.scrollEnabled = YES;
        }else{
            self.textView.scrollEnabled = NO;
        }
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self hide];
}

- (void)hide{
    [SVProgressHUD dismiss];
    void (^handler)(void)  = self.completeHandler;
    [self dismissViewControllerAnimated:NO
                             completion:^{
                                 if (handler) {
                                     handler();
                                 }
                             }];
}

- (IBAction)cancelTrans:(id)sender{
    [SVProgressHUD dismiss];
    [self dismissViewControllerAnimated:NO
                             completion:nil];
}

- (BOOL)shouldAutorotate{
    return NO;
}

- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] initWithFrame:self.view.bounds];
        _textView.font = [UIFont systemFontOfSize:34.0];
    }
    return _textView;
}

@end
