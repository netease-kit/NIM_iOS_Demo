//
//  UIView+Swizzling.m
//  NIM
//
//  Created by chris on 15/10/27.
//  Copyright © 2015年 Netease. All rights reserved.
//

#import "UIView+Swizzling.h"
#import "SwizzlingDefine.h"

@implementation UIView (Swizzling)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //响应链日志，在调试的时候开启
        //swizzling_exchangeMethod([UIView class] ,@selector(hitTest:withEvent:), @selector(swizzling_hitTest:withEvent:));
        // setFrame 日志，在调试的时候开启
        //swizzling_exchangeMethod([UIView class] ,@selector(setFrame:), @selector(swizzling_setFrame:));
    });
}

#pragma mark - HitTest
- (UIView *)swizzling_hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [self swizzling_hitTest:point withEvent:event];
    if (view) {
        DDLogDebug(@"--hit test--，%@ hit view : %@",[self class],[view class]);
    }
    return view;
}


#pragma mark - SetFrame
- (void)swizzling_setFrame:(CGRect)frame
{
    [self swizzling_setFrame:frame];
    if ([self isKindOfClass:[UITableView class]])
    {
        DDLogDebug(@"--set frame--，view : %@, [%.2f,%.2f,%.2f,%.2f] ",[self class],frame.origin.x,frame.origin.y,frame.size.width,frame.size.height);
    }    
}


@end
