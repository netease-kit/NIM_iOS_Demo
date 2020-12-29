//
//  NTESMediaPreviewViewController.h
//  NIM
//
//  Created by chris on 2017/9/21.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,NTESMediaPreviewType){
    NTESMediaPreviewTypeImage,
    NTESMediaPreviewTypeVideo,
};

@interface NTESMediaPreviewObject : NSObject

@property (nonatomic,copy) NSString *objectId; //messageId

@property (nonatomic,assign) NTESMediaPreviewType type;

@property (nonatomic,copy) NSString *path;

@property (nonatomic,copy) NSString *thumbPath;

@property (nonatomic,copy) NSString *url;

@property (nonatomic,copy) NSString *thumbUrl;

@property (nonatomic,copy) NSString *displayName;

@property (nonatomic,assign) NSTimeInterval timestamp;

@property (nonatomic,assign) NSTimeInterval duration;

@property (nonatomic,assign) CGSize imageSize;

@end

@interface NTESMediaPreviewViewController : UIViewController

- (instancetype)initWithPriviewObjects:(NSArray<NTESMediaPreviewObject *> *) objects
                           focusObject:(NTESMediaPreviewObject *)object;

@end
