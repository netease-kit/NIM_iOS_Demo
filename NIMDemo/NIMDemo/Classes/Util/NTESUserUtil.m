//
//  NTESUserUtil.m
//  NIM
//
//  Created by chris on 15/9/17.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NTESUserUtil.h"
#import "NIMKitUtil.h"

@implementation NTESUserUtil

+ (NSString *)genderString:(NIMUserGender)gender{
    NSString *genderStr = @"";
    switch (gender) {
        case NIMUserGenderMale:
            genderStr = @"男".ntes_localized;
            break;
        case NIMUserGenderFemale:
            genderStr = @"女".ntes_localized;
            break;
        case NIMUserGenderUnknown:
            genderStr = @"未知".ntes_localized;
        default:
            break;
    }
    return genderStr;
}

@end
