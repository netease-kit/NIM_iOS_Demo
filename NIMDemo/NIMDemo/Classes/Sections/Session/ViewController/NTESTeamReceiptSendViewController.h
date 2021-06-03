//
//  NTESTeamReceiptSendViewController.h
//  NIM
//
//  Created by chris on 2018/3/14.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import "NIMGrowingTextView.h"

@interface NTESTeamReceiptSendViewController : UIViewController

- (instancetype)initWithSession:(NIMSession *)session;

@property (nonatomic,strong) UITextView *sendTextView;

@property (nonatomic,strong) IBOutlet UIButton *sendButton;

@end
