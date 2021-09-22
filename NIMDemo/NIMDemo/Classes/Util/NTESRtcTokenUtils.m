//
//  NTESRtcTokenUtils.m
//  NERtcDemo
//
//  Created by Sampson on 2019/4/29.
//

#import "NTESRtcTokenUtils.h"

@interface NTESRtcTokenUtils ()

@property (nonatomic, strong) NSString *apiUrl;

@end

@implementation NTESRtcTokenUtils

+ (instancetype)sharedInstance {
    static NTESRtcTokenUtils *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = self.new;
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.apiUrl = @"https://nrtc.netease.im/demo/";
    }
    return self;
}

- (void)requestTokenWithUid:(uint64_t)myUid
                     appKey:(NSString *)appKey
                 completion:(NTESRtcTokenRequestHandler)completion
{
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSString *apiUrl = self.apiUrl;
    
    NSURL *url = [NSURL URLWithString:[apiUrl stringByAppendingString:@"getChecksum.action"]];
#if DEBUG
    NSLog(@"%@", url.absoluteString);
#endif
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                            timeoutInterval:10];
    
    [request setHTTPMethod:@"Post"];
    [request addValue:@"application/x-www-form-urlencoded;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSString *postData = [NSString stringWithFormat:@"uid=%lld&appkey=%@",
                          myUid, appKey];
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    
#if DEBUG
    NSLog(@"%@", postData);
#endif
    NSURLSessionTask *sessionTask =
    [urlSession dataTaskWithRequest:request
                  completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable connectionError)
     {
        NSError *error = connectionError;
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(error, nil);
                }
            });
            return;
        }
        
        NSString *token = nil;
        NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
        if (statusCode != 200 || !data) {
            error = [NSError errorWithDomain:@"nrtcdemo domain"
                                        code:statusCode
                                    userInfo:nil];
        }
        else {
            NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data
                                                                  options:0
                                                                    error:nil];
            NSInteger code = [dict[@"code"] integerValue];
            if (code != 200) {
                error = [NSError errorWithDomain:@"nrtcdemo domain"
                                            code:code
                                        userInfo:nil];
            }
            else {
                token = dict[@"checksum"];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(error, token);
            }
        });
    }];
    
    [sessionTask resume];
}

@end
