//
//  NERtcCallKitDelegateProxy.m
//  NLiteAVDemo
//
//  Created by Wenchao Ding on 2020/10/28.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NERtcCallKitDelegateProxy.h"

@implementation NERtcCallKitDelegateProxy

- (instancetype)init
{
    self.weakDelegates = NSHashTable.weakObjectsHashTable;
    return self;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return aSelector == @selector(addDelegate:) || aSelector == @selector(removeDelegate:);
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    NSArray *allDelegates = self.weakDelegates.allObjects;
    for (NSObject *delegate in allDelegates) {
        NSMethodSignature *sig = [delegate methodSignatureForSelector:sel];
        if (sig) {
            return sig;
        }
    }
    return [NSObject instanceMethodSignatureForSelector:@selector(init)];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    NSArray *allDelegates = self.weakDelegates.allObjects;
    for (id<NERtcCallKitDelegate> delegate in allDelegates) {
        if ([delegate respondsToSelector:invocation.selector]) {
            [invocation invokeWithTarget:delegate];
        } else {
            invocation.target = nil;
            [invocation invoke];
        }
    }
}

- (void)addDelegate:(id<NERtcCallKitDelegate>)delegate
{
    [self.weakDelegates addObject:delegate];
}

- (void)removeDelegate:(id<NERtcCallKitDelegate>)delegate
{
    [self.weakDelegates removeObject:delegate];
}

@end
