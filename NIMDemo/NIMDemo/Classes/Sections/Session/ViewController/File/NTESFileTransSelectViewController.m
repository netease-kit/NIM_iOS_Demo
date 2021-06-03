//
//  FileTransSelectViewController.m
//  NIM
//
//  Created by chris on 15/4/20.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NTESFileTransSelectViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>

#define FileName @"fileName"
#define FileExt  @"fileExt"

@interface NTESFileTransSelectViewController ()

@property(nonatomic,strong) NSArray *data;

@end

@implementation NTESFileTransSelectViewController

- (void)dealloc {
    [SVProgressHUD dismiss];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"文件列表".ntes_localized;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.data = [[NSBundle mainBundle] pathsForResourcesOfType:nil inDirectory:@"Files"];
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *filePath = self.data[indexPath.row];
    [SVProgressHUD showWithStatus:@"加载中".ntes_localized];
    
    if (self.completionBlock) {
        unsigned long long fileSize = [self fileSizeWithPath:filePath];
        if(fileSize > 200 * 1024 * 1024 || indexPath.row % 2 == 1) {
            self.completionBlock(filePath,filePath.pathExtension);
            self.completionBlock = nil;
        }else{
            NSData *data = [NSData dataWithContentsOfFile:filePath];
            self.completionBlock(data,filePath.pathExtension);
            self.completionBlock = nil;
        }
    }else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    NSString *path = self.data[indexPath.row];
    if (indexPath.row % 2 == 0) {
        cell.textLabel.text = path.lastPathComponent;
    }else{
        cell.textLabel.text = [path.lastPathComponent stringByAppendingString:@"(DATA 传输)".ntes_localized];
    }

    return cell;
}


- (unsigned long long)fileSizeWithPath:(NSString *)filepath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    unsigned long long fileSize = 0;
    if ([filepath length]  && [fileManager fileExistsAtPath:filepath])
    {
        NSDictionary *attributes = [fileManager attributesOfItemAtPath:filepath
                                                          error:nil];
        id item = [attributes objectForKey:NSFileSize];
        fileSize = [item isKindOfClass:[NSNumber class]] ? [item unsignedLongLongValue] : 0;
    }
    return fileSize;
    
    
}



@end
