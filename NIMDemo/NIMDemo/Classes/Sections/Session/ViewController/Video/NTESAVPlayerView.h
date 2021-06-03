//
//  NTESAVPlayerView.h
//  NIM
//
//  Created by Genning-Work on 2019/10/25.
//  Copyright © 2019 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NTESAVPlayerView : UIView

@property (nonatomic, strong) AVPlayer* player;

- (void)setPlayer:(nullable AVPlayer*)player;
- (void)setVideoFillMode:(NSString *)fillMode;

@end

NS_ASSUME_NONNULL_END
