//
//  NTESLoginManager.m
//  NIM
//
//  Created by amao on 5/26/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NTESLoginManager.h"
#import "NTESFileLocationHelper.h"
#import "NTESDemoConfig.h"

#define NIMAccount      @"account"
#define NIMToken        @"token"

#if DEBUG
static NSString * const kApiHost = @"https://yiyong-qa.netease.im";
#else
static NSString * const kApiHost = @"http://yiyong.netease.im";
#endif

@interface NTESLoginData ()<NSCoding>

@end

@implementation NTESLoginData

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        _account = [aDecoder decodeObjectForKey:NIMAccount];
        _token = [aDecoder decodeObjectForKey:NIMToken];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    if ([_account length]) {
        [encoder encodeObject:_account forKey:NIMAccount];
    }
    if ([_token length]) {
        [encoder encodeObject:_token forKey:NIMToken];
    }
}
@end

@interface NTESLoginManager ()
@property (nonatomic,copy)  NSString    *filepath;
@end

@implementation NTESLoginManager

+ (instancetype)sharedManager
{
    static NTESLoginManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *filepath = [[NTESFileLocationHelper getAppDocumentPath] stringByAppendingPathComponent:@"nim_sdk_ntes_login_data"];
        instance = [[NTESLoginManager alloc] initWithPath:filepath];
    });
    return instance;
}


- (instancetype)initWithPath:(NSString *)filepath
{
    if (self = [super init])
    {
        _filepath = filepath;
        [self readData];
    }
    return self;
}


- (void)setCurrentLoginData:(NTESLoginData *)currentLoginData
{
    _currentLoginData = currentLoginData;
    [self saveData];
}

//从文件中读取和保存用户名密码,建议上层开发对这个地方做加密,DEMO只为了做示范,所以没加密
- (void)readData
{
    NSString *filepath = [self filepath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filepath])
    {
        id object = [NSKeyedUnarchiver unarchiveObjectWithFile:filepath];
        _currentLoginData = [object isKindOfClass:[NTESLoginData class]] ? object : nil;
    }
}

- (void)saveData
{
    NSData *data = [NSData data];
    if (_currentLoginData)
    {
        data = [NSKeyedArchiver archivedDataWithRootObject:_currentLoginData];
    }
    [data writeToFile:[self filepath] atomically:YES];
}

- (void)sendSmsCode:(NSString *)mobile completion:(void (^)(NSError *))completion {
    NSURL *baseURL = [NSURL URLWithString:kApiHost];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"/auth/sendLoginSmsCode" relativeToURL:baseURL]];
    request.HTTPMethod = @"POST";
    NSDictionary *params = @{ @"mobile": mobile };
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:NTESDemoConfig.sharedConfig.appKey forHTTPHeaderField:@"appKey"];
    NSURLSessionDataTask *task = [NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *JSON;
        if (!error) {
            if ([(NSHTTPURLResponse *)response statusCode] != 200) {
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSURLErrorCannotDecodeContentData userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Fail for status code: %@", @([(NSHTTPURLResponse *)response statusCode])]}];
            } else if (!data) {
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSURLErrorCannotDecodeContentData userInfo:@{NSLocalizedDescriptionKey: @"Empty data"}];
            } else {
                JSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                if (!error) {
                    NSInteger code = [JSON[@"code"] integerValue];
                    if (code != 200) {
                        error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSURLErrorBadServerResponse userInfo:@{NSLocalizedDescriptionKey: JSON[@"msg"] ?: @"Empty message field!"}];
                    }
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(error);
            }
        });
    }];
    [task resume];
}

- (void)smsLogin:(NTESSmsLoginParams *)params completion:(void (^)(NTESSmsLoginResult *, NSError *))completion {
    NSURL *baseURL = [NSURL URLWithString:kApiHost];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"/auth/loginBySmsCode" relativeToURL:baseURL]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:params.toDictionary options:0 error:nil];
    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:NTESDemoConfig.sharedConfig.appKey forHTTPHeaderField:@"appKey"];
    NSURLSessionDataTask *task = [NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *JSON;
        if (!error) {
            if ([(NSHTTPURLResponse *)response statusCode] != 200) {
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSURLErrorCannotDecodeContentData userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Fail for status code: %@", @([(NSHTTPURLResponse *)response statusCode])]}];
            } else if (!data) {
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSURLErrorCannotDecodeContentData userInfo:@{NSLocalizedDescriptionKey: @"Empty data"}];
            } else {
                JSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                if (!error) {
                    NSInteger code = [JSON[@"code"] integerValue];
                    if (code != 200) {
                        error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSURLErrorBadServerResponse userInfo:@{NSLocalizedDescriptionKey: JSON[@"msg"] ?: @"Empty message field!"}];
                    }
                }
            }
        }
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(nil, error);
                }
            });
            return;
        }
        NTESSmsLoginResult *result = [[NTESSmsLoginResult alloc] initWithDictionary:JSON[@"data"]];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(result, nil);
            }
        });
    }];
    [task resume];
}

- (void)smsRegister:(NTESSmsRegisterParams *)params completion:(void (^)(NTESSmsLoginResult *, NSError *))completion {
    NSURL *baseURL = [NSURL URLWithString:kApiHost];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"/auth/registerBySmsCode" relativeToURL:baseURL]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:params.toDictionary options:0 error:nil];
    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:NTESDemoConfig.sharedConfig.appKey forHTTPHeaderField:@"appKey"];
    NSURLSessionDataTask *task = [NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *JSON;
        if (!error) {
            if ([(NSHTTPURLResponse *)response statusCode] != 200) {
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSURLErrorCannotDecodeContentData userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Fail for status code: %@", @([(NSHTTPURLResponse *)response statusCode])]}];
            } else if (!data) {
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSURLErrorCannotDecodeContentData userInfo:@{NSLocalizedDescriptionKey: @"Empty data"}];
            } else {
                JSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                if (!error) {
                    NSInteger code = [JSON[@"code"] integerValue];
                    if (code != 200) {
                        error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSURLErrorBadServerResponse userInfo:@{NSLocalizedDescriptionKey: JSON[@"msg"] ?: @"Empty message field!"}];
                    }
                }
            }
        }
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(nil, error);
                }
            });
            return;
        }
        NTESSmsLoginResult *result = [[NTESSmsLoginResult alloc] initWithDictionary:JSON[@"data"]];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(result, nil);
            }
        });
    }];
    [task resume];
}


@end
