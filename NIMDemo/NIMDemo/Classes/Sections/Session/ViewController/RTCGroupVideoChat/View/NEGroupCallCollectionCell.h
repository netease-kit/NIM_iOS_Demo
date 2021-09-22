//
//  NEGroupCallCollectionCell.h
//  NIM
//
//  Created by I am Groot on 2020/11/7.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@interface NEGroupCallCollectionCell : UICollectionViewCell
@property(strong,nonatomic)NSString *userID;
@property(strong,nonatomic)UIView *videoView;
@property(strong,nonatomic)UILabel *nameLabel;
@property(strong,nonatomic)UILabel *cameraTip;
@property(strong,nonatomic)UIImageView *muteImageView;

//@property (nonatomic, copy) void(^voiceImageClickBlock)(BOOL isListen);

@end

NS_ASSUME_NONNULL_END
