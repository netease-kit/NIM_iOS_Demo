//
//  UINavigationBar+Swizzling.m
//  NIM
//
//  Created by chris on 15/6/23.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "UINavigationBar+Swizzling.h"
#import "UIView+NTES.h"
#import "SwizzlingDefine.h"
@implementation UINavigationBar (Swizzling)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        swizzling_exchangeMethod([UINavigationBar class] ,@selector(layoutSubviews), @selector(swizzling_layoutSubviews));
    });
}

#pragma mark - LayoutSubviews
#define TitleMargin 43

- (void)swizzling_layoutSubviews{
    [self swizzling_layoutSubviews];
    UINavigationItem *navigationItem = [self topItem];
    UIView *subview  = [[navigationItem leftBarButtonItem] customView];
    CGFloat navigationBtnMargin = IOS11? -10 : 28;
    subview.left = navigationBtnMargin;
    
    //解决标题过长时，设置navigationItem.title导致标题偏移的问题
    UILabel *label = (UILabel *)navigationItem.titleView;
    if ([label isKindOfClass:[UILabel class]])
    {
        label.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    
    UIFont *font   = self.titleTextAttributes[NSFontAttributeName];
    if (font)
    {
        label.font = font;
    }
    UIColor *color = self.titleTextAttributes[NSForegroundColorAttributeName];
    if (color) {
        label.textColor = color;
    }
    [label sizeToFit];
    [self layoutLabel];
}

#pragma mark - Private
- (void)layoutLabel{
    UINavigationItem *navigationItem = [self topItem];
    
    UIView *view = navigationItem.titleView;
    
    
    CGPoint centerPonit = CGPointMake(self.width * .5f, self.height *.5f);
    UIView *superView = view.superview;
    centerPonit = [superView convertPoint:centerPonit fromView:self];
    
    view.center = centerPonit;
}


@end
