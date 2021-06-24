//
//  NERtcCallKitDelegateProxy.m
//  NERtcCallKit
//
//  Created by Wenchao Ding on 2020/10/28.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NERtcCallKitDelegateProxy.h"

@interface NERtcCallKitDelegateProxy ()

@property (nonatomic, strong) NSHashTable<id<NERtcCallKitDelegate>> *weakDelegates;
@property (nonatomic, copy) NSDictionary<NSString *, NSString *> *deprecations;

@end

@implementation NERtcCallKitDelegateProxy

- (instancetype)init {
    return [self initWithDeprecations:nil];
}

- (instancetype)initWithDeprecations:(NSDictionary<NSString *,NSString *> *)deprecations {
    self.weakDelegates = NSHashTable.weakObjectsHashTable;
    self.deprecations = deprecations;
    return self;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return aSelector == @selector(addDelegate:) || aSelector == @selector(removeDelegate:);
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    NSArray *allDelegates = self.weakDelegates.allObjects;
    for (NSObject *delegate in allDelegates) {
        NSMethodSignature *sig = [delegate methodSignatureForSelector:sel] ?: [delegate methodSignatureForSelector:[self deprecatedSelectorOfSelector:sel]];
        if (sig) {
            return sig;
        }
    }
    return [NSObject instanceMethodSignatureForSelector:@selector(init)];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    NSArray *allDelegates = self.weakDelegates.allObjects;
    for (id<NERtcCallKitDelegate> delegate in allDelegates) {
        if ([delegate respondsToSelector:invocation.selector]) {
            [invocation invokeWithTarget:delegate];
        } else if ([delegate respondsToSelector:[self deprecatedSelectorOfSelector:invocation.selector]]) {
            invocation.selector = [self deprecatedSelectorOfSelector:invocation.selector];
            [invocation invokeWithTarget:delegate];
        } else {
            invocation.target = nil;
            [invocation invoke];
        }
    }
}

- (void)addDelegate:(id<NERtcCallKitDelegate>)delegate {
    [self.weakDelegates addObject:delegate];
}

- (void)removeDelegate:(id<NERtcCallKitDelegate>)delegate {
    [self.weakDelegates removeObject:delegate];
}

- (SEL)deprecatedSelectorOfSelector:(SEL)selector {
    NSString *selectorString = NSStringFromSelector(selector);
    selectorString = self.deprecations[selectorString];
    return NSSelectorFromString(selectorString);
}

@end
