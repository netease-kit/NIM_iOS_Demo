//
//  NTESNoticationUtil.h
//  NIM
//
//  Created by Genning on 2020/8/27.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NTESNoticationUtil : NSObject

+ (NSString *)revokeNoticationContent:(NIMRevokeMessageNotification *)note;

@end

NS_ASSUME_NONNULL_END
