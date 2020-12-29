//
//  NTESImportMessageViewController.h
//  NIM
//
//  Created by Sampson on 2018/12/10.
//  Copyright © 2018 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NTESImportMessageViewController : UIViewController

@property (nonatomic, copy) NSString *remoteFilePath;
@property (nonatomic, copy) NSString *secureKey;

@end

NS_ASSUME_NONNULL_END
