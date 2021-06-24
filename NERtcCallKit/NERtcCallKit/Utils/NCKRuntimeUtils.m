//
//  NCKRuntimeUtils.m
//  NERtcCallKit
//
//  Created by Wenchao Ding on 2021/6/1.
//  Copyright © 2021 Wenchao Ding. All rights reserved.
//

#import "NCKRuntimeUtils.h"
#import <objc/runtime.h>

@implementation NCKRuntimeUtils

+ (void)swizzleInstanceMethod:(Class)cls
             originalSelector:(SEL)originalSelector
             swizzledSelector:(SEL)swizzledSelector {
    
    Class class = cls;
    
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL didAddMethod =
    class_addMethod(class,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@end
