//
//  NTESPrivatizationManager.m
//  NIM
//
//  Created by He on 2018/12/28.
//  Copyright © 2018 Netease. All rights reserved.
//

#import "NTESPrivatizationManager.h"
#import <NIMSDK/NIMSDK.h>
#import "NTESDemoConfig.h"

@interface NTESPrivatizationManager ()
@property(nonatomic, strong) NSString *requestURLStr;
@property(nonatomic, strong) NSURL *requestURL;
@property(nonatomic, copy) NSString *configFilePath;
@property(nonatomic, strong) dispatch_semaphore_t semaphore;
@end

@implementation NTESPrivatizationManager
@synthesize requestURL = URL;
@synthesize configFilePath = configFilePath;

+ (void)initialize {
    NSDictionary *dict = @{
                           @"privatization_enabled" : @(NO),
                           @"privatization_password_md5_enabled" : @(NO)
                           };
    [[NSUserDefaults standardUserDefaults] registerDefaults:dict];
}

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static NTESPrivatizationManager *instance;
    dispatch_once(&onceToken, ^{
        instance = [[NTESPrivatizationManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if(self = [super init]) {
        configFilePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingString:@"/private_config.cache"];
    }
    return self;
}

- (void)setupPrivatization {
    BOOL privatizationEnabled = NO;
    id setting = nil;
    setting = [[NSUserDefaults standardUserDefaults] objectForKey:@"privatization_enabled"];
    
    if(setting) {
        privatizationEnabled = [setting boolValue];
    }else {
        return;
    }
    
    if(!privatizationEnabled) {
        return;
    }
    
    setting = [[NSUserDefaults standardUserDefaults] valueForKey:@"privatization_url"];
    if(setting && ![self.requestURLStr isEqualToString:setting]) {
        URL = [NSURL URLWithString:setting];
        self.requestURLStr = setting;
    }else {
        return;
    }
    
    // 网络请求私有化文件
    self.semaphore = dispatch_semaphore_create(0);
    [self requestRemoteConfig];
    dispatch_semaphore_wait(self.semaphore, dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 3));
 
}

- (void)requestRemoteConfig {
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if([fileManager fileExistsAtPath:configFilePath]) {
            [fileManager removeItemAtPath:configFilePath error:nil];
        }
        
        if(error || !data) {
            NSLog(@"私有化配置地址获取失败");
        }else{
            [self setupPrivatizationWithDict:data];
        }
        dispatch_semaphore_signal(self.semaphore);
    }] resume];
}

#pragma mark -  SetupPrivatization

- (void)setupPrivatizationWithDict:(NSData *)data
{
    [self setupPrivatizationDemo:data];
    
    // NIM 私有化配置
    [self setupPrivatizationIM:data];

}

- (void)setupPrivatizationDemo:(NSData *)data {

    id obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    if (![obj isKindOfClass:[NSDictionary class]]) {
        NSLog(@"私有化配置数据格式错误，配置失败");
        return;
    }
    
    NSDictionary *config = (NSDictionary *)obj;
    id setting = [config objectForKey:@"appkey"];
    if(setting) {
        [NTESDemoConfig sharedConfig].appKey = setting;
    }
    
    setting = [config objectForKey:@"chatroomDemoListUrl"];
    if(setting) {
        [NTESDemoConfig sharedConfig].chatroomListURL = setting;
    }
    
}

- (void)setupPrivatizationIM:(NSData *)data {
    NIMServerSetting *nimServerSetting = [NIMSDK sharedSDK].serverSetting;
    [nimServerSetting updateSettingFromConfigData:data];
}


@end
