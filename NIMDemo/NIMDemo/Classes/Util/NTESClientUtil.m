//
//  NTESClientUtil.m
//  NIM
//
//  Created by chris on 15/7/27.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NTESClientUtil.h"

@implementation NTESClientUtil

+ (NSString *)clientName:(NIMLoginClientType)clientType{
    switch (clientType) {
        case NIMLoginClientTypeAOS:
        case NIMLoginClientTypeiOS:
        case NIMLoginClientTypeWP:
            return @"移动".ntes_localized;
        case NIMLoginClientTypePC:
        case NIMLoginClientTypemacOS:
            return @"电脑".ntes_localized;
        case NIMLoginClientTypeWeb:
            return @"网页".ntes_localized;
        default:
            return @"";
    }
}

@end
