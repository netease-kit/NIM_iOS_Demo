//
//  NTESAVMoivePlayerController.h
//  NIM
//
//  Created by Genning-Work on 2019/10/25.
//  Copyright © 2019 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const NTESAVMediaPlaybackIsPreparedToPlayDidChangeNotification;
extern NSString *const NTESAVMoviePlayerPlaybackDidFinishNotification;
extern NSString *const NTESAVMoviePlayerPlaybackDidFinishReasonUserInfoKey;
extern NSString *const NTESAVMoviePlayerPlaybackStateDidChangeNotification;
extern NSString *const NTESAVMoviePlayerLoadStateDidChangeNotification;

typedef NS_ENUM(NSInteger, NTESAVMoviePlaybackState) {
    NTESAVMoviePlaybackStateStopped,
    NTESAVMoviePlaybackStatePlaying,
    NTESAVMoviePlaybackStatePaused,
    NTESAVMoviePlaybackStateInterrupted,
    NTESAVPMoviePlaybackStateSeekingForward,
    NTESAVPMoviePlaybackStateSeekingBackward
};

typedef NS_OPTIONS(NSUInteger, NTESAVMovieLoadState) {
    NTESAVMovieLoadStateUnknown        = 0,
    NTESAVMovieLoadStatePlayable       = 1 << 0,
    NTESAVMovieLoadStatePlaythroughOK  = 1 << 1, // Playback will be automatically started in this state when shouldAutoplay is YES
    NTESAVMovieLoadStateStalled        = 1 << 2, // Playback will be automatically paused in this state, if started
};

typedef NS_ENUM(NSInteger, NTESAVMovieScalingMode) {
    NTESAVMovieScalingModeNone,       // No scaling
    NTESAVMovieScalingModeAspectFit,  // Uniform scale until one dimension fits
    NTESAVMovieScalingModeAspectFill, // Uniform scale until the movie fills the visible bounds. One dimension may have clipped contents
    NTESAVMovieScalingModeFill        // Non-uniform scale. Both render dimensions will exactly match the visible bounds
};

typedef NS_OPTIONS(NSUInteger, NTESAVMovieFinishReason) {
    NTESAVMovieFinishReasonPlaybackEnded,
    NTESAVMovieFinishReasonPlaybackError,
    NTESAVMovieFinishReasonUserExited
};

@interface NTESAVMoivePlayerController : NSObject

- (id)initWithContentURL:(NSURL *)aUrl;

- (void)prepareToPlay;
- (void)play;
- (void)pause;
- (void)stop;

@property(nonatomic, readonly) UIView *view;
@property(nonatomic, assign) NSTimeInterval currentPlaybackTime;
@property(nonatomic, readonly) NSTimeInterval duration;
@property(nonatomic, readonly) NSTimeInterval playableDuration;
@property(nonatomic, readonly) NSInteger bufferingProgress;
@property(nonatomic, readonly) NTESAVMoviePlaybackState playbackState;
@property(nonatomic, readonly) NTESAVMovieLoadState loadState;
@property(nonatomic, assign) NTESAVMovieScalingMode scalingMode;
@property(nonatomic, assign) float playbackRate;
@property(nonatomic, assign) float playbackVolume;
@property(nonatomic, assign) BOOL shouldAutoplay;

@end

NS_ASSUME_NONNULL_END
