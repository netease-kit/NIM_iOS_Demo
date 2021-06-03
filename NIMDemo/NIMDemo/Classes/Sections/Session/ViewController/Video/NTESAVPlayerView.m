//
//  NTESAVPlayerView.m
//  NIM
//
//  Created by Genning-Work on 2019/10/25.
//  Copyright © 2019 Netease. All rights reserved.
//

#import "NTESAVPlayerView.h"

@implementation NTESAVPlayerView
{
    NSString* _videoFillMode;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _videoFillMode = @"AVLayerVideoGravityResizeAspect";
        // Initialization code
    }
    return self;
}

+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

- (AVPlayer*)player
{
    return [(AVPlayerLayer*)[self layer] player];
}

- (void)setPlayer:(AVPlayer*)player
{
    if ([self player] != player) {
        [(AVPlayerLayer*)[self layer] setPlayer:player];
        [self setVideoFillMode:_videoFillMode];
    }
}

/* Specifies how the video is displayed within a player layer’s bounds.
 (AVLayerVideoGravityResizeAspect is default) */
- (void)setVideoFillMode:(NSString *)fillMode
{
    _videoFillMode = fillMode;

    AVPlayerLayer *playerLayer = (AVPlayerLayer*)[self layer];
    playerLayer.videoGravity = fillMode;
}

- (void)setContentMode:(UIViewContentMode)contentMode
{
    [super setContentMode:contentMode];

    switch (contentMode) {
        case UIViewContentModeScaleToFill:
            [self setVideoFillMode:AVLayerVideoGravityResize];
            break;
        case UIViewContentModeCenter:
            [self setVideoFillMode:AVLayerVideoGravityResizeAspect];
            break;
        case UIViewContentModeScaleAspectFill:
            [self setVideoFillMode:AVLayerVideoGravityResizeAspectFill];
            break;
        case UIViewContentModeScaleAspectFit:
            [self setVideoFillMode:AVLayerVideoGravityResizeAspect];
        default:
            break;
    }
}

@end
