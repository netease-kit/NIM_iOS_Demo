//
//  NTESPrivatizationManager.h
//  NIM
//
//  Created by He on 2019/1/2.
//  Copyright © 2019 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NTESPrivatizationManager : NSObject
+ (instancetype)sharedInstance;
- (void)setupPrivatization;
@end
