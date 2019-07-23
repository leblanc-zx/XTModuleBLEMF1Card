//
//  CBCentralManager+MF1.m
//  QuickTopUp
//
//  Created by apple on 2019/6/11.
//  Copyright © 2019 新天科技股份有限公司. All rights reserved.
//

#import "CBCentralManager+XT.h"
#import <objc/runtime.h>

NSString *const XTCBCentralManagerInitKey = @"XTCBCentralManagerInitKey";

void xt_exchangeInstanceMethod(Class class, SEL originalSelector, SEL newSelector) {
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method newMethod = class_getInstanceMethod(class, newSelector);
    if(class_addMethod(class, originalSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
        class_replaceMethod(class, newSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, newMethod);
    }
}

@implementation CBCentralManager (XT)

+ (void)load {
    xt_exchangeInstanceMethod([self class], @selector(initWithDelegate:queue:options:), @selector(xt_initWithDelegate:queue:options:));
}
- (instancetype)xt_initWithDelegate:(id<CBCentralManagerDelegate>)delegate queue:(dispatch_queue_t)queue options:(NSDictionary<NSString *,id> *)options {
    
    NSDictionary *objectDic = @{
                                @"Class": NSStringFromClass([delegate class]),
                                @"Object": self,
                                };
    [[NSNotificationCenter defaultCenter] postNotificationName:XTCBCentralManagerInitKey object:objectDic];
    return [self xt_initWithDelegate:delegate queue:queue options:options];
}

@end
