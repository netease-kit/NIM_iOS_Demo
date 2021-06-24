//
//  NCKEventReporter.m
//  NERtcCallKit
//
//  Created by Wenchao Ding on 2021/5/25.
//  Copyright © 2021 Wenchao Ding. All rights reserved.
//

#import "NCKEventReporter.h"

static NSInteger kFlushThreshhold = 8;
static NSString *kReportURLString = @"https://statistic.live.126.net/statics/report/callkit/action";

@interface NCKEventReporter ()<NSURLSessionDelegate>

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) dispatch_queue_t dispatchQueue;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) dispatch_semaphore_t sema;

@property (nonatomic, strong) NSMutableArray<NSDictionary *> *items;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) NSURL *reportURL;

@end

@implementation NCKEventReporter

+ (instancetype)sharedReporter {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = self.new;
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.dispatchQueue = dispatch_queue_create("com.netease.yunxin.kit.call.report", DISPATCH_QUEUE_SERIAL);
        self.sema = dispatch_semaphore_create(1);
        self.operationQueue = [[NSOperationQueue alloc] init];
        self.operationQueue.underlyingQueue = self.dispatchQueue;
        self.session = [NSURLSession sessionWithConfiguration:NSURLSessionConfiguration.defaultSessionConfiguration delegate:self delegateQueue:self.operationQueue];
        
        self.items = NSMutableArray.array;
        NSString *reportDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"NERtcCallKit/Report"];
        if (![NSFileManager.defaultManager fileExistsAtPath:reportDir isDirectory:nil]) {
            NSError *error;
            [NSFileManager.defaultManager createDirectoryAtPath:reportDir withIntermediateDirectories:YES attributes:nil error:&error];
            if (error) {
                NCKLogError(@"Create dir failed: %@", error);
            }
        }
        self.filePath = [reportDir stringByAppendingPathComponent:@"items"];
        self.reportURL = [NSURL URLWithString:kReportURLString];
        dispatch_async(self.dispatchQueue, ^{
            NSArray *items = [NSKeyedUnarchiver unarchiveObjectWithFile:self.filePath];
            if (items) {
                [self.items addObjectsFromArray:items];
            }
        });
    }
    return self;
}

- (void)report:(nullable NSDictionary *)event {
    if (!event) return;
    dispatch_async(self.dispatchQueue, ^{
        [self.items addObject:event];
        if (self.items.count > kFlushThreshhold) {
            [self flush];
            return;
        }
        BOOL res = [NSKeyedArchiver archiveRootObject:self.items toFile:self.filePath];
        if (!res) {
            NCKLogError(@"Save items failed: %@", self.items); // Not gonna happen
        }
    });
}

- (void)flushAsync {
    if (!self.items.count) return;
    dispatch_async(self.dispatchQueue, ^{
        [self flush];
    });
}

- (void)flush {
    if (!self.items.count) return;
    dispatch_semaphore_wait(self.sema, DISPATCH_TIME_FOREVER);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.reportURL];
    [request setHTTPMethod:@"POST"];

    NSError *error;
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:self.items options:0 error:&error];
    [request setHTTPBody:bodyData];
    [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-type"];
    
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NCKLogError(@"Report failed: \n event: %@ \n error: %@ \n", self.items, error);
            dispatch_semaphore_signal(self.sema);
            return;
        }
        NSHTTPURLResponse *resp = (NSHTTPURLResponse *)response;
        if (resp.statusCode != 200) {
            NCKLogError(@"Report failed: \n event: %@ \n statusCode: %@ \n", self.items, @(resp.statusCode))
            dispatch_semaphore_signal(self.sema);
            return;
        }
        [NSFileManager.defaultManager removeItemAtPath:self.filePath error:nil];
        NCKLogInfo(@"Report events succeed: %@!", self.items);
        [self.items removeAllObjects];
        dispatch_semaphore_signal(self.sema);
    }];
    [task resume];
}

@end
