//
//  NTESGalleryViewController.h
//  NIMDemo
//
//  Created by ght on 15-2-3.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NTESGalleryItem : NSString
@property (nonatomic,copy)  NSString    *itemId;
@property (nonatomic,copy)  NSString    *thumbPath;
@property (nonatomic,copy)  NSString    *imageURL;
@property (nonatomic,copy)  NSString    *imagePath;
@property (nonatomic,copy)  NSString    *name;
@property (nonatomic,assign) CGSize     size;
@end


@interface NTESGalleryViewController : UIViewController
- (instancetype)initWithItem:(NTESGalleryItem *)item session:(NIMSession *)session;
@end



@interface NTESGalleryViewController(SingleView)

+ (UIView *)alertSingleSnapViewWithMessage:(NIMMessage *)message baseView:(UIView *)view;

@end
