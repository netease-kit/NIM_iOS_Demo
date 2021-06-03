//
//  NTESLoginManager.h
//  NIM
//
//  Created by amao on 5/26/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NTESLoginData : NSObject

@property (nonatomic,copy)  NSString *account;
@property (nonatomic,copy)  NSString *token;
@property (nonatomic)       int authType;
@property (nonatomic,copy)  NSString *loginExtension;

- (BOOL)isValid;

@end

@interface NTESLoginManager : NSObject
+ (instancetype)sharedManager;

@property (nonatomic,strong)    NTESLoginData   *currentLoginData;
@end
