//
//  NTESLogViewController.m
//  NIM
//
//  Created by Xuhui on 15/4/1.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NTESLogViewController.h"
#import "NTESLogManager.h"

@interface NTESLogViewController ()<NSLayoutManagerDelegate>
@property (strong, nonatomic) UITextView *logTextView;
@property (copy,nonatomic) NSString *path;
@property (copy,nonatomic) NSString *content;
@end

@implementation NTESLogViewController


- (instancetype)initWithFilepath:(NSString *)path
{
    if (self = [super init])
    {
        self.path = path;
    }
    return self;
}


- (instancetype)initWithContent:(NSString *)content
{
    if (self = [super init])
    {
        self.content = content;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.view addSubview:self.logTextView];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"退出".ntes_localized style:UIBarButtonItemStyleDone target:self action:@selector(onDismiss:)];
    
    NSString *content = nil;
    if (_path)
    {
        NSData *data = [NSData dataWithContentsOfFile:_path];
        content = [[NSString alloc] initWithData:data
                                        encoding:NSUTF8StringEncoding];
        if (content == nil)
        {
            content = [[NSString alloc] initWithData:data
                                            encoding:NSASCIIStringEncoding];
        }
    }
    else if(_content)
    {
        content = _content;
    }
    
    _logTextView.text = content;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if ([_logTextView.text length])
    {
        [_logTextView scrollRangeToVisible:NSMakeRange([_logTextView.text length], 0)];
    }
    
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _logTextView.frame = self.view.bounds;
}

- (void)onDismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UITextView *)logTextView {
    if (!_logTextView) {
        _logTextView = [[UITextView alloc] initWithFrame:self.view.bounds];
        _logTextView.font = [UIFont systemFontOfSize:14.0];
        _logTextView.textColor = [UIColor lightTextColor];
        _logTextView.backgroundColor = [UIColor blackColor];
    }
    return _logTextView;
}

@end
